import json
import os
import re
from datetime import datetime

import pandas as pd

EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
ISBN_CLEAN_RE = re.compile(r"[^0-9Xx]")


def read_csv(path):
    return pd.read_csv(path, dtype=str, keep_default_na=False)


def write_csv(df, path):
    os.makedirs(os.path.dirname(path) or '.', exist_ok=True)
    df.to_csv(path, index=False)


def clean_students(df):
    report = {
        "initial_rows": len(df),
        "removed_empty_rows": 0,
        "invalid_emails": 0,
        "duplicate_emails": 0,
        "dropped_missing_names": 0
    }

    empty_mask = df.apply(lambda row: all([str(x).strip() == '' for x in row]), axis=1)
    report['removed_empty_rows'] = int(empty_mask.sum())
    df = df[~empty_mask].copy()

    df = df.map(lambda x: x.strip() if isinstance(x, str) else x)

    for col in ['FirstName', 'LastName', 'Email', 'Phone', 'Status']:
        if col not in df.columns:
            df[col] = ''

    missing_names = df['FirstName'].astype(str).str.strip() == ''
    missing_last = df['LastName'].astype(str).str.strip() == ''
    drop_mask = missing_names | missing_last
    report['dropped_missing_names'] = int(drop_mask.sum())
    df = df[~drop_mask].copy()

    df['Email_valid'] = df['Email'].astype(str).apply(lambda x: bool(EMAIL_RE.match(x)) if x else False)
    report['invalid_emails'] = ((~df['Email_valid']) & (df['Email'].astype(str).str.len() > 0)).sum()

    dup_mask = df.duplicated(subset=['Email'], keep='first') & df['Email'].astype(bool)
    report['duplicate_emails'] = int(dup_mask.sum())
    df = df[~dup_mask].copy()

    df['Phone'] = df['Phone'].astype(str).apply(lambda x: ''.join(re.findall(r'\d+', x)))

    df['Status'] = df['Status'].astype(str).str.upper().replace({'': 'ACTIVE'})
    df.loc[~df['Status'].isin(['ACTIVE', 'INACTIVE']), 'Status'] = 'ACTIVE'

    df.drop(columns=['Email_valid'], inplace=True, errors='ignore')

    report['final_rows'] = len(df)
    return df, report


def clean_books(df):
    report = {
        "initial_rows": len(df),
        "removed_empty_rows": 0,
        "invalid_isbn": 0,
        "duplicate_isbn": 0,
        "fixed_copies": 0
    }

    empty_mask = df.apply(lambda row: all([str(x).strip() == '' for x in row]), axis=1)
    report['removed_empty_rows'] = int(empty_mask.sum())
    df = df[~empty_mask].copy()

    df = df.map(lambda x: x.strip() if isinstance(x, str) else x)

    for col in ['ISBN', 'Title', 'Author', 'Publisher', 'YearPublished', 'TotalCopies', 'AvailableCopies']:
        if col not in df.columns:
            df[col] = ''

    df['ISBN_raw'] = df['ISBN'].astype(str)
    df['ISBN'] = df['ISBN_raw'].apply(lambda x: ISBN_CLEAN_RE.sub('', x))

    df['ISBN_valid'] = df['ISBN'].astype(str).apply(lambda x: bool(x) and len(x) >= 10)
    report['invalid_isbn'] = ((~df['ISBN_valid']) & (df['ISBN'].astype(str).str.len() > 0)).sum()

    has_isbn = df['ISBN'].astype(bool)
    dup_counts = df[has_isbn].duplicated(subset=['ISBN'], keep='first')
    report['duplicate_isbn'] = int(dup_counts.sum())

    if report['duplicate_isbn']:
        agg = df[has_isbn].groupby('ISBN').agg({
            'Title': 'first', 'Author': 'first', 'Publisher': 'first', 'YearPublished': 'first',
            'TotalCopies': lambda s: sum([int(x) if str(x).isdigit() else 0 for x in s]),
            'AvailableCopies': lambda s: sum([int(x) if str(x).isdigit() else 0 for x in s])
        }).reset_index()
        no_isbn = df[~has_isbn].copy()
        agg = agg.astype({'TotalCopies': int, 'AvailableCopies': int})
        df = pd.concat([agg, no_isbn], ignore_index=True, sort=False)

    def to_int_safe(x):
        try:
            return int(float(x))
        except Exception:
            return 0

    df['TotalCopies'] = df['TotalCopies'].apply(to_int_safe)
    df['AvailableCopies'] = df['AvailableCopies'].apply(to_int_safe)

    mask_fix = df['AvailableCopies'] > df['TotalCopies']
    report['fixed_copies'] = int(mask_fix.sum())
    df.loc[mask_fix, 'AvailableCopies'] = df.loc[mask_fix, 'TotalCopies']

    current_year = datetime.now().year

    def fix_year(y):
        try:
            yi = int(float(y))
            if yi < 1000 or yi > current_year:
                return ''
            return yi
        except Exception:
            return ''

    df['YearPublished'] = df['YearPublished'].apply(fix_year)

    df.drop(columns=['ISBN_raw', 'ISBN_valid'], inplace=True, errors='ignore')

    report['final_rows'] = len(df)
    return df, report


def save_report(report, path):
    os.makedirs(os.path.dirname(path) or '.', exist_ok=True)
    clean = {k: int(v) if hasattr(v, 'item') else v for k, v in report.items()}
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(clean, f, indent=2)


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SAMPLE_DIR = os.path.join(BASE_DIR, '..', 'sample')

FILES_TO_CLEAN = [
    {
        'type': 'students',
        'input': os.path.join(SAMPLE_DIR, 'students_sample.csv'),
        'output': os.path.join(SAMPLE_DIR, 'students_sample_cleaned.csv'),
        'report': os.path.join(SAMPLE_DIR, 'students_report.json'),
    },
    {
        'type': 'books',
        'input': os.path.join(SAMPLE_DIR, 'books_sample.csv'),
        'output': os.path.join(SAMPLE_DIR, 'books_sample_cleaned.csv'),
        'report': os.path.join(SAMPLE_DIR, 'books_report.json'),
    },
]


def main():
    for entry in FILES_TO_CLEAN:
        input_path = entry['input']

        if not os.path.isfile(input_path):
            print(f"[SKIP] File not found: {input_path}")
            continue

        print(f"\n[START] Cleaning {entry['type']} -> {input_path}")
        df = read_csv(input_path)

        if entry['type'] == 'students':
            cleaned, report = clean_students(df)
        else:
            cleaned, report = clean_books(df)

        write_csv(cleaned, entry['output'])
        save_report(report, entry['report'])

        print(f"[DONE]  Cleaned file saved to: {entry['output']}")
        print(f"        Report saved to:       {entry['report']}")
        print(json.dumps({k: int(v) if hasattr(v, 'item') else v for k, v in report.items()}, indent=2))

    print('\nAll cleaning tasks complete.')


if __name__ == '__main__':
    main()

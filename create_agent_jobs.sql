USE msdb;
GO

-- Create or replace Daily job to update overdue fines
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs_view WHERE name = 'Daily_Update_Fines')
    EXEC msdb.dbo.sp_delete_job @job_name = 'Daily_Update_Fines';

EXEC msdb.dbo.sp_add_job @job_name = 'Daily_Update_Fines', @enabled = 1, @description = 'Update overdue fines daily', @owner_login_name = SUSER_SNAME();

EXEC msdb.dbo.sp_add_jobstep
    @job_name = 'Daily_Update_Fines',
    @step_name = 'Update fines',
    @subsystem = 'TSQL',
    @command = 'USE LibraryDB; EXEC lib.sp_UpdateAllFines;',
    @database_name = 'LibraryDB';

EXEC msdb.dbo.sp_add_schedule @schedule_name = 'Daily_00_15', @enabled = 1, @freq_type = 4, @freq_interval = 1, @active_start_time = 001500;
EXEC msdb.dbo.sp_attach_schedule @job_name = 'Daily_Update_Fines', @schedule_name = 'Daily_00_15';
EXEC msdb.dbo.sp_add_jobserver @job_name = 'Daily_Update_Fines';

-- Create or replace Monthly job to mark inactive students (1st of month)
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs_view WHERE name = 'Monthly_Mark_Inactive_Students')
    EXEC msdb.dbo.sp_delete_job @job_name = 'Monthly_Mark_Inactive_Students';

EXEC msdb.dbo.sp_add_job @job_name = 'Monthly_Mark_Inactive_Students', @enabled = 1, @description = 'Mark students INACTIVE if no borrows in last 6 months', @owner_login_name = SUSER_SNAME();

EXEC msdb.dbo.sp_add_jobstep
    @job_name = 'Monthly_Mark_Inactive_Students',
    @step_name = 'Mark inactive',
    @subsystem = 'TSQL',
    @command = 'USE LibraryDB; EXEC lib.sp_MarkInactiveStudents;',
    @database_name = 'LibraryDB';

EXEC msdb.dbo.sp_add_schedule @schedule_name = 'Monthly_OnDay1_02_00', @enabled = 1, @freq_type = 8, @freq_interval = 1, @active_start_time = 020000;
EXEC msdb.dbo.sp_attach_schedule @job_name = 'Monthly_Mark_Inactive_Students', @schedule_name = 'Monthly_OnDay1_02_00';
EXEC msdb.dbo.sp_add_jobserver @job_name = 'Monthly_Mark_Inactive_Students';

PRINT 'Jobs created/updated. Ensure SQL Server Agent is running.';
GO
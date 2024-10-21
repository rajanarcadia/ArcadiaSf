global with sharing class UtilityCredentialSyncScheduler implements Schedulable {
    private static final Integer DEFAULT_INTERVAL = 1;
    private static final String JOB_NAME = 'Get Credentials by Correlation Id';

    public UtilityCredentialSyncScheduler() {
    }

    /**
     * Default method to schedule sync to run based on default interval
     * @return Job ID
     */
    global static String scheduleJob() {
        abortDefaultScheduledJob();
        return scheduleJob(JOB_NAME, UrjanetUtils.getSchedulerExpression(DateTime.Now().addDays(DEFAULT_INTERVAL)));
    }

    /**
     * Overload method to allow subscribers to schedule job based in own cron expression
     * @param jobName - Name of scheduled job
     * @param cron - Cron expression
     *
     * @return Job ID
     */
    global static String scheduleJob(String jobName, String cron) {
        return System.schedule(jobName, cron, new UtilityCredentialSyncScheduler());
    }

    /**
     * Schedulable implementation
     * @param sc
     */
    public void execute(SchedulableContext sc) {
        Logger.getInstance()
            .log(UtilityCredentialSyncScheduler.class.getName(), Logger.Level.INFO, 'Scheduler started.');
        Urjanetutils.insertAccessTokenForBatchUse();
    }

    /**
     * Gets the default scheduled job
     * @return
     */
    private static List<CronTrigger> getDefaultScheduledJob() {
        //CRUD/FLS is ignored since permissions cannot be applied to CRON TRIGGER object
        return Data.read(
            'Select Id, CronJobDetail.Name, NextFireTime, PreviousFireTime From CronTrigger Where CronJobDetail.Name LIKE \'%' +
                JOB_NAME +
                '%\'',
            null,
            false,
            false,
            false
        );
    }

    /**
     * Aborts the default scheduled job
     */
    private static void abortDefaultScheduledJob() {
        abortJobs(getDefaultScheduledJob());
    }

    /**
     * Aborts scheduled apex jobs.
     * @param cronRecs - jobs to abort
     */
    private static void abortJobs(List<CronTrigger> cronRecs) {
        for (CronTrigger cron : cronRecs) {
            System.abortJob(cron.id);
        }
    }
}
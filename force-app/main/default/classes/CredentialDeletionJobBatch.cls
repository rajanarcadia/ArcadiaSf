public with sharing class CredentialDeletionJobBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public CredentialDeletionJobBatch() {
    }

    /**
     * Start implementation
     * @param bc
     *
     * @return
     */
    public Database.Querylocator start(Database.BatchableContext bc) {
        //CRUD / FLS is ignored to ensure that query runs in system context in order to sync over records to Urjanet.
        Logger.getInstance(false)
            .log(
                CredentialDeletionJobService.class.getName(),
                Logger.Level.INFO,
                'Utility Credential Deletion Job Batch Started'
            );
        CredentialDeletionJobSelector selector = new CredentialDeletionJobSelector(false, false, false);
        return selector.getRecordsForCredentialDeletionLogBatch();
    }

    /**
     * @description process the correlationIds
     * @param  bc    bc description
     * @param  scope scope description
     */
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        //Run schedule job process
        CredentialDeletionJobService.createQueueItemsForCredentialDeletionLogs(scope);
    }

    public void finish(Database.BatchableContext bc) {
        Logger.getInstance(false)
            .log(
                CredentialDeletionJobService.class.getName(),
                Logger.Level.INFO,
                'QueueItems Successfully Created for Credential Deletion Logs Processing.'
            );
    }
}
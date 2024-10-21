public with sharing class UtilityCredentialSyncBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public UtilityCredentialSyncBatch() {
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
                .log(UtilityCredentialService.class.getName(), Logger.Level.INFO, 'Utility Credential Sync Batch Started');
        UtilityCredentialSelector selector = new UtilityCredentialSelector(false, false, false);
        return selector.getRecordsForCredentialSyncBatch();
    }

    /**
     * @description process the correlationIds
     * @param  bc    bc description
     * @param  scope scope description
     */
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        //Run schedule job process
        UtilityCredentialService.getUtilityCredentials(scope);
    }
    public void finish(Database.BatchableContext bc) {
        Logger.getInstance(false)
                .log(UtilityCredentialService.class.getName(), Logger.Level.INFO, 'Utility Credential Sync Batch Completed');
    }
}
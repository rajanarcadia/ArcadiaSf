public with sharing class UtilityAccountSyncBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public UtilityAccountSyncBatch() {
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
            .log(UtilityAccountSyncBatch.class.getName(), Logger.Level.INFO, 'Utility Account Sync Batch Started');
        UtilityAccountSelector selector = new UtilityAccountSelector(false, false, false);
        return selector.getUtilAccountsSyncBatchWithoutCredential();
    }

    /**
     * @description process the correlationIds
     * @param  bc    bc description
     * @param  scope scope description
     */
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        //Run schedule job process
        UtilityAccountService.createQueueItemsForUtilityAccounts(scope);
    }

    public void finish(Database.BatchableContext bc) {
        // Backfill Supplier id field for accounts where supplier id is null
        List<UtilityAccount__c> accountsToUpdate = [
            SELECT Id, UtilityCredential__r.ProviderName__c
            FROM UtilityAccount__c
            WHERE Supplier__c = NULL AND UtilityCredential__r.ProviderName__c != NULL
        ];
        if (!accountsToUpdate.isEmpty()) {
            for (UtilityAccount__c account : accountsToUpdate) {
                account.Supplier__c = account.UtilityCredential__r.ProviderName__c;
            }
            update accountsToUpdate;

            Logger.getInstance(false)
                .log(
                    UtilityAccountSyncBatch.class.getName(),
                    Logger.Level.INFO,
                    'Updated Supplier for ' + accountsToUpdate.size() + ' Utility Accounts'
                );
        }

        Logger.getInstance(false)
            .log(
                UtilityAccountSyncBatch.class.getName(),
                Logger.Level.INFO,
                'QueueItems Successfully Created for Accounts Processing'
            );
    }
}
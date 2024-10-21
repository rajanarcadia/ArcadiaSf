public with sharing class UtilityStatementFileSyncBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public UtilityStatementFileSyncBatch() {
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
                UtilityStatementFileSyncBatch.class.getName(),
                Logger.Level.INFO,
                'Utility Statement File Sync Batch Started'
            );
        UtilityStatementFileSelector selector = new UtilityStatementFileSelector(false, false, false);
        return selector.getRecordsForUtilStatementFileSyncBatch();
    }

    /**
     * @description process the Utility Statement Files
     * @param  bc    bc description
     * @param  scope scope description
     */
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        //Run schedule job process
        UtilityStatementFileService.getUtilityStatementFiles(scope);
    }

    public void finish(Database.BatchableContext bc) {
        List<UtilityStatementFile__c> statements = [
            SELECT Id
            FROM UtilityStatementFile__c
            WHERE
                EntityId__c != NULL
                AND StatementId__c != NULL
                AND Status__c = 'SUCCESS'
                AND Id NOT IN (SELECT Utility_Statement_File__c FROM Utility_File_Account_Association__c)
        ];

        if (!statements.isEmpty()) {
            UtilityStatementFileService.linkUtilityStatementFilesWithAccount(statements);
        }
        Logger.getInstance(false)
            .log(
                UtilityStatementFileSyncBatch.class.getName(),
                Logger.Level.INFO,
                'Utility Statement File Sync Batch Completed'
            );
    }
}
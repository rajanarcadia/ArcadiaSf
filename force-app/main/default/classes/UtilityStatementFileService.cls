public with sharing class UtilityStatementFileService {
    public static void getUtilityStatementFiles(List<UtilityStatementFile__c> lstUtilityStatementFiles) {
        List<String> lstFieldIds = new List<String>();
        List<UtilityStatementFile__c> lstUpdateUtilStatementFiles = new List<UtilityStatementFile__c>();
        for (UtilityStatementFile__c utilStatementFileObj : lstUtilityStatementFiles) {
            lstFieldIds.add(utilStatementFileObj.EntityId__c);
        }

        if (lstFieldIds.size() > 0) {
            GetUtilityStatementFilesResponse response = (GetUtilityStatementFilesResponse) new UrjanetApiClient()
                .getUrjanetResponse(
                    UrjanetEnums.RequestType.STATEMENT_FILES_BY_ENTITY_ID,
                    UrjanetEnums.ApiMethod.GET,
                    new List<String>{ getFileIdString(lstFieldIds) }
                );

            if (response != null && response.embedded != null && response.embedded.files.size() > 0) {
                for (GetUtilityStatementFilesResponse.Files fileResponseObj : response.embedded.files) {
                    lstUpdateUtilStatementFiles.add(fileResponseObj.toRecord());
                }
            }
            if (response.errorMsg != null) {
                Logger.getInstance().log(UtilityStatementFileService.class.getName(), response.errorMsg);
                throw new ArcadiaCalloutServiceException(response.errorMsg, response.status);
            }
        }

        if (!lstUpdateUtilStatementFiles.isEmpty()) {
            try {
                Database.DMLOptions option = new Database.DMLOptions();
                option.OptAllOrNone = false;
                Logger.getInstance()
                    .log(
                        UtilityStatementFileService.class.getName(),
                        UrjanetUtils.getSObjectName(Schema.UtilityStatementFile__c.SObjectType),
                        Data.upsurt(
                            lstUpdateUtilStatementFiles,
                            Schema.UtilityStatementFile__c.fields.EntityId__c,
                            option,
                            true,
                            true,
                            true,
                            null
                        )
                    );
            } catch (Exception e) {
                Logger.getInstance().log(UtilityStatementFileService.class.getName(), e);
            }
        } else {
            Logger.getInstance(false)
                .log(
                    UtilityStatementFileService.class.getName(),
                    Logger.Level.DEBUG,
                    'No Utility Statement files to Update'
                );
        }
    }

    public static String getFileIdString(List<String> lstFieldIds) {
        return '(' + String.join(lstFieldIds, ',') + ')';
    }

    public static void createQueueItemsForUtilityStatementFiles(List<UtilityStatementFile__c> records) {
        createQueueItemsForUtilityStatementFiles(records, null);
    }

    public static void createQueueItemsForUtilityStatementFiles(
        List<UtilityStatementFile__c> records,
        Map<Id, UtilityStatementFile__c> oldMap
    ) {
        List<UtilityStatementFile__c> lstUpdatedUtilityStatements = getUtilityStatementsToRefresh(records, oldMap);
        Type processorClass = QueueItemProcessorFactory.getProcessorType(UtilityStatementFile__c.SObjectType);
        List<Database.SaveResult> saveResults = new QueueItemsBuilder(lstUpdatedUtilityStatements, processorClass)
            .buildQueueItemsPerRecord()
            .createRecords();
        UrjanetUtils.logFailures(
            UtilityStatementFileService.class.getName(),
            String.valueOf(UtilityStatementFile__c.SObjectType),
            saveResults
        );
    }

    public static void linkUtilityStatementFilesWithAccount(List<UtilityStatementFile__c> records) {
        Logger.getInstance()
            .log(
                UtilityStatementFileService.class.getName(),
                Logger.Level.INFO,
                'Linking Utility Statement Files with Account'
            );

        Type processorClass = QueueItemProcessorFactory.getProcessorType(UtilityStatementFile__c.SObjectType);
        List<Database.SaveResult> saveResults = new QueueItemsBuilder(records, processorClass)
            .buildQueueItemsPerRecord()
            .createRecords();
        UrjanetUtils.logFailures(
            UtilityStatementFileService.class.getName(),
            String.valueOf(UtilityStatementFile__c.SObjectType),
            saveResults
        );
    }

    @TestVisible
    private static List<UtilityStatementFile__c> getUtilityStatementsToRefresh(
        List<UtilityStatementFile__c> records,
        Map<Id, UtilityStatementFile__c> oldMap
    ) {
        List<UtilityStatementFile__c> lstUpdatedUtilityStatementFiles = new List<UtilityStatementFile__c>();
        if (oldMap == null) {
            lstUpdatedUtilityStatementFiles.addAll(records);
        } else {
            for (UtilityStatementFile__c fileObj : (List<UtilityStatementFile__c>) records) {
                UtilityStatementFile__c oldFileObj = oldMap.get(fileObj.id);
                if (
                    fileObj.Status__c == 'SUCCESS' &&
                    oldFileObj.Status__c != fileObj.Status__c &&
                    !String.isEmpty(fileObj.StatementId__c)
                ) {
                    lstUpdatedUtilityStatementFiles.add(fileObj);
                }
            }
        }
        return lstUpdatedUtilityStatementFiles;
    }
}
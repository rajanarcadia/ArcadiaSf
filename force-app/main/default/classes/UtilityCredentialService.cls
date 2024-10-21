public with sharing class UtilityCredentialService {
    //default constructor
    public UtilityCredentialService() {
    }

    public static void getUtilityCredentials(List<UtilityCredential__c> utilityCredentials) {
        List<String> correlationIds = new List<String>();
        List<UtilityCredential__c> credentialsToUpdate = new List<UtilityCredential__c>();
        for (UtilityCredential__c credential : utilityCredentials) {
            correlationIds.add(credential.CorrelationID__c);
        }

        if (correlationIds.size() > 0) {
            GetCredentialsResponse response = (GetCredentialsResponse) new UrjanetApiClient()
                .getUrjanetResponse(
                    UrjanetEnums.RequestType.CREDENTIALS_BY_CORRELATION_ID,
                    UrjanetEnums.ApiMethod.GET,
                    new List<String>{ getCorrelationIdString(correlationIds) }
                );
            if (response != null && response.embedded != null && response.embedded.credentials.size() > 0) {
                for (GetCredentialsResponse.Credentials credential : response.embedded.credentials) {
                    credentialsToUpdate.add(credential.toRecord());
                }
            }
        }

        if (!credentialsToUpdate.isEmpty()) {
            try {
                Database.DMLOptions option = new Database.DMLOptions();
                option.OptAllOrNone = false;
                Logger.getInstance(false)
                    .log(
                        UtilityCredentialService.class.getName(),
                        UrjanetUtils.getSObjectName(Schema.UtilityCredential__c.SObjectType),
                        Data.upsurt(
                            credentialsToUpdate,
                            Schema.UtilityCredential__c.fields.correlationId__c,
                            option,
                            true,
                            true,
                            true,
                            null
                        )
                    );
            } catch (Exception e) {
                Logger.getInstance().log(UtilityCredentialService.class.getName(), e);
            }
        } else {
            Logger.getInstance(false)
                .log(UtilityCredentialService.class.getName(), Logger.Level.DEBUG, 'No Utility Credentials to Update');
        }
    }

    public static String getCorrelationIdString(List<String> correlationIds) {
        String finalString = '(';
        for (String correlationId : correlationIds) {
            String tempCorrelationId = EncodingUtil.urlEncode(correlationId, 'UTF-8').replaceAll('\\+', '%20');
            finalString = finalString + '\'' + tempCorrelationId + '\',';
        }
        finalString = finalString.removeEnd(',');
        finalString = finalString + ')';
        return finalString;
    }

    public static void generateCorrelationId(
        List<UtilityCredential__c> utilityCredentials,
        Map<Id, UtilityCredential__c> oldUtilityCredentialsMap
    ) {
        List<UtilityCredential__c> credentialsToUpdate = new List<UtilityCredential__c>();
        for (UtilityCredential__c credential : utilityCredentials) {
            if (oldUtilityCredentialsMap == null) {
                if (credential.CorrelationId__c == null) {
                    UtilityCredential__c utilityCred = new UtilityCredential__c();
                    utilityCred.Id = credential.Id;
                    utilityCred.CorrelationId__c = 'NZC-ARC-' + credential.Id;
                    credentialsToUpdate.add(utilityCred);
                }
            } else if (
                oldUtilityCredentialsMap.get(credential.Id).CorrelationId__c != credential.CorrelationId__c &&
                credential.CorrelationId__c == null
            ) {
                credential.CorrelationId__c = 'NZC-ARC-' + credential.Id;
            }
        }
        //In the insert scenario update the creds with correation Id
        if (credentialsToUpdate.size() > 0) {
            Database.DMLOptions option = new Database.DMLOptions();
            option.OptAllOrNone = false;
            Logger.getInstance(false)
                .log(
                    StationaryAssetEnergyUseService.class.getName(),
                    UrjanetUtils.getSObjectName(Schema.UtilityCredential__c.SObjectType),
                    Data.modify(credentialsToUpdate, option, true, true, true)
                );
        }
    }

    public static void createQueueItemsForUtilityCredentials(List<UtilityCredential__c> records) {
        createQueueItemsForUtilityCredentials(records, null);
    }

    public static void createQueueItemsForUtilityCredentials(
        List<UtilityCredential__c> records,
        Map<Id, UtilityCredential__c> oldMap
    ) {
        List<UtilityCredential__c> updatedCredentials = getCredentialsToRefresh(records, oldMap);
        Type processorClass = QueueItemProcessorFactory.getProcessorType(UtilityCredential__c.SObjectType);
        List<Database.SaveResult> saveResults = new QueueItemsBuilder(updatedCredentials, processorClass)
            .buildQueueItemsPerRecord()
            .createRecords();
        UrjanetUtils.logFailures(
            UtilityCredentialService.class.getName(),
            String.valueOf(UtilityCredential__c.SObjectType),
            saveResults
        );
    }

    @TestVisible
    private static List<UtilityCredential__c> getCredentialsToRefresh(
        List<UtilityCredential__c> records,
        Map<Id, UtilityCredential__c> oldMap
    ) {
        List<UtilityCredential__c> updatedUtilityCredentials = new List<UtilityCredential__c>();
        if (oldMap == null) {
            updatedUtilityCredentials.addAll(records);
        } else {
            SObjectField syncField = UtilityCredential__c.LastModifiedInUrjanet__c;
            for (UtilityCredential__c credential : records) {
                if (UrjanetUtils.hasSyncFieldUpdated(credential, oldMap, syncField)) {
                    updatedUtilityCredentials.add(credential);
                }
            }
        }
        return updatedUtilityCredentials;
    }
}
public with sharing class UtilityAccountService {
    public static void createAccountFromDataResponse(
        GetAccountsByCredsResponse response,
        UtilityCredential__c credential
    ) {
        List<UtilityAccount__c> accountRecords = new List<UtilityAccount__c>();
        if (response != null && response.embedded != null && response.embedded.accounts != null) {
            for (GetAccountsByCredsResponse.Account account : response.embedded.accounts) {
                UtilityAccount__c utilityAccount = toObject(account);
                utilityAccount.UtilityCredential__r = new UtilityCredential__c(UrjanetId__c = credential.UrjanetId__c);
                utilityAccount.Supplier__c = credential.ProviderName__c;
                accountRecords.add(utilityAccount);
            }
        }

        if (!accountRecords.isEmpty()) {
            try {
                // This will be running as a system process that should complete
                // no matter who kicked it off
                Database.DMLOptions option = new Database.DMLOptions();
                option.OptAllOrNone = false;
                Logger.getInstance()
                    .log(
                        UtilityAccountService.class.getName(),
                        UrjanetUtils.getSObjectName(Schema.UtilityAccount__c.SObjectType),
                        Data.upsurt(
                            accountRecords,
                            Schema.UtilityAccount__c.fields.UrjanetId__c,
                            option,
                            false,
                            false,
                            false,
                            null
                        )
                    );
            } catch (DmlException e) {
                Logger.getInstance(false).log(UtilityAccountService.class.getName(), e);
            }
        }
    }

    public static void createAccountFromDataResponse(
        GetAccountsByCredsResponse response,
        UtilityStatementFile__c utilityStatementFileObj
    ) {
        List<UtilityAccount__c> accountRecords = new List<UtilityAccount__c>();
        if (response != null && response.embedded != null && response.embedded.accounts != null) {
            for (GetAccountsByCredsResponse.Account account : response.embedded.accounts) {
                UtilityAccount__c utilityAccount = toObject(account);
                utilityAccount.Supplier__c = utilityStatementFileObj.Supplier__c;
                accountRecords.add(utilityAccount);
            }
        }

        if (!accountRecords.isEmpty()) {
            try {
                // This will be running as a system process that should complete
                // no matter who kicked it off
                Database.DMLOptions option = new Database.DMLOptions();
                option.OptAllOrNone = false;
                Logger.getInstance()
                    .log(
                        UtilityAccountService.class.getName(),
                        UrjanetUtils.getSObjectName(Schema.UtilityAccount__c.SObjectType),
                        Data.upsurt(
                            accountRecords,
                            Schema.UtilityAccount__c.fields.UrjanetId__c,
                            option,
                            false,
                            false,
                            false,
                            null
                        )
                    );
                List<Utility_File_Account_Association__c> fileAccountRecords = new List<Utility_File_Account_Association__c>();

                for (UtilityAccount__c utilityAccount : accountRecords) {
                    Utility_File_Account_Association__c fileAccount = new Utility_File_Account_Association__c();
                    fileAccount.Unique_Id__c = utilityAccount.Id + ' ' + utilityStatementFileObj.Id;
                    fileAccount.Utility_Account__c = utilityAccount.Id;
                    fileAccount.Utility_Statement_File__c = utilityStatementFileObj.Id;
                    fileAccountRecords.add(fileAccount);
                }
                try {
                    insert fileAccountRecords;
                } catch (Exception e) {
                    if (!e.getMessage().contains('DUPLICATE_VALUE')) {
                        Logger.getInstance(false).log(UtilityAccountService.class.getName() + '_Files', e);
                        // No need for Logs in case of duplicate records
                    }
                }
            } catch (DmlException e) {
                Logger.getInstance(false).log(UtilityAccountService.class.getName() + '_Files', e);
            }
        }
    }

    @TestVisible
    private static UtilityAccount__c toObject(GetAccountsByCredsResponse.Account account) {
        UtilityAccount__c utilityAccount = new UtilityAccount__c();
        utilityAccount.CreatedDateInUrjanet__c = UrjanetUtils.getDateTime(account.createdDate);
        utilityAccount.CreatedByInUrjanet__c = account.createdBy;
        utilityAccount.Enabled__c = account.enabled;
        utilityAccount.LastModifiedInUrjanet__c = UrjanetUtils.getDateTime(account?.lastModifiedDate);
        utilityAccount.LastModifiedByInUrjanet__c = account.lastModifiedBy;
        utilityAccount.LatestNewStatement__c = UrjanetUtils.getDateTime(account.latestNewStatement);
        utilityAccount.LatestStatementDate__c = (account.latestStatementDate == null
            ? null
            : Date.valueOf(account.latestStatementDate));
        utilityAccount.AccountNumber__c = account.normalizedAccountNumber;
        utilityAccount.Prepaid__c = account.prepaid;
        utilityAccount.Status__c = account.status;
        utilityAccount.StatusDetail__c = account.statusDetail;
        utilityAccount.Type__c = account.type;
        utilityAccount.UrjanetId__c = account.entityId;
        utilityAccount.LastUrjanetSyncDateTime__c = Datetime.now();
        String name = account.providerName + ' - ' + account.normalizedAccountNumber;
        utilityAccount.Name = name.abbreviate(80);
        return utilityAccount;
    }

    public static void createQueueItemsForUtilityAccounts(List<UtilityAccount__c> records) {
        createQueueItemsForUtilityAccounts(records, null);
    }

    public static void createQueueItemsForUtilityAccounts(
        List<UtilityAccount__c> records,
        Map<Id, UtilityAccount__c> oldMap
    ) {
        List<UtilityAccount__c> updatedAccounts = getAccountsToRefresh(records, oldMap);
        Type processorClass = QueueItemProcessorFactory.getProcessorType(UtilityAccount__c.SObjectType);
        List<Database.SaveResult> saveResults = new QueueItemsBuilder(updatedAccounts, processorClass)
            .buildQueueItemsPerRecord()
            .createRecords();
        UrjanetUtils.logFailures(
            UtilityAccountService.class.getName(),
            String.valueOf(UtilityAccount__c.SObjectType),
            saveResults
        );
    }

    @TestVisible
    private static List<UtilityAccount__c> getAccountsToRefresh(
        List<UtilityAccount__c> records,
        Map<Id, UtilityAccount__c> oldMap
    ) {
        List<UtilityAccount__c> updatedUtilityAccounts = new List<UtilityAccount__c>();
        if (oldMap == null) {
            updatedUtilityAccounts.addAll(records);
        } else {
            SObjectField syncField = UtilityAccount__c.LastModifiedInUrjanet__c;
            for (UtilityAccount__c account : records) {
                if (UrjanetUtils.hasSyncFieldUpdated(account, oldMap, syncField)) {
                    updatedUtilityAccounts.add(account);
                }
            }
        }
        return updatedUtilityAccounts;
    }
}
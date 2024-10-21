public without sharing class DeleteCredentialApiController {
    @AuraEnabled
    public static DeletePlugApiResponse.DeleteApiUiResponse deleteCredentialMethod(
        String credentialId,
        String actionParameter
    ) {
        DeletePlugApiResponse.DeleteApiUiResponse uiResponse = new DeletePlugApiResponse.DeleteApiUiResponse();
        try {
            UtilityCredential__c credentialRecord = (UtilityCredential__c) new UtilityCredentialSelector()
                .getRecordById(credentialId);
            if (actionParameter == UrjanetConstants.DELETE_IN_BOTH) {
                if (credentialRecord != null && credentialRecord.UrjanetId__c != null) {
                    uiResponse = deleteCredentialApiCallout(credentialRecord.UrjanetId__c);
                } else {
                    String errorMessage = 'Unable to Process the Credential :' + credentialId + ' as ArcadiaId is null';
                    Logger.getInstance()
                        .log(DeleteCredentialApiController.class.getName(), Logger.Level.ERROR, errorMessage);
                    uiResponse.statusCode = UrjanetConstants.FAILURE_MESSAGE;
                    uiResponse.message = errorMessage;
                }
            }
            if (actionParameter == UrjanetConstants.DELETE_IN_SFDC) {
                deleteCredentialsAndRelatedRecords(credentialRecord.Id, UrjanetConstants.DELETE_IN_SFDC);
                uiResponse.message = 'Credential and related Records Deleted Successfully in Net Zero Cloud!!';
                uiResponse.statusCode = UrjanetConstants.SUCCESS_MESSAGE;
            }
        } catch (Exception e) {
            Logger.getInstance().log(DeleteCredentialApiController.class.getName(), e);
            throw new AuraHandledException(e.getMessage());
        }
        return uiResponse;
    }

    /**
     * this method is used by the Delete Action to call Delete API by sending the credential id to delete the credentials & realted records
     */
    public static DeletePlugApiResponse.DeleteApiUiResponse deleteCredentialApiCallout(String credentialIdToBeDeleted) {
        DeletePlugApiResponse.DeleteApiUiResponse uiResponse = new DeletePlugApiResponse.DeleteApiUiResponse();
        List<Credential_Deletion_Log__c> existingDelLogs = new List<Credential_Deletion_Log__c>();
        String deletionJobId = '';

        //Before calling the Delete API we are calling Disable API for disabling the credenitals and other associated records in ODIN so that these records will not be available for sync
        DisablePlugApiResponse disableRes;
        existingDelLogs = checkForExistingCredentialDeletionLogs(credentialIdToBeDeleted);
        if (existingDelLogs != null && !existingDelLogs.isEmpty()) {
            deleteCredentialsAndRelatedRecords(credentialIdToBeDeleted, UrjanetConstants.DELETE_IN_BOTH);
            uiResponse.message = 'Credential and related Records Deleted Successfully';
            uiResponse.statusCode = UrjanetConstants.SUCCESS_MESSAGE;
            return uiResponse;
        } else {
            disableRes = DisableCredentialApiController.disableCredentialApiCallout(credentialIdToBeDeleted);
        }
        if (disableRes != null && disableRes.statusCode == 202 && disableRes.id != null) {
            DeletePlugApiResponse deleteResponse = (DeletePlugApiResponse) new UrjanetApiClient()
                .getUrjanetResponse(
                    UrjanetEnums.RequestType.DELETE_CREDENTIAL,
                    UrjanetEnums.ApiMethod.DELETE_METHOD,
                    new List<String>{ credentialIdToBeDeleted }
                );

            if (deleteResponse.statusCode == 200 && deleteResponse.id != null && deleteResponse.id.contains('del_')) {
                deletionJobId = deleteResponse.id.substringAfter('del_');
                if (
                    deleteResponse.status != null &&
                    (deleteResponse.status == UrjanetConstants.DELETE_API_STATUS_SCHEDULED ||
                    deleteResponse.status == UrjanetConstants.DELETE_API_STATUS_PENDING)
                ) {
                    //Before deleting the Credential in sfdc we are storing the deletion job id from ODIN to track the status of the Deletion Job
                    Credential_Deletion_Log__c credLog = createDeletionLog(credentialIdToBeDeleted, deletionJobId);
                    deleteCredentialsAndRelatedRecords(credentialIdToBeDeleted, UrjanetConstants.DELETE_IN_BOTH);
                    uiResponse.message = 'Credential and related Records Deleted Successfully';
                    uiResponse.statusCode = UrjanetConstants.SUCCESS_MESSAGE;
                }
            } else {
                throw new ArcadiaCalloutServiceException(
                    UrjanetConstants.FAILED_TO_DELETE_CREDENTIAL +
                        credentialIdToBeDeleted +
                        ' , ' +
                        (deleteResponse.statusCode != null
                            ? ' Status Code :' + String.valueOf(deleteResponse.statusCode)
                            : '') +
                        +' , ' +
                        (deleteResponse.errorMsg != null ? deleteResponse.errorMsg : '')
                );
            }
        } else {
            throw new ArcadiaCalloutServiceException(
                UrjanetConstants.FAILED_TO_DISABLE_CREDENTIAL +
                    credentialIdToBeDeleted +
                    +' , ' +
                    (disableRes.statusCode != null ? ' Status Code :' + String.valueOf(disableRes.statusCode) : '') +
                    +' , ' +
                    (disableRes.errorMsg != null ? disableRes.errorMsg : '')
            );
        }
        return uiResponse;
    }

    /**
     * to Create the Deletion log record to track the status of the deletion log
     */
    private static Credential_Deletion_Log__c createDeletionLog(String credentialIdToBeDeleted, String deletionJobId) {
        Credential_Deletion_Log__c credLog = prepareCredentialDeletionLogRecord(
            credentialIdToBeDeleted,
            deletionJobId,
            ''
        );
        Database.DMLOptions option = new Database.DMLOptions();
        option.OptAllOrNone = false;
        Logger.getInstance(false)
            .log(
                UtilityCredentialService.class.getName(),
                UrjanetUtils.getSObjectName(Schema.Credential_Deletion_Log__c.SObjectType),
                Data.create(new List<sObject>{ credLog }, option, false, false, false)
            );
        return credLog;
    }

    @testVisible
    private static Credential_Deletion_Log__c prepareCredentialDeletionLogRecord(
        String credId,
        String delId,
        String errMessage
    ) {
        Credential_Deletion_Log__c credDeletionLog = new Credential_Deletion_Log__c();
        credDeletionLog.Credential_Id__c = credId;
        credDeletionLog.Deletion_Log_Id__c = delId;
        credDeletionLog.Error_Message__c = errMessage;
        credDeletionLog.Status__c = UrjanetConstants.CRED_DEL_STATUS_INPROGRESS;
        return credDeletionLog;
    }

    /**
     * check for existing deletion log , if exist which means the deletion request is already sent
     */
    private static List<Credential_Deletion_Log__c> checkForExistingCredentialDeletionLogs(String credentialID) {
        List<Credential_Deletion_Log__c> exisitingCredDeletionLogs = [
            SELECT Id, Credential_Id__c, Deletion_Log_Id__c
            FROM Credential_Deletion_Log__c
            WHERE Credential_Id__c = :credentialID AND Status__c = :UrjanetConstants.CRED_DEL_STATUS_INPROGRESS
            LIMIT 1
        ];
        return exisitingCredDeletionLogs;
    }

    /**
     * This method will delete the Credential record and its associated Utility Accounts , Utility Meters , Usages
     */
    private static void deleteCredentialsAndRelatedRecords(String credentialId, String actionParameter) {
        List<UtilityCredential__c> credentialRecords = (List<UtilityCredential__c>) new UtilityCredentialSelector()
            .getCredentialAndRelatedAccounts(credentialId, actionParameter);
        if (credentialRecords != null && !credentialRecords.isEmpty()) {
            List<Utility_Account_Meter_Relation__c> utilityMeterRelations = new List<Utility_Account_Meter_Relation__c>();
            List<UtilityMeter__c> utilityMeters = new List<UtilityMeter__c>();

            if (credentialRecords[0].UtilityAccounts__r != null && !credentialRecords[0].UtilityAccounts__r.isEmpty()) {
                utilityMeterRelations = [
                    SELECT Id, Utility_Account__c, Utility_Meter__c
                    FROM Utility_Account_Meter_Relation__c
                    WHERE Utility_Account__c IN :credentialRecords[0].UtilityAccounts__r
                ];
            }
            Set<Id> meterIdSet = new Set<Id>();
            for (Utility_Account_Meter_Relation__c meterRelation : utilityMeterRelations) {
                if (meterRelation.Utility_Meter__c != null) {
                    meterIdSet.add(meterRelation.Utility_Meter__c);
                }
            }
            if (meterIdSet != null && !meterIdSet.isEmpty()) {
                utilityMeters = [
                    SELECT Id
                    FROM UtilityMeter__c
                    WHERE Id IN :meterIdSet
                ];
            }

            if (utilityMeters != null && !utilityMeters.isEmpty()) {
                //Method already exist for Deleting meters and Usages reusing it here
                UtilityMeterUsageService.checkForMeterWithUsageIdNullAndDelete(utilityMeters);
                Data.remove(utilityMeters, false, false, false);
            }

            if (credentialRecords[0].UtilityAccounts__r != null && !credentialRecords[0].UtilityAccounts__r.isEmpty()) {
                Data.remove(credentialRecords[0].UtilityAccounts__r, false, false, false);
            }
            Data.remove(credentialRecords[0], false, false, false);
        }
    }
}
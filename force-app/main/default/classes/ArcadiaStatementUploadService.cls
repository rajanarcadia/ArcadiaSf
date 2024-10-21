public with sharing class ArcadiaStatementUploadService {
    @future(callout=true)
    public static void uploadFile(String jsonFileDetails, String supplierId, String fileName) {
        try {
            ArcadiaStatementUploadCalloutService aracadiaCalloutService = ArcadiaStatementUploadCalloutService.getInstance();
            ArcadiaStatementUploadCalloutResources.UploadStatementResponse fileUploadResult = aracadiaCalloutService.uploadStatement(
                jsonFileDetails,
                fileName
            );
            UtilityStatementFile__c utilityStatementObj = fileUploadResult.toUtilityStatementRecord();
            utilityStatementObj.Supplier__c = supplierId;
            utilityStatementObj.Name = fileName.abbreviate(80);

            List<Database.UpsertResult> lstUpsertResults = Data.upsurt(
                new List<UtilityStatementFile__c>{ utilityStatementObj },
                Schema.UtilityStatementFile__c.fields.EntityId__c,
                false,
                false,
                false,
                null
            );

            //verify that the upsert happened without issues
            ArcadiaGenericController.handleDMLErrors(lstUpsertResults[0]);
        } catch (Exception e) {
            Logger.getPlatformLogger().log('ArcadiaStatementUploadService', e);
        }
    }
}
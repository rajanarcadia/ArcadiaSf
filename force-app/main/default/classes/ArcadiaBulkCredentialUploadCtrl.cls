public with sharing class ArcadiaBulkCredentialUploadCtrl extends ArcadiaGenericController{
    @TestVisible
    private static ArcadiaBulkCredentialUploadService arcadiaBulkCredServObj = new ArcadiaBulkCredentialUploadService();

    @AuraEnabled
    public static ArcadiaBulkCredentialUploadService.BulkCredentialsCreationResponse createSalesforceCredentials(String jsonCredentialDetails){
        try{
            ArcadiaBulkCredentialUploadService.BulkCredentialsCreationResponse response = arcadiaBulkCredServObj.createSalesforceCredentials(jsonCredentialDetails);
            return response;
        } catch (Exception e) {throw handleException('ArcadiaStatementUploadService.createSalesforceCredentials', e);}
    }

    @AuraEnabled
    public static void deleteSalesforceCredentials(String jsonCredentialDetails){
        try {
            arcadiaBulkCredServObj.deleteSalesforceCredentials(jsonCredentialDetails);
        } catch (Exception e) {throw handleException('ArcadiaStatementUploadService.deleteSalesforceCredentials', e);}
    }

    @AuraEnabled
    public static boolean uploadBulkCredentials(String jsonCredentialDetails){
        try {
            return arcadiaBulkCredServObj.uploadBulkCredentials(jsonCredentialDetails);
        } catch (Exception e) {throw handleException('ArcadiaStatementUploadService.uploadBulkCredentials', e);}
    }

    @AuraEnabled 
    public static List<GetArcadiaServiceProvidersResponse.ProviderDetails> getArcadiaProviders(){
        try{
            return arcadiaBulkCredServObj.getArcadiaProviders();
        } catch (Exception e) {throw handleException('ArcadiaStatementUploadService.uploadFile', e);}
    }

}
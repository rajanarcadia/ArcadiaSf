public with sharing class ArcadiaStatementUploadCtrl extends ArcadiaGenericController {
    @TestVisible
    private static ArcadiaStatementUploadService arcadiaStatementUploadServiceObj = new ArcadiaStatementUploadService();

    @AuraEnabled
    public static void uploadFile(Map<String, Object> fileDetails, String supplierId, String fileName) {
        if (fileDetails == null || fileDetails.isEmpty() || String.isBlank(supplierId) || String.isBlank(fileName)) {
            throw new ArcadiaCalloutServiceException('File is empty', 400);
        }
        try {
            ArcadiaStatementUploadService.uploadFile(JSON.serialize(fileDetails), supplierId, fileName);

            //Add some delay (3 seconds) when UI is refreshed the API call be done
            Long startingTime = System.now().getTime(); // Num milliseconds since Jan 1 1970
            Integer delayInMilliseconds = 3000; // three-second delay
            while (System.now().getTime() - startingTime < delayInMilliseconds) {
                // Do nothing until desired delay has passed
            }
        } catch (Exception e) {
            throw handleException('ArcadiaStatementUploadService.uploadFile', e);
        }
    }
}
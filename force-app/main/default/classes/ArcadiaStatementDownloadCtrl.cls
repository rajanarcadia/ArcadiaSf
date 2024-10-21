public with sharing class ArcadiaStatementDownloadCtrl extends ArcadiaGenericController {
    @AuraEnabled
    public static String getAccessToken() {
        try {
            AccessToken__c accessToken = UrjanetUtils.checkAndUpdateAccessToken();
            if (null != accessToken)
                return UrjanetUtils.extractAccessToken(accessToken);
            return null;
        } catch (Exception e) {
            Logger.getInstance(false)
                .log(ArcadiaStatementDownloadCtrl.class.getName(), 'Error in getAccessToken', Logger.Level.ERROR, e);
            throw handleException('ArcadiaStatementDownloadCtrl', e);
        }
    }
}
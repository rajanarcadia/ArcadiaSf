public with sharing class TestHarnessController {
    @AuraEnabled(cacheable=true)
    public static String getAccessToken() {
        try {
            UrjanetApiClient apiClient = new UrjanetApiClient();
            return JSON.serializePretty(apiClient.getAccessToken(), false);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getCredentialsResponse(List<String> requestParams) {
        try {
            UrjanetApiClient apiClient = new UrjanetApiClient();
            return JSON.serializePretty(
                apiClient.getUrjanetResponse(
                    UrjanetEnums.RequestType.CREDENTIALS_BY_CORRELATION_ID,
                    UrjanetEnums.ApiMethod.GET,
                    requestParams
                ),
                false
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getAccountsByCredsResponse(List<String> requestParams) {
        try {
            UrjanetApiClient apiClient = new UrjanetApiClient();
            return JSON.serializePretty(
                apiClient.getUrjanetResponse(
                    UrjanetEnums.RequestType.ACCOUNTS_BY_CREDS,
                    UrjanetEnums.ApiMethod.GET,
                    requestParams
                ),
                false
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getMetersByAccountResponse(List<String> requestParams) {
        try {
            UrjanetApiClient apiClient = new UrjanetApiClient();
            return JSON.serializePretty(
                apiClient.getUrjanetResponse(
                    UrjanetEnums.RequestType.METERS_BY_ACCOUNT,
                    UrjanetEnums.ApiMethod.GET,
                    requestParams
                ),
                false
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String retrieveMeterDetailsResponse(List<String> requestParams) {
        try {
            UrjanetApiClient apiClient = new UrjanetApiClient();
            return JSON.serializePretty(
                apiClient.getUrjanetResponse(
                    UrjanetEnums.RequestType.RETRIEVE_METER_DETAILS,
                    UrjanetEnums.ApiMethod.GET,
                    requestParams
                ),
                false
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getUpdateUrlByCredResponse(List<String> requestParams) {
        try {
            UrjanetApiClient apiClient = new UrjanetApiClient();
            return JSON.serializePretty(
                apiClient.getUrjanetResponse(
                    UrjanetEnums.RequestType.UPDATE_URL_BY_CREDENTIAL,
                    UrjanetEnums.ApiMethod.GET,
                    requestParams
                ),
                false
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
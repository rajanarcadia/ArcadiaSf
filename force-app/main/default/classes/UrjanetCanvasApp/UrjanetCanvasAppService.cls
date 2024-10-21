public with sharing class UrjanetCanvasAppService {
    public UrjanetCanvasAppService() {
    }
    public static Map<String, String> getAlternatePath(String credentialId) {
        UtilityCredentialSelector selector = new UtilityCredentialSelector();
        UtilityCredential__c credentialRecord = (UtilityCredential__c) selector.getRecordById(credentialId);
        Map<String, String> pathMap = new Map<String, String>();
        String alternatePath;

        if (credentialRecord != null) {
            if (String.isBlank(credentialRecord.Status__c)) {
                String orgId = getOrgId();
                alternatePath = buildAlternatePathforInitCred(orgId, credentialRecord.CorrelationId__c);
            } else if (credentialRecord.Status__c == UrjanetConstants.CREDENTIAL_STATUS) {
                alternatePath = null;
            } else {
                if (!String.isBlank(credentialRecord.UrjanetId__c)) {
                    List<String> requestParams = new List<String>{ credentialRecord.UrjanetId__c };
                    GetUpdateUrlByCredentialResponse response = (GetUpdateUrlByCredentialResponse) new UrjanetApiClient()
                        .getUrjanetResponse(
                            UrjanetEnums.RequestType.UPDATE_URL_BY_CREDENTIAL,
                            UrjanetEnums.ApiMethod.GET,
                            requestParams
                        );

                    if (response != null && !String.isBlank(response.updateUrl)) {
                        alternatePath = buildAlternatePathforReCred(response.updateUrl);
                    } else {
                        Logger.getInstance()
                            .log(
                                UrjanetCanvasAppService.class.getName(),
                                'Error in getting update url response : ' + response.toString()
                            );
                        alternatePath = null;
                    }
                }
            }
        }
        pathMap.put('path', alternatePath);
        return pathMap;
    }

    /**
     * Get the OrgId from Custom Setting
     *
     * @return	String - Org Id
     */
    public static String getOrgId() {
        // Get the Urjanet Org Id using Org Defaults
        UrjanetSettings__c settings = UrjanetSettings__c.getOrgDefaults();
        return settings.OrganizationId__c;
    }

    private static String buildAlternatePathforInitCred(String orgId, String correlationId) {
        PageReference pageRef = new PageReference(String.escapeSingleQuotes('/' + orgId + '/canvas'));
        pageRef.getParameters().put('salesforce', 'true');
        pageRef.getParameters().put('correlationId', correlationId);
        pageRef.getParameters().put('hideFinalButtons', 'true');
        return pageRef.getUrl();
    }

    private static String buildAlternatePathforReCred(String updateUrl) {
        String baseUrl = getBaseUrl();
        PageReference pageRef = new PageReference(String.escapeSingleQuotes(updateUrl.replace(baseUrl, '')));
        pageRef.getParameters().put('salesforce', 'true');
        pageRef.getParameters().put('hideFinalButtons', 'true');
        return pageRef.getUrl();
    }

    /**
     * Update the status for Utility Credentials
     *
     * @return	void
     */
    public static void updateCredentialStatus(String credentialId) {
        // Get the Urjanet Org Id using Org Defaults
        UtilityCredential__c credential = new UtilityCredential__c(Id = credentialId);
        credential.Status__c = UrjanetConstants.CREDENTIAL_STATUS;
        Data.upsurt(credential);
    }

    /**
     * Get the baseUrl from Custom Metadata
     *
     * @return	String - baseUrl
     */
    public static String getBaseUrl() {
        UrjanetConfigurationSetting__mdt urjanetSetting = UrjanetConfigurationSetting__mdt.getInstance('Base_Url');
        return urjanetSetting.SettingValue__c;
    }
}
public with sharing class UtilityAccountSelector extends Selector {
    public UtilityAccountSelector() {
        super(Schema.UtilityAccount__c.SObjectType);
    }

    public UtilityAccountSelector(Boolean enforceCRUD, Boolean enforceFLS, Boolean enforceShr) {
        super(Schema.UtilityAccount__c.SObjectType, enforceCRUD, enforceFLS, EnforceShr);
    }

    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'Name',
            'UrjanetId__c',
            'UtilityCredential__c',
            'UtilityCredential__r.ProviderName__c',
            'UtilityCredential__r.ProviderName__r.Name',
            'UtilityCredential__r.ProviderName__r.ElectricityEmissionsFactors__c',
            'UtilityCredential__r.ProviderName__r.OtherEmissionsFactors__c',
            'Supplier__c',
            'Supplier__r.Name',
            'Supplier__r.ElectricityEmissionsFactors__c',
            'Supplier__r.OtherEmissionsFactors__c'
        };
    }

    /**
     * Gets UtilityAccount__c records that need the details synced from Arcadia that are not linked to Credentials
     * @return Database.QueryLocator
     */
    public Database.QueryLocator getUtilAccountsSyncBatchWithoutCredential() {
        Map<String, Object> params = new Map<String, Object>();

        //we need to get the utility account records that are not linked to Utility Credentials
        String query = getDefaultQuery();
        query += ' WHERE UrjanetId__c != null and UtilityCredential__c=null';
        return Data.Locator(query, params, this.isEnforcingCRUD(), this.isEnforcingFLS(), this.isEnforcingShr());
    }
}
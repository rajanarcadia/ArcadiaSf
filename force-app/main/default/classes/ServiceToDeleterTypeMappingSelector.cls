public with sharing class ServiceToDeleterTypeMappingSelector extends Selector {
    public ServiceToDeleterTypeMappingSelector() {
        super(Schema.UtilityMeterUsageDeleterSetting__mdt.SObjectType);
    }
    public ServiceToDeleterTypeMappingSelector(Boolean enforceCRUD, Boolean enforceFLS, Boolean enforceShr) {
        super(Schema.UtilityMeterUsageDeleterSetting__mdt.SObjectType, enforceCRUD, enforceFLS, enforceShr);
    }

    /**
     * Returns a Set that has all of the default fields.
     * @return   Set of Strings that contain the default fields for this object
     */
    public override Set<String> getDefaultFields() {
        return new Set<String>{ 'Id', 'DeveloperName', 'DeleterClassName__c', 'ServiceType__c' };
    }
}
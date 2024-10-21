public with sharing class ServiceToUpdaterTypeMappingSelector extends Selector {
    public ServiceToUpdaterTypeMappingSelector() {
        super(Schema.UtilityMeterUsageUpdaterSetting__mdt.SObjectType);
    }
    public ServiceToUpdaterTypeMappingSelector(Boolean enforceCRUD, Boolean enforceFLS, Boolean enforceShr) {
        super(Schema.UtilityMeterUsageUpdaterSetting__mdt.SObjectType, enforceCRUD, enforceFLS, enforceShr);
    }

    /**
     * Returns a Set that has all of the default fields.
     * @return   Set of Strings that contain the default fields for this object
     */
    public override Set<String> getDefaultFields() {
        return new Set<String>{ 'Id', 'DeveloperName', 'UpdaterClassName__c', 'ServiceType__c' };
    }
}
public with sharing class ServiceToProcessorTypeMappingSelector extends Selector {
    public ServiceToProcessorTypeMappingSelector() {
        super(Schema.UtilityMeterUsageProcessorSetting__mdt.SObjectType);
    }
    public ServiceToProcessorTypeMappingSelector(Boolean enforceCRUD, Boolean enforceFLS, Boolean enforceShr) {
        super(Schema.UtilityMeterUsageProcessorSetting__mdt.SObjectType, enforceCRUD, enforceFLS, enforceShr);
    }

    /**
     * Returns a Set that has all of the default fields.
     * @return   Set of Strings that contain the default fields for this object
     */
    public override Set<String> getDefaultFields() {
        return new Set<String>{ 'Id', 'DeveloperName', 'ProcessorClassName__c', 'ServiceType__c' };
    }
}
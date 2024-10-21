public with sharing class MeterProcessorMappingSelector extends Selector {
    public MeterProcessorMappingSelector() {
        super(Schema.UtilityMeterProcessorSetting__mdt.SObjectType);
    }
    public MeterProcessorMappingSelector(Boolean enforceCRUD, Boolean enforceFLS, Boolean enforceShr) {
        super(Schema.UtilityMeterProcessorSetting__mdt.SObjectType, enforceCRUD, enforceFLS, enforceShr);
    }

    /**
     * Returns a Set that has all of the default fields.
     * @return   Set of Strings that contain the default fields for this object
     */
    public override Set<String> getDefaultFields() {
        return new Set<String>{ 'Id', 'DeveloperName', 'ProcessorClassName__c', 'ServiceType__c' };
    }
}
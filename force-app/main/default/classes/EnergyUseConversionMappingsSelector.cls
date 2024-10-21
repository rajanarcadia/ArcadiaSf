public with sharing class EnergyUseConversionMappingsSelector extends Selector {
    public EnergyUseConversionMappingsSelector() {
        super(Schema.EnergyUseConversionMapping__mdt.SObjectType);
    }

    public EnergyUseConversionMappingsSelector(Boolean enforceCRUD, Boolean enforceFLS, Boolean enforceShr) {
        super(Schema.EnergyUseConversionMapping__mdt.SObjectType, enforceCRUD, enforceFLS, enforceShr);
    }

    /**
     * Returns a Set that has all of the default fields.
     * @return   Set of Strings that contain the default fields for this object
     */
    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'DeveloperName',
            'ApiUnitOfMeasurementFrom__c',
            'ConversionRate__c',
            'ApiUnitOfMeasurementTo__c'
        };
    }
}
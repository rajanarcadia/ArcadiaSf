public with sharing class ServiceTypeToFuelTypeMappingSelector extends Selector {
    public ServiceTypeToFuelTypeMappingSelector() {
        super(Schema.ServiceTypeToFuelTypeMapping__mdt.SObjectType);
    }
    public ServiceTypeToFuelTypeMappingSelector(Boolean enforceCRUD, Boolean enforceFLS, Boolean enforceShr) {
        super(Schema.ServiceTypeToFuelTypeMapping__mdt.SObjectType, enforceCRUD, enforceFLS, enforceShr);
    }

    /**
     * Returns a Set that has all of the default fields.
     * @return   Set of Strings that contain the default fields for this object
     */
    public override Set<String> getDefaultFields() {
        return new Set<String>{ 'Id', 'DeveloperName', 'FuelType__c', 'ServiceType__c' };
    }
}
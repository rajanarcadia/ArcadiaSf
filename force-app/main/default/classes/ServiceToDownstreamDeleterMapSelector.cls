public with sharing class ServiceToDownstreamDeleterMapSelector extends Selector {
    public ServiceToDownstreamDeleterMapSelector() {
        super(Schema.UsageDownstreamDeleterSetting__mdt.SObjectType);
    }
    public ServiceToDownstreamDeleterMapSelector(Boolean enforceCRUD, Boolean enforceFLS, Boolean enforceShr) {
        super(Schema.UsageDownstreamDeleterSetting__mdt.SObjectType, enforceCRUD, enforceFLS, enforceShr);
    }

    /**
     * Returns a Set that has all of the default fields.
     * @return   Set of Strings that contain the default fields for this object
     */
    public override Set<String> getDefaultFields() {
        return new Set<String>{ 'Id', 'DeveloperName', 'DeleterClassName__c', 'ServiceType__c' };
    }
}
public with sharing class UtilityMeterSelector extends Selector {
    public UtilityMeterSelector() {
        super(Schema.UtilityMeter__c.SObjectType);
    }

    public UtilityMeterSelector(Boolean enforceCRUD, Boolean enforceFLS, Boolean enforceShr) {
        super(Schema.UtilityMeter__c.SObjectType, enforceCRUD, enforceFLS, EnforceShr);
    }

    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'Name',
            'UrjanetId__c',
            'ServiceType__c',
            'StationaryAssetEnvironmentalSource__c',
            'StationaryAssetEnvironmentalSource__r.UrjanetId__c',
            'Enabled__c'
        };
    }
    public Database.QueryLocator getUtilityMetersWithNullValues() {
        Map<String, Object> params = new Map<String, Object>();

        String query = getDefaultQuery();
        String subquery = 'SELECT UtilityMeter__c FROM UtilityMeterUsage__c WHERE UrjanetId__c = null';
        query += ' WHERE Id IN (' + subquery + ')';

        return Database.getQueryLocator(query);
    }
    public Database.QueryLocator getUtilityMeterWithValidUsages() {
        Map<String, Object> params = new Map<String, Object>();
        String query = 'SELECT Id,Name,Enabled__c,StationaryAssetEnvironmentalSource__c,PodNumber__c, ServiceType__c, '+
                        '(SELECT Id, MeasuredUsage__c, PeriodStart__c, PeriodEnd__c, Arcadia_Statement_ID__c , UtilityMeter__c FROM UtilityMeterUsages__r '+
                        'WHERE To_Be_Ignored__c = false AND MeasuredUsage__c != null) '+
                        'FROM UtilityMeter__c WHERE Enabled__c = true AND StationaryAssetEnvironmentalSource__c != null' ;
        return Database.getQueryLocator(query);
    }
}
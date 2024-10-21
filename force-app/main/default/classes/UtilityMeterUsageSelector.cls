/**
 * Created by mike on 5/11/22.
 */

 public with sharing class UtilityMeterUsageSelector extends Selector {
    public UtilityMeterUsageSelector() {
        super(Schema.UtilityMeterUsage__c.SObjectType);
    }

    public UtilityMeterUsageSelector(Boolean enforceCRUD, Boolean enforceFLS, Boolean enforceShr) {
        super(Schema.UtilityMeterUsage__c.SObjectType, enforceCRUD, enforceFLS, EnforceShr);
    }

    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'Name',
            'PeriodStart__c',
            'PeriodEnd__c',
            'UsageUnit__c',
            'MeasuredUsage__c',
            'MeasurementType__c',
            'AccountType__c',
            'DeregulationStatus__c',
            'UtilityMeter__c',
            'UtilityMeter__r.ServiceType__c',
            'UtilityMeter__r.StationaryAssetEnvironmentalSource__c',
            'UtilityMeter__r.StationaryAssetEnvironmentalSource__r.Name',
            'UtilityMeter__r.StationaryAssetEnvironmentalSource__r.UtilityAccount__r.UtilityCredential__r.ProviderName__c'
        };
    }

    public List<UtilityMeterUsage__c> getMostRecentUtilityMeterUsageForMeter(Id meterId) {
        List<String> queryFields = new List<String>(this.getDefaultFields());

        Map<String, Object> queryArgs = new Map<String, Object>{ 'meterId' => meterId };

        String query =
            'SELECT ' +
            String.join(queryFields, ', ') +
            ' FROM UtilityMeterUsage__c' +
            ' WHERE UtilityMeter__c = :meterId' +
            ' ORDER BY PeriodEnd__c DESC' +
            ' LIMIT 1';

        return new List<UtilityMeterUsage__c>(
            (List<UtilityMeterUsage__c>) Data.read(
                query,
                queryArgs,
                this.isEnforcingCRUD(),
                this.isEnforcingFLS(),
                this.isEnforcingShr()
            )
        );
    }

    public Database.QueryLocator getUsagesToBeCheckedForDuplicacy() {
        List<String> measuredUsageInTextList = getMeasuredUsageInTextWithCountGreaterThanOne();

        if (measuredUsageInTextList.isEmpty()) {
            // Return an empty query locator if no results found in the first query
            return Database.getQueryLocator([SELECT Id FROM UtilityMeterUsage__c WHERE Id = NULL]);
        }

        String query =
            'SELECT Id, UsageUnit__c , MeasuredUsage__c , MeasuredUsageInText__c, PeriodStart__c, PeriodEnd__c, Arcadia_Statement_ID__c, To_Be_Ignored__c, UtilityMeter__c, UtilityMeter__r.PodNumber__c, UtilityMeter__r.ServiceType__c, UtilityMeter__r.StationaryAssetEnvironmentalSource__c, UtilityMeter__r.Enabled__c ' +
            'FROM UtilityMeterUsage__c ' +
            'WHERE To_Be_Ignored__c = false AND MeasuredUsage__c != null AND MeasuredUsage__c > 0 AND UtilityMeter__r.Enabled__c = true ' +
            'AND UsageUnit__c != null ' +
            'AND MeasuredUsageInText__c IN :measuredUsageInTextList AND IsRecordLocked__c = false ' +
            'ORDER BY CreatedDate ASC';

        return Database.getQueryLocator(query);
    }

    private List<String> getMeasuredUsageInTextWithCountGreaterThanOne() {
        String query =
            'SELECT MeasuredUsageInText__c ' +
            'FROM UtilityMeterUsage__c ' +
            'WHERE To_Be_Ignored__c = false AND MeasuredUsage__c != null AND MeasuredUsage__c > 0 AND UtilityMeter__r.Enabled__c = true ' +
            'AND PeriodStart__c != null AND PeriodEnd__c != null AND Arcadia_Statement_ID__c != null AND IsRecordLocked__c = false ' +
            'GROUP BY MeasuredUsageInText__c ' +
            'HAVING COUNT(Id) > 1';

        List<AggregateResult> aggregateResults = Database.query(query);
        List<String> measuredUsageInTextList = new List<String>();

        if (!UrjanetUtils.getDevelopmentOrg()){
            for (AggregateResult ar : aggregateResults) {
                measuredUsageInTextList.add((String) ar.get('urjanet__MeasuredUsageInText__c'));
            }
        }
        else {
            for (AggregateResult ar : aggregateResults) {
                measuredUsageInTextList.add((String) ar.get('MeasuredUsageInText__c'));
            }
        }
        return measuredUsageInTextList;
    }
    public Database.QueryLocator getUsagesToBeDeleted() {
        String query =
            'SELECT Id, UtilityMeter__r.ServiceType__c, UtilityMeter__r.Enabled__c ' +
            'FROM UtilityMeterUsage__c ' +
            'WHERE To_Be_Ignored__c = true ' +
            'OR UtilityMeter__r.Enabled__c = false';
        return Database.getQueryLocator(query);
    }
}
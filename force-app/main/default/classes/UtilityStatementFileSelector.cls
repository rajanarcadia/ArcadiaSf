public with sharing class UtilityStatementFileSelector extends Selector {
    public UtilityStatementFileSelector() {
        this(true, true, true);
    }

    public UtilityStatementFileSelector(Boolean enforceCRUD, Boolean enforceFLS, Boolean enforceShr) {
        super(Schema.UtilityStatementFile__c.SObjectType, enforceCRUD, enforceFLS, enforceShr);
    }

    /**
     * Returns a Set that has all of the default fields.
     * @return   Set of Strings that contain the default fields for this object
     */
    public override Set<String> getDefaultFields() {
        Set<String> defaultFields = new Set<String>{
            'Id',
            'Name',
            'CreatedDateInArcadia__c',
            'EntityId__c',
            'Status__c',
            'Supplier__c',
            'Name',
            'StatementId__c'
        };
        return defaultFields;
    }

    /**
     * Gets UtilityStatementFile records that need the details synced from Urjanet
     * @return Database.QueryLocator
     */
    public Database.QueryLocator getRecordsForUtilStatementFileSyncBatch() {
        Map<String, Object> params = new Map<String, Object>();

        //we need to get the utilit Statement files with Pending Status or Failure Status
        //For failure status we will get the ones that got crated in Arcadia in the last 90 days including today (Last N months, was ignoring the current month)
        String query = getDefaultQuery();
        query += ' WHERE EntityId__c != null and (Status__c IN (\'PENDING\' , \'QUEUED\' , \'COVERAGE_REQUEST\' , \'IN_PROGRESS\') or (Status__c IN (\'FAILURE\', \'REJECTED\') and CreatedDateInArcadia__c = LAST_N_DAYS:90))';
        return Data.Locator(query, params, this.isEnforcingCRUD(), this.isEnforcingFLS(), this.isEnforcingShr());
    }
}
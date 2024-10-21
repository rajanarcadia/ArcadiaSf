public with sharing class UtilityCredentialSelector extends Selector {
    public UtilityCredentialSelector() {
        this(true, true, true);
    }

    public UtilityCredentialSelector(Boolean enforceCRUD, Boolean enforceFLS, Boolean enforceShr) {
        super(Schema.UtilityCredential__c.SObjectType, enforceCRUD, enforceFLS, enforceShr);
    }

    /**
     * Returns a Set that has all of the default fields.
     * @return   Set of Strings that contain the default fields for this object
     */
    public override Set<String> getDefaultFields() {
        Set<String> defaultFields = new Set<String>{
            'Id',
            'Name',
            'CorrelationID__c',
            'CreatedByInUrjanet__c',
            'CreatedDateInUrjanet__c',
            'Enabled__c',
            'LastModifiedByInUrjanet__c',
            'LastModifiedInUrjanet__c',
            'LastUrjanetSyncDateTime__c',
            'NextScheduledRun__c',
            'Status__c',
            'StatusDetail__c',
            'urjanetId__c',
            'Username__c',
            'Username2__c',
            'Username3__c',
            'Username4__c',
            'ProviderName__c',
            'ArcadiaServiceProviderId__c'
        };
        return defaultFields;
    }

    /**
     * Gets UtilityCredential records that need the details synced from Urjanet
     * @return Database.QueryLocator
     */
    public Database.QueryLocator getRecordsForCredentialSyncBatch() {
        Map<String, Object> params = new Map<String, Object>();

        String query = getDefaultQuery();
        query += ' WHERE CorrelationID__c != null';

        return Data.Locator(query, params, this.isEnforcingCRUD(), this.isEnforcingFLS(), this.isEnforcingShr());
    }

    public List<UtilityCredential__c> getUtilityCredentialsByIds(Set<Id> setCredentialIds) {
        List<String> queryFields = new List<String>(this.getDefaultFields());

        Map<String, Object> queryArgs = new Map<String, Object>{ 'setCredentialIds' => setCredentialIds };

        String query =
            'SELECT ' +
            String.join(queryFields, ', ') +
            ' FROM UtilityCredential__c' +
            ' WHERE Id IN :setCredentialIds';

        return new List<UtilityCredential__c>(
            (List<UtilityCredential__c>) Data.read(
                query,
                queryArgs,
                this.isEnforcingCRUD(),
                this.isEnforcingFLS(),
                this.isEnforcingShr()
            )
        );
    }

    public List<UtilityCredential__c> getAllUtilityCredentials() {
        List<String> queryFields = new List<String>(this.getDefaultFields());
        Map<String, Object> queryArgs = new Map<String, Object>{};

        String query = 'SELECT ' + String.join(queryFields, ', ') + ' FROM UtilityCredential__c';

        return new List<UtilityCredential__c>(
            (List<UtilityCredential__c>) Data.read(
                query,
                queryArgs,
                this.isEnforcingCRUD(),
                this.isEnforcingFLS(),
                this.isEnforcingShr()
            )
        );
    }

    public List<UtilityCredential__c> getCredentialAndRelatedAccounts(String credentialId, String actionParamter) {
        String query =
            'SELECT Id, UrjanetId__c, (SELECT Id FROM UtilityAccounts__r)' +
            ' FROM UtilityCredential__c' +
            ' WHERE' +
            (actionParamter == UrjanetConstants.DELETE_IN_BOTH
                ? ' UrjanetId__c = :credentialId'
                : ' Id =:credentialId');
        Map<String, Object> queryArgs = new Map<String, Object>{ 'credentialId' => credentialId };
        return new List<UtilityCredential__c>(
            (List<UtilityCredential__c>) Data.read(
                query,
                queryArgs,
                this.isEnforcingCRUD(),
                this.isEnforcingFLS(),
                this.isEnforcingShr()
            )
        );
    }
}
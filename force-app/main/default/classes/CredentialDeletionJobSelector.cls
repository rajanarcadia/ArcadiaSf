public with sharing class CredentialDeletionJobSelector extends Selector {
    public CredentialDeletionJobSelector() {
        this(true, true, true);
    }
    public CredentialDeletionJobSelector(Boolean enforceCRUD, Boolean enforceFLS, Boolean enforceShr) {
        super(Schema.Credential_Deletion_Log__c.SObjectType, enforceCRUD, enforceFLS, enforceShr);
    }

    /**
     * Returns a Set that has all of the default fields.
     * @return   Set of Strings that contain the default fields for this object
     */
    public override Set<String> getDefaultFields() {
        Set<String> defaultFields = new Set<String>{
            'Id',
            'Name',
            'Credential_Id__c',
            'Deletion_Log_Id__c',
            'Error_Message__c',
            'Status__c'
        };
        return defaultFields;
    }

    /**
     * Gets UtilityCredential records that need the details synced from Urjanet
     * @return Database.QueryLocator
     */
    public Database.QueryLocator getRecordsForCredentialDeletionLogBatch() {
        Map<String, Object> params = new Map<String, Object>();

        String query = getDefaultQuery();
        query += ' WHERE Status__c = \'In Progress\'';
        return Data.Locator(query, params, this.isEnforcingCRUD(), this.isEnforcingFLS(), this.isEnforcingShr());
    }

    /**
     * Gets CredentialDeletion record based on Deletion LogID
     * @return Credential_Deletion_Log__c
     */
    public List<Credential_Deletion_Log__c> getCredentialDeletionLogBasedonDeletionLogId(String deletionLog) {
        String query = getDefaultQuery();
        query += ' WHERE Deletion_Log_Id__c = :deletionLog limit 1';
        Map<String, Object> queryArgs = new Map<String, Object>{ 'deletionLog' => deletionLog };
        return new List<Credential_Deletion_Log__c>(
            (List<Credential_Deletion_Log__c>) Data.read(
                query,
                queryArgs,
                this.isEnforcingCRUD(),
                this.isEnforcingFLS(),
                this.isEnforcingShr()
            )
        );
    }
}
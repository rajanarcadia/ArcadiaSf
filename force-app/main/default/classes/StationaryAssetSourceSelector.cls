public with sharing class StationaryAssetSourceSelector extends Selector {
    public StationaryAssetSourceSelector() {
        super(Schema.StnryAssetEnvrSrc.SObjectType);
    }

    public StationaryAssetSourceSelector(Boolean enforceCRUD, Boolean enforceFLS, Boolean enforceShr) {
        super(Schema.StnryAssetEnvrSrc.SObjectType, enforceCRUD, enforceFLS, EnforceShr);
    }

    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'Name',
            'City',
            'Country',
            'State',
            'StreetAddress',
            'StreetAddress2',
            'StationaryAssetType',
            'PostalCode',
            'UrjanetSiteCode__c',
            'UrjanetSiteNumber__c',
            'BusinessRegion',
            'UrjanetSubRegion__c',
            'UrjanetId__c'
        };
    }

    /**
     * Gets Stationary asset source records that need the details synced to Urjanet
     * @return Stationary Asset Sources
     */
    public List<StnryAssetEnvrSrc> getRecordsToCreateSites() {
        Map<String, Object> params = new Map<String, Object>();

        String query = getDefaultQuery();
        query += ' WHERE UrjanetId__c = null AND Name != null';

        return new List<StnryAssetEnvrSrc>(
            (List<StnryAssetEnvrSrc>) Data.read(
                query,
                params,
                this.isEnforcingCRUD(),
                this.isEnforcingFLS(),
                this.isEnforcingShr()
            )
        );
    }
}
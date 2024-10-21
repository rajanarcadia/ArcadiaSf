@namespaceAccessible
public with sharing class StationaryAssetSourceService {
    @TestVisible
    @namespaceAccessible
    public static void upsertSiteList(List<StnryAssetEnvrSrc> stationaryAssetRecords) {
        if (!stationaryAssetRecords.isEmpty()) {
            try {
                // This will be running as a system process that should complete
                // no matter who kicked it off
                Database.DMLOptions option = new Database.DMLOptions();
                option.OptAllOrNone = false;
                Logger.getInstance()
                    .log(
                        StationaryAssetSourceService.class.getName(),
                        UrjanetUtils.getSObjectName(Schema.StnryAssetEnvrSrc.SObjectType),
                        Data.upsurt(
                            stationaryAssetRecords,
                            Schema.StnryAssetEnvrSrc.fields.UrjanetId__c,
                            option,
                            false,
                            false,
                            false,
                            null
                        )
                    );
            } catch (DmlException e) {
                Logger.getInstance(false).log(StationaryAssetSourceService.class.getName(), e);
            }
        }
    }

    @namespaceAccessible
    public static void updateSiteDetailsFromResponse(PostSiteResponse site, Id siteId) {
        try {
            StnryAssetEnvrSrc stationaryAsset = toObject(site);
            stationaryAsset.Id = siteId;
            // This will be running as a system process that should complete
            // no matter who kicked it off
            Database.DMLOptions option = new Database.DMLOptions();
            option.OptAllOrNone = false;
            Logger.getInstance()
                .log(
                    StationaryAssetSourceService.class.getName(),
                    UrjanetUtils.getSObjectName(Schema.StnryAssetEnvrSrc.SObjectType),
                    Data.upsurt(
                        new List<sObject>{ stationaryAsset },
                        Schema.StnryAssetEnvrSrc.fields.UrjanetId__c,
                        option,
                        false,
                        false,
                        false,
                        null
                    )
                );
            updateMeterSiteLink(stationaryAsset);
        } catch (DmlException e) {
            Logger.getInstance(false).log(StationaryAssetSourceService.class.getName(), e);
        }
    }

    private static void updateMeterSiteLink(StnryAssetEnvrSrc stationaryAsset) {
        List<UtilityMeter__c> meters = [
            SELECT Id, StationaryAssetEnvironmentalSource__c
            FROM UtilityMeter__c
            WHERE StationaryAssetEnvironmentalSource__c = :stationaryAsset.Id
        ];
        if (meters != null && !meters.isEmpty()) {
            // Create queue to hit API for Meter Site Link Update
            List<Database.SaveResult> saveResults = new QueueItemsBuilder(meters, SiteUpdateProcessor.class)
                .buildQueueItemsPerRecord()
                .createRecords();
            UrjanetUtils.logFailures(
                UtilityMeterService.class.getName(),
                String.valueOf(UtilityMeter__c.SObjectType),
                saveResults
            );
        }
    }

    @TestVisible
    private static StnryAssetEnvrSrc toObject(PostSiteResponse site) {
        StnryAssetEnvrSrc stationaryAssetSrc = new StnryAssetEnvrSrc();
        stationaryAssetSrc.CreatedDateInUrjanet__c = UrjanetUtils.getDateTime(site.createdDate);
        stationaryAssetSrc.CreatedByInUrjanet__c = site.createdBy;
        stationaryAssetSrc.LastModifiedInUrjanet__c = UrjanetUtils.getDateTime(site.lastModifiedDate);
        stationaryAssetSrc.LastModifiedByInUrjanet__c = site.lastModifiedBy;
        stationaryAssetSrc.UrjanetId__c = site.entityId;
        stationaryAssetSrc.LastUrjanetSyncDateTime__c = Datetime.now();
        return stationaryAssetSrc;
    }

    //default constructor
    @namespaceAccessible
    public StationaryAssetSourceService() {
    }

    @AuraEnabled
    public static void createQueueItemsToSendStationaryAssetSource() {
        // This will be running as a system process that should complete
        // no matter who kicked it off
        Logger.getInstance(false)
            .log(StationaryAssetSourceService.class.getName(), Logger.Level.INFO, 'Push Sites process Started');
        List<StnryAssetEnvrSrc> sitesToCreate = (List<StnryAssetEnvrSrc>) new StationaryAssetSourceSelector(
                false,
                false,
                false
            )
            .getRecordsToCreateSites();
        List<Database.SaveResult> saveResults = new QueueItemsBuilder(sitesToCreate, SiteCreateProcessor.class)
            .buildQueueItemsPerRecord()
            .createRecords();
        UrjanetUtils.logFailures(
            StationaryAssetSourceService.class.getName(),
            String.valueOf(StnryAssetEnvrSrc.SObjectType),
            saveResults
        );
        Logger.getInstance(false)
            .log(
                StationaryAssetSourceService.class.getName(),
                Logger.Level.INFO,
                'QueueItems Successfully Created for Sites Processing'
            );
    }

    @namespaceAccessible
    public static String mapToSalesforceCountryCode(String countryCode) {
        String countryValue = countryCode;
        if (countryCode != null) {
            Map<String, CountryCodeMapping__mdt> countryMap = CountryCodeMapping__mdt.getAll();

            for (String nameCountry : countryMap.keySet()) {
                if (
                    countryCode.length() == 3 &&
                    countryCode.toUpperCase() == countryMap.get(nameCountry).CountryCode3Digit__c.toUpperCase()
                ) {
                    countryValue = countryMap.get(nameCountry).CountryCode2Digit__c;
                    break;
                }
            }
        }
        return countryValue;
    }

    @namespaceAccessible
    public static String mapToUrjanetCountryCode(String countryCode) {
        String countryValue = countryCode;

        if (countryCode != null) {
            Map<String, CountryCodeMapping__mdt> countryMap = CountryCodeMapping__mdt.getAll();
            for (String nameCountry : countryMap.keySet()) {
                if (
                    countryCode.length() == 2 &&
                    countryCode.toUpperCase() == countryMap.get(nameCountry).CountryCode2Digit__c.toUpperCase()
                ) {
                    countryValue = countryMap.get(nameCountry).CountryCode3Digit__c;
                    break;
                }
            }
        }
        return countryValue;
    }
}
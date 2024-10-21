@namespaceAccessible
public with sharing class UtilityMeterService {
    @namespaceAccessible
    public static void createQueueItemsForUtilityMeters(List<UtilityMeter__c> records) {
        createQueueItemsForUtilityMeters(records, null);
    }

    @namespaceAccessible
    public static void createQueueItemsForUtilityMeters(
        List<UtilityMeter__c> records,
        Map<Id, UtilityMeter__c> oldMap
    ) {
        List<UtilityMeter__c> updatedMeters = getMetersToRefresh(records, oldMap);
        Type processorClass = QueueItemProcessorFactory.getProcessorType(UtilityMeter__c.SObjectType);
        List<Database.SaveResult> saveResults = new QueueItemsBuilder(updatedMeters, processorClass)
            .buildQueueItemsPerRecord()
            .createRecords();
        UrjanetUtils.logFailures(
            UtilityMeterService.class.getName(),
            String.valueOf(UtilityMeter__c.SObjectType),
            saveResults
        );
    }

    @TestVisible
    private static List<UtilityMeter__c> getMetersToRefresh(
        List<UtilityMeter__c> records,
        Map<Id, UtilityMeter__c> oldMap
    ) {
        List<UtilityMeter__c> updatedUtilityMeters = new List<UtilityMeter__c>();
        if (oldMap == null) {
            for (UtilityMeter__c meter : records) {
                //bypassing meters with empty siteid
                if (meter != null  && meter.Enabled__c  && meter.StationaryAssetEnvironmentalSource__c != null) {
                    updatedUtilityMeters.add(meter);
                }
            }
        } else {
            SObjectField syncField = UtilityMeter__c.LastUrjanetSyncDateTime__c;
            for (UtilityMeter__c meter : records) {
                //bypassing meters with empty siteid
                if (meter != null  && meter.Enabled__c
                    && meter.StationaryAssetEnvironmentalSource__c != null) {
                    updatedUtilityMeters.add(meter);
                }
            }
        }
        return updatedUtilityMeters;
    }

    //Since Trigger Context Does not Hold the loop up data Querying additonally
    @namespaceAccessible
    public static List<UtilityMeter__c> queryRelatedDataOfUtilityMeters(List<UtilityMeter__c> records) {
        List<UtilityMeter__c> utilityMetersWithRelatedData = [
            SELECT
                Id,
                StationaryAssetEnvironmentalSource__c,
                LastUrjanetSyncDateTime__c,
                StationaryAssetEnvironmentalSource__r.UrjanetId__c,
                Enabled__c
            FROM UtilityMeter__c
            WHERE Id IN :records
        ];
        return utilityMetersWithRelatedData;
    }

    @namespaceAccessible
    public static List<UtilityMeter__c> createMeterFromDataResponse(GetMetersByAccountResponse response) {
        List<UtilityMeter__c> meterRecords = new List<UtilityMeter__c>();
        if (response != null && response.embedded != null && response.embedded.meters != null) {
            for (GetMetersByAccountResponse.Meter meter : response.embedded.meters) {
                UtilityMeter__c utilityMeter = toObject(meter);
                meterRecords.add(utilityMeter);
            }
        }
        return meterRecords;
    }

    @TestVisible
    @namespaceAccessible
    public static void upsertMeterList(List<UtilityMeter__c> meterRecords) {
        if (!meterRecords.isEmpty()) {
            try {
                // This will be running as a system process that should complete
                // no matter who kicked it off
                Database.DMLOptions option = new Database.DMLOptions();
                option.OptAllOrNone = false;
                Logger.getInstance()
                    .log(
                        UtilityMeterService.class.getName(),
                        UrjanetUtils.getSObjectName(Schema.UtilityMeter__c.SObjectType),
                        Data.upsurt(
                            meterRecords,
                            Schema.UtilityMeter__c.fields.UrjanetId__c,
                            option,
                            false,
                            false,
                            false,
                            null
                        )
                    );
            } catch (DmlException e) {
                Logger.getInstance(false).log(UtilityMeterService.class.getName(), e);
            }
        }
    }

    @TestVisible
    @namespaceAccessible
    public static void upsertMeterListForAccountProcessed(
        List<UtilityMeter__c> metersByAccountList,
        UtilityAccount__c accountToProcess
    ) {
        if (!metersByAccountList.isEmpty()) {
            try {
                // This will be running as a system process that should complete
                // no matter who kicked it off
                Database.DMLOptions option = new Database.DMLOptions();
                option.OptAllOrNone = false;
                Logger.getInstance()
                    .log(
                        UtilityMeterService.class.getName(),
                        UrjanetUtils.getSObjectName(Schema.UtilityMeter__c.SObjectType),
                        Data.upsurt(
                            metersByAccountList,
                            Schema.UtilityMeter__c.fields.UrjanetId__c,
                            option,
                            false,
                            false,
                            false,
                            null
                        )
                    );
                List<Utility_Account_Meter_Relation__c> accountMeterRecords = new List<Utility_Account_Meter_Relation__c>();
                for (UtilityMeter__c utilityMeter : metersByAccountList) {
                    Utility_Account_Meter_Relation__c accountMeter = new Utility_Account_Meter_Relation__c();
                    accountMeter.Utility_Account__c = accountToProcess.Id;
                    accountMeter.Utility_Meter__c = utilityMeter.Id;
                    accountMeterRecords.add(accountMeter);
                }
                try {
                    insert accountMeterRecords;
                } catch (Exception e) {
                    if (!e.getMessage().contains('DUPLICATE_VALUE')) {
                        Logger.getInstance(false).log(UtilityMeterService.class.getName(), e);
                        // No need for Logs in case of duplicate records
                    }
                }
            } catch (DmlException e) {
                Logger.getInstance(false).log(UtilityMeterService.class.getName(), e);
            }
        }
    }

    @TestVisible
    private static UtilityMeter__c toObject(GetMetersByAccountResponse.Meter meter) {
        UtilityMeter__c utilityMeter = new UtilityMeter__c();
        utilityMeter.UrjanetId__c = meter.entityId;
        utilityMeter.BulbType__c = meter.bulbType;
        utilityMeter.CreatedDateInUrjanet__c = UrjanetUtils.getDateTime(meter.createdDate);
        utilityMeter.CreatedByInUrjanet__c = meter.createdBy;
        utilityMeter.LastModifiedInUrjanet__c = UrjanetUtils.getDateTime(meter.lastModifiedDate);
        utilityMeter.LastModifiedByInUrjanet__c = meter.lastModifiedBy;
        utilityMeter.MeterStatus__c = meter.meterStatus;
        utilityMeter.NextExpectedPostDate__c = (meter.nextExpectedPostDate == null
            ? null
            : Date.valueOf(meter.nextExpectedPostDate));
        utilityMeter.MeterNumber__c = meter.normalizedMeterNumber;
        utilityMeter.PodNumber__c = meter.normalizedPodNumber;
        utilityMeter.PreviousMeterNumber__c = meter.normalizedPreviousMeterNumber;
        utilityMeter.PipeType__c = meter.pipeType;
        utilityMeter.ServiceDescription__c = meter.serviceDescription;
        utilityMeter.ServiceType__c = meter.serviceType;
        utilityMeter.City__c = meter.serviceAddress?.city;
        utilityMeter.Country__c = StationaryAssetSourceService.mapToSalesforceCountryCode(
            meter.serviceAddress?.country
        );
        utilityMeter.PostalCode__c = meter.serviceAddress?.postalCode;
        utilityMeter.State__c = meter.serviceAddress?.state;
        utilityMeter.StreetLine1__c = meter.serviceAddress?.streetLine1;
        utilityMeter.StreetLine2__c = meter.serviceAddress?.streetLine2;
        utilityMeter.Name = meter.normalizedMeterNumber;
        utilityMeter.LastUrjanetSyncDateTime__c = Datetime.now();
        utilityMeter.ProviderName__c = meter.providerName;
        utilityMeter.ProviderId__c = meter.provider.entityId;
        return utilityMeter;
    }

    @namespaceAccessible
    public static void createQueueItemsForSiteUpdate(List<UtilityMeter__c> records) {
        createQueueItemsForSiteUpdate(records, null);
    }

    @namespaceAccessible
    public static void createQueueItemsForSiteUpdate(List<UtilityMeter__c> records, Map<Id, UtilityMeter__c> oldMap) {
        List<UtilityMeter__c> updatedMeters = getMetersToUpdateSite(records, oldMap);
        if (updatedMeters != null && !updatedMeters.isEmpty()) {
            List<Database.SaveResult> saveResults = new QueueItemsBuilder(updatedMeters, SiteUpdateProcessor.class)
                .buildQueueItemsPerRecord()
                .createRecords();
            UrjanetUtils.logFailures(
                UtilityMeterService.class.getName(),
                String.valueOf(UtilityMeter__c.SObjectType),
                saveResults
            );
        }
    }

    @namespaceAccessible
    public static List<UtilityMeter__c> getMetersToUpdateSite(
        List<UtilityMeter__c> records,
        Map<Id, UtilityMeter__c> oldMap
    ) {
        List<UtilityMeter__c> meterList = new List<UtilityMeter__c>();
        List<UtilityMeter__c> recordsWithLookUpData = queryRelatedDataOfUtilityMeters(records);
        SObjectField syncField = UtilityMeter__c.StationaryAssetEnvironmentalSource__c;
        for (UtilityMeter__c meter : recordsWithLookUpData) {
            if (
                meter != null &&
                meter.Enabled__c &&
                meter.StationaryAssetEnvironmentalSource__c != null &&
                UrjanetUtils.hasSyncFieldUpdated(meter, oldMap, syncField)
            ) {
                if (meter.StationaryAssetEnvironmentalSource__r.UrjanetId__c != null) {
                    meterList.add(meter);
                } else {
                    // UrjanetId__c is null means Site is not yet pushed.
                    // create All sites and link meters to them at Arcadia.
                    StationaryAssetSourceService.createQueueItemsToSendStationaryAssetSource();
                }
            }
        }
        return meterList;
    }

    @namespaceAccessible
    public static void processUtilityMeterQueue(QueueItem__c queueItem) {
        // Get most recent meter usage record related to meter by periodEndDate
        /*List<UtilityMeterUsage__c> mostRecentMeterUsage =
            new UtilityMeterUsageSelector().getMostRecentUtilityMeterUsageForMeter(meterToProcess.Id);
         */
        // We want to be able to filter records retrieved from the endpoint by periodStart
        // as of now that's not possible.

        // Get usage data from urjanet
        UtilityMeter__c meterToProcess = (UtilityMeter__c) new UtilityMeterSelector(false, false, false)
            .getRecordById(queueItem.RecordId__c);

        String pageSize = UrjanetUtils.getAPIPageSize();
        String pageNumber = (queueItem.PageNumber__c == null
            ? '0'
            : String.valueOf(Integer.valueOf(queueItem.PageNumber__c)));

        List<String> requestParams = new List<String>{ meterToProcess.UrjanetId__c, pageSize, pageNumber };

        if (
            queueItem.RequestType__c == null ||
            queueItem.RequestType__c == UrjanetEnums.RequestType.RETRIEVE_METER_DETAILS.name()
        ) {
            RetrieveMeterDetailsResponse response = (RetrieveMeterDetailsResponse) new UrjanetApiClient()
                .getUrjanetResponse(
                    UrjanetEnums.RequestType.RETRIEVE_METER_DETAILS,
                    UrjanetEnums.ApiMethod.GET,
                    requestParams
                );
            if (response.errorMsg != null) {
                UrjanetUtils.handleApiError(
                    queueItem,
                    response.errorMsg,
                    response.message,
                    response.status,
                    UtilityMeterProcessor.class.getName()
                );
            } else {
                // write UtilityMeterUsage__c records
                Set<String> staleDataToBeDeletedSet = new Set<String>();
                if (queueItem.StaleDataIdsList__c != null) {
                    staleDataToBeDeletedSet.addAll(
                        (Set<String>) JSON.deserialize(queueItem.StaleDataIdsList__c, Set<String>.class)
                    );
                }
                UtilityMeterUsageService.createMeterUsageFromMeterDataResponse(
                    response,
                    meterToProcess,
                    pageNumber,
                    staleDataToBeDeletedSet
                );
                //check if needed for pagination to create queue items for the other pages
                UrjanetUtils.createPaginationQueueItemFromAPIResponse(
                    response.page,
                    meterToProcess.Id,
                    UrjanetEnums.RequestType.RETRIEVE_METER_DETAILS.name(),
                    QueueItemProcessorFactory.getProcessorType(UtilityMeter__c.SObjectType),
                    Double.valueOf(pageNumber) + 1,
                    staleDataToBeDeletedSet
                );
            }
        }
    }
}
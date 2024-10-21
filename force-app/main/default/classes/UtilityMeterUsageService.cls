@namespaceAccessible
public with sharing class UtilityMeterUsageService {
    @namespaceAccessible
    public static void createMeterUsageFromMeterDataResponse(
        RetrieveMeterDetailsResponse response,
        UtilityMeter__c parentMeter,
        String pageNo,
        Set<String> staleDataToBeDeletedSet
    ) {
        String meterId = parentMeter.UrjanetId__c;

        List<UtilityMeterUsage__c> usageRecords = new List<UtilityMeterUsage__c>();

        if (response != null && response.embedded != null) {
            // get all the meter usages for the meter
            List<UtilityMeterUsage__c> availableMeterUsagesData = [
                SELECT
                    UrjanetId__c,
                    LastModifiedInUrjanet__c,
                    PeriodStart__c,
                    MeasuredUsage__c,
                    PeriodEnd__c,
                    UtilityMeter__r.ServiceType__c,
                    Id
                FROM UtilityMeterUsage__c
                WHERE UtilityMeter__r.UrjanetId__c = :meterId
            ];
            Map<string, DateTime> availableMeterUsageIdDateMap = new Map<string, DateTime>();
            Set<string> arcadiaMeterUsageIds = new Set<string>();
            Map<string, UtilityMeterUsage__c> availableUsageRecordsToCheckDuplicatesMap = new Map<string, UtilityMeterUsage__c>();
            Map<string, UtilityMeterUsage__c> arcadiaUsageRecordsToCheckDuplicatesMap = new Map<string, UtilityMeterUsage__c>();

            // add all the available meter usage ids and last sync date to a Map
            for (UtilityMeterUsage__c meterUsage : availableMeterUsagesData) {
                availableMeterUsageIdDateMap.put(meterUsage.UrjanetId__c, meterUsage.LastModifiedInUrjanet__c);
                availableUsageRecordsToCheckDuplicatesMap.put(createUniqeKeyForMeterUsage(meterUsage), meterUsage);
            }

            for (RetrieveMeterDetailsResponse.Meter meter : response.embedded.meters) {
                RetrieveMeterDetailsResponse.Usage totalUsage = getTotalUsageObject(meter);

                if (totalUsage != null) {
                    string usageId = totalUsage.entityId;
                    // create new meter usages if they are not present in the system
                    Boolean addUsage = !availableMeterUsageIdDateMap.containsKey(usageId);
                    Boolean updateUsageRecord = false;
                    arcadiaMeterUsageIds.add(usageId);
                    // update meter usages if they are present in the system and have been updated in Odin
                    if (
                        !addUsage &&
                        totalUsage.lastModifiedDate != null &&
                        UrjanetUtils.getDateTime(totalUsage.lastModifiedDate) >
                        availableMeterUsageIdDateMap.get(usageId)
                    ) {
                        updateUsageRecord = true;
                    }
                    if (addUsage || updateUsageRecord) {
                        UtilityMeterUsage__c generatedMeterUse = toObject(totalUsage, meter);
                        generatedMeterUse.UtilityMeter__r = new UtilityMeter__c(UrjanetId__c = meterId);
                        // verify and add the meter usage to the list only if it is not a duplicate
                        // from the response and the available meter usage data
                        if (
                            (updateUsageRecord ||
                            !isDuplicateRecord(generatedMeterUse, availableUsageRecordsToCheckDuplicatesMap)) &&
                            !isDuplicateRecord(generatedMeterUse, arcadiaUsageRecordsToCheckDuplicatesMap)
                        ) {
                            usageRecords.add(generatedMeterUse);
                            arcadiaUsageRecordsToCheckDuplicatesMap.put(
                                createUniqeKeyForMeterUsage(generatedMeterUse),
                                generatedMeterUse
                            );
                        }
                    }
                }
            }
            staleDataToBeDeletedSet.addAll(arcadiaMeterUsageIds);
            // reached the last page of the response so delete the stale data
            if (Integer.valueOf(pageNo) == (response.page.totalPages - 1)) {
                if (!usageRecords.isEmpty()) {
                    availableMeterUsagesData.addAll(usageRecords);
                }

                List<String> growthUsageRecordIDsToDeleteList = new List<String>();
                List<String> baseUsageRecordIDsToDeleteList = new List<String>();
                for (UtilityMeterUsage__c meterUsage : availableMeterUsagesData) {
                    if (meterUsage.Id != null && !staleDataToBeDeletedSet.contains(meterUsage.UrjanetId__c)) {
                        if (UrjanetConstants.growthServiceTypes.contains(meterUsage.UtilityMeter__r.ServiceType__c)) {
                            growthUsageRecordIDsToDeleteList.add(meterUsage.Id);
                        } else if (
                            !UrjanetConstants.growthServiceTypes.contains(meterUsage.UtilityMeter__r.ServiceType__c)
                        ) {
                            baseUsageRecordIDsToDeleteList.add(meterUsage.Id);
                        }
                    }
                }
                if (!baseUsageRecordIDsToDeleteList.isEmpty() || !growthUsageRecordIDsToDeleteList.isEmpty()) {
                    UrjanetUtils.deleteMeterUsagesAndDownStreamData(
                        baseUsageRecordIDsToDeleteList,
                        growthUsageRecordIDsToDeleteList
                    );
                }
                staleDataToBeDeletedSet.clear();
            }
        }
        if (!usageRecords.isEmpty()) {
            try {
                // This will be running as a system process that should complete
                // no matter who kicked it off
                Database.DMLOptions option = new Database.DMLOptions();
                option.OptAllOrNone = false;
                Logger.getInstance(false)
                    .log(
                        UtilityMeterUsageService.class.getName(),
                        UrjanetUtils.getSObjectName(Schema.UtilityMeterUsage__c.SObjectType),
                        Data.upsurt(
                            usageRecords,
                            Schema.UtilityMeterUsage__c.fields.UrjanetId__c,
                            option,
                            false,
                            false,
                            false,
                            null
                        )
                    );
            } catch (DmlException e) {
                Logger.getInstance(false).log(UtilityMeterUsageService.class.getName(), e);
            }
        }
    }

    private static string createUniqeKeyForMeterUsage(UtilityMeterUsage__c usage) {
        return (usage.PeriodStart__c).format() + string.valueOf(usage.MeasuredUsage__c.setScale(3));
    }

    @TestVisible
    private static Boolean isDuplicateRecord(UtilityMeterUsage__c usage, Map<string, UtilityMeterUsage__c> usageMap) {
        String uniqueKey = createUniqeKeyForMeterUsage(usage);
        UtilityMeterUsage__c existingUsage = usageMap.get(uniqueKey);
        if (
            null != existingUsage &&
            (existingUsage.PeriodEnd__c == usage.PeriodEnd__c ||
            existingUsage.PeriodEnd__c.addDays(1) == usage.PeriodEnd__c ||
            existingUsage.PeriodEnd__c.addDays(-1) == usage.PeriodEnd__c)
        ) {
            return true;
        }
        return false;
    }

    @TestVisible
    private static UtilityMeterUsage__c toObject(
        RetrieveMeterDetailsResponse.Usage usage,
        RetrieveMeterDetailsResponse.Meter meter
    ) {
        UtilityMeterUsage__c meterUsage = new UtilityMeterUsage__c();
        meterUsage.UrjanetId__c = usage.entityId;
        meterUsage.CitedUsage__c = usage.citedUsage;
        meterUsage.ContributionStatus__c = usage.contributionStatus;
        meterUsage.CreatedDateInUrjanet__c = usage.createdDate == null
            ? null
            : UrjanetUtils.getDateTime(usage.createdDate);
        meterUsage.MeasuredUsage__c = usage.measuredUsage;
        meterUsage.MeasurementType__c = usage.measurementType;
        meterUsage.UsageUnit__c = usage.usageUnit;
        meterUsage.PeriodStart__c = (meter.periodStart == null ? null : Date.valueOf(meter.periodStart));
        meterUsage.PeriodEnd__c = (meter.periodEnd == null ? null : Date.valueOf(meter.periodEnd));
        meterUsage.Name = meter.meterNumber + ' - ' + meter.periodStart + ' - ' + meter.periodEnd;
        meterUsage.LastUrjanetSyncDateTime__c = Datetime.now();
        meterUsage.LastModifiedInUrjanet__c = usage.lastModifiedDate == null
            ? null
            : UrjanetUtils.getDateTime(usage.lastModifiedDate);
        meterUsage.DeregulationStatus__c = meter.deregulationStatus;
        meterUsage.AccountType__c = meter.accountType;
        meterUsage.Arcadia_Statement_ID__c = meter.statementId;
        meterUsage.Arcadia_Statement_Date__c = (meter.statementDate == null ? null : Date.valueOf(meter.statementDate));
        return meterUsage;
    }

    @namespaceAccessible
    public static void createQueueItemsForUtilityMeterUsages(List<UtilityMeterUsage__c> records) {
        createQueueItemsForUtilityMeterUsages(records, null);
    }

    @namespaceAccessible
    public static void createQueueItemsForUtilityMeterUsages(
        List<UtilityMeterUsage__c> records,
        Map<Id, UtilityMeterUsage__c> oldMap
    ) {
        List<UtilityMeterUsage__c> updatedMeterUsages = getMeterUsagesToRefresh(records, oldMap);
        Type processorClass = QueueItemProcessorFactory.getProcessorType(UtilityMeterUsage__c.SObjectType);
        List<Database.SaveResult> saveResults = new QueueItemsBuilder(updatedMeterUsages, processorClass)
            .buildQueueItemsPerRecord()
            .createRecords();
        UrjanetUtils.logFailures(
            UtilityMeterUsageService.class.getName(),
            String.valueOf(UtilityMeterUsage__c.SObjectType),
            saveResults
        );
    }

    @namespaceAccessible
    public static void createQueueItemstoUpdateUtilityMeterUsages(
        List<UtilityMeterUsage__c> records,
        Map<Id, UtilityMeterUsage__c> oldMap
    ) {
        List<UtilityMeterUsage__c> updatedMeterUsages = getMeterUsagesToUpdate(records, oldMap);
        if (updatedMeterUsages.isEmpty()) {
            // No need to create queue items if there are no records to update
            return;
        }

        List<Database.SaveResult> saveResults = new QueueItemsBuilder(
                updatedMeterUsages,
                UtilityMeterUsageUpdateProcessor.class
            )
            .buildQueueItemsPerRecord()
            .createRecords();
        UrjanetUtils.logFailures(
            UtilityMeterUsageService.class.getName(),
            String.valueOf(UtilityMeterUsage__c.SObjectType),
            saveResults
        );
    }

    @TestVisible
    private static List<UtilityMeterUsage__c> getMeterUsagesToRefresh(
        List<UtilityMeterUsage__c> records,
        Map<Id, UtilityMeterUsage__c> oldMap
    ) {
        List<UtilityMeterUsage__c> updatedUtilityMeterUsages = new List<UtilityMeterUsage__c>();
        if (oldMap == null) {
            updatedUtilityMeterUsages.addAll(records);
        } else {
            SObjectField syncField = UtilityMeterUsage__c.LastModifiedInUrjanet__c;
            for (UtilityMeterUsage__c meterUsage : records) {
                if (UrjanetUtils.hasSyncFieldUpdated(meterUsage, oldMap, syncField)) {
                    updatedUtilityMeterUsages.add(meterUsage);
                }
            }
        }
        return updatedUtilityMeterUsages;
    }

    @TestVisible
    private static List<UtilityMeterUsage__c> getMeterUsagesToUpdate(
        List<UtilityMeterUsage__c> records,
        Map<Id, UtilityMeterUsage__c> oldMap
    ) {
        List<UtilityMeterUsage__c> updatedUtilityMeterUsages = new List<UtilityMeterUsage__c>();
        if (oldMap == null) {
            return updatedUtilityMeterUsages;
        } else {
            for (UtilityMeterUsage__c meterUsage : records) {
                if (oldmap.containsKey(meterUsage.Id)) {
                    if (
                        (oldmap.get(meterUsage.Id).MeasuredUsage__c != meterUsage.MeasuredUsage__c ||
                        oldmap.get(meterUsage.Id).PeriodStart__c != meterUsage.PeriodStart__c ||
                        oldmap.get(meterUsage.Id).PeriodEnd__c != meterUsage.PeriodEnd__c ||
                        oldmap.get(meterUsage.Id).UsageUnit__c != meterUsage.UsageUnit__c) &&
                        !meterUsage.To_Be_Ignored__c
                    )
                        updatedUtilityMeterUsages.add(meterUsage);
                }
            }
        }

        return updatedUtilityMeterUsages;
    }

    @TestVisible
    private static RetrieveMeterDetailsResponse.Usage getTotalUsageObject(RetrieveMeterDetailsResponse.Meter meter) {
        RetrieveMeterDetailsResponse.Usage totalUsage;
        Boolean givePriorityToKWH = meterHasTwoTRCWithOneKWHAndOneKVarhUnit(meter);
        for (RetrieveMeterDetailsResponse.Usage usage : meter.usages) {
            if (
                null != usage.tariffRateComponents &&
                !usage.tariffRateComponents.isEmpty() &&
                null != usage.measuredUsage &&
                usage.measurementType == UrjanetConstants.GENERAL_CONSUMPTION &&
                (null == usage.contributionStatus ||
                usage.contributionStatus == UrjanetConstants.CONTRIBUTING)
            ) {
                for (RetrieveMeterDetailsResponse.TariffRateComponent rateComponent : usage.tariffRateComponents) {
                    if (rateComponent.tariffRateComponentType == UrjanetConstants.RATE_TYPE_TOTAL) {
                        totalUsage = usage;
                        if (givePriorityToKWH) {
                            if (usage.usageUnit == UrjanetConstants.KWH_UNIT) {
                                return totalUsage;
                            }
                            continue;
                        } else {
                            return totalUsage;
                        }
                    }
                }
            }
        }
        return totalUsage;
    }
    @namespaceAccessible
    public static Boolean meterHasTwoTRCWithOneKWHAndOneKVarhUnit(RetrieveMeterDetailsResponse.Meter meter) {
        Boolean hasKWHUnit = false;
        Boolean hasKVARHUnit = false;

        for (RetrieveMeterDetailsResponse.Usage usage : meter.usages) {
            if (
                null != usage.tariffRateComponents &&
                !usage.tariffRateComponents.isEmpty() &&
                null != usage.measuredUsage &&
                usage.measurementType == UrjanetConstants.GENERAL_CONSUMPTION &&
                (null == usage.contributionStatus ||
                usage.contributionStatus == UrjanetConstants.CONTRIBUTING) &&
                tRCIsTotal(usage.tariffRateComponents)
            ) {
                if (usage.usageUnit == UrjanetConstants.KWH_UNIT) {
                    hasKWHUnit = true;
                }
                if (usage.usageUnit == UrjanetConstants.KVARH_UNIT) {
                    hasKVARHUnit = true;
                }
                if (hasKVARHUnit && hasKWHUnit) {
                    return true;
                }
            }
        }
        return false;
    }
    @namespaceAccessible
    public static Boolean tRCIsTotal(List<RetrieveMeterDetailsResponse.TariffRateComponent> rateComponents) {
        for (RetrieveMeterDetailsResponse.TariffRateComponent rateComponent : rateComponents) {
            if (rateComponent.tariffRateComponentType == UrjanetConstants.RATE_TYPE_TOTAL) {
                return true;
            }
        }
        return false;
    }

    @namespaceAccessible
    public static void updateMeterUsage(List<UtilityMeter__c> utilityMeters) {
        Set<UtilityMeterUsage__c> meterUsageToUpdate = new Set<UtilityMeterUsage__c>();
        Set<Id> recordIDsToDeleteEnergy = new Set<Id>();
        Set<Id> recordIDsToDeleteWater = new Set<Id>();

        for (UtilityMeter__c meter : utilityMeters) {
            if (meter.Name == null || meter.UrjanetId__c == null) {
                continue;
            }
            List<String> requestParams = new List<String>{ meter.UrjanetId__c };
            RetrieveMeterDetailsResponse response = (RetrieveMeterDetailsResponse) new UrjanetApiClient()
                .getUrjanetResponse(
                    UrjanetEnums.RequestType.RETRIEVE_ALL_METER_DETAILS,
                    UrjanetEnums.ApiMethod.GET,
                    requestParams
                );

            if (response.errorMsg != null) {
                Logger.getInstance(false)
                    .log(
                        UtilityMeterUsageService.class.getName(),
                        Logger.Level.ERROR,
                        'Response for meter id: ' + meter.UrjanetId__c + ' is: ' + response
                    );
                continue;
            }
            if (response != null && response.embedded != null) {
                Map<String, Set<UtilityMeterUsage__c>> meterUsageMap = new Map<String, Set<UtilityMeterUsage__c>>();

                List<UtilityMeterUsage__c> allMeterUsages = [
                    SELECT
                        Id,
                        Name,
                        UtilityMeter__r.Id,
                        UtilityMeter__r.ServiceType__c,
                        PeriodStart__c,
                        PeriodEnd__c,
                        MeasuredUsage__c,
                        UrjanetId__c
                    FROM UtilityMeterUsage__c
                    WHERE UtilityMeter__r.Id = :meter.Id AND (AccountType__c = NULL OR DeregulationStatus__c = NULL)
                ];
                for (UtilityMeterUsage__c meterUsage : allMeterUsages) {
                    if (meterUsage.MeasuredUsage__c == null) {
                        if (UrjanetConstants.growthServiceTypes.contains(meterUsage.UtilityMeter__r.ServiceType__c)) {
                            recordIDsToDeleteWater.add(meterUsage.Id);
                        } else {
                            recordIDsToDeleteEnergy.add(meterUsage.Id);
                        }
                    }

                    String key = meterUsage.MeasuredUsage__c + ' - ' + meterUsage.PeriodStart__c;
                    if (!meterUsageMap.containsKey(key)) {
                        meterUsageMap.put(key, new Set<UtilityMeterUsage__c>());
                    }
                    meterUsageMap.get(key).add(meterUsage);
                }

                for (RetrieveMeterDetailsResponse.Meter meterResponse : response.embedded.meters) {
                    if (
                        meterResponse != null &&
                        meterResponse.usages != null &&
                        meterResponse.periodStart != null &&
                        meterResponse.periodEnd != null
                    ) {
                        RetrieveMeterDetailsResponse.Usage totalUsage = getTotalUsageObject(meterResponse);
                        if (totalUsage == null) {
                            continue;
                        }
                        String meterUsageName =
                            meterResponse.meterNumber +
                            ' - ' +
                            meterResponse.periodStart +
                            ' - ' +
                            meterResponse.periodEnd;

                        Decimal measuredUsage = totalUsage.measuredUsage;
                        measuredUsage = measuredUsage.setScale(3);

                        String startDateStr = meterResponse.periodStart;
                        Date startDate = Date.valueOf(startDateStr);

                        String endDateStr = meterResponse.periodEnd;
                        Date endDate = Date.valueOf(endDateStr);

                        String meterName = meter.Name;
                        String key = measuredUsage + ' - ' + startDate;

                        if (meterUsageMap.containsKey(key)) {
                            Set<UtilityMeterUsage__c> meterUsageList = meterUsageMap.get(key);
                            if (meterUsageList.size() > 1) {
                                List<Id> recordIDs = UrjanetUtils.getDuplicateMeterUsage(
                                    meterUsageList,
                                    measuredUsage,
                                    startDate,
                                    endDate
                                );
                                for (Id recordID : recordIDs) {
                                    if (
                                        recordID != null &&
                                        !recordIDsToDeleteEnergy.contains(recordID) &&
                                        !recordIDsToDeleteWater.contains(recordID)
                                    ) {
                                        if (UrjanetConstants.growthServiceTypes.contains(meter.ServiceType__c))
                                            recordIDsToDeleteWater.add(recordID);
                                        else
                                            recordIDsToDeleteEnergy.add(recordID);
                                    }
                                }
                            }
                            for (UtilityMeterUsage__c meterUsage : meterUsageList) {
                                if (
                                    !meterUsageToUpdate.contains(meterUsage) &&
                                    !recordIDsToDeleteEnergy.contains(meterUsage.Id) &&
                                    !recordIDsToDeleteWater.contains(meterUsage.Id) &&
                                    meterUsage.Name == meterUsageName
                                ) {
                                    meterUsage.DeregulationStatus__c = meterResponse.deregulationStatus;
                                    meterUsage.AccountType__c = meterResponse.accountType;
                                    meterUsageToUpdate.add(meterUsage);
                                }
                            }
                        }
                    }
                }
            }
        } // for loop
        if (!meterUsageToUpdate.isEmpty() || !recordIDsToDeleteWater.isEmpty() || !recordIDsToDeleteEnergy.isEmpty()) {
            List<UtilityMeterUsage__c> meterUsageToUpdateList = new List<UtilityMeterUsage__c>(meterUsageToUpdate);
            List<Id> recordIDsToDeleteWaterList = new List<Id>(recordIDsToDeleteWater);
            List<Id> recordIDsToDeleteEnergyList = new List<Id>(recordIDsToDeleteEnergy);
            UpdateMeterUsageQueue queueableJob = new UpdateMeterUsageQueue(
                meterUsageToUpdateList,
                recordIDsToDeleteEnergyList,
                recordIDsToDeleteWaterList
            );
            System.enqueueJob(queueableJob);
        }
    } // Method closed

    public static void deleteGrowthMeterUsages() {
        try {
            // Get all usages whose service type mappings are not present in base.
            List<UtilityMeterUsage__c> usages = [
                SELECT Id
                FROM UtilityMeterUsage__c
                WHERE
                    UtilityMeter__r.ServiceType__c NOT IN (
                        'electric',
                        'lighting',
                        'natural_gas',
                        'fuel_oil',
                        'propane',
                        'steam'
                    )
            ];
            // Water Stationary Assets will not be present in this case so no need to check for that
            if (usages.size() > 0) {
                Logger.getInstance(false)
                    .log(
                        UtilityMeterUsageService.class.getName(),
                        Logger.Level.INFO,
                        'Deleting ' + usages.size() + ' Growth Meter Usages as Growth Package is not present.'
                    );
                Data.remove(usages, false, false, false);
            }
        } catch (DmlException e) {
            Logger.getInstance()
                .log(
                    UtilityMeterUsageService.class.getName(),
                    Logger.Level.ERROR,
                    'Error in deleting Growth meter usages : ' + e.getMessage()
                );
        }
    }

    @namespaceAccessible
    public static void checkForMeterWithUsageIdNullAndDelete(List<UtilityMeter__c> meters) {
        try {
            List<UtilityMeterUsage__c> baseUsagesToDelete = [
                SELECT Id
                FROM UtilityMeterUsage__c
                WHERE
                    UtilityMeter__r.ServiceType__c NOT IN :UrjanetConstants.growthServiceTypes
                    AND UtilityMeter__r.Id IN :meters
            ];

            List<UtilityMeterUsage__c> growthUsagesToDelete = [
                SELECT Id
                FROM UtilityMeterUsage__c
                WHERE
                    UtilityMeter__r.ServiceType__c IN :UrjanetConstants.growthServiceTypes
                    AND UtilityMeter__r.Id IN :meters
            ];
            deleteMeterUsages(baseUsagesToDelete, growthUsagesToDelete);
        } catch (DmlException e) {
            Logger.getInstance()
                .log(
                    UtilityMeterUsageService.class.getName(),
                    Logger.Level.ERROR,
                    'Error in deleting : ' + e.getMessage()
                );
        }
    }

    public static void deleteMeterUsages(
        List<UtilityMeterUsage__c> baseUsagesToDelete,
        List<UtilityMeterUsage__c> growthUsagesToDelete
    ) {
        List<Id> baseUsageRecordIDsToDeleteList = new List<Id>();
        for (UtilityMeterUsage__c baseUsage : baseUsagesToDelete) {
            baseUsageRecordIDsToDeleteList.add(baseUsage.Id);
        }

        List<Id> growthUsageRecordIDsToDeleteList = new List<Id>();
        for (UtilityMeterUsage__c growthUsage : growthUsagesToDelete) {
            growthUsageRecordIDsToDeleteList.add(growthUsage.Id);
        }
        UrjanetUtils.deleteMeterUsagesAndDownStreamData(
            baseUsageRecordIDsToDeleteList,
            growthUsageRecordIDsToDeleteList
        );
    }

    public static void deleteMeterUsagesDownstreamData(
        List<UtilityMeterUsage__c> baseUsagesToDelete,
        List<UtilityMeterUsage__c> growthUsagesToDelete
    ) {
        List<Id> baseUsageRecordIDsToDeleteList = new List<Id>();
        for (UtilityMeterUsage__c baseUsage : baseUsagesToDelete) {
            baseUsageRecordIDsToDeleteList.add(baseUsage.Id);
        }

        List<Id> growthUsageRecordIDsToDeleteList = new List<Id>();
        for (UtilityMeterUsage__c growthUsage : growthUsagesToDelete) {
            growthUsageRecordIDsToDeleteList.add(growthUsage.Id);
        }
        UrjanetUtils.deleteMeterUsageDownStreamData(baseUsageRecordIDsToDeleteList, growthUsageRecordIDsToDeleteList);
    }

    @namespaceAccessible
    public static void validateMeterAndUsages(List<UtilityMeterUsage__c> usages) {
        Map<String, List<UtilityMeterUsage__c>> measuredUsageToUsagesMap = new Map<String, List<UtilityMeterUsage__c>>();
        for (UtilityMeterUsage__c usage : usages) {
            if (measuredUsageToUsagesMap.containsKey(usage.MeasuredUsageInText__c)) {
                measuredUsageToUsagesMap.get(usage.MeasuredUsageInText__c).add(usage);
            } else {
                measuredUsageToUsagesMap.put(usage.MeasuredUsageInText__c, new List<UtilityMeterUsage__c>{ usage });
            }
        }
        try {
            Map<String, Object> results = getDuplicateMetersAndUsages(measuredUsageToUsagesMap);
            List<UtilityMeterUsage__c> usagesToBeIgnored = (List<UtilityMeterUsage__c>) results.get(
                'usagesToBeIgnored'
            );
            List<UtilityMeter__c> metersToBeDisabled = (List<UtilityMeter__c>) results.get('metersToBeDisabled');
            updateRecordList(usagesToBeIgnored, metersToBeDisabled);
        } catch (Exception e) {
            Logger.getInstance()
                .log(
                    UtilityMeterUsageService.class.getName(),
                    Logger.Level.ERROR,
                    'Error  : ' + e.getMessage() + ' ' + e.getStackTraceString()
                );
        }
    }

    @namespaceAccessible
    public static void validateMeterAndUsages(List<UtilityMeter__c> meters) {
        List<UtilityMeterUsage__c> usagesToBeIgnored = new List<UtilityMeterUsage__c>();
        for (UtilityMeter__c meter : meters) {
            List<UtilityMeterUsage__c> usages = [
                SELECT Id, To_Be_Ignored__c
                FROM UtilityMeterUsage__c
                WHERE UtilityMeter__c = :meter.Id
            ];
            Boolean isFirstRecord = true;
            for (UtilityMeterUsage__c usage : usages) {
                if (isFirstRecord) {
                    isFirstRecord = false;
                    continue;
                }
                usage.To_Be_Ignored__c = true;
                usagesToBeIgnored.add(usage);
            }
        }
        if (!usagesToBeIgnored.isEmpty()) {
            update usagesToBeIgnored;
        }
        deleteDownstreamData(usagesToBeIgnored);
    }

    public static Map<String, Object> getDuplicateMetersAndUsages(
        Map<String, List<UtilityMeterUsage__c>> measuredUsageToUsagesMap
    ) {
        Map<Id, UtilityMeterUsage__c> usagesToBeIgnored = new Map<Id, UtilityMeterUsage__c>();
        Map<Id, UtilityMeter__c> metersToBeDisabled = new Map<Id, UtilityMeter__c>();
        Set<Id> usagesCheckedIds = new Set<Id>();
        Set<Id> metersCheckedIds = new Set<Id>();

        for (String measuredUsage : measuredUsageToUsagesMap.keySet()) {
            List<UtilityMeterUsage__c> usageList = measuredUsageToUsagesMap.get(measuredUsage);
            getDuplicates(usageList, usagesToBeIgnored, metersToBeDisabled, usagesCheckedIds, metersCheckedIds);
        }
        Map<String, Object> results = new Map<String, Object>();
        results.put('usagesToBeIgnored', usagesToBeIgnored.values());
        results.put('metersToBeDisabled', metersToBeDisabled.values());
        return results;
    }

    public static void getDuplicates(
        List<UtilityMeterUsage__c> usageList,
        Map<Id, UtilityMeterUsage__c> usagesToBeIgnored,
        Map<Id, UtilityMeter__c> metersToBeDisabled,
        Set<Id> usagesCheckedIds,
        Set<Id> metersCheckedIds
    ) {
        for (UtilityMeterUsage__c usage : usageList) {
            if (usagesToBeIgnored.containsKey(usage.Id) || metersToBeDisabled.containsKey(usage.UtilityMeter__r.Id)) {
                continue;
            }

            Date periodStart = usage.PeriodStart__c;
            Date periodStartMinus1 = periodStart.addDays(-1);
            Date periodStartPlus1 = periodStart.addDays(1);
            Date endDate = usage.PeriodEnd__c;
            Date endDatePlusOneDay = endDate.addDays(1);
            Date endDateMinusOneDay = endDate.addDays(-1);
            Decimal measuredUsage = usage.MeasuredUsage__c;
            String usageUnit = usage.UsageUnit__c;

            String serviceType = usage.UtilityMeter__r != null ? usage.UtilityMeter__r.ServiceType__c : null;
            String podNumber = usage.UtilityMeter__r != null ? usage.UtilityMeter__r.PodNumber__c : null;
            Id site = usage.UtilityMeter__r != null
                ? usage.UtilityMeter__r.StationaryAssetEnvironmentalSource__c
                : null;

            Id usageId = usage.Id;
            usagesCheckedIds.add(usageId);

            Id meterId = usage.UtilityMeter__r != null ? usage.UtilityMeter__r.Id : null;
            metersCheckedIds.add(meterId);
            String statementId = usage.Arcadia_Statement_ID__c;
            String orderBy = 'ORDER BY CreatedDate ASC';
            String baseQuery =
                'SELECT Id, MeasuredUsage__c, UsageUnit__c, PeriodStart__c, PeriodEnd__c, To_Be_Ignored__c, ' +
                'UtilityMeter__c, UtilityMeter__r.MeterNumber__c, UtilityMeter__r.ServiceType__c, UtilityMeter__r.Enabled__c ' +
                'FROM UtilityMeterUsage__c WHERE Id NOT IN :usagesCheckedIds AND MeasuredUsage__c = :measuredUsage ' +
                'AND UtilityMeter__r.Enabled__c = true ' +
                'AND To_Be_Ignored__c = false ' +
                'AND UsageUnit__c = :usageUnit ' +
                'AND (PeriodStart__c = :periodStartMinus1 OR PeriodStart__c = :periodStartPlus1 OR PeriodStart__c = :periodStart) ' +
                'AND (PeriodEnd__c = :endDatePlusOneDay OR PeriodEnd__c = :endDateMinusOneDay OR PeriodEnd__c = :endDate) ' +
                'AND Arcadia_Statement_ID__c = :statementId AND IsRecordLocked__c = false ';

            // Additional conditions for meter duplicates
            if (podNumber != null && serviceType != null && site != null) {
                String meterConditions =
                    ' AND UtilityMeter__r.Id NOT IN :metersCheckedIds AND UtilityMeter__r.ServiceType__c = :serviceType ' +
                    'AND UtilityMeter__r.StationaryAssetEnvironmentalSource__c = :site ' +
                    'AND UtilityMeter__r.PodNumber__c = :podNumber ' +
                    orderBy;
                String fullQuery = baseQuery + meterConditions;

                List<UtilityMeterUsage__c> usagesWithDuplicateMeters = Database.query(fullQuery);
                for (UtilityMeterUsage__c usagesWithDuplicateMeter : usagesWithDuplicateMeters) {
                    if (!metersToBeDisabled.containsKey(usagesWithDuplicateMeter.UtilityMeter__r.Id)) {
                        metersToBeDisabled.put(
                            usagesWithDuplicateMeter.UtilityMeter__r.Id,
                            usagesWithDuplicateMeter.UtilityMeter__r
                        );
                    }
                }
            }
            baseQuery = baseQuery + orderBy;
            List<UtilityMeterUsage__c> duplicateUsages = Database.query(baseQuery);
            for (UtilityMeterUsage__c duplicateUsage : duplicateUsages) {
                if (!usagesToBeIgnored.containsKey(duplicateUsage.Id)) {
                    usagesToBeIgnored.put(duplicateUsage.Id, duplicateUsage);
                }
            }
        }
    }

    public static void updateRecordList(
        List<UtilityMeterUsage__c> usagesToBeIgnored,
        List<UtilityMeter__c> metersToBeDisabled
    ) {
        if (!metersToBeDisabled.isEmpty()) {
            for (UtilityMeter__c meter : metersToBeDisabled) {
                meter.Enabled__c = false;
            }
            update metersToBeDisabled;
        }
        Logger.getInstance()
            .log(
                UtilityMeterUsageService.class.getName(),
                Logger.Level.DEBUG,
                'Meters Disabled size =' + metersToBeDisabled.size()
            );

        if (!usagesToBeIgnored.isEmpty()) {
            for (UtilityMeterUsage__c usage : usagesToBeIgnored) {
                usage.To_Be_Ignored__c = true;
            }
            update usagesToBeIgnored;
        }
        Logger.getInstance()
            .log(
                UtilityMeterUsageService.class.getName(),
                Logger.Level.DEBUG,
                'Usages Ignored size =' + usagesToBeIgnored.size()
            );
    }

    @namespaceAccessible
    public static void deleteDownstreamData(List<UtilityMeterUsage__c> usages) {
        try {
            List<UtilityMeterUsage__c> baseUsagesToDelete = new List<UtilityMeterUsage__c>();
            List<UtilityMeterUsage__c> growthUsagesToDelete = new List<UtilityMeterUsage__c>();
            List<UtilityMeterUsage__c> baseUsageDownstreamToDelete = new List<UtilityMeterUsage__c>();
            List<UtilityMeterUsage__c> growthUsageDownstreamToDelete = new List<UtilityMeterUsage__c>();

            for (UtilityMeterUsage__c usage : usages) {
                Boolean isGrowthService = UrjanetConstants.growthServiceTypes.contains(
                    usage.UtilityMeter__r.ServiceType__c
                );
                Boolean isEnabled = usage.UtilityMeter__r.Enabled__c;

                if (isGrowthService) {
                    (isEnabled ? growthUsageDownstreamToDelete : growthUsagesToDelete).add(usage);
                } else {
                    (isEnabled ? baseUsageDownstreamToDelete : baseUsagesToDelete).add(usage);
                }
            }

            Logger.getInstance()
                .log(
                    UtilityMeterUsageService.class.getName(),
                    Logger.Level.DEBUG,
                    'Deleting : baseUsagesToDelete size = ' +
                        baseUsagesToDelete.size() +
                        ' and growthUsagesToDelete size= ' +
                        growthUsagesToDelete.size() +
                        'baseUsageDownstreamToDelete size = ' +
                        baseUsageDownstreamToDelete.size() +
                        ' and growthUsageDownstreamToDelete size= ' +
                        growthUsageDownstreamToDelete.size()
                );

            deleteMeterUsages(baseUsagesToDelete, growthUsagesToDelete);
            deleteMeterUsagesDownstreamData(baseUsageDownstreamToDelete, growthUsageDownstreamToDelete);
        } catch (Exception e) {
            Logger.getInstance()
                .log(
                    UtilityMeterUsageService.class.getName(),
                    Logger.Level.ERROR,
                    'Error in deleteDownstreamData: ' + e.getMessage()
                );
        }
    }
}
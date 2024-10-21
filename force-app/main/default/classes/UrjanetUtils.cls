@namespaceAccessible
public with sharing class UrjanetUtils {
    public static String sanitizeResponse(String jsonString) {
        if (jsonString != null) {
            Integer offset = 100000;
            Integer currentStartIndex = 0;
            Integer finalIndex = jsonString.length() - 1;

            List<String> processedChunks = new List<String>();
            while (currentStartIndex < finalIndex) {
                //Add one to include the colon in the previous chunk
                Integer endIndex = currentStartIndex + offset;
                if (endIndex > finalIndex) {
                    endIndex = finalIndex + 1;
                } else {
                    endIndex = jsonString.indexOf(':', endIndex) + 1;
                }

                String chunk = jsonString.substring(currentStartIndex, endIndex);

                String processedChunk = chunk.replaceAll('\"_links\"\\s*?:', '\"links\":')
                    .replaceAll('\"_embedded\"\\s*?:', '\"embedded\":')
                    .replaceAll('\"number\"\\s*?:', '\"numbers\":')
                    .replaceAll('\"exception\"\\s*?:', '\"ex\":');

                processedChunks.add(processedChunk);
                currentStartIndex = endIndex;
            }

            return String.join(processedChunks, '');
        }
        return null;
    }

    public static String getSchedulerExpression(Datetime dt) {
        return ('' +
        dt.second() +
        ' ' +
        dt.minute() +
        ' ' +
        dt.hour() +
        ' ' +
        dt.day() +
        ' ' +
        dt.month() +
        ' ? ' +
        dt.year());
    }

    public static DateTime getDateTime(String dateTimeString) {
        DateTime dateTimeVal;
        if (!String.isEmpty(dateTimeString)) {
            dateTimeVal = DateTime.valueOfGmt(dateTimeString.substringBefore('+').replace('T', ' '));
        }
        return dateTimeVal;
    }

    /**
     * @ Check if the field has been changed and return boolean
     * @param  record - SObject, OldMap - Map<Id, SObject> and syncField - SObjectField
     * @return          Boolen - to determine whether the field has changed
     */
    public static Boolean hasSyncFieldUpdated(SObject record, Map<Id, SObject> oldMap, SObjectField syncField) {
        if (oldMap.containsKey(record.Id)) {
            try {
                Object syncFieldValue = record.get(syncField);
                Object oldSyncFieldValue = oldMap.get(record.Id).get(syncField);
                if (
                    syncFieldValue != null &&
                    oldSyncFieldValue != null &&
                    syncFieldValue instanceof DateTime &&
                    oldSyncFieldValue instanceof DateTime
                ) {
                    // Return true if syncFieldDateTime is greater than oldSyncFieldDateTime, indicating an update
                    DateTime syncFieldDateTime = (DateTime) syncFieldValue;
                    DateTime oldSyncFieldDateTime = (DateTime) oldSyncFieldValue;
                    return syncFieldDateTime > oldSyncFieldDateTime;
                } else if (syncFieldValue != null && oldSyncFieldValue != null) {
                    // case when fields are no DateTime
                    return !syncFieldValue.equals(oldSyncFieldValue);
                }
            } catch (Exception e) {
                // Handle the exception or log an error message
                Logger.getInstance()
                    .log(
                        UrjanetUtils.class.getName(),
                        Logger.Level.ERROR,
                        'Exception occurred while checking for sync field update. Error: ' +
                            e.getMessage() +
                            ' for record id' +
                            record.Id +
                            'error ' +
                            e
                    );
            }
        }
        return true;
    }

    @TestVisible
    public static void logFailures(String className, String sObjectName, List<Database.SaveResult> saveResults) {
        Logger logWriter = Logger.getInstance();
        logWriter.log(className, sObjectName, saveResults);
    }

    @TestVisible
    public static void logFailures(String className, String sObjectName, List<Database.DeleteResult> deleteResults) {
        Logger logWriter = Logger.getInstance();
        logWriter.log(className, sObjectName, deleteResults);
    }

    /**
     * @ get Namespace
     * @return String Namespace
     */
    public static String getThisNameSpace() {
        String thisNamespace = getNamespace();
        if (thisNamespace != '') {
            return thisNamespace;
        }
        /**this would be changed to 'c' once entire repo is packaged. Since only connected app is packaged now,
         *requires us to specify 'urjanet' specifically
         */
        return 'urjanet';
    }

    public static String getNamespaceWithUnderscores() {
        String namespace = getNamespace();
        if (String.isNotBlank(namespace)) {
            namespace += '__';
        }
        return namespace;
    }

    public static String getNamespace() {
        return CSUtils.class.getName().substringBefore('CSUtils').removeEnd('.');
    }

    public static Map<String, String> getServiceToFuelTypeMappings() {
        Map<String, String> fuelTypeMappings = new Map<String, String>();
        ServiceTypeToFuelTypeMappingSelector mappingsSelector = new ServiceTypeToFuelTypeMappingSelector(
            false,
            false,
            false
        );
        for (
            ServiceTypeToFuelTypeMapping__mdt mapping : (List<ServiceTypeToFuelTypeMapping__mdt>) mappingsSelector.getAllRecords()
        ) {
            if (!fuelTypeMappings.containsKey(mapping.ServiceType__c)) {
                fuelTypeMappings.put(mapping.ServiceType__c, mapping.FuelType__c);
            }
        }
        return fuelTypeMappings;
    }

    public static Map<String, String> getServiceToProcessorTypeMappings() {
        Map<String, String> serviceTypeMappings = new Map<String, String>();
        ServiceToProcessorTypeMappingSelector mappingsSelector = new ServiceToProcessorTypeMappingSelector(
            false,
            false,
            false
        );
        for (
            UtilityMeterUsageProcessorSetting__mdt mapping : (List<UtilityMeterUsageProcessorSetting__mdt>) mappingsSelector.getAllRecords()
        ) {
            if (!serviceTypeMappings.containsKey(mapping.ServiceType__c)) {
                serviceTypeMappings.put(mapping.ServiceType__c, mapping.ProcessorClassName__c);
            }
        }
        return serviceTypeMappings;
    }

    public static Map<String, String> getServiceToDeleterTypeMappings() {
        Map<String, String> serviceTypeMappings = new Map<String, String>();
        ServiceToDeleterTypeMappingSelector mappingsSelector = new ServiceToDeleterTypeMappingSelector(
            false,
            false,
            false
        );
        for (
            UtilityMeterUsageDeleterSetting__mdt mapping : (List<UtilityMeterUsageDeleterSetting__mdt>) mappingsSelector.getAllRecords()
        ) {
            if (!serviceTypeMappings.containsKey(mapping.ServiceType__c)) {
                serviceTypeMappings.put(mapping.ServiceType__c, mapping.DeleterClassName__c);
            }
        }
        return serviceTypeMappings;
    }

    public static Map<String, String> getServiceToDownstreamDeleterTypeMappings() {
        Map<String, String> serviceTypeMappings = new Map<String, String>();
        ServiceToDownstreamDeleterMapSelector mappingsSelector = new ServiceToDownstreamDeleterMapSelector(
            false,
            false,
            false
        );
        for (
            UsageDownstreamDeleterSetting__mdt mapping : (List<UsageDownstreamDeleterSetting__mdt>) mappingsSelector.getAllRecords()
        ) {
            if (!serviceTypeMappings.containsKey(mapping.ServiceType__c)) {
                serviceTypeMappings.put(mapping.ServiceType__c, mapping.DeleterClassName__c);
            }
        }
        return serviceTypeMappings;
    }
    
    public static Map<String, String> getServiceToUpdaterTypeMappings() {
        Map<String, String> serviceTypeMappings = new Map<String, String>();
        ServiceToUpdaterTypeMappingSelector mappingsSelector = new ServiceToUpdaterTypeMappingSelector(
            false,
            false,
            false
        );
        for (
            UtilityMeterUsageUpdaterSetting__mdt mapping : (List<UtilityMeterUsageUpdaterSetting__mdt>) mappingsSelector.getAllRecords()
        ) {
            if (!serviceTypeMappings.containsKey(mapping.ServiceType__c)) {
                serviceTypeMappings.put(mapping.ServiceType__c, mapping.UpdaterClassName__c);
            }
        }
        return serviceTypeMappings;
    }

    public static Map<String, String> getStationaryAssetDeleterMappings() {
        Map<String, String> serviceTypeMappings = new Map<String, String>();
        StnryAssetDeleterMappingSelector mappingsSelector = new StnryAssetDeleterMappingSelector(false, false, false);
        for (
            StnryAssetDeleterSetting__mdt mapping : (List<StnryAssetDeleterSetting__mdt>) mappingsSelector.getAllRecords()
        ) {
            if (!serviceTypeMappings.containsKey(mapping.ServiceType__c)) {
                serviceTypeMappings.put(mapping.ServiceType__c, mapping.DeleterClassName__c);
            }
        }
        return serviceTypeMappings;
    }

    public static Map<String, String> getServiceToMeterProcessorTypeMappings() {
        Map<String, String> serviceTypeMappings = new Map<String, String>();
        MeterProcessorMappingSelector mappingsSelector = new MeterProcessorMappingSelector(false, false, false);
        for (
            UtilityMeterProcessorSetting__mdt mapping : (List<UtilityMeterProcessorSetting__mdt>) mappingsSelector.getAllRecords()
        ) {
            if (!serviceTypeMappings.containsKey(mapping.ServiceType__c)) {
                serviceTypeMappings.put(mapping.ServiceType__c, mapping.ProcessorClassName__c);
            }
        }
        return serviceTypeMappings;
    }

    /**
     * @return The API name of the object that this Selector works with.
     */
    @namespaceAccessible
    public static String getSObjectName(SObjectType sot) {
        return sot.getDescribe().getName();
    }

    private static UrjanetSettings__c settings;

    @namespaceAccessible
    public static String getAPIPageSize() {
        if (settings == null) {
            settings = UrjanetSettings__c.getOrgDefaults();
        }
        Integer pageSize = settings?.APIPageSize__c != null
            ? Integer.valueOf(settings?.APIPageSize__c)
            : UrjanetConstants.FALLBACK_PAGE_SIZE;
        return String.valueOf(pageSize);
    }

    @AuraEnabled(cacheable=true)
    public static Boolean getDevelopmentOrg() {
        if (settings == null) {
            settings = UrjanetSettings__c.getOrgDefaults();
        }
        return settings.DevelopmentOrg__c;
    }

    @namespaceAccessible
    public static Integer getBatchSize(Boolean isTesting) {
        if (isTesting) {
            return null;
        }
        Integer batchSize = settings?.SyncBatchSize__c != null
            ? Integer.valueOf(settings?.SyncBatchSize__c)
            : UrjanetConstants.FALLBACK_BATCH_SIZE;
        return batchSize;
    }

    @namespaceAccessible
    public static List<SplitDateDetails> getDateRanges(UtilityMeterUsage__c meterUsage) {
        List<SplitDateDetails> lstDateRanges = new List<SplitDateDetails>();

        Date periodStart = meterUsage.PeriodStart__c;
        Date periodEnd = meterUsage.PeriodEnd__c;
        Integer noOfMonths = periodStart.monthsBetween(periodEnd);

        if (noOfMonths == 0) {
            lstDateRanges.add(new SplitDateDetails(periodStart, periodEnd));
        } else {
            for (Integer i = 0; i <= noOfMonths; i++) {
                SplitDateDetails splitDetailsObj = new SplitDateDetails();
                if (i == 0) {
                    splitDetailsObj.startDate = periodStart;
                    splitDetailsObj.endDate = periodStart.addMonths(1).toStartOfMonth().addDays(-1); //to go to last day of the month we want
                } else if (i > 0 && periodStart.addMonths(i).month() != periodEnd.month()) {
                    splitDetailsObj.startDate = periodStart.addMonths(i).toStartOfMonth();
                    splitDetailsObj.endDate = periodStart.addMonths(i + 1).toStartOfMonth().addDays(-1);
                } else if (i > 0 && periodStart.addMonths(i).month() == periodEnd.month()) {
                    splitDetailsObj.startDate = periodStart.addMonths(i).toStartOfMonth();
                    splitDetailsObj.endDate = periodEnd;
                }
                lstDateRanges.add(splitDetailsObj);
            }
        }
        return lstDateRanges;
    }

    @namespaceAccessible
    public static void createPaginationQueueItemFromAPIResponse(
        UrjanetResponse.Pages pageDetails,
        Id parentRecordId,
        String requestType,
        Type processorClass,
        Double pageNumber,
        Set<String> staleDataToBeDeletedSet
    ) {
        if (
            null != staleDataToBeDeletedSet &&
            !staleDataToBeDeletedSet.isEmpty() &&
            pageDetails != null &&
            pageDetails.totalPages > 1 &&
            pageNumber != pageDetails.totalPages // page no starts with 0 and ends with totalPages - 1, so we need to check if the current page is not the last page
        ) {
            List<Database.SaveResult> saveResults = new QueueItemsBuilder(
                    parentRecordId,
                    processorClass,
                    requestType,
                    pageDetails.totalPages,
                    pageNumber,
                    staleDataToBeDeletedSet
                )
                .buildQueueItemsPerPageForMeterUsages()
                .createRecords();
            UrjanetUtils.logFailures(
                UrjanetUtils.class.getName(),
                String.valueOf(UtilityMeter__c.SObjectType),
                saveResults
            );
        }
    }
    @namespaceAccessible
    public static void createPaginationQueueItemFromAPIResponse(
        UrjanetResponse.Pages pageDetails,
        Id parentRecordId,
        String requestType,
        Type processorClass
    ) {
        if (pageDetails != null && pageDetails.numbers == 0 && pageDetails.totalPages > 1) {
            List<Database.SaveResult> saveResults = new QueueItemsBuilder(
                    parentRecordId,
                    processorClass,
                    requestType,
                    pageDetails.totalPages
                )
                .buildQueueItemsPerPage()
                .createRecords();
            UrjanetUtils.logFailures(
                UrjanetUtils.class.getName(),
                String.valueOf(UtilityMeter__c.SObjectType),
                saveResults
            );
        }
    }

    @namespaceAccessible
    public class SplitDateDetails {
        @namespaceAccessible
        public Date startDate;
        @namespaceAccessible
        public Date endDate;

        @namespaceAccessible
        public SplitDateDetails() {
        }

        @namespaceAccessible
        public SplitDateDetails(Date startDateValue, Date endDateValue) {
            this.startDate = startDateValue;
            this.endDate = endDateValue;
        }
    }

    @namespaceAccessible
    public static void handleApiError(
        QueueItem__c queueItem,
        String errorMessage,
        String message,
        Integer status,
        String className
    ) {
        Logger.getInstance().log(className, Logger.Level.ERROR, errorMessage + message);
        QueueItemWorker queueItemWorker = new queueItemWorker();
        queueItemWorker.handleError(queueItem, errorMessage);
        throw new ArcadiaCalloutServiceException(errorMessage, status);
    }

    public static Map<String, EnergyUseConversionMapping__mdt> getEnergyUseConversionMappings() {
        Map<String, EnergyUseConversionMapping__mdt> mapEnergyUseConversions = new Map<String, EnergyUseConversionMapping__mdt>();
        EnergyUseConversionMappingsSelector mappingsSelector = new EnergyUseConversionMappingsSelector(
            false,
            false,
            false
        );
        for (
            EnergyUseConversionMapping__mdt mapping : (List<EnergyUseConversionMapping__mdt>) mappingsSelector.getAllRecords()
        ) {
            if (!mapEnergyUseConversions.containsKey(mapping.ApiUnitOfMeasurementFrom__c)) {
                mapEnergyUseConversions.put(mapping.ApiUnitOfMeasurementFrom__c, mapping);
            }
        }
        return mapEnergyUseConversions;
    }

    @future(callout=true)
    @namespaceAccessible
    public static void insertAccessTokenForBatchUse() {
        AccessToken__c accessTokenSetting = AccessToken__c.getInstance(UserInfo.getProfileId());
        if (
            accessTokenSetting == null ||
            accessTokenSetting.Token1__c == null ||
            accessTokenSetting.ExpirationTime__c == null ||
            accessTokenSetting.ExpirationTime__c.getTime() < Datetime.now().getTime()
        ) {
            insertAccessToken(accessTokenSetting);
        }
        // call the scheduler as now the token is updated
        UtilityBatchSyncScheduler.scheduleJob();
    }

    @namespaceAccessible
    public static AccessToken__c checkAndUpdateAccessToken() {
        AccessToken__c accessTokenSetting = AccessToken__c.getInstance(UserInfo.getProfileId());
        if (
            accessTokenSetting == null ||
            accessTokenSetting.Token1__c == null ||
            accessTokenSetting.ExpirationTime__c == null ||
            accessTokenSetting.ExpirationTime__c.getTime() < Datetime.now().getTime()
        ) {
            return insertAccessToken(accessTokenSetting);
        }
        return accessTokenSetting;
    }

    @namespaceAccessible
    public static AccessToken__c insertAccessToken(AccessToken__c accessTokenSetting) {
        LoginResponse tokenResponse = getNewLoginResponse();

        if (tokenResponse.status != 200) {
            Logger.getInstance()
                .log(
                    UrjanetUtils.class.getName(),
                    UrjanetConstants.LOGIN_FAILURE,
                    Logger.Level.ERROR,
                    tokenResponse.errorMsg
                );
            return null;
        } else {
            String newToken = tokenResponse.token;
            String expirationTime = String.valueOf(tokenResponse.expires);
            Long expirationTimeMillis = Long.valueOf(expirationTime) * 1000;

            String message = (tokenResponse.message != null) ? tokenResponse.message : 'Success';

            if (accessTokenSetting.Token1__c == null) {
                accessTokenSetting = new AccessToken__c(Name = 'Default');
            }
            Integer chunkSize = 255;
            Integer numChunks = (newToken.length() + chunkSize - 1) / chunkSize;
            for (Integer i = 0; i < numChunks; i++) {
                String chunk = newToken.substring(i * chunkSize, Math.min((i + 1) * chunkSize, newToken.length()));
                String fieldName = 'Token' + (i + 1) + '__c';
                accessTokenSetting.put(fieldName, chunk);
            }

            accessTokenSetting.ExpirationTime__c = DateTime.newInstance(expirationTimeMillis);
            accessTokenSetting.Message__c = message;

            try {
                upsert accessTokenSetting;
            } catch (Exception e) {
                Logger.getInstance()
                    .log(
                        UrjanetApiClient.class.getName(),
                        'error occured : ' + e.getMessage(),
                        Logger.Level.ERROR,
                        tokenResponse.errorMsg
                    );
                return null;
            }
        }
        return accessTokenSetting;
    }

    @namespaceAccessible
    public static LoginResponse getNewLoginResponse() {
        LoginResponse tokenResponse;
        AccessTokenProvider tokenProvider = new AccessTokenProviderFactory()
            .getAccessTokenProvider(UrjanetEnums.AccessTokenType.CALLOUT);
        return tokenProvider.getAccessToken();
    }

    @namespaceAccessible
    public static List<Id> getDuplicateMeterUsage(
        Set<UtilityMeterUsage__c> meterUsageList,
        Decimal measuredUsage,
        Date startDate,
        Date endDate
    ) {
        Date endDatePlusOneDay = endDate.addDays(1);
        Date endDateMinusOneDay = endDate.addDays(-1);
        List<Id> recordIDsToDelete = new List<Id>();

        Boolean firstRecord = true;

        for (UtilityMeterUsage__c meterUsage : meterUsageList) {
            if (
                meterUsage.MeasuredUsage__c == measuredUsage &&
                meterUsage.PeriodStart__c == startDate &&
                (meterUsage.PeriodEnd__c == endDate ||
                meterUsage.PeriodEnd__c == endDatePlusOneDay ||
                meterUsage.PeriodEnd__c == endDateMinusOneDay)
            ) {
                if (firstRecord) {
                    firstRecord = false;
                    continue;
                }
                recordIDsToDelete.add(meterUsage.Id);
            }
        }

        return recordIDsToDelete;
    }

    public static String extractAccessToken(AccessToken__c accessTokenSetting) {
        List<String> tokenFields = new List<String>();
        Integer numTokenFields = 20;
        String combinedToken = '';

        for (Integer i = 1; i <= numTokenFields; i++) {
            String token = (String) accessTokenSetting.get('Token' + i + '__c');
            if (token == null) {
                break;
            }
            combinedToken += token;
        }
        return combinedToken;
    }
    @namespaceAccessible
    public static void deleteMeterUsagesAndDownStreamData(
        List<Id> recordIDsToDeleteEnergy,
        List<Id> recordIDsToDeleteWater
    ) {
        try {
            String ns = UtilityMeterUsageProcessor.class
                .getName()
                .substringBefore('UtilityMeterUsageProcessor')
                .removeEnd('.');

            Map<String, String> deleterMapping = UrjanetUtils.getServiceToDeleterTypeMappings();
            if (!recordIDsToDeleteEnergy.isEmpty() && (deleterMapping.containsKey('electric'))) {
                // Create an instance of the class dynamically
                Type dynamicTypeElectric;
                if (String.isBlank(ns)) {
                    dynamicTypeElectric = Type.forName(deleterMapping.get('electric'));
                } else {
                    dynamicTypeElectric = Type.forName(ns, deleterMapping.get('electric'));
                }
                IUtilityMeterUsageDeleter processorElectric = (IUtilityMeterUsageDeleter) dynamicTypeElectric.newInstance();
                // Call the interface method
                processorElectric.deleteUtilityMeterUsage(recordIDsToDeleteEnergy);
            }
            if (!recordIDsToDeleteWater.isEmpty() && (deleterMapping.containsKey('water'))) {
                // Create an instance of the class dynamically
                Type dynamicTypeWater;
                if (String.isBlank(ns)) {
                    dynamicTypeWater = Type.forName(deleterMapping.get('water'));
                } else {
                    dynamicTypeWater = Type.forName(ns, deleterMapping.get('water'));
                }
                IUtilityMeterUsageDeleter processorWater = (IUtilityMeterUsageDeleter) dynamicTypeWater.newInstance();
                // Call the interface method
                processorWater.deleteUtilityMeterUsage(recordIDsToDeleteWater);
            }
        } catch (Exception e) {
            Logger.getInstance().log(UrjanetUtils.class.getName(), 'Line 596 Error ='+ e + 'stack trace'+ e.getStackTraceString() + 'Line Number ='+e.getLineNumber());
        }
    }

    @namespaceAccessible
    public static void deleteMeterUsageDownStreamData(
        List<Id> recordIDsToDeleteEnergy,
        List<Id> recordIDsToDeleteWater
    ) {
        try {
            String ns = UtilityMeterUsageProcessor.class
                .getName()
                .substringBefore('UtilityMeterUsageProcessor')
                .removeEnd('.');

            Map<String, String> deleterMapping = UrjanetUtils.getServiceToDownstreamDeleterTypeMappings();
            if (!recordIDsToDeleteEnergy.isEmpty() && (deleterMapping.containsKey('electric'))) {
                // Create an instance of the class dynamically
                Type dynamicTypeElectric;
                if (String.isBlank(ns)) {
                    dynamicTypeElectric = Type.forName(deleterMapping.get('electric'));
                } else {
                    dynamicTypeElectric = Type.forName(ns, deleterMapping.get('electric'));
                }
                IUtilityMeterUsageDownstreamDeleter processorElectric = (IUtilityMeterUsageDownstreamDeleter) dynamicTypeElectric.newInstance();
                // Call the interface method
                processorElectric.deleteMeterUsageDownstreamData(recordIDsToDeleteEnergy);
            }
            if (!recordIDsToDeleteWater.isEmpty() && (deleterMapping.containsKey('water'))) {
                // Create an instance of the class dynamically
                Type dynamicTypeWater;
                if (String.isBlank(ns)) {
                    dynamicTypeWater = Type.forName(deleterMapping.get('water'));
                } else {
                    dynamicTypeWater = Type.forName(ns, deleterMapping.get('water'));
                }
                IUtilityMeterUsageDownstreamDeleter processorWater = (IUtilityMeterUsageDownstreamDeleter) dynamicTypeWater.newInstance();
                // Call the interface method
                processorWater.deleteMeterUsageDownstreamData(recordIDsToDeleteWater);
            }
        } catch (Exception e) {
            Logger.getInstance().log(UrjanetUtils.class.getName(), 'Line 637 Error ='+ e + 'stack trace'+ e.getStackTraceString() + 'Line Number ='+e.getLineNumber());
        }
    }

    @namespaceAccessible
    public static void updateMeterUsagesToBeIgnoredAndDeleteStreamData(
        List<Id> recordIDsToDeleteEnergy,
        List<Id> recordIDsToDeleteWater
    ) {
        try {
            String ns = UtilityMeterUsageProcessor.class
                .getName()
                .substringBefore('UtilityMeterUsageProcessor')
                .removeEnd('.');

            Map<String, String> updaterMapping = UrjanetUtils.getServiceToUpdaterTypeMappings();
            if (!recordIDsToDeleteEnergy.isEmpty() && (updaterMapping.containsKey('electric'))) {
                // Create an instance of the class dynamically
                Type dynamicTypeElectric;
                if (String.isBlank(ns)) {
                    dynamicTypeElectric = Type.forName(updaterMapping.get('electric'));
                } else {
                    dynamicTypeElectric = Type.forName(ns, updaterMapping.get('electric'));
                }
                IUtilityMeterUsageUpdater processorElectric = (IUtilityMeterUsageUpdater) dynamicTypeElectric.newInstance();

                // Call the interface method
                processorElectric.updateUtilityMeterUsageToBeIgnored(recordIDsToDeleteEnergy);
            }
            if (!recordIDsToDeleteWater.isEmpty() && (updaterMapping.containsKey('water'))) {
                // Create an instance of the class dynamically
                Type dynamicTypeWater;
                if (String.isBlank(ns)) {
                    dynamicTypeWater = Type.forName(updaterMapping.get('water'));
                } else {
                    dynamicTypeWater = Type.forName(ns, updaterMapping.get('water'));
                }
                IUtilityMeterUsageUpdater processorWater = (IUtilityMeterUsageUpdater) dynamicTypeWater.newInstance();

                // Call the interface method
                processorWater.updateUtilityMeterUsageToBeIgnored(recordIDsToDeleteWater);
            }
        } catch (Exception e) {
            Logger.getInstance().log(UrjanetUtils.class.getName(), e);
        }
    }

    public static void upsertLastSuccessfulSyncDate() {
        LastSuccessfulSyncDate__c lastSuccessfulSyncDate = LastSuccessfulSyncDate__c.getInstance(
            UserInfo.getProfileId()
        );
        if (lastSuccessfulSyncDate == null) {
            // upsert as this would be the first time the record is being created
            lastSuccessfulSyncDate.PreviousLastSyncDate__c = Datetime.newInstance(1990, 1, 1);
            lastSuccessfulSyncDate.LastSyncDate__c = DateTime.now();
            upsert lastSuccessfulSyncDate;
        } else if (canUpsertLastSuccessfulSyncDate(lastSuccessfulSyncDate)) {
            lastSuccessfulSyncDate.PreviousLastSyncDate__c = (lastSuccessfulSyncDate.LastSyncDate__c != null
                ? lastSuccessfulSyncDate.LastSyncDate__c
                : Datetime.newInstance(1990, 1, 1));
            lastSuccessfulSyncDate.LastSyncDate__c = DateTime.now();
            upsert lastSuccessfulSyncDate;
        }
    }

    public static Boolean canUpsertLastSuccessfulSyncDate(LastSuccessfulSyncDate__c lastSuccessfulSyncDate) {
        Datetime filterDate = lastSuccessfulSyncDate.PreviousLastSyncDate__c != null
            ? lastSuccessfulSyncDate.PreviousLastSyncDate__c
            : (lastSuccessfulSyncDate.LastSyncDate__c != null
                  ? lastSuccessfulSyncDate.LastSyncDate__c
                  : Datetime.now());
        Integer enqueuedJobs = [
            SELECT COUNT()
            FROM AsyncApexJob
            WHERE
                JobType = 'BatchApex'
                AND Status IN ('Queued', 'Preparing', 'Processing', 'Failed', 'Aborted')
                AND CreatedDate >= :filterDate
        ];

        Integer queueItems = [
            SELECT COUNT()
            FROM QueueItem__c
            WHERE CreatedDate > :filterDate
        ];
        return (enqueuedJobs == 0 && queueItems == 0);
    }
    public static void updateMeasuredUsageInText() {
        List<UtilityMeterUsage__c> utilityMeterUsages = [
            SELECT Id
            FROM UtilityMeterUsage__c
            WHERE MeasuredUsageInText__c = NULL AND IsRecordLocked__c = FALSE
        ];
        if (utilityMeterUsages.size() > 0) {
            // dummy update to populate MeasuredUsageInText__c
            update utilityMeterUsages;
        }
    }
}
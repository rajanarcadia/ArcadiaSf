public with sharing class UtilityMeterUsageUpdateProcessor extends QueueItemWorkerBase {
    public override QueueItem__c process(QueueItem__c queueItem) {
        // Ignoring security here since this is a system process
        UtilityMeterUsage__c meterUsageToProcess = (UtilityMeterUsage__c) new UtilityMeterUsageSelector(
                false,
                false,
                false
            )
            .getRecordById(queueItem.RecordId__c);

        if (meterUsageToProcess == null) {
            Logger.getInstance()
                .log(
                    UtilityMeterUsageUpdateProcessor.class.getName(),
                    Logger.Level.WARN,
                    'Unable to Process Meter Usage as the record is null : ' + queueItem.RecordId__c
                );
            return queueItem;
        }

        if (meterUsageToProcess.UtilityMeter__c == null) {
            Logger.getInstance()
                .log(
                    UtilityMeterUsageUpdateProcessor.class.getName(),
                    Logger.Level.WARN,
                    'Unable to Process Meter Usage as Utility Meter is null : ' + queueItem.RecordId__c
                );
            return queueItem;
        }

        String ns = UtilityMeterUsageUpdateProcessor.class
            .getName()
            .substringBefore('UtilityMeterUsageUpdateProcessor')
            .removeEnd('.');

        String serviceType = meterUsageToProcess.UtilityMeter__r.ServiceType__c;

        deleteExistingStationaryAssets(ns, serviceType, meterUsageToProcess);

        createNewStationaryAssets(ns, serviceType, meterUsageToProcess);

        return queueItem;
    }

    private static void deleteExistingStationaryAssets(String ns, String serviceType, UtilityMeterUsage__c meterUsage) {
        Map<String, String> deleterMapping = UrjanetUtils.getStationaryAssetDeleterMappings();

        if (deleterMapping.containsKey(serviceType)) {
            Type dynamicType;
            if (String.isBlank(ns)) {
                dynamicType = Type.forName(deleterMapping.get(serviceType));
            } else {
                dynamicType = Type.forName(ns, deleterMapping.get(serviceType));
            }

            if (dynamicType != null) {
                IStationaryAssetDeleter processor = (IStationaryAssetDeleter) dynamicType.newInstance();
                processor.deleteStationaryAsset(meterUsage);
            }
        }
    }

    private static void createNewStationaryAssets(String ns, String serviceType, UtilityMeterUsage__c meterUsage) {
        Map<String, String> createrMapping = UrjanetUtils.getServiceToProcessorTypeMappings();

        if (createrMapping.containsKey(serviceType)) {
            Type dynamicType;
            if (String.isBlank(ns)) {
                dynamicType = Type.forName(createrMapping.get(serviceType));
            } else {
                dynamicType = Type.forName(ns, createrMapping.get(serviceType));
            }

            if (dynamicType != null) {
                IUtilityMeterUsageProcessor processor = (IUtilityMeterUsageProcessor) dynamicType.newInstance();
                processor.processUtilityMeterUsage(meterUsage);
            }
        }
    }
}
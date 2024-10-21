public with sharing class UtilityMeterUsageProcessor extends QueueItemWorkerBase {
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
                    UtilityMeterUsageProcessor.class.getName(),
                    Logger.Level.WARN,
                    'Unable to Process Meter Usage as the record is null : ' + queueItem.RecordId__c
                );
            return queueItem;
        }

        if (meterUsageToProcess.UtilityMeter__c == null) {
            Logger.getInstance()
                .log(
                    UtilityMeterUsageProcessor.class.getName(),
                    Logger.Level.WARN,
                    'Unable to Process Meter Usage as Utility Meter is null : ' + queueItem.RecordId__c
                );
            return queueItem;
        }

        //call the right processor (interface implementation) based on the custom metadata value
        if (
            UrjanetUtils.getServiceToProcessorTypeMappings()
                .containsKey(meterUsageToProcess.UtilityMeter__r.ServiceType__c)
        ) {
            String ns = UtilityMeterUsageProcessor.class
                .getName()
                .substringBefore('UtilityMeterUsageProcessor')
                .removeEnd('.');

            // Create an instance of the class dynamically
            Type dynamicType;
            if (String.isBlank(ns)) {
                dynamicType = Type.forName(
                    UrjanetUtils.getServiceToProcessorTypeMappings()
                        .get(meterUsageToProcess.UtilityMeter__r.ServiceType__c)
                );
            } else {
                dynamicType = Type.forName(
                    ns,
                    UrjanetUtils.getServiceToProcessorTypeMappings()
                        .get(meterUsageToProcess.UtilityMeter__r.ServiceType__c)
                );
            }

            if (dynamicType != null) {
                IUtilityMeterUsageProcessor processor = (IUtilityMeterUsageProcessor) dynamicType.newInstance();

                // Call the interface method
                processor.processUtilityMeterUsage(meterUsageToProcess);
            }
        }

        return queueItem;
    }
}
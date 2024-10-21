public with sharing class UtilityMeterProcessor extends QueueItemWorkerBase {
    public override QueueItem__c process(QueueItem__c queueItem) {
        // Ignoring security here since this is a system process
        UtilityMeter__c meterToProcess = (UtilityMeter__c) new UtilityMeterSelector(false, false, false)
            .getRecordById(queueItem.RecordId__c);

        if (meterToProcess == null) {
            Logger.getInstance()
                .log(
                    UtilityMeterProcessor.class.getName(),
                    Logger.Level.WARN,
                    'Unable to Process Meter as the record is null : ' + queueItem.RecordId__c
                );
            return queueItem;
        }

        if (meterToProcess.UrjanetId__c == null) {
            Logger.getInstance()
                .log(
                    UtilityMeterProcessor.class.getName(),
                    Logger.Level.WARN,
                    'Unable to Process Meter as ArcadiaId is null : ' + queueItem.RecordId__c
                );
            return queueItem;
        }
        Map<String, String> serviceTypeMappings = UrjanetUtils.getServiceToMeterProcessorTypeMappings();
        //call the right processor (interface implementation) based on the custom metadata value
        if (serviceTypeMappings.containsKey(meterToProcess.ServiceType__c)) {
            String ns = UtilityMeterProcessor.class.getName().substringBefore('UtilityMeterProcessor').removeEnd('.');

            // Create an instance of the class dynamically
            Type dynamicType;
            if (String.isBlank(ns)) {
                dynamicType = Type.forName(serviceTypeMappings.get(meterToProcess.ServiceType__c));
            } else {
                dynamicType = Type.forName(ns, serviceTypeMappings.get(meterToProcess.ServiceType__c));
            }
            IUtilityMeterProcessor processor = (IUtilityMeterProcessor) dynamicType.newInstance();

            // Call the interface method
            processor.processUtilityMeterQueue(queueItem);
        }

        return queueItem;
    }
}
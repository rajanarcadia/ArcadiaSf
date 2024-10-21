public class ElectricMeterProcessor implements IUtilityMeterProcessor {
    public void processUtilityMeterQueue(QueueItem__c queueItem) {
        UtilityMeterService.processUtilityMeterQueue(queueItem);
    }
}
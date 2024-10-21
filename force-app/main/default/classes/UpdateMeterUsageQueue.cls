public class UpdateMeterUsageQueue implements Queueable {
    private List<UtilityMeterUsage__c> meterUsageToUpdate;
    private List<Id> recordIDsToDeleteEnergy;
    private List<Id> recordIDsToDeleteWater;

    public UpdateMeterUsageQueue(
        List<UtilityMeterUsage__c> meterUsageToUpdate,
        List<Id> recordIDsToDeleteEnergy,
        List<Id> recordIDsToDeleteWater
    ) {
        this.meterUsageToUpdate = meterUsageToUpdate;
        this.recordIDsToDeleteEnergy = recordIDsToDeleteEnergy;
        this.recordIDsToDeleteWater = recordIDsToDeleteWater;
    }

    public void execute(QueueableContext context) {
        Database.DMLOptions option = new Database.DMLOptions();
        option.OptAllOrNone = false;

        if (!meterUsageToUpdate.isEmpty()) {
            try {
                Logger.getInstance(false)
                    .log(
                        UpdateMeterUsageQueue.class.getName(),
                        Logger.Level.DEBUG,
                        'Updating Meter Usage: ' + meterUsageToUpdate.size()
                    );
                Data.upsurt(
                    meterUsageToUpdate,
                    Schema.UtilityMeterUsage__c.fields.UrjanetId__c,
                    option,
                    false,
                    false,
                    false,
                    null
                );
            } catch (DmlException e) {
                Logger.getInstance().log(UpdateMeterUsageQueue.class.getName(), Logger.Level.ERROR, e.getMessage());
            }
        }
        UrjanetUtils.deleteMeterUsagesAndDownStreamData(recordIDsToDeleteEnergy, recordIDsToDeleteWater);
    }
}
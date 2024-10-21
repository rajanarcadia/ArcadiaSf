public class BaseMeterUsageUpdater implements IUtilityMeterUsageUpdater {
    public void updateUtilityMeterUsageToBeIgnored(List<Id> meterUsageIds) {
        Database.DMLOptions option = new Database.DMLOptions();
        option.OptAllOrNone = false;
        try {
            List<StnryAssetEnrgyUse> energy = [
                SELECT Id
                FROM StnryAssetEnrgyUse
                WHERE UtilityMeterUsage__r.Id IN :meterUsageIds
            ];
            List<UtilityMeterUsage__c> usageRecords = [
                SELECT Id, UrjanetId__c, To_Be_Ignored__c
                FROM UtilityMeterUsage__c
                WHERE Id IN :meterUsageIds
            ];

            for (UtilityMeterUsage__c usageRecord : usageRecords) {
                usageRecord.To_Be_Ignored__c = true;
            }

            Logger.getInstance(false)
                .log(
                    BaseMeterUsageUpdater.class.getName(),
                    Logger.Level.DEBUG,
                    'Deleting Energy Usage: ' + energy.size()
                );
            Logger.getInstance(false)
                .log(
                    BaseMeterUsageUpdater.class.getName(),
                    Logger.Level.DEBUG,
                    'Updating Meter Usage: ' + meterUsageIds.size()
                );
            Data.remove(energy, false, false, false);

            if (!usageRecords.isEmpty()) {
                
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
            }
        } catch (DmlException e) {
            Logger.getInstance()
                .log(
                    BaseMeterUsageUpdater.class.getName(),
                    Logger.Level.ERROR,
                    'DmlException in updateUtilityMeterUsageToBeIgnored Energy : ' + e.getMessage()
                );
        }
        catch (Exception e) {
            Logger.getInstance()
                .log(
                    BaseMeterUsageUpdater.class.getName(),
                    Logger.Level.ERROR,
                    'Exception in updateUtilityMeterUsageToBeIgnored Energy : ' + e.getMessage()
                );
        }
    } 
    
}
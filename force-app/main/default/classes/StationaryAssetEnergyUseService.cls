public with sharing class StationaryAssetEnergyUseService {
    public StationaryAssetEnergyUseService() {
    }

    public static void createStationaryAssetEnergyUses(UtilityMeterUsage__c meterUsage) {
        if (
            meterUsage != null &&
            meterUsage.PeriodStart__c != null &&
            meterUsage.PeriodEnd__c != null &&
            meterUsage.MeasuredUsage__c != null
        ) {
            //Get the conversion multiplier to be used to convert the usage value from the API measurement to SF supported unit.
            Decimal conversionMultiplier = 1;
            String sfSupportedUnit;
            String usageUnitValue = (meterUsage.UsageUnit__c != null
                ? meterUsage.UsageUnit__c.toLowercase()
                : meterUsage.UsageUnit__c);
            Map<String, EnergyUseConversionMapping__mdt> mapConversionFactor = UrjanetUtils.getEnergyUseConversionMappings();

            if (mapConversionFactor.containsKey(usageUnitValue)) {
                EnergyUseConversionMapping__mdt energyUseConversionMapping = mapConversionFactor.get(usageUnitValue);
                conversionMultiplier = energyUseConversionMapping.ConversionRate__c;
                sfSupportedUnit = energyUseConversionMapping.ApiUnitOfMeasurementTo__c;
            } else {
                Logger.getInstance()
                    .log(
                        StationaryAssetEnergyUseService.class.getName(),
                        String.format(
                            Label.Conversion_Unsupported_Unit,
                            new List<String>{ meterUsage.UsageUnit__c, meterUsage.Id }
                        )
                    );
                return;
            }

            List<StnryAssetEnrgyUse> energyUseList = new List<StnryAssetEnrgyUse>();
            List<UrjanetUtils.SplitDateDetails> lstSplitDateRanges = UrjanetUtils.getDateRanges(meterUsage);

            try {
                for (UrjanetUtils.SplitDateDetails splitDetaildObj : lstSplitDateRanges) {
                    StnryAssetEnrgyUse energyUse = new StnryAssetEnrgyUse();
                    energyUse.StartDate = splitDetaildObj.startDate;
                    energyUse.EndDate = splitDetaildObj.endDate;
                    energyUseList.add(energyUse);
                }

                // Running in System context, ignore CRUD/FLS and Sharing
                Database.DMLOptions option = new Database.DMLOptions();
                option.OptAllOrNone = false;
                Logger.getInstance()
                    .log(
                        StationaryAssetEnergyUseService.class.getName(),
                        UrjanetUtils.getSObjectName(Schema.StnryAssetEnrgyUse.SObjectType),
                        Data.create(
                            populateOtherValuesForEnergyUses(
                                energyUseList,
                                meterUsage,
                                conversionMultiplier,
                                sfSupportedUnit
                            ),
                            option,
                            false,
                            false,
                            false
                        )
                    );
            } catch (DmlException e) {
                Logger.getInstance(false).log(StationaryAssetEnergyUseService.class.getName(), e);
            }
        }
    }

    private static List<StnryAssetEnrgyUse> populateOtherValuesForEnergyUses(
        List<StnryAssetEnrgyUse> energyUses,
        UtilityMeterUsage__c meterUsage,
        Decimal conversionMultiplier,
        String sfSupportedUnit
    ) {
        if (
            meterUsage == null ||
            meterUsage.PeriodStart__c == null ||
            meterUsage.PeriodEnd__c == null ||
            meterUsage.MeasuredUsage__c == null
        ) {
            return new List<StnryAssetEnrgyUse>();
        }

        Integer noOfDays = meterUsage.PeriodStart__c.daysBetween(meterUsage.PeriodEnd__c) + 1;
        Decimal measuredUsageValue = meterUsage.MeasuredUsage__c * conversionMultiplier;
        Decimal perDayMeasure = measuredUsageValue / noOfDays;
        Map<String, String> fuelTypeMappings = UrjanetUtils.getServiceToFuelTypeMappings();

        for (StnryAssetEnrgyUse energyUse : energyUses) {
            energyUse.StnryAssetEnvrSrcId = meterUsage.UtilityMeter__r?.StationaryAssetEnvironmentalSource__c;
            energyUse.SupplierId = meterUsage.UtilityMeter__r
                ?.StationaryAssetEnvironmentalSource__r
                ?.UtilityAccount__r
                ?.UtilityCredential__r
                ?.ProviderName__c;
            energyUse.FuelConsumptionUnit = sfSupportedUnit;
            if (
                meterUsage.UtilityMeter__r?.ServiceType__c != null &&
                fuelTypeMappings.containsKey(meterUsage.UtilityMeter__r?.ServiceType__c)
            ) {
                energyUse.FuelType = fuelTypeMappings.get(meterUsage.UtilityMeter__r?.ServiceType__c);
            } else {
                Logger.getInstance()
                    .log(
                        StationaryAssetEnergyUseService.class.getName(),
                        String.format(
                            Label.Conversion_Unsupported_FuelType,
                            new List<String>{ meterUsage.UtilityMeter__r?.ServiceType__c, meterUsage.Id }
                        )
                    );
                continue;
            }
            energyUse.FuelConsumption = (energyUse.StartDate.daysBetween(energyUse.EndDate) + 1) * perDayMeasure;
            energyUse.UtilityMeterUsage__c = meterUsage.Id;
            energyUse.Name =
                meterUsage.UtilityMeter__r?.StationaryAssetEnvironmentalSource__r?.Name +
                ' - ' +
                DateTime.newInstance(energyUse.StartDate.year(), energyUse.StartDate.month(), energyUse.StartDate.day())
                    .format('MMM') +
                ' - ' +
                String.valueOf(energyUse.StartDate.year());
        }
        return energyUses;
    }
}
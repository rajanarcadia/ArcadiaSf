/****************************************************************************************
Name            : RetrieveMeterDetailsResponse
Revision Log    : 2022-05-11 Mike McGee - CodeScience
                :
                :
Use             :  Urjanet API Callout Response - Retrieve meter details by Meter Id
*****************************************************************************************/
@namespaceAccessible
public class RetrieveMeterDetailsResponse extends UrjanetResponse {
    @namespaceAccessible
    public RetrieveMeterDetailsResponse() {
    }

    @namespaceAccessible
    public Embedded embedded { get; set; }

    @namespaceAccessible
    public class Meter {
        @namespaceAccessible
        public String entityId { get; set; }
        @namespaceAccessible
        public String createdDate { get; set; }
        @namespaceAccessible
        public String serviceType { get; set; }
        @namespaceAccessible
        public String periodStart { get; set; }
        @namespaceAccessible
        public String periodEnd { get; set; }
        @namespaceAccessible
        public String meterReadDate { get; set; }
        @namespaceAccessible
        public String nextReadDate { get; set; }
        @namespaceAccessible
        public String prevReadDate { get; set; }
        @namespaceAccessible
        public String meterNumber { get; set; }
        @namespaceAccessible
        public String normalizedMeterNumber { get; set; }
        @namespaceAccessible
        public String previousMeterNumber { get; set; }
        @namespaceAccessible
        public String normalizedPreviousMeterNumber { get; set; }
        @namespaceAccessible
        public String rateOrTariffActualName { get; set; }
        @namespaceAccessible
        public String podNumber { get; set; }
        @namespaceAccessible
        public String normalizedPodNumber { get; set; }
        @namespaceAccessible
        public String serviceDescription { get; set; }
        @namespaceAccessible
        public String readTypeAsPrinted { get; set; }
        @namespaceAccessible
        public String deregulationStatus { get; set; }
        @namespaceAccessible
        public String accountType { get; set; }
        @namespaceAccessible
        public Address serviceAddress { get; set; }
        @namespaceAccessible
        public Decimal meterConstantMultiplier { get; set; }
        @namespaceAccessible
        public Decimal previousMeterConstantMultiplier { get; set; }
        @namespaceAccessible
        public Decimal meterConversionMultiplier { get; set; }
        @namespaceAccessible
        public String contributionStatus { get; set; }
        @namespaceAccessible
        public Decimal energyCarryForward { get; set; }
        @namespaceAccessible
        public Decimal energyNewCarryForward { get; set; }
        @namespaceAccessible
        public String energyAnniversaryDate { get; set; }
        @namespaceAccessible
        public Decimal lineLoss { get; set; }
        @namespaceAccessible
        public Decimal gridPointLineLoss { get; set; }
        @namespaceAccessible
        public Decimal powerFactor { get; set; }
        @namespaceAccessible
        public String bulbType { get; set; }
        @namespaceAccessible
        public Decimal bulbQuantity { get; set; }
        @namespaceAccessible
        public String pipeType { get; set; }
        @namespaceAccessible
        public Decimal amountDue { get; set; }
        @namespaceAccessible
        public Decimal amountDueAfterDueDate { get; set; }
        @namespaceAccessible
        public Decimal amountDueBeforeDueDate { get; set; }
        @namespaceAccessible
        public Decimal discountBeforeDueDate { get; set; }
        @namespaceAccessible
        public Decimal previousBalance { get; set; }
        @namespaceAccessible
        public Decimal outstandingBalance { get; set; }
        @namespaceAccessible
        public Decimal totalCharges { get; set; }
        @namespaceAccessible
        public Decimal newCharges { get; set; }
        @namespaceAccessible
        public String customerNumber { get; set; }
        @namespaceAccessible
        public String cycleNumber { get; set; }
        @namespaceAccessible
        public String facilityNumber { get; set; }
        @namespaceAccessible
        public String facilityName { get; set; }
        @namespaceAccessible
        public String finalBillNotice { get; set; }
        @namespaceAccessible
        public String mapNumber { get; set; }
        @namespaceAccessible
        public Decimal amountDueByDate { get; set; }
        @namespaceAccessible
        public String disconnectDate { get; set; }
        @namespaceAccessible
        public String totalUsage { get; set; }
        @namespaceAccessible
        public String totalUsageUnit { get; set; }
        @namespaceAccessible
        public String chargeType { get; set; }
        @namespaceAccessible
        public List<Usage> usages { get; set; }
        @namespaceAccessible
        public List<Charge> charges { get; set; }
        @namespaceAccessible
        public InnerLinks links { get; set; }
        @namespaceAccessible
        public String statementId { get; set; }
        @namespaceAccessible
        public String statementDate { get; set; }
    }

    @namespaceAccessible
    public class InnerLinks {
        @namespaceAccessible
        public Href meter { get; set; }
        @namespaceAccessible
        public Href statement { get; set; }
    }

    @namespaceAccessible
    public class Usage {
        @namespaceAccessible
        public String entityId { get; set; }
        @namespaceAccessible
        public String createdDate { get; set; }
        @namespaceAccessible
        public Decimal citedUsage { get; set; }
        @namespaceAccessible
        public String lastModifiedDate { get; set; }
        @namespaceAccessible
        public Decimal measuredUsage { get; set; }
        @namespaceAccessible
        public Decimal noncoincidentalUsage { get; set; }
        @namespaceAccessible
        public Decimal hoursOfUse { get; set; }
        @namespaceAccessible
        public Decimal loadFactor { get; set; }
        @namespaceAccessible
        public Decimal powerFactor { get; set; }
        @namespaceAccessible
        public Decimal previousUsage { get; set; }
        @namespaceAccessible
        public Decimal meterReadingRaw { get; set; }
        @namespaceAccessible
        public Decimal meterReadingDelta { get; set; }
        @namespaceAccessible
        public Decimal meterReadingRawPrevious { get; set; }
        @namespaceAccessible
        public Decimal meterReadingDeltaPrevious { get; set; }
        @namespaceAccessible
        public Decimal numberOfDaysInPeriod { get; set; }
        @namespaceAccessible
        public Decimal pressureMultiplier { get; set; }
        @namespaceAccessible
        public Decimal meterConstantMultiplier { get; set; }
        @namespaceAccessible
        public Decimal meterConversionMultiplier { get; set; }
        @namespaceAccessible
        public Decimal calorificValue { get; set; }
        @namespaceAccessible
        public String loadType { get; set; }
        @namespaceAccessible
        public String readTypeAsPrinted { get; set; }
        @namespaceAccessible
        public String previousReadTypeAsPrinted { get; set; }
        @namespaceAccessible
        public String rateOrTariffActualName { get; set; }
        @namespaceAccessible
        public String usageActualName { get; set; }
        @namespaceAccessible
        public String readingSchedule { get; set; }
        @namespaceAccessible
        public String outageBlock { get; set; }
        @namespaceAccessible
        public String meterReadDate { get; set; }
        @namespaceAccessible
        public String prevReadDate { get; set; }
        @namespaceAccessible
        public String contributionStatus { get; set; }
        @namespaceAccessible
        public String usageUnit { get; set; }
        @namespaceAccessible
        public String meterReadingDeltaUsageUnit { get; set; }
        @namespaceAccessible
        public String measurementType { get; set; }
        @namespaceAccessible
        public String meterReadType { get; set; }
        @namespaceAccessible
        public String previousMeterReadType { get; set; }
        @namespaceAccessible
        public List<TariffRateComponent> tariffRateComponents { get; set; }
    }

    @namespaceAccessible
    public class TariffRateComponent {
        @namespaceAccessible
        public String tariffName { get; set; }
        @namespaceAccessible
        public String tariffRateComponentType { get; set; }
    }

    @namespaceAccessible
    public class Tariff {
        @namespaceAccessible
        public String createdDate { get; set; }
        @namespaceAccessible
        public String providerAlias { get; set; }
        @namespaceAccessible
        public String providerName { get; set; }
        @namespaceAccessible
        public String tariffName { get; set; }
    }

    @namespaceAccessible
    public class Charge {
        @namespaceAccessible
        public String createdDate { get; set; }
        @namespaceAccessible
        public Decimal chargeAmount { get; set; }
        @namespaceAccessible
        public Decimal averageUnitCost { get; set; }
        @namespaceAccessible
        public String chargeActualName { get; set; }
        @namespaceAccessible
        public String chargeGroupHeading { get; set; }
        @namespaceAccessible
        public String chargeName { get; set; }
        @namespaceAccessible
        public String lifecycleStage { get; set; }
        @namespaceAccessible
        public String chargeAmountCurrency { get; set; }
        @namespaceAccessible
        public String chargeRateCurrency { get; set; }
        @namespaceAccessible
        public String measurementType { get; set; }
        @namespaceAccessible
        public String usageUnit { get; set; }
        @namespaceAccessible
        public Decimal chargeUnitsUsed { get; set; }
        @namespaceAccessible
        public Decimal chargeRate { get; set; }
        @namespaceAccessible
        public Decimal chargeRateBase { get; set; }
        @namespaceAccessible
        public Decimal chargeRateAdder { get; set; }
        @namespaceAccessible
        public Decimal unitsPerRate { get; set; }
        @namespaceAccessible
        public Decimal additionalRateMultiplier { get; set; }
        @namespaceAccessible
        public List<TariffRateComponent> tariffRateComponents;
        @namespaceAccessible
        public Tariff tariff;
        @namespaceAccessible
        public String contributionStatus { get; set; }
        @namespaceAccessible
        public String chargeType { get; set; }
    }

    @namespaceAccessible
    public class Embedded {
        @namespaceAccessible
        public List<Meter> meters { get; set; }
    }
}
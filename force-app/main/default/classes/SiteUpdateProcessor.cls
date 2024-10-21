public with sharing class SiteUpdateProcessor extends QueueItemWorkerBase {
    //this method is to update the site in meters on Urjanet application
    public override QueueItem__c process(QueueItem__c queueItem) {
        // Ignoring security here since this is a system process
        UtilityMeter__c meterToProcess = (UtilityMeter__c) new UtilityMeterSelector(false, false, false)
            .getRecordById(queueItem.RecordId__c);
        if (meterToProcess.UrjanetId__c == null) {
            Logger.getInstance()
                .log(
                    SiteUpdateProcessor.class.getName(),
                    Logger.Level.WARN,
                    'Unable to Link Site with meter in Arcadia as Meter ArcadiaId is null : ' + queueItem.RecordId__c
                );
            return queueItem;
        }

        List<String> requestParams = new List<String>{
            meterToProcess.UrjanetId__c,
            meterToProcess.StationaryAssetEnvironmentalSource__r.UrjanetId__c
        };
        LinkMetersAndSiteResponse response = (LinkMetersAndSiteResponse) new UrjanetApiClient()
            .getUrjanetResponse(
                UrjanetEnums.RequestType.UPDATE_SITE_IN_METER,
                UrjanetEnums.ApiMethod.PATCH,
                requestParams
            );
        if (response.errorMsg != null) {
            UrjanetUtils.handleApiError(
                queueItem,
                response.errorMsg,
                response.message,
                response.status,
                SiteUpdateProcessor.class.getName()
            );
        }
        return queueItem;
    }
}
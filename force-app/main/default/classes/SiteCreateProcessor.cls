public with sharing class SiteCreateProcessor extends QueueItemWorkerBase {
    //this method is to update the site in meters on Urjanet application
    public override QueueItem__c process(QueueItem__c queueItem) {
        // Ignoring security here since this is a system process
        StnryAssetEnvrSrc siteToProcess = (StnryAssetEnvrSrc) new StationaryAssetSourceSelector(false, false, false)
            .getRecordById(queueItem.RecordId__c);
        if (siteToProcess.UrjanetId__c == null) {
            List<String> requestParams = new List<String>{
                siteToProcess.City,
                StationaryAssetSourceService.mapToUrjanetCountryCode(siteToProcess.Country),
                siteToProcess.StationaryAssetType,
                siteToProcess.PostalCode,
                siteToProcess.BusinessRegion,
                siteToProcess.UrjanetSiteCode__c,
                siteToProcess.Name,
                siteToProcess.UrjanetSiteNumber__c,
                siteToProcess.UrjanetSubRegion__c,
                siteToProcess.State,
                siteToProcess.StreetAddress,
                siteToProcess.StreetAddress2
            };
            PostSiteResponse response = (PostSiteResponse) new UrjanetApiClient()
                .getUrjanetResponse(UrjanetEnums.RequestType.CREATE_SITE, UrjanetEnums.ApiMethod.POST, requestParams);
            if (response.errorMsg == null) {
                StationaryAssetSourceService.updateSiteDetailsFromResponse(response, queueItem.RecordId__c);
            } else {
                UrjanetUtils.handleApiError(
                    queueItem,
                    response.errorMsg,
                    response.message,
                    response.status,
                    SiteCreateProcessor.class.getName()
                );
            }

            return queueItem;
        }

        return queueItem;
    }
}
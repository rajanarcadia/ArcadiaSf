@namespaceAccessible
public with sharing class LinkMetersAndSiteResponseParser implements UrjanetResponseParser {
    @namespaceAccessible
    public UrjanetResponse parseResponse(HttpResponse response) {
        LinkMetersAndSiteResponse metersResponse = new LinkMetersAndSiteResponse();
        try {
            if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
                String responseString = UrjanetUtils.sanitizeResponse(response?.getBody());
                metersResponse = (LinkMetersAndSiteResponse) JSON.deserialize(
                    responseString,
                    LinkMetersAndSiteResponse.class
                );
                metersResponse.responseType = UrjanetEnums.RequestType.UPDATE_SITE_IN_METER.name();
                metersResponse.responseBody = response?.getBody();
                metersResponse.endpoint = String.format(
                    UrjanetConstants.UPDATE_SITE_IN_METER_API_ENDPOINT,
                    new List<String>{ '{siteId}' }
                );
            } else {
                ErrorResponse errResponse = new ErrorResponse();
                errResponse = (ErrorResponse) JSON.deserialize(
                    UrjanetUtils.sanitizeResponse(response.getBody()),
                    ErrorResponse.class
                );
                metersResponse.errorMsg = errResponse.status + ' ' + errResponse.error;
                metersResponse.message = (errResponse.message != null ? ' Message =' + errResponse.message : '');
                metersResponse.status = errResponse.status;
                metersResponse.endpoint = errResponse.path;
            }
        } catch (Exception e) {
            metersResponse.ex = e;
            Logger.getInstance().log(LinkMetersAndSiteResponse.class.getName(), e);
        }

        return metersResponse;
    }
}
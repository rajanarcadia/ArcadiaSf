public with sharing class PostSiteResponseParser implements UrjanetResponseParser {
    public UrjanetResponse parseResponse(HttpResponse response) {
        PostSiteResponse siteResponse = new PostSiteResponse();
        try {
            if (response.getStatusCode() == 202 && String.isNotBlank(response.getBody())) {
                String responseString = UrjanetUtils.sanitizeResponse(response?.getBody());
                siteResponse = (PostSiteResponse) JSON.deserialize(responseString, PostSiteResponse.class);
                siteResponse.responseType = UrjanetEnums.RequestType.CREATE_SITE.name();
                siteResponse.responseBody = response?.getBody();
                siteResponse.endpoint = UrjanetConstants.POST_SITE_API_ENDPOINT;
            } else {
                ErrorResponse errResponse = new ErrorResponse();
                errResponse = (ErrorResponse) JSON.deserialize(
                    UrjanetUtils.sanitizeResponse(response.getBody()),
                    ErrorResponse.class
                );
                if (errResponse.message != null) {
                    siteResponse.errorMsg = errResponse.message;
                } else {
                    siteResponse.errorMsg = errResponse.status + ' ' + errResponse.error;
                }
                siteResponse.status = errResponse.status;
                siteResponse.endpoint = errResponse.path;
            }
        } catch (Exception e) {
            siteResponse.ex = e;
            Logger.getInstance().log(PostSiteResponse.class.getName(), e);
        }

        return siteResponse;
    }
}
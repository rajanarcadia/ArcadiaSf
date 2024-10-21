public with sharing class PostBulkCredentialsResponseParser implements UrjanetResponseParser{
    public UrjanetResponse parseResponse(HttpResponse response) {
        PostBulkCredentialsResponse bulkResponse = new PostBulkCredentialsResponse();
        try {
            if (response.getStatusCode() == 202 && String.isNotBlank(response.getBody())) {
                String responseString = response?.getBody();
                responseString= responseString.replace('"_links":', '"links":')
                                    .replace('"_embedded":', '"embedded":')
                                    .replace('"number":', '"numbers":')
                                    .replace('"exception":', '"ex":');
                bulkResponse = (PostBulkCredentialsResponse) JSON.deserialize(responseString, PostBulkCredentialsResponse.class);
                bulkResponse.responseType = UrjanetEnums.RequestType.CREATE_BULK_CREDENTIALS.name();
                bulkResponse.responseBody = response?.getBody();
                bulkResponse.endpoint = UrjanetConstants.POST_BULK_CREDENTIALS_API_ENDPOINT;
            } else {
                ErrorResponse errResponse = new ErrorResponse();
                errResponse = (ErrorResponse) JSON.deserialize(
                    UrjanetUtils.sanitizeResponse(response.getBody()),
                    ErrorResponse.class
                );
                if (errResponse.message != null) {
                    bulkResponse.errorMsg = errResponse.message;
                } else {
                    bulkResponse.errorMsg = errResponse.status + ' ' + errResponse.error;
                }
                bulkResponse.status = String.valueOf(errResponse.status);
                bulkResponse.endpoint = errResponse.path;
            }
        } catch (Exception e) {
            bulkResponse.ex = e;
            Logger.getInstance().log(PostBulkCredentialsResponse.class.getName(), e);
        }

        return bulkResponse;
    }
}
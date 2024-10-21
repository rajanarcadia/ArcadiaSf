public with sharing class GetCredentialsResponseParser implements UrjanetResponseParser {
    public UrjanetResponse parseResponse(HttpResponse response) {
        GetCredentialsResponse credentialResponse = new GetCredentialsResponse();
        try {
            if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
                String responseString = UrjanetUtils.sanitizeResponse(response?.getBody());
                credentialResponse = (GetCredentialsResponse) JSON.deserialize(
                    responseString,
                    GetCredentialsResponse.class
                );
                credentialResponse.responseType = UrjanetEnums.RequestType.CREDENTIALS_BY_CORRELATION_ID.name();
                credentialResponse.responseBody = response?.getBody();
                credentialResponse.endpoint = String.format(
                    UrjanetConstants.CREDENTIALS_BY_CORRELATIONID_API_ENDPOINT,
                    new List<String>{ '{accountId}' }
                );
            } else {
                ErrorResponse errResponse = new ErrorResponse();
                errResponse = (ErrorResponse) JSON.deserialize(
                    UrjanetUtils.sanitizeResponse(response.getBody()),
                    ErrorResponse.class
                );
                credentialResponse.errorMsg = errResponse.status + ' ' + errResponse.error;
                credentialResponse.message = (errResponse.message != null ? ' Message =' + errResponse.message : '');
                credentialResponse.endpoint = errResponse.path;
                return credentialResponse;
            }
        } catch (Exception e) {
            credentialResponse.ex = e;
            Logger.getInstance()
                .log(
                    GetCredentialsResponseParser.class.getName(),
                    UrjanetConstants.CREDENTIALS_API_ERROR_MESSAGE,
                    Logger.Level.ERROR,
                    e
                );
        }

        return credentialResponse;
    }
}
public with sharing class GetUpdateUrlByCredResponseParser implements UrjanetResponseParser {
    public UrjanetResponse parseResponse(HttpResponse response) {
        GetUpdateUrlByCredentialResponse updateUrlResponse = new GetUpdateUrlByCredentialResponse();
        try {
            if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
                String responseString = UrjanetUtils.sanitizeResponse(response?.getBody());
                updateUrlResponse = (GetUpdateUrlByCredentialResponse) JSON.deserialize(
                    responseString,
                    GetUpdateUrlByCredentialResponse.class
                );
                updateUrlResponse.responseType = UrjanetEnums.RequestType.UPDATE_URL_BY_CREDENTIAL.name();
                updateUrlResponse.responseBody = response?.getBody();
                updateUrlResponse.endpoint = String.format(
                    UrjanetConstants.UPDATE_URL_BY_CREDENTIAL_API_ENDPOINT,
                    new List<String>{ '{credentialId}' }
                );
            } else {
                ErrorResponse errResponse = new ErrorResponse();
                errResponse = (ErrorResponse) JSON.deserialize(
                    UrjanetUtils.sanitizeResponse(response.getBody()),
                    ErrorResponse.class
                );
                updateUrlResponse.errorMsg = errResponse.status + ' ' + errResponse.error;
                updateUrlResponse.message = (errResponse.message != null ? ' Message =' + errResponse.message : '');
                updateUrlResponse.endpoint = errResponse.path;
                return updateUrlResponse;
            }
        } catch (Exception e) {
            updateUrlResponse.ex = e;
            Logger.getInstance()
                .log(
                    GetUpdateUrlByCredResponseParser.class.getName(),
                    UrjanetConstants.UPDATE_URL_API_ERROR_MESSAGE,
                    Logger.Level.ERROR,
                    e
                );
        }

        return updateUrlResponse;
    }
}
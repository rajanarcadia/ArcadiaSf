public with sharing class GetArcadiaServiceProvidersResponseParser implements UrjanetResponseParser {
    public UrjanetResponse parseResponse(HttpResponse response) {
        GetArcadiaServiceProvidersResponse arcadiaProvidersResponse = new GetArcadiaServiceProvidersResponse();
        try {
            if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
                String responseString = response?.getBody();
                responseString = responseString.replace('"_links"', '"links"')
                    .replace('"_embedded"', '"embedded"')
                    .replace('"number"', '"numbers"')
                    .replace('"exception"', '"ex"');

                arcadiaProvidersResponse = (GetArcadiaServiceProvidersResponse) JSON.deserialize(
                    responseString,
                    GetArcadiaServiceProvidersResponse.class
                );
                arcadiaProvidersResponse.responseType = UrjanetEnums.RequestType.LIST_PROVIDERS.name();
                arcadiaProvidersResponse.responseBody = response?.getBody();
                arcadiaProvidersResponse.endpoint = String.format(
                    UrjanetConstants.ARCADIA_SERVICE_PROVIDER_ENDPOINT,
                    new List<String>()
                );
            } else {
                ErrorResponse errResponse = new ErrorResponse();
                errResponse = (ErrorResponse) JSON.deserialize(
                    UrjanetUtils.sanitizeResponse(response.getBody()),
                    ErrorResponse.class
                );
                arcadiaProvidersResponse.errorMsg = errResponse.status + ' ' + errResponse.error;
                arcadiaProvidersResponse.message = (errResponse.message != null
                    ? ' Message =' + errResponse.message
                    : '');
                arcadiaProvidersResponse.endpoint = errResponse.path;
                return arcadiaProvidersResponse;
            }
        } catch (Exception e) {
            arcadiaProvidersResponse.ex = e;
            Logger.getInstance()
                .log(
                    GetArcadiaServiceProvidersResponseParser.class.getName(),
                    UrjanetConstants.GET_UTILITY_STATEMENT_FILES_ERROR_MESSAGE,
                    Logger.Level.ERROR,
                    e
                );
        }

        return arcadiaProvidersResponse;
    }
}
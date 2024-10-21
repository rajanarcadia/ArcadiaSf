public with sharing class GetUtilityStatementFilesResponseParser implements UrjanetResponseParser {
    public UrjanetResponse parseResponse(HttpResponse response) {
        GetUtilityStatementFilesResponse utilStatementFilesResponse = new GetUtilityStatementFilesResponse();
        try {
            if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
                String responseString = UrjanetUtils.sanitizeResponse(response?.getBody());
                utilStatementFilesResponse = (GetUtilityStatementFilesResponse) JSON.deserialize(
                    responseString,
                    GetUtilityStatementFilesResponse.class
                );
                utilStatementFilesResponse.responseType = UrjanetEnums.RequestType.STATEMENT_FILES_BY_ENTITY_ID.name();
                utilStatementFilesResponse.responseBody = response?.getBody();
                utilStatementFilesResponse.endpoint = String.format(
                    UrjanetConstants.UTILITY_STATMENT_FILES_BY_ENTITYID_API_ENDPOINT,
                    new List<String>{ '{FileIds}' }
                );
            } else {
                ErrorResponse errResponse = new ErrorResponse();
                errResponse = (ErrorResponse) JSON.deserialize(
                    UrjanetUtils.sanitizeResponse(response.getBody()),
                    ErrorResponse.class
                );
                utilStatementFilesResponse.errorMsg = errResponse.status + ' ' + errResponse.error;
                utilStatementFilesResponse.message = (errResponse.message != null
                    ? ' Message =' + errResponse.message
                    : '');
                utilStatementFilesResponse.endpoint = errResponse.path;
                return utilStatementFilesResponse;
            }
        } catch (Exception e) {
            utilStatementFilesResponse.ex = e;
            Logger.getInstance()
                .log(
                    GetUtilityStatementFilesResponseParser.class.getName(),
                    UrjanetConstants.GET_UTILITY_STATEMENT_FILES_ERROR_MESSAGE,
                    Logger.Level.ERROR,
                    e
                );
        }

        return utilStatementFilesResponse;
    }
}
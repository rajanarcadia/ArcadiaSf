public with sharing class ResponseParserFactory {
    public HttpRequest request;

    public ResponseParserFactory() {
    }

    public UrjanetResponseParser getResponseParser(UrjanetEnums.RequestType requestType) {
        UrjanetResponseParser responseParser;

        if (requestType == UrjanetEnums.RequestType.LOGIN) {
            responseParser = new LoginResponseParser();
        } else if (requestType == UrjanetEnums.RequestType.CREDENTIALS_BY_CORRELATION_ID) {
            responseparser = new GetCredentialsResponseParser();
        } else if (requestType == UrjanetEnums.RequestType.STATEMENT_FILES_BY_ENTITY_ID) {
            responseparser = new GetUtilityStatementFilesResponseParser();
        } else if (requestType == UrjanetEnums.RequestType.ACCOUNTS_BY_CREDS) {
            responseparser = new GetAccountsByCredsResponseParser();
        } else if (requestType == UrjanetEnums.RequestType.ACCOUNTS_BY_STATEMENTIDS) {
            responseparser = new GetAccountsByStatementIdsResponseParser();
        } else if (requestType == UrjanetEnums.RequestType.UPDATE_URL_BY_CREDENTIAL) {
            responseparser = new GetUpdateUrlByCredResponseParser();
        } else if (requestType == UrjanetEnums.RequestType.METERS_BY_ACCOUNT) {
            responseparser = new GetMetersByAccountResponseParser();
        } else if (requestType == UrjanetEnums.RequestType.RETRIEVE_METER_DETAILS) {
            responseparser = new RetrieveMeterDetailsResponseParser();
        } else if (requestType == UrjanetEnums.RequestType.RETRIEVE_ALL_METER_DETAILS) {
            responseparser = new RetrieveMeterDetailsResponseParser();
        } else if (requestType == UrjanetEnums.RequestType.UPDATE_SITE_IN_METER) {
            responseparser = new LinkMetersAndSiteResponseParser();
        } else if (requestType == UrjanetEnums.RequestType.CREATE_SITE) {
            responseparser = new PostSiteResponseParser();
        } else if (requestType == UrjanetEnums.RequestType.CREATE_BULK_CREDENTIALS) {
            responseparser = new PostBulkCredentialsResponseParser();
        } else if (requestType == UrjanetEnums.RequestType.LIST_PROVIDERS) {
            responseparser = new GetArcadiaServiceProvidersResponseParser();
        } else if (requestType == UrjanetEnums.RequestType.DISABLE_CREDENTIAL) {
            responseparser = new DisableCredentialResponseParser();
        } else if (requestType == UrjanetEnums.RequestType.DELETE_CREDENTIAL) {
            responseparser = new DeleteCredentialResponseParser();
        } else if (requestType == UrjanetEnums.RequestType.GET_DELETION_JOB_STATUS) {
            responseparser = new CredentialDeletionJobResponseParser();
        }

        return responseParser;
    }
}
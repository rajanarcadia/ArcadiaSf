/****************************************************************************************
Name            : RequestBuilderFactory
Revision Log    : 2022-04-19 Abhi Tangudu - CodeScience
                :
                :
Use             :  To build requests to get update url from Urjanet via API
*****************************************************************************************/
public with sharing class RequestBuilderFactory {
    public class UnhandledRequestException extends Exception {
    }

    /**
     * Provides the request builder based on the arguements
     * @param  args type of callout, callout params etcc
     * @return      Request builder
     */
    public UrjanetRequestBuilder getRequestBuilder(UrjanetRequestArgs args) {
        UrjanetRequestBuilder requestBuilder;

        if (args.requestType == UrjanetEnums.RequestType.CREDENTIALS_BY_CORRELATION_ID) {
            requestBuilder = new GetCredentialsRequestBuilder(args);
        } else if (args.requestType == UrjanetEnums.RequestType.STATEMENT_FILES_BY_ENTITY_ID) {
            requestBuilder = new GetUtilityStatementFilesRequestBuilder(args);
        } else if (args.requestType == UrjanetEnums.RequestType.ACCOUNTS_BY_CREDS) {
            requestBuilder = new GetAccountsByCredentialRequestBuilder(args);
        } else if (args.requestType == UrjanetEnums.RequestType.ACCOUNTS_BY_STATEMENTIDS) {
            requestBuilder = new GetAccountsByStatementIdRequestBuilder(args);
        } else if (args.requestType == UrjanetEnums.RequestType.UPDATE_URL_BY_CREDENTIAL) {
            requestBuilder = new GetUpdateUrlByCredentialRequestBuilder(args);
        } else if (args.requestType == UrjanetEnums.RequestType.METERS_BY_ACCOUNT) {
            requestBuilder = new GetMetersByAccountRequestBuilder(args);
        } else if (args.requestType == UrjanetEnums.RequestType.RETRIEVE_METER_DETAILS) {
            requestBuilder = new RetrieveMeterDetailsRequestBuilder(args);
        } else if (args.requestType == UrjanetEnums.RequestType.RETRIEVE_ALL_METER_DETAILS) {
            requestBuilder = new RetrieveAllMeterDetailsRequestBuilder(args);
        } else if (args.requestType == UrjanetEnums.RequestType.UPDATE_SITE_IN_METER) {
            requestBuilder = new UpdateSiteInMeterRequestBuilder(args);
        } else if (args.requestType == UrjanetEnums.RequestType.CREATE_SITE) {
            requestBuilder = new CreateSiteRequestBuilder(args);
        } else if (args.requestType == UrjanetEnums.RequestType.CREATE_BULK_CREDENTIALS) {
            requestBuilder = new CreateBulkCredentialsRequestBuilder(args);
        } else if (args.requestType == UrjanetEnums.RequestType.LIST_PROVIDERS) {
            requestBuilder = new GetArcadiaServiceProvidersRequestBuilder(args);
        } else if (args.requestType == UrjanetEnums.RequestType.DISABLE_CREDENTIAL) {
            requestBuilder = new DisableCredentialRequestBuilder(args);
        } else if (args.requestType == UrjanetEnums.RequestType.DELETE_CREDENTIAL) {
            requestBuilder = new DeleteCredentialRequestBuilder(args);
        } else if (args.requestType == UrjanetEnums.RequestType.GET_DELETION_JOB_STATUS) {
            requestBuilder = new CredentialDeletionJobRequestBuilder(args);
        } else {
            throw new UnhandledRequestException(UrjanetConstants.UNHANDLED_REQUEST);
        }

        return requestBuilder;
    }
}
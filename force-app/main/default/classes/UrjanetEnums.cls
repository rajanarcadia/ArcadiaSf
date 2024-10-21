public with sharing class UrjanetEnums {
    public UrjanetEnums() {
    }

    public enum RequestType {
        LOGIN,
        LOGIN_CREDS,
        CREDENTIALS_BY_CORRELATION_ID,
        STATEMENT_FILES_BY_ENTITY_ID,
        ACCOUNTS_BY_CREDS,
        ACCOUNTS_BY_STATEMENTIDS,
        UPDATE_URL_BY_CREDENTIAL,
        RETRIEVE_METER_DETAILS,
        RETRIEVE_ALL_METER_DETAILS,
        UPDATE_SITE_IN_METER,
        METERS_BY_ACCOUNT,
        CREATE_SITE,
        LIST_PROVIDERS,
        CREATE_BULK_CREDENTIALS,
        DISABLE_CREDENTIAL,
        DELETE_CREDENTIAL,
        GET_DELETION_JOB_STATUS
    }

    public enum ApiMethod {
        GET,
        POST,
        PATCH,
        DELETE_METHOD
    }

    public enum AccessTokenType {
        CALLOUT
    }
}
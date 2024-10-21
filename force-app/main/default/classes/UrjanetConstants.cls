public with sharing class UrjanetConstants {
    //Urjanet Error messages
    public static final String UNHANDLED_REQUEST = 'Unknown request type';
    public static final String LOGIN_FAILURE = System.Label.Arcadia_Login_Failure_Error_Message;
    public static final String SAES_RECORD_CREATION_FAILURE_TITLE = System.Label.SAESRecordCreatiomErrorMessageTitle;
    public static final String SAES_RECORD_CREATION_FAILURE_1 = System.Label.SAESRecordCreatiomErrorMessage;
    public static final String SAES_RECORD_CREATION_FAILURE_2 = System.Label.SAESRecordCreationErrorMessage2;
    public static final String CREDENTIALS_API_ERROR_MESSAGE = System.Label.GetCredentialsErrorMessage;
    public static final String GET_UTILITY_STATEMENT_FILES_ERROR_MESSAGE = System.Label.GetUtilityStatementFilesErrorMessage;
    public static final String GET_ARCADIA_PROVIDERS_ERROR_MESSAGE = System.Label.GetArcadiaServiceProvidersErrorMessage;
    public static final String SITES_API_ERROR_MESSAGE = System.Label.GetSitesErrorMessage;
    public static final String STATEMENTS_API_ERROR_MESSAGE = System.Label.GetStatementsErrorMessage;
    public static final String UPDATE_URL_API_ERROR_MESSAGE = System.Label.GetUpdateUrlErrorMessage;
    public static final String RETRIEVE_METER_DETAILS_ERROR_MESSAGE = System.Label.RetrieveMetersErrorMessage;
    public static final String UPDATE_SITE_IN_METER_ERROR_MESSAGE = System.Label.UpdateSiteInMeterErrorMessage;
    public static final String METERS_BY_ACCOUNT_API_ERROR_MESSAGE = System.Label.GetMetersByAccountErrorMessage;

    public static final Integer FALLBACK_PAGE_SIZE = 100;
    public static final Integer FALLBACK_BATCH_SIZE = 20;

    public static final List<String> growthServiceTypes = new List<String>{ 'water', 'irrigation' };

    //Urjanet Api Endpoints
    public static final String CREDENTIALS_BY_CORRELATIONID_API_ENDPOINT =
        'callout:' +
        UrjanetUtils.getNamespaceWithUnderscores() +
        'Urjanet/utility/credentials?search=correlationId=in={0}';
    public static final String PLUG_BASE_URL = 'https://api.arcadia.com/plug/';
    public static final String CREDENTIALS_DELETE_API_ENDPOINT = PLUG_BASE_URL + 'credentials/crd_{0}/resources';
    public static final String CREDENTIALS_DISABLE_API_ENDPOINT =
        PLUG_BASE_URL + 'credentials/crd_{0}/disable-resources';
    public static final String DELETION_JOB_STATUS_API_ENDPOINT = PLUG_BASE_URL + 'deletionLogs/{0}';
    public static final String UTILITY_STATMENT_FILES_BY_ENTITYID_API_ENDPOINT =
        'callout:' +
        UrjanetUtils.getNamespaceWithUnderscores() +
        'Urjanet/utility/files?search=id=in={0}';
    public static final String ARCADIA_SERVICE_PROVIDER_ENDPOINT =
        'callout:' +
        UrjanetUtils.getNamespaceWithUnderscores() +
        'Urjanet/utility/providers?size={0}&page={1}';
    public static final String ACCOUNTS_BY_CREDENTIAL_API_ENDPOINT =
        'callout:' +
        UrjanetUtils.getNamespaceWithUnderscores() +
        'Urjanet/utility/credentials/{0}/accounts?size={1}&page={2}&sort=id,desc';
    public static final String ACCOUNTS_BY_STATEMENTS_API_ENDPOINT =
        'callout:' +
        UrjanetUtils.getNamespaceWithUnderscores() +
        'Urjanet/utility/statements/{0}/accounts';
    public static final String UPDATE_URL_BY_CREDENTIAL_API_ENDPOINT =
        'callout:' +
        UrjanetUtils.getNamespaceWithUnderscores() +
        'Urjanet/utility/credentials/{0}/updateUrl';
    public static final String METERS_BY_ACCOUNT_API_ENDPOINT_STRING =
        'callout:' +
        UrjanetUtils.getNamespaceWithUnderscores() +
        'Urjanet/utility/accounts/{0}/meters?size={1}&page={2}&sort=id,desc&search=meterDataLastUpdatedAt%3E%20{3}';
    public static final String RETRIEVE_METER_DETAILS_API_ENDPOINT =
        'callout:' +
        UrjanetUtils.getNamespaceWithUnderscores() +
        'Urjanet/utility/meters/{0}/meterData?size={1}&page={2}&sort=measurementPeriod.intervalStart,asc&sort=deregulationStatus';
    public static final String RETRIEVE_ALL_METER_DETAILS_API_ENDPOINT =
        'callout:' +
        UrjanetUtils.getNamespaceWithUnderscores() +
        'Urjanet/utility/meters/{0}/meterData?search=deregulationStatus!=supply&size=100&sort=measurementPeriod.intervalStart,asc';
    public static final String UPDATE_SITE_IN_METER_API_ENDPOINT =
        'callout:' +
        UrjanetUtils.getNamespaceWithUnderscores() +
        'Urjanet/utility/meters/{0}';
    public static final String POST_SITE_API_ENDPOINT =
        'callout:' +
        UrjanetUtils.getNamespaceWithUnderscores() +
        'Urjanet/utility/sites';
    public static final String POST_BULK_CREDENTIALS_API_ENDPOINT =
        'callout:' +
        UrjanetUtils.getNamespaceWithUnderscores() +
        'Urjanet/utility/asyncJobs/bulkCredentialUpload';
    public static final String POST_STATEMENT_ENDPOINT = 'https://downloads.urjanet.com/utility/files';

    //Canvas App
    public static final String CREDENTIAL_STATUS = 'SENT_TO_URJANET';
    public static final String SUCCESS_MESSAGE = 'SUCCESS';
    public static final String FAILURE_MESSAGE = 'FAILURE';

    // App Constants
    public static final String RATE_TYPE_TOTAL = 'total';
    public static final String GENERAL_CONSUMPTION = 'general_consumption';
    public static final String KWH_UNIT = 'KWH';
    public static final String KVARH_UNIT = 'KVARH';
    public static final String CONTRIBUTING = 'CONTRIBUTING';

    //DELETE & DISABLE API CONSTANTS
    public static final String DELETE_API_STATUS_SCHEDULED = 'SCHEDULED';
    public static final String DELETE_API_STATUS_PENDING = 'PENDING';
    public static final String DELETE_API_STATUSCODE_DELETE = 'DELETE';
    public static final String DELETE_API_STATUSCODE_PATCH = 'PATCH';
    public static final String CRED_DEL_STATUS_INPROGRESS = 'In Progress';
    public static final String CRED_DEL_STATUS_FAILED = 'Failed';

    public static final String DELETE_IN_SFDC = 'DELETE_IN_SFDC';
    public static final String DELETE_IN_BOTH = 'DELETE_IN_BOTH';
    public static final String FAILED_TO_DELETE_CREDENTIAL = 'Failed to delete credential : ';
    public static final String FAILED_TO_DISABLE_CREDENTIAL = 'Failed to disable Credential : ';

    //CREDENTIAL DELETION JOB API CONSTANTS
    public static final String CRED_DELETION_JOB_STATUS_COMPLETED = 'COMPLETED';
    public static final String CRED_DELETION_JOB_STATUS_SUCCESS = 'SUCCESS';
    public static final String ERROR_IN_PROCESSING_CREDENTIAL_DELETION_JOB = 'Error in Processing Credential Deletion Job : ';
}
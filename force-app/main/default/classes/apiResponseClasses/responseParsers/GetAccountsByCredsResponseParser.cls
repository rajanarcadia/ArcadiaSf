public with sharing class GetAccountsByCredsResponseParser implements UrjanetResponseParser {
    public UrjanetResponse parseResponse(HttpResponse response) {
        GetAccountsByCredsResponse accountsResponse = new GetAccountsByCredsResponse();
        try {
            if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
                String responseString = UrjanetUtils.sanitizeResponse(response?.getBody());
                accountsResponse = (GetAccountsByCredsResponse) JSON.deserialize(
                    responseString,
                    GetAccountsByCredsResponse.class
                );
                accountsResponse.responseType = UrjanetEnums.RequestType.ACCOUNTS_BY_CREDS.name();
                accountsResponse.responseBody = response?.getBody();
                accountsResponse.endpoint = String.format(
                    UrjanetConstants.ACCOUNTS_BY_CREDENTIAL_API_ENDPOINT,
                    new List<String>{ '{credentialId}' }
                );
            } else {
                ErrorResponse errResponse = new ErrorResponse();
                errResponse = (ErrorResponse) JSON.deserialize(
                    UrjanetUtils.sanitizeResponse(response.getBody()),
                    ErrorResponse.class
                );
                accountsResponse.errorMsg = errResponse.status + ' ' + errResponse.error;
                accountsResponse.message = (errResponse.message != null ? ' Message =' + errResponse.message : '');
                accountsResponse.status = errResponse.status;
                accountsResponse.endpoint = errResponse.path;
            }
        } catch (Exception e) {
            accountsResponse.ex = e;
            Logger.getInstance().log(GetAccountsByCredsResponse.class.getName(), e);
        }

        return accountsResponse;
    }
}
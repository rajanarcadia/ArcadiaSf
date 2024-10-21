public with sharing class GetMetersByAccountResponseParser implements UrjanetResponseParser {
    public UrjanetResponse parseResponse(HttpResponse response) {
        GetMetersByAccountResponse metersResponse = new GetMetersByAccountResponse();
        try {
            if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
                String responseString = UrjanetUtils.sanitizeResponse(response?.getBody());
                metersResponse = (GetMetersByAccountResponse) JSON.deserialize(
                    responseString,
                    GetMetersByAccountResponse.class
                );
                metersResponse.responseType = UrjanetEnums.RequestType.METERS_BY_ACCOUNT.name();
                metersResponse.responseBody = response?.getBody();
                metersResponse.endpoint = String.format(
                    UrjanetConstants.METERS_BY_ACCOUNT_API_ENDPOINT_STRING,
                    new List<String>{ '{accountId}' }
                );
            } else {
                ErrorResponse errResponse = new ErrorResponse();
                errResponse = (ErrorResponse) JSON.deserialize(
                    UrjanetUtils.sanitizeResponse(response.getBody()),
                    ErrorResponse.class
                );
                metersResponse.errorMsg = errResponse.status + ' ' + errResponse.error;
                metersResponse.message = (errResponse.message != null ? ' Message =' + errResponse.message : '');
                metersResponse.status = errResponse.status;
                metersResponse.endpoint = errResponse.path;
            }
        } catch (Exception e) {
            metersResponse.ex = e;
            Logger.getInstance()
                .log(
                    GetMetersByAccountResponse.class.getName(),
                    UrjanetConstants.METERS_BY_ACCOUNT_API_ERROR_MESSAGE,
                    Logger.Level.ERROR,
                    e
                );
        }

        return metersResponse;
    }
}
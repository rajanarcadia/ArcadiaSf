@namespaceAccessible
public with sharing class RetrieveMeterDetailsResponseParser implements UrjanetResponseParser {
    @namespaceAccessible
    public UrjanetResponse parseResponse(HttpResponse response) {
        RetrieveMeterDetailsResponse meterResponse = new RetrieveMeterDetailsResponse();
        try {
            if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
                String responseString = UrjanetUtils.sanitizeResponse(response?.getBody());
                meterResponse = (RetrieveMeterDetailsResponse) JSON.deserialize(
                    responseString,
                    RetrieveMeterDetailsResponse.class
                );
                meterResponse.responseType = UrjanetEnums.RequestType.RETRIEVE_METER_DETAILS.name();
                meterResponse.responseBody = response?.getBody();
                meterResponse.endpoint = String.format(
                    UrjanetConstants.RETRIEVE_METER_DETAILS_API_ENDPOINT,
                    new List<String>{ '{meterId}' }
                );
            } else {
                ErrorResponse errResponse = new ErrorResponse();
                errResponse = (ErrorResponse) JSON.deserialize(
                    UrjanetUtils.sanitizeResponse(response.getBody()),
                    ErrorResponse.class
                );
                if (!String.isEmpty(errResponse.error)) {
                    meterResponse.errorMsg = errResponse.status + ' ' + errResponse.error;
                    meterResponse.message = (errResponse.message != null ? ' Message =' + errResponse.message : '');
                }
                meterResponse.status = errResponse.status;
                meterResponse.endpoint = errResponse.path;
            }
        } catch (Exception e) {
            meterResponse.ex = e;
            Logger.getInstance()
                .log(
                    RetrieveMeterDetailsResponseParser.class.getName(),
                    UrjanetConstants.RETRIEVE_METER_DETAILS_ERROR_MESSAGE,
                    Logger.Level.ERROR,
                    e
                );
        }

        return meterResponse;
    }
}
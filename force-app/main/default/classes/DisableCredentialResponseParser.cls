public with sharing class DisableCredentialResponseParser implements UrjanetResponseParser {
    public UrjanetResponse parseResponse(HttpResponse response) {
        DisablePlugApiResponse disableResponse = new DisablePlugApiResponse();
        try {
            if (response.getStatusCode() == 202 && String.isNotBlank(response.getBody())) {
                disableResponse = (DisablePlugApiResponse) JSON.deserialize(
                    response.getBody(),
                    DisablePlugApiResponse.class
                );
                disableResponse.responseType = UrjanetEnums.RequestType.DISABLE_CREDENTIAL.name();
                disableResponse.responseBody = response?.getBody();
                String credId = ((disableResponse.id != null && disableResponse.id.contains('crd_'))
                    ? disableResponse.id.substringAfter('crd_')
                    : '');
                disableResponse.endpoint = String.format(
                    UrjanetConstants.CREDENTIALS_DELETE_API_ENDPOINT,
                    new List<String>{ credId }
                );
            } else {
                disableResponse.errorMsg = response.getBody();
            }
            disableResponse.statusCode = response.getStatusCode();
        } catch (Exception e) {
            disableResponse.ex = e;
            disableResponse.errorMsg = e.getMessage();
        }
        return disableResponse;
    }
}
public with sharing class DeleteCredentialResponseParser implements UrjanetResponseParser {
    public UrjanetResponse parseResponse(HttpResponse response) {
        DeletePlugApiResponse deleteResponse = new DeletePlugApiResponse();
        try {
            if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
                deleteResponse = (DeletePlugApiResponse) JSON.deserialize(
                    response.getBody(),
                    DeletePlugApiResponse.class
                );
                deleteResponse.responseType = UrjanetEnums.RequestType.DELETE_CREDENTIAL.name();
                deleteResponse.responseBody = response?.getBody();
                deleteResponse.endpoint = String.format(
                    UrjanetConstants.CREDENTIALS_DELETE_API_ENDPOINT,
                    new List<String>()
                );
            } else {
                deleteResponse.errorMsg = response.getBody();
            }
            deleteResponse.statusCode = response.getStatusCode();
        } catch (Exception e) {
            deleteResponse.ex = e;
            deleteResponse.errorMsg = e.getMessage();
            Logger.getInstance().log(DeleteCredentialApiController.class.getName(), e);
        }
        return deleteResponse;
    }
}
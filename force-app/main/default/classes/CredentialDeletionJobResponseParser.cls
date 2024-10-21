public with sharing class CredentialDeletionJobResponseParser implements UrjanetResponseParser {
    public UrjanetResponse parseResponse(HttpResponse response) {
        CredentialDeletionJobApiResponse deletionJobResponse = new CredentialDeletionJobApiResponse();
        try {
            if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
                deletionJobResponse = (CredentialDeletionJobApiResponse) JSON.deserialize(
                    response.getBody(),
                    CredentialDeletionJobApiResponse.class
                );
                deletionJobResponse.responseType = UrjanetEnums.RequestType.GET_DELETION_JOB_STATUS.name();
                deletionJobResponse.responseBody = response?.getBody();
                String delJobId = ((deletionJobResponse.id != null && deletionJobResponse.id.contains('del_'))
                    ? deletionJobResponse.id.substringAfter('del_')
                    : '');
                deletionJobResponse.endpoint = String.format(
                    UrjanetConstants.DELETION_JOB_STATUS_API_ENDPOINT,
                    new List<String>{ delJobId }
                );
            } else {
                deletionJobResponse.errorMsg = response.getBody();
            }
            deletionJobResponse.statusCode = response.getStatusCode();
        } catch (Exception e) {
            deletionJobResponse.ex = e;
            deletionJobResponse.errorMsg = e.getMessage();
            Logger.getInstance().log(CredentialDeletionJobBatch.class.getName(), e);
        }
        return deletionJobResponse;
    }
}
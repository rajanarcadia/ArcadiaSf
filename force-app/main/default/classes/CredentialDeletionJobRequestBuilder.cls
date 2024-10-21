public with sharing class CredentialDeletionJobRequestBuilder extends UrjanetRequestBuilder {
    public CredentialDeletionJobRequestBuilder(UrjanetRequestArgs args) {
        super(args);
    }

    /**
     * Generates a HttpRequest for GET callout to get the status of Deletion job Id
     * @return   DELETION job GET HttpRequest
     */
    public override HttpRequest buildRequest() {
        String formattedEndPoint = String.format(UrjanetConstants.DELETION_JOB_STATUS_API_ENDPOINT, args.requestParams);
        this.request.setEndpoint(formattedEndPoint);
        this.request.setMethod(UrjanetEnums.apiMethod.GET.name());
        this.request.setHeader('Arc-Version', System.Label.Arcadia_Plug_API_Arc_Version);
        this.request.setHeader('Sandbox-Mode', 'false');
        this.request.setHeader('Accept', 'application/json');
        return this.request;
    }
}
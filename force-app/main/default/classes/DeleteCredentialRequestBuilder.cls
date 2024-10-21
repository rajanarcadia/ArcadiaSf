public with sharing class DeleteCredentialRequestBuilder extends UrjanetRequestBuilder {
    public DeleteCredentialRequestBuilder(UrjanetRequestArgs args) {
        super(args);
    }

    /**
     * Generates a HttpRequest for GET callout to delete Credentials API endpoint to delete Credentials by correlation Id
     * @return   Credentials PATCH HttpRequest
     */
    public override HttpRequest buildRequest() {
        String formattedEndPoint = String.format(UrjanetConstants.CREDENTIALS_DELETE_API_ENDPOINT, args.requestParams);
        this.request.setEndpoint(formattedEndPoint);
        this.request.setMethod(UrjanetConstants.DELETE_API_STATUSCODE_DELETE);
        this.request.setHeader('Arc-Version', System.Label.Arcadia_Plug_API_Arc_Version);
        this.request.setHeader('Sandbox-Mode', 'false');
        this.request.setHeader('Accept', 'application/json');
        return this.request;
    }
}
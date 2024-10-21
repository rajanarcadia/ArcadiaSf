public with sharing class DisableCredentialRequestBuilder extends UrjanetRequestBuilder {
    public DisableCredentialRequestBuilder(UrjanetRequestArgs args) {
        super(args);
    }

    /**
     * Generates a HttpRequest for GET callout to Disable Credentials API endpoint to disable Credentials by correlation Id
     * @return   Credentials PATCH HttpRequest
     */
    public override HttpRequest buildRequest() {
        String formattedEndPoint = String.format(UrjanetConstants.CREDENTIALS_DISABLE_API_ENDPOINT, args.requestParams);
        this.request.setEndpoint(formattedEndPoint);
        this.request.setMethod(UrjanetEnums.apiMethod.PATCH.name());
        this.request.setHeader('Arc-Version', System.Label.Arcadia_Plug_API_Arc_Version);
        this.request.setHeader('Sandbox-Mode', 'false');
        this.request.setHeader('Accept', 'application/json');
        return this.request;
    }
}
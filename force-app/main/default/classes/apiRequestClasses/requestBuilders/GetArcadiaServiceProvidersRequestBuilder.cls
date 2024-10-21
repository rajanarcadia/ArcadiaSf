/****************************************************************************************
This cllass is used to build requests to get the service prodviders from Arcadia via API
*****************************************************************************************/
public class GetArcadiaServiceProvidersRequestBuilder extends UrjanetRequestBuilder{
    public GetArcadiaServiceProvidersRequestBuilder(UrjanetRequestArgs args) {
        super(args);
    }

    /**
     * Generates a HttpRequest for GET callout to get Arcadidia Service Providers
     * @return   Service Providers GET HttpRequest
     */
    public override HttpRequest buildRequest() {
        String formattedEndPoint = String.format(
            UrjanetConstants.ARCADIA_SERVICE_PROVIDER_ENDPOINT,
            args.requestParams
        );

        this.request.setEndpoint(formattedEndPoint);
        this.request.setMethod(UrjanetEnums.apiMethod.GET.name());
        if (Test.isRunningTest()) {
            this.request.setHeader('mock', ArcadiaServiceProvidersResponseMock.Mock.SERVICE_PROVIDERS_DOWNLOAD.name());
        }
        
        return this.request;
    }
}
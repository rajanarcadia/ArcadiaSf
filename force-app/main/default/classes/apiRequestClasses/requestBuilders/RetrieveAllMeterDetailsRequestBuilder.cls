public with sharing class RetrieveAllMeterDetailsRequestBuilder extends UrjanetRequestBuilder {
    public RetrieveAllMeterDetailsRequestBuilder(UrjanetRequestArgs args) {
        super(args);
    }

    /**
     * Generates a HttpRequest for GET callout to site API endpoint
     * @return   Meter details GET HttpRequest
     */
    public override HttpRequest buildRequest() {
        String formattedEndPoint = String.format(
            UrjanetConstants.RETRIEVE_ALL_METER_DETAILS_API_ENDPOINT,
            args.requestParams
        );
        this.request.setEndpoint(formattedEndPoint);
        this.request.setMethod(UrjanetEnums.apiMethod.GET.name());
        return this.request;
    }
}
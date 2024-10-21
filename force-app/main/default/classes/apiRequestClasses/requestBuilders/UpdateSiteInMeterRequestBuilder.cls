/****************************************************************************************
Name            : UpdateSiteInMeterRequestBuilder
Revision Log    : 2022-04-19 Alagu Chellappa - CodeScience
                :
                :
Use             :  To build requests to get meter details from Urjanet via API
*****************************************************************************************/
public class UpdateSiteInMeterRequestBuilder extends UrjanetRequestBuilder {
    public UpdateSiteInMeterRequestBuilder(UrjanetRequestArgs args) {
        super(args);
    }

    /**
     * Generates a HttpRequest for PATCH callout to meter API endpoint to update the site on the meter.
     * @return   Meter PATCH HttpRequest
     */
    public override HttpRequest buildRequest() {
        String formattedEndPoint = String.format(
            UrjanetConstants.UPDATE_SITE_IN_METER_API_ENDPOINT,
            args.requestParams
        );
        this.request.setEndpoint(formattedEndPoint);
        this.request.setMethod(UrjanetEnums.apiMethod.PATCH.name());
        if (Test.isRunningTest()) {
            this.request.setHeader('mock', MeterResponseMock.Mock.METER.name());
        }
        Map<String, String> siteMap = new Map<String, String>{ 'site' => args.requestParams[1] };
        this.request.setBody(JSON.serialize(siteMap));
        return this.request;
    }
}
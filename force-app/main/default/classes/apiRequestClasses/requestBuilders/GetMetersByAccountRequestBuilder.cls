/****************************************************************************************
Name            : GetMetersByAccountRequestBuilder
Revision Log    : 2022-06-07 Alagu Chellappa - CodeScience
                :
                :
Use             :  To build requests to get meters from Urjanet via API
*****************************************************************************************/
public class GetMetersByAccountRequestBuilder extends UrjanetRequestBuilder {
    public GetMetersByAccountRequestBuilder(UrjanetRequestArgs args) {
        super(args);
    }

    /**
     * Generates a HttpRequest for GET callout to Meters API endpoint to get Meters by account
     * @return   Meters GET HttpRequest
     */
    public override HttpRequest buildRequest() {
        String formattedEndPoint = String.format(
            UrjanetConstants.METERS_BY_ACCOUNT_API_ENDPOINT_STRING,
            args.requestParams
        );
        this.request.setEndpoint(formattedEndPoint);
        this.request.setMethod(UrjanetEnums.apiMethod.GET.name());
        return this.request;
    }
}
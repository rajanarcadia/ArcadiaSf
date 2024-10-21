/****************************************************************************************
Name            : RetrieveMeterDetailsRequestBuilder
Revision Log    : 2022-04-19 Alagu Chellappa - CodeScience
                :
                :
Use             :  To build requests to get meter details from Urjanet via API
*****************************************************************************************/
public class RetrieveMeterDetailsRequestBuilder extends UrjanetRequestBuilder {
    public RetrieveMeterDetailsRequestBuilder(UrjanetRequestArgs args) {
        super(args);
    }

    /**
     * Generates a HttpRequest for GET callout to site API endpoint
     * @return   Meter details GET HttpRequest
     */
    public override HttpRequest buildRequest() {
        String formattedEndPoint = String.format(
            UrjanetConstants.RETRIEVE_METER_DETAILS_API_ENDPOINT,
            args.requestParams
        );
        this.request.setEndpoint(formattedEndPoint);
        this.request.setMethod(UrjanetEnums.apiMethod.GET.name());
        return this.request;
    }
}
/****************************************************************************************
Name            : GetUpdateUrlByCredentialRequestBuilder
Revision Log    : 2022-05-02 Abhi Tangudu - CodeScience
                :
                :
Use             :  To build requests to get update url from Urjanet via API
*****************************************************************************************/
public class GetUpdateUrlByCredentialRequestBuilder extends UrjanetRequestBuilder {
    public GetUpdateUrlByCredentialRequestBuilder(UrjanetRequestArgs args) {
        super(args);
    }

    /**
     * Generates a HttpRequest for GET callout to Credential API endpoint to get Update credentials url by credential Id
     * @return   Credentials GET HttpRequest
     */
    public override HttpRequest buildRequest() {
        String formattedEndPoint = String.format(
            UrjanetConstants.UPDATE_URL_BY_CREDENTIAL_API_ENDPOINT,
            args.requestParams
        );
        this.request.setEndpoint(formattedEndPoint);
        this.request.setMethod(UrjanetEnums.apiMethod.GET.name());
        return this.request;
    }
}
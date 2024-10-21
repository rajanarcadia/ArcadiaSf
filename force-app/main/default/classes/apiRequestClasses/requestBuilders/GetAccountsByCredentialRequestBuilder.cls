/****************************************************************************************
Name            : GetAccountsByCredentialRequestBuilder
Revision Log    : 2022-04-28 Abhi Tangudu - CodeScience
                :
                :
Use             :  To build requests to get accounts from Urjanet via API
*****************************************************************************************/
public class GetAccountsByCredentialRequestBuilder extends UrjanetRequestBuilder {
    public GetAccountsByCredentialRequestBuilder(UrjanetRequestArgs args) {
        super(args);
    }

    /**
     * Generates a HttpRequest for GET callout to Accounts API endpoint to get Accounts by credential
     * @return   Accounts GET HttpRequest
     */
    public override HttpRequest buildRequest() {
        String formattedEndPoint = String.format(
            UrjanetConstants.ACCOUNTS_BY_CREDENTIAL_API_ENDPOINT,
            args.requestParams
        );
        this.request.setEndpoint(formattedEndPoint);
        this.request.setMethod(UrjanetEnums.apiMethod.GET.name());
        return this.request;
    }
}
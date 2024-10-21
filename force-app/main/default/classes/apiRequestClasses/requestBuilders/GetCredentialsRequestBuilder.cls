/****************************************************************************************
Name            : GetCredentialsRequestBuilder
Revision Log    : 2022-04-27 Alagu Chellappa - CodeScience
                :
                :
Use             :  To build requests to get credentials from Urjanet via API
*****************************************************************************************/
public class GetCredentialsRequestBuilder extends UrjanetRequestBuilder {
    public GetCredentialsRequestBuilder(UrjanetRequestArgs args) {
        super(args);
    }

    /**
     * Generates a HttpRequest for GET callout to Credentials API endpoint to get Credentials by correlation Id
     * @return   Credentials GET HttpRequest
     */
    public override HttpRequest buildRequest() {
        String formattedEndPoint = String.format(
            UrjanetConstants.CREDENTIALS_BY_CORRELATIONID_API_ENDPOINT,
            args.requestParams
        );
        this.request.setEndpoint(formattedEndPoint);
        this.request.setMethod(UrjanetEnums.apiMethod.GET.name());
        if (Test.isRunningTest()) {
            this.request.setHeader('mock', CredentialResponseMock.Mock.CREDENTIAL.name());
        }
        return this.request;
    }
}
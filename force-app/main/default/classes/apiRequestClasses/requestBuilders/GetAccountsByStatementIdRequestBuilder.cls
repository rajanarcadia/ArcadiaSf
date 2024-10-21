public class GetAccountsByStatementIdRequestBuilder extends UrjanetRequestBuilder{
    
    public GetAccountsByStatementIdRequestBuilder(UrjanetRequestArgs args) {
        super(args);
    }

    /**
     * Generates a HttpRequest for GET callout to Accounts API endpoint to get Accounts by credential
     * @return   Accounts GET HttpRequest
     */
    public override HttpRequest buildRequest() {
        String formattedEndPoint = String.format(
            UrjanetConstants.ACCOUNTS_BY_STATEMENTS_API_ENDPOINT,
            args.requestParams
        );
        this.request.setEndpoint(formattedEndPoint);
        this.request.setMethod(UrjanetEnums.apiMethod.GET.name());
        return this.request;
    }
}
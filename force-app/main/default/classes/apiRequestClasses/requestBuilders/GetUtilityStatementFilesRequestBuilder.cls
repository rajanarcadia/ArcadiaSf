/****************************************************************************************
This cllass is used to build requests to get Utility Statment Files from Arcadia via API
*****************************************************************************************/
public class GetUtilityStatementFilesRequestBuilder extends UrjanetRequestBuilder{
    public GetUtilityStatementFilesRequestBuilder(UrjanetRequestArgs args) {
        super(args);
    }

    /**
     * Generates a HttpRequest for GET callout to Utility Statement Files API endpoint to get Files by Entity Id
     * @return   Utility Statement Files GET HttpRequest
     */
    public override HttpRequest buildRequest() {
        String formattedEndPoint = String.format(
            UrjanetConstants.UTILITY_STATMENT_FILES_BY_ENTITYID_API_ENDPOINT,
            args.requestParams
        );
        this.request.setEndpoint(formattedEndPoint);
        this.request.setMethod(UrjanetEnums.apiMethod.GET.name());
        if (Test.isRunningTest()) {
            this.request.setHeader('mock', UtilityStatementFileResponseMock.Mock.STATEMENT_FILES_BY_ENTITY_ID.name());
        }
        
        return this.request;
    }
}
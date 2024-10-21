public with sharing class ArcadiaStatementUploadCalloutService {
    public String accessToken;

    @testVisible
    private static ArcadiaStatementUploadCalloutService instance = null;
    @testVisible
    ArcadiaMultiPartBodyHelper helper = new ArcadiaMultiPartBodyHelper();
    @testVisible
    ArcadiaStatementUploadCalloutResources callout = new ArcadiaStatementUploadCalloutResources();
    @testVisible
    UrjanetApiClient client = new UrjanetApiClient();

    //This would be private but Apex does not allow the Mocking of private constructor classes
    public ArcadiaStatementUploadCalloutService() {
    }

    public static ArcadiaStatementUploadCalloutService getInstance() {
        // lazy load- only initialize if it doesn't already exist
        if (instance == null)
            instance = new ArcadiaStatementUploadCalloutService();
        return instance;
    }

    public ArcadiaStatementUploadCalloutResources.UploadStatementResponse uploadStatement(
        String jsonFileDetails,
        String fileName
    ) {
        try {
            if (this.accessToken == null) {
                this.accessToken = this.client.getAccessToken().token;
            }

            HttpRequest req = new HttpRequest();
            Blob bodyBlob = callout.getUploadStatementBody(jsonFileDetails, fileName);
            req.setEndpoint(UrjanetConstants.POST_STATEMENT_ENDPOINT);
            req.setBodyAsBlob(bodyBlob);
            req.setHeader('Authorization', 'bearer ' + accessToken);
            req.setHeader('Content-Length', String.valueOf(bodyBlob.size()));
            req.setHeader('Content-Type', helper.GetContentType());
            if (Test.isRunningTest()) {
                req.setHeader('mock', ArcadiaStatementUploadResponseMock.Mock.UPLOAD.name());
            }
            req.setMethod(UrjanetEnums.apiMethod.POST.name());
            req.setTimeout(120000);
            Http httpCall = new Http();
            HttpResponse res = httpCall.send(req);
            if (res.getStatusCode() == 200) {
                return callout.getFileResponseDetails(res.getBody(), res.getStatusCode());
            } else {
                //Catch will log this exception
                throw new ArcadiaCalloutServiceException(
                    Label.Arcadia_StatementUpload_UploadError,
                    ArcadiaGenericController.generateErrorCode()
                );
            }
        } catch (Exception ex) {
            String errorCode = ArcadiaGenericController.generateErrorCode();
            Logger logInstance = Logger.getPlatformLogger();
            logInstance.log(ArcadiaStatementUploadCalloutService.class.getName(), ex);
            throw new ArcadiaCalloutServiceException(ex.getMessage(), ex, errorCode);
        }
    }
}
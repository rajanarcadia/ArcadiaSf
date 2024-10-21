public with sharing class CreateBulkCredentialsRequestBuilder extends UrjanetRequestBuilder{
    public CreateBulkCredentialsRequestBuilder(UrjanetRequestArgs args) {
        super(args);
    }

    /**
     * Generates a HttpRequest for POST callout to Bulk Credentials API 
     * @return   site POST HttpRequest
     */
    public override HttpRequest buildRequest() {
        this.request.setEndpoint(UrjanetConstants.POST_BULK_CREDENTIALS_API_ENDPOINT);
        this.request.setMethod(UrjanetEnums.apiMethod.POST.name());
        this.request.setHeader('Content-Type', 'application/json');
        if (Test.isRunningTest()) {
            this.request.setHeader('mock', PostBulkCredentialsResponseMock.Mock.BULK_CREDNETIALS.name());
        }

        String jsonCredsDetails = args.requestParams[0];
        List<ArcadiaBulkCredentialUploadService.BulkCredentialDetails> lstCredentials = (List<ArcadiaBulkCredentialUploadService.BulkCredentialDetails>) JSON.deserialize(jsonCredsDetails, List<ArcadiaBulkCredentialUploadService.BulkCredentialDetails>.class);
        PostBulkCredential postBulkCrendentialBody = new PostBulkCredential(lstCredentials);
        this.request.setBody(JSON.serialize(postBulkCrendentialBody.lstCredentials,true));
        return this.request;
    }

    public class PostBulkCredential{
        public List<CredentialDetials> lstCredentials {get;set;}

        public PostBulkCredential(List<ArcadiaBulkCredentialUploadService.BulkCredentialDetails> lstBulkCreds){
            lstCredentials = new List<CredentialDetials>();
            for(ArcadiaBulkCredentialUploadService.BulkCredentialDetails bulkCred : lstBulkCreds){
                lstCredentials.add(new CredentialDetials(bulkCred));
            }
        }
    }

    public Class CredentialDetials{
        public String username;
        public String username2;
        public String username3;
        public String username4;
        public String password;
        public String password2;
        public String password3;
        public String password4;
        public String correlationId;
        public String providerId;

        public CredentialDetials(ArcadiaBulkCredentialUploadService.BulkCredentialDetails bulkCred){
            this.username = bulkCred.userName1;
            this.username2 = bulkCred.userName2;
            this.username3 = bulkCred.userName3;
            this.username4 = bulkCred.userName4;
            this.password  = bulkCred.password1;
            this.password2 = bulkCred.password2;
            this.password3 = bulkCred.password3;
            this.password4 = bulkCred.password4;
            this.providerId = bulkCred.arcadiaServiceProviderID;
            this.correlationId = bulkCred.correlationID;
        }
    }
}
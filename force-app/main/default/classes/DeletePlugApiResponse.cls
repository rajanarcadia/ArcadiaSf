public with sharing class DeletePlugApiResponse extends UrjanetResponse {
    public DeletePlugApiResponse() {
    }
    public String credentialId;
    public String id;
    public String status;
    public string errorMsg;
    public Integer statusCode;
    public class DeleteApiUiResponse {
        @AuraEnabled
        public String statusCode { get; set; }
        @AuraEnabled
        public String message { get; set; }
    }
}
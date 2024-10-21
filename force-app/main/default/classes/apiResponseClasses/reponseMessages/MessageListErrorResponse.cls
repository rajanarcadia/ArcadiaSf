public with sharing class MessageListErrorResponse extends UrjanetResponse {
    public MessageListErrorResponse() {
    }
    public List<String> message;
    public String error;
    public String ex;
    public String path;
    public String timestamp;
    public Integer status;
}
/****************************************************************************************
Name            : ErrorResponse
Revision Log    : 2022-04-26 Abhi Tangudu - CodeScience
                :
                :
Use             :  Error response for the API Callout Response
*****************************************************************************************/
public with sharing class ErrorResponse extends UrjanetResponse {
    public ErrorResponse() {
    }
    public String message;
    public String error;
    public String ex;
    public String path;
    public String timestamp;
    public Integer status;
}
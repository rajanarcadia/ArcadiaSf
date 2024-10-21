/****************************************************************************************
Name            : GetUpdateUrlByCredentialResponse
Revision Log    : 2022-04-28 Abhi Tangudu - CodeScience
                :
                :
Use             :  Urjanet API Callout Response - Get Update Url by Credential 
*****************************************************************************************/
public with sharing class GetUpdateUrlByCredentialResponse extends UrjanetResponse {
    public GetUpdateUrlByCredentialResponse() {
    }
    public String updateUrl { get; set; }
    public String expiration { get; set; }
}
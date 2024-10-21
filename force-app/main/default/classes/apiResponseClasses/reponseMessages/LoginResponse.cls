/****************************************************************************************
Name            : LoginResponse
Revision Log    : 2022-04-19 Abhi Tangudu - CodeScience
                :
                :
Use             :  Urjanet API Callout Response - Login detail
*****************************************************************************************/
public with sharing class LoginResponse extends UrjanetResponse {
    public LoginResponse() {
    }
    public String expires;
    public String message;
    public String token;
}
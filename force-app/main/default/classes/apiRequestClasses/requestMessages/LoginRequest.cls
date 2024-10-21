/****************************************************************************************
Name            : LoginRequest
Revision Log    : 2022-04-19 Abhi Tangudu - CodeScience
                :
                :
Use             :  message class to build requests to make callout to get token from Urjanet API
*****************************************************************************************/
public with sharing class LoginRequest {
    public LoginRequest() {
    }
    public String username;
    public String password;
}
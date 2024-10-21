/****************************************************************************************
Name            : UrjanetRequestBuilder
Revision Log    : 2022-04-19 Abhi Tangudu - CodeScience
                :
                :
Use             :  Abstract class to build requests to make callout to Urjanet API
*****************************************************************************************/
public abstract class UrjanetRequestBuilder {
    protected HttpRequest request;
    protected UrjanetRequestArgs args;
    String token;
    public UrjanetRequestBuilder(UrjanetRequestArgs args) {
        this.args = args;
        HttpRequest request = new HttpRequest();
        AccessToken__c accessTokenSetting = AccessToken__c.getInstance(UserInfo.getProfileId());
        if (
            accessTokenSetting.Token1__c != null &&
            accessTokenSetting.ExpirationTime__c != null &&
            accessTokenSetting.ExpirationTime__c > DateTime.now()
        ) {
            token = UrjanetUtils.extractAccessToken(accessTokenSetting);
        } else {
            token = new UrjanetApiClient().getAccessToken().token;
        }
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setMethod(args.apiMethod);
        this.request = request;
    }

    abstract public HttpRequest buildRequest();
}
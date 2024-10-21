public with sharing class CalloutAccessTokenProvider extends AccessTokenProvider {
    public CalloutAccessTokenProvider(UrjanetEnums.AccessTokenType tokenType) {
        super(tokenType);
    }

    public override LoginResponse getAccessToken() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:' + UrjanetUtils.getNamespaceWithUnderscores() + 'Urjanet/auth/login');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        if (Test.isRunningTest()) {
            request.setHeader('mock', CredentialResponseMock.Mock.LOGIN.name());
        }
        request.setMethod(UrjanetEnums.ApiMethod.GET.name());
        LoginRequest login = new LoginRequest();
        login.username = '{!$credential.username}';
        login.password = '{!$credential.password}';
        request.setBody(JSON.serialize(login));
        HttpResponse res = new Http().send(request);
        UrjanetResponseParser parser = new ResponseParserFactory().getResponseParser(UrjanetEnums.RequestType.LOGIN);
        LoginResponse response = (LoginResponse) parser.parseResponse(res);
        return response;
    }
}
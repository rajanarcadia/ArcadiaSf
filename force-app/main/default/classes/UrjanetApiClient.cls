public with sharing class UrjanetApiClient {
    public UrjanetResponse getUrjanetResponse(
        UrjanetEnums.RequestType requestType,
        UrjanetEnums.ApiMethod apiMethod,
        List<String> requestParams
    ) {
        UrjanetRequestArgs args = new UrjanetRequestArgs();
        args.requestType = requestType;
        args.apiMethod = apiMethod.name();
        args.requestParams = requestParams;
        UrjanetRequestBuilder requestBuilder = new RequestBuilderFactory().getRequestBuilder(args);
        UrjanetResponseParser responseParser = new ResponseParserFactory().getResponseParser(requestType);

        HttpRequest request = requestBuilder.buildrequest();
        UrjanetResponse response;
        try {
            HttpResponse apiResponse = new Http().send(request);
            response = responseParser.parseResponse(apiResponse);
        } catch (Exception e) {
            response = new UrjanetResponse();
            response.ex = e;
            response.errorMsg = e.getMessage();
            Logger.getInstance().log(UrjanetApiClient.class.getName(), e);
        }

        return response;
    }

    public LoginResponse getAccessToken() {
        LoginResponse tokenResponse;
        AccessTokenProvider tokenProvider = new AccessTokenProviderFactory()
            .getAccessTokenProvider(UrjanetEnums.AccessTokenType.CALLOUT);
        tokenResponse = tokenProvider.getAccessToken();
        if (tokenResponse.status != 200) {
            Logger.getInstance()
                .log(
                    UrjanetApiClient.class.getName(),
                    UrjanetConstants.LOGIN_FAILURE,
                    Logger.Level.ERROR,
                    tokenResponse.errorMsg
                );
        }

        return tokenResponse;
    }
}
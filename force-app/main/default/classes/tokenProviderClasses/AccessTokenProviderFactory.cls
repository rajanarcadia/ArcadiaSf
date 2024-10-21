public with sharing class AccessTokenProviderFactory {
    public class UnhandledRequestException extends Exception {
    }
    public AccessTokenProvider getAccessTokenProvider(UrjanetEnums.AccessTokenType tokenType) {
        AccessTokenProvider tokenProvider;

        if (tokenType == UrjanetEnums.AccessTokenType.CALLOUT) {
            tokenProvider = new CalloutAccessTokenProvider(tokenType);
        } else {
            throw new UnhandledRequestException(UrjanetConstants.UNHANDLED_REQUEST);
        }

        return tokenProvider;
    }
}
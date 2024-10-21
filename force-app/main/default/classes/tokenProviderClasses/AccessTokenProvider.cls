public abstract class AccessTokenProvider {
    protected LoginResponse accessToken;
    protected UrjanetEnums.AccessTokenType tokenType;

    public AccessTokenProvider(UrjanetEnums.AccessTokenType tokenType) {
        this.tokenType = tokenType;
    }

    abstract public LoginResponse getAccessToken();
}
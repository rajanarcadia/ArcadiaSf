public with sharing class LoginResponseParser implements UrjanetResponseParser {
    public UrjanetResponse parseResponse(HttpResponse response) {
        LoginResponse authResponse = new LoginResponse();
        try {
            if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
                authResponse = (LoginResponse) JSON.deserialize(response.getBody(), LoginResponse.class);
                authResponse.responseType = UrjanetEnums.RequestType.LOGIN.name();
                authResponse.responseBody = response.getBody();
                authResponse.endpoint = 'auth/login';
            } else {
                ErrorResponse errResponse = new ErrorResponse();
                errResponse = (ErrorResponse) JSON.deserialize(
                    UrjanetUtils.sanitizeResponse(response.getBody()),
                    ErrorResponse.class
                );
                authResponse.errorMsg = errResponse.status + ' ' + errResponse.error;
                authResponse.message = (errResponse.message != null ? ' Message =' + errResponse.message : '');
                authResponse.status = errResponse.status;
                authResponse.endpoint = errResponse.path;
                return authResponse;
            }
        } catch (Exception e) {
            authResponse.ex = e;
            Logger.getInstance().log(LoginResponseParser.class.getName(), e);
        }

        return authResponse;
    }
}
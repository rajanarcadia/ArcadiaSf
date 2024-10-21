public with sharing class DisableCredentialApiController {
    /**
     * this method is used to call teh Disable API for disabling the Credentials and other associated records in ODIN
     */
    public static DisablePlugApiResponse disableCredentialApiCallout(String credentialIdToBeDeleted) {
        DisablePlugApiResponse response = (DisablePlugApiResponse) new UrjanetApiClient()
            .getUrjanetResponse(
                UrjanetEnums.RequestType.DISABLE_CREDENTIAL,
                UrjanetEnums.ApiMethod.PATCH,
                new List<String>{ credentialIdToBeDeleted }
            );
        return response;
    }
}
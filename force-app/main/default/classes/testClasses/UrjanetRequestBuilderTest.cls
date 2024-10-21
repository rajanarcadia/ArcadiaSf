@IsTest
private class UrjanetRequestBuilderTest {
    @TestSetup
    static void makeData() {
        User adminUser = TestUtility.createUserAdmin('urjanetAdmin@urjanettest.com');
        System.runAs(adminUser) {
            AccessToken__c accessTokenSetting = AccessToken__c.getInstance(UserInfo.getProfileId());
            accessTokenSetting.Token1__c = ' Token 1 Part ';
            accessTokenSetting.Token2__c = ' Token 2 Part ';
            accessTokenSetting.Token3__c = ' Token 3 Part ';
            accessTokenSetting.Token4__c = ' Token 4 Part ';
            accessTokenSetting.Token5__c = ' Token 5 Part ';
            accessTokenSetting.Token6__c = ' Token 6 Part ';
            accessTokenSetting.Token7__c = ' Token 7 Part ';
            accessTokenSetting.Token8__c = ' Token 8 Part ';
            accessTokenSetting.Token9__c = ' Token 9 Part ';
            accessTokenSetting.Name = 'Default';
            accessTokenSetting.ExpirationTime__c = Datetime.now().addMinutes(5);
            accessTokenSetting.Message__c = 'Authentication Successful';
            insert accessTokenSetting;
        }
    }
    @IsTest
    static void testBuildRequest() {
        Test.startTest();
        UrjanetRequestArgs args = new UrjanetRequestArgs();
        args.requestType = UrjanetEnums.RequestType.STATEMENT_FILES_BY_ENTITY_ID;
        args.apiMethod = UrjanetEnums.ApiMethod.GET.name();
        args.requestParams = new List<String>{ 'FileId' };
        UrjanetRequestBuilder requestBuilder = new RequestBuilderFactory().getRequestBuilder(args);
        HttpRequest request = requestBuilder.buildRequest();
        Test.stopTest();
        CSUtils.itShouldBe(
            'Authorization Header',
            'Bearer Token 1 PartToken 2 PartToken 3 PartToken 4 PartToken 5 PartToken 6 PartToken 7 PartToken 8 PartToken 9 Part',
            request.getHeader('Authorization')
        );
    }
}
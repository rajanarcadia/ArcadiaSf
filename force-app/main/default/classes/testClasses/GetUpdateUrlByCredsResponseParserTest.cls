@isTest
public with sharing class GetUpdateUrlByCredsResponseParserTest {
    @isTest
    static void getUpdateUrlByCredsExceptionTest() {
        List<Log__c> logbeforeAPICall = [SELECT Id FROM Log__c LIMIT 1];
        CSUtils.itShouldBe('Expected number of records in Log Object', 0, logBeforeAPICall.size());

        Test.startTest();
        UrjanetResponse response = new GetUpdateUrlByCredResponseParser().parseResponse(null);
        Test.stopTest();

        List<Log__c> logAfterAPICall = [SELECT Id, Message__c FROM Log__c LIMIT 1];
        CSUtils.itShouldBe('Number of records in Log Object', 1, logAfterAPICall.size());
        CSUtils.itShouldBe('Error message', (response.ex).getMessage(), logAfterAPICall[0].Message__c.trim());
    }

    @isTest
    static void getUpdateUrlByCredsTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('UpdateUrlByCredsResponse', 200);
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());

        Test.startTest();
        UrjanetResponse response = new GetUpdateUrlByCredResponseParser().parseResponse(mockHttpResponse);
        Test.stopTest();

        CSUtils.itShouldBe('There should be no error message ', null, response.errorMsg);
        CSUtils.itShouldBe(
            'Response Type should match ',
            UrjanetEnums.RequestType.UPDATE_URL_BY_CREDENTIAL.name(),
            response.responseType
        );
        CSUtils.itShouldBe(
            'UpdateURL should match ',
            'https://connect.urjanet.com/TestUpdatelUrl?app=RECURRING_UTILITY',
            ((GetUpdateUrlByCredentialResponse) response).updateUrl
        );
    }

    @isTest
    static void getUpdateUrlByCredsErrorTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'UpdateUrlByCredsResponseFailure',
            400
        );
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());

        Test.startTest();
        UrjanetResponse response = new GetUpdateUrlByCredResponseParser().parseResponse(mockHttpResponse);
        Test.stopTest();

        CSUtils.itShouldBe('Error message should be ', '400 Bad request', response.errorMsg);
        CSUtils.itShouldBe(
            'Message should match ',
            ' Message =Credential with id test-credential-Id not found',
            response.message
        );
    }
}
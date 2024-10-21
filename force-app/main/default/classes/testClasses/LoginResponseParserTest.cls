@isTest
public with sharing class LoginResponseParserTest {
    @isTest
    static void getAccesTokenExceptionTest() {
        List<Log__c> logbeforeAPICall = [SELECT Id FROM Log__c LIMIT 1];
        CSUtils.itShouldBe('Expected number of records in Log Object', 0, logBeforeAPICall.size());

        Test.startTest();
        LoginResponse response = (LoginResponse) new LoginResponseParser().parseResponse(null);
        Test.stopTest();

        List<Log__c> logAfterAPICall = [SELECT Id, Message__c FROM Log__c LIMIT 1];
        CSUtils.itShouldBe('Number of records in Log Object', 1, logAfterAPICall.size());
        CSUtils.itShouldBe('Error message', (response.ex).getMessage(), logAfterAPICall[0].Message__c.trim());
    }

    @isTest
    static void getAccesTokenTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('LoginResponse', 200);
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());

        Test.startTest();
        LoginResponse response = (LoginResponse) new LoginResponseParser().parseResponse(mockHttpResponse);
        Test.stopTest();

        CSUtils.itShouldBe('There should be no error message ', null, response.errorMsg);
        CSUtils.itShouldBe('End point should match ', 'auth/login', response.endpoint);
        CSUtils.itShouldBe('Response type should match', UrjanetEnums.RequestType.LOGIN.name(), response.responseType);
    }

    @isTest
    static void getAccesTokenErrorTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('LoginResponseFailure', 400);
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());

        Test.startTest();
        LoginResponse response = (LoginResponse) new LoginResponseParser().parseResponse(mockHttpResponse);
        Test.stopTest();

        CSUtils.itShouldBe('Error message should be ', '401 Unauthorized', response.errorMsg);
        CSUtils.itShouldBe('Status should match ', 401, response.status);
    }
}
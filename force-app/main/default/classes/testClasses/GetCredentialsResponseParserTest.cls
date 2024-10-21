@isTest
public with sharing class GetCredentialsResponseParserTest {
    @isTest
    static void getCredentialsExceptionTest() {
        List<Log__c> logbeforeAPICall = [SELECT Id FROM Log__c LIMIT 1];
        CSUtils.itShouldBe('Expected number of records in Log Object', 0, logBeforeAPICall.size());

        Test.startTest();
        UrjanetResponse response = new GetCredentialsResponseParser().parseResponse(null);
        Test.stopTest();

        List<Log__c> logAfterAPICall = [SELECT Id, Message__c, LogTitle__c FROM Log__c LIMIT 1];
        CSUtils.itShouldBe('Number of records in Log Object', 1, logAfterAPICall.size());
        CSUtils.itShouldBe('Error message', (response.ex).getMessage(), logAfterAPICall[0].Message__c.trim());
        CSUtils.itShouldBe(
            'Error message in Log title',
            UrjanetConstants.CREDENTIALS_API_ERROR_MESSAGE,
            logAfterAPICall[0].LogTitle__c
        );
    }

    @isTest
    static void getCredentialsResponseTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('GetCredentialsResponse', 200);
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());

        Test.startTest();
        UrjanetResponse response = new GetCredentialsResponseParser().parseResponse(mockHttpResponse);
        Test.stopTest();
        CSUtils.itShouldBe(
            'ResponseType should be Credential correlationId ',
            'CREDENTIALS_BY_CORRELATION_ID',
            response.responseType
        );
        CSUtils.itShouldBe('There should be no error message ', null, response.errorMsg);
        CSUtils.itShouldBe(
            'Username should be Test_Name_1 ',
            'Test_Name_1',
            ((GetCredentialsResponse) response).embedded.credentials[0].username
        );
        CSUtils.itShouldBe(
            'Staus should be OK ',
            'OK',
            ((GetCredentialsResponse) response).embedded.credentials[0].status
        );
        CSUtils.itShouldBe(
            'Correlation Id should match ',
            '001TestCorrelationId',
            ((GetCredentialsResponse) response).embedded.credentials[0].correlationId
        );
    }

    @isTest
    static void getCredentialsResponseErrorTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('GetCredentialsResponseFailure', 400);
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());

        Test.startTest();
        UrjanetResponse response = new GetCredentialsResponseParser().parseResponse(mockHttpResponse);
        Test.stopTest();

        CSUtils.itShouldBe('Message should be ', ' Message =Invalid search.', response.message);
        CSUtils.itShouldBe('Error message should be ', '400 Bad request', response.errorMsg);
    }
}
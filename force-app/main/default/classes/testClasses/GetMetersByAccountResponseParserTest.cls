@isTest
public with sharing class GetMetersByAccountResponseParserTest {
    @isTest
    static void getMetersByAccountExceptionTest() {
        List<Log__c> logbeforeAPICall = [SELECT Id FROM Log__c LIMIT 1];
        CSUtils.itShouldBe('Expected number of records in Log Object', 0, logBeforeAPICall.size());

        Test.startTest();
        UrjanetResponse response = new GetMetersByAccountResponseParser().parseResponse(null);
        Test.stopTest();

        List<Log__c> logAfterAPICall = [SELECT Id, Message__c, LogTitle__c FROM Log__c LIMIT 1];
        CSUtils.itShouldBe('Number of records in Log Object', 1, logAfterAPICall.size());
        CSUtils.itShouldBe('Error message', (response.ex).getMessage(), logAfterAPICall[0].Message__c.trim());
        CSUtils.itShouldBe(
            'Error message in Log title',
            UrjanetConstants.METERS_BY_ACCOUNT_API_ERROR_MESSAGE,
            logAfterAPICall[0].LogTitle__c
        );
    }

    @isTest
    static void getMetersByAccountTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('MetersByAccountResponse', 200);
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());

        Test.startTest();
        UrjanetResponse response = new GetMetersByAccountResponseParser().parseResponse(mockHttpResponse);
        Test.stopTest();

        CSUtils.itShouldBe('There should be no error message ', null, response.errorMsg);
        CSUtils.itShouldBe(
            'MeterStatus should be CURRENT ',
            'CURRENT',
            ((GetMetersByAccountResponse) response).embedded.meters[0].meterStatus
        );
        CSUtils.itShouldBe(
            'ServiceType should be electric ',
            'electric',
            ((GetMetersByAccountResponse) response).embedded.meters[0].serviceType
        );
    }

    @isTest
    static void getMetersByAccountErrorTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'MetersByAccountResponseFailure',
            400
        );
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());

        Test.startTest();
        UrjanetResponse response = new GetMetersByAccountResponseParser().parseResponse(mockHttpResponse);
        Test.stopTest();

        CSUtils.itShouldBe('Status should be 400 ', 400, response.status);
        CSUtils.itShouldBe('Error message should be ', '400 Bad request', response.errorMsg);
    }
}
@isTest
public with sharing class RetrieveMeterDetailsResponseParserTest {
    @isTest
    static void retrieveMeterDetailsExceptionTest() {
        List<Log__c> logbeforeAPICall = [SELECT Id FROM Log__c LIMIT 1];
        CSUtils.itShouldBe('Expected number of records in Log Object', 0, logBeforeAPICall.size());

        Test.startTest();
        List<String> requestParams = new List<String>{ 'test-Account-Id' };
        UrjanetResponse response = new RetrieveMeterDetailsResponseParser().parseResponse(null);
        Test.stopTest();

        List<Log__c> logAfterAPICall = [SELECT Id, Message__c, LogTitle__c FROM Log__c LIMIT 1];
        CSUtils.itShouldBe('Number of records in Log Object', 1, logAfterAPICall.size());
        CSUtils.itShouldBe('Error message', (response.ex).getMessage(), logAfterAPICall[0].Message__c.trim());
        CSUtils.itShouldBe(
            'Error message in Log title',
            UrjanetConstants.RETRIEVE_METER_DETAILS_ERROR_MESSAGE,
            logAfterAPICall[0].LogTitle__c
        );
    }

    @isTest
    static void retrieveMeterDetailsTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('RetrieveMeterDetailsResponse', 200);
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());

        Test.startTest();
        UrjanetResponse response = new RetrieveMeterDetailsResponseParser().parseResponse(mockHttpResponse);
        Test.stopTest();

        CSUtils.itShouldBe('There should be no error message ', null, response.errorMsg);
        CSUtils.itShouldBe(
            'responseType should match ',
            UrjanetEnums.RequestType.RETRIEVE_METER_DETAILS.name(),
            response.responseType
        );
        CSUtils.itShouldBe(
            'podNumber should match ',
            '303682599',
            ((RetrieveMeterDetailsResponse) response).embedded.meters[0].podNumber
        );
        CSUtils.itShouldBe(
            'MeterNumber should match ',
            '28707791',
            ((RetrieveMeterDetailsResponse) response).embedded.meters[0].meterNumber
        );
        CSUtils.itShouldBe(
            'Calorific Value should match ',
            2300,
            ((RetrieveMeterDetailsResponse) response).embedded.meters[0].usages[0].calorificValue
        );
    }

    @isTest
    static void retrieveMeterDetailsErrorTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'RetrieveMeterDetailsResponseFailure',
            400
        );
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());

        Test.startTest();
        UrjanetResponse response = new RetrieveMeterDetailsResponseParser().parseResponse(mockHttpResponse);
        Test.stopTest();

        CSUtils.itShouldBe('Error message should be ', '400 Bad request', response.errorMsg);
        CSUtils.itShouldBe('Status should be 400 ', 400, response.status);
    }
}
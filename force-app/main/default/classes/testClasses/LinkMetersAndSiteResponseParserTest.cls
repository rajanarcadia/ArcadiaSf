@isTest
public with sharing class LinkMetersAndSiteResponseParserTest {
    @isTest
    static void linkMetersAndSiteExceptionTest() {
        List<Log__c> logbeforeAPICall = [SELECT Id FROM Log__c LIMIT 1];
        CSUtils.itShouldBe('Expected number of records in Log Object', 0, logBeforeAPICall.size());

        Test.startTest();
        UrjanetResponse response = new LinkMetersAndSiteResponseParser().parseResponse(null);
        Test.stopTest();

        List<Log__c> logAfterAPICall = [SELECT Id, Message__c FROM Log__c LIMIT 1];
        CSUtils.itShouldBe('Number of records in Log Object', 1, logAfterAPICall.size());
        CSUtils.itShouldBe('Error message', (response.ex).getMessage(), logAfterAPICall[0].Message__c.trim());
    }

    @isTest
    static void linkMetersAndSiteTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('LinkMetersAndSiteResponse', 200);
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());

        Test.startTest();
        UrjanetResponse response = new LinkMetersAndSiteResponseParser().parseResponse(mockHttpResponse);
        Test.stopTest();

        CSUtils.itShouldBe('There should be no error message ', null, response.errorMsg);
        CSUtils.itShouldBe(
            'EntityId should match ',
            'Test-Site-Id',
            ((LinkMetersAndSiteResponse) response).embedded.meters[0].entityId
        );
        CSUtils.itShouldBe(
            'MeterNumber should match ',
            'R1251766',
            ((LinkMetersAndSiteResponse) response).embedded.meters[0].meterNumber
        );
    }

    @isTest
    static void linkMetersAndSiteErrorTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('GenericFailureMessageResponse', 400);
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());

        Test.startTest();
        UrjanetResponse response = new LinkMetersAndSiteResponseParser().parseResponse(mockHttpResponse);
        Test.stopTest();

        CSUtils.itShouldBe('Error message should be ', '400 Request Failed', response.errorMsg);
        CSUtils.itShouldBe('Status should be 400 ', 400, response.status);
        CSUtils.itShouldBe('Message should match ', ' Message =Server Down', response.message);
    }
}
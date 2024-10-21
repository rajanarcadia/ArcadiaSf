@IsTest
public with sharing class PostSiteResponseParserTest {
    @isTest
    static void postSiteExceptionTest() {
        List<Log__c> logbeforeAPICall = [SELECT Id FROM Log__c LIMIT 1];
        CSUtils.itShouldBe('Expected number of records in Log Object', 0, logBeforeAPICall.size());

        Test.startTest();
        UrjanetResponse response = new PostSiteResponseParser().parseResponse(null);
        Test.stopTest();

        List<Log__c> logAfterAPICall = [SELECT Id, Message__c FROM Log__c LIMIT 1];
        CSUtils.itShouldBe('Number of records in Log Object', 1, logAfterAPICall.size());
        CSUtils.itShouldBe('Error message', (response.ex).getMessage(), logAfterAPICall[0].Message__c.trim());
    }

    @isTest
    static void postSiteTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('PostSiteResponse', 202);
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());

        Test.startTest();
        UrjanetResponse response = new PostSiteResponseParser().parseResponse(mockHttpResponse);
        Test.stopTest();

        CSUtils.itShouldBe('There should be no error message ', null, response.errorMsg);
        CSUtils.itShouldBe(
            'responseType should match ',
            UrjanetEnums.RequestType.CREATE_SITE.name(),
            response.responseType
        );
        CSUtils.itShouldBe('Region should match ', 'AMER', ((PostSiteResponse) response).region);
        CSUtils.itShouldBe('Sitecode should match ', '123789', ((PostSiteResponse) response).siteCode);
    }

    @isTest
    static void postSiteErrorTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('PostSiteResponseFailure', 400);
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());

        Test.startTest();
        UrjanetResponse response = new PostSiteResponseParser().parseResponse(mockHttpResponse);
        Test.stopTest();

        CSUtils.itShouldBe('Error message should be ', 'Site with the same Address already exists', response.errorMsg);
        CSUtils.itShouldBe('Status  should be  400', 400, response.status);
    }
}
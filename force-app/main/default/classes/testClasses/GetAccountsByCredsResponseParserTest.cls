@isTest
public with sharing class GetAccountsByCredsResponseParserTest {
    @isTest
    static void getAccountsByCredsExceptionTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'AccountsByCredsResponseFailure',
            400
        );
        List<Log__c> logbeforeAPICall = [SELECT Id FROM Log__c LIMIT 1];
        CSUtils.itShouldBe('Expected number of records in Log Object', 0, logBeforeAPICall.size());

        Test.startTest();
        UrjanetResponse response = new GetAccountsByCredsResponseParser().parseResponse(null);
        Test.stopTest();

        List<Log__c> logAfterAPICall = [SELECT Id, Message__c FROM Log__c LIMIT 1];
        CSUtils.itShouldBe('Number of records in Log Object', 1, logAfterAPICall.size());
        CSUtils.itShouldBe('Error message', (response.ex).getMessage(), logAfterAPICall[0].Message__c.trim());
    }

    @isTest
    static void getAccountsByCredsResponseTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('AccountsByCredsResponse', 200);
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());

        Test.startTest();
        UrjanetResponse response = new GetAccountsByCredsResponseParser().parseResponse(mockHttpResponse);
        Test.stopTest();
        CSUtils.itShouldBe(
            'Response Type Should match ',
            UrjanetEnums.RequestType.ACCOUNTS_BY_CREDS.name(),
            response.responseType
        );
        CSUtils.itShouldBe(
            'Entity Id  should match ',
            'test-self',
            ((GetAccountsByCredsResponse) response).embedded.accounts[0].entityId
        );
        CSUtils.itShouldBe(
            'Provider Name  should match ',
            'Xcel Energy',
            ((GetAccountsByCredsResponse) response).embedded.accounts[0].providerName
        );
    }

    @isTest
    static void getAccountsByCredsResponseErrorTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'AccountsByCredsResponseFailure',
            400
        );
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());

        Test.startTest();
        UrjanetResponse response = new GetAccountsByCredsResponseParser().parseResponse(mockHttpResponse);
        Test.stopTest();
        CSUtils.itShouldBe('Error message should be ', '400 Bad request', response.errorMsg);
        CSUtils.itShouldBe(
            'message should be ',
            ' Message =Credential with id Test-credential-Id not found',
            response.message
        );
    }
}
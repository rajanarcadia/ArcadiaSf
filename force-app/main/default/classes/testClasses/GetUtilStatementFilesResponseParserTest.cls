@isTest
public with sharing class GetUtilStatementFilesResponseParserTest {
    @isTest
    static void getUtilityStatmentFileExceptionTest() {
        List<Log__c> logbeforeAPICall = [SELECT Id FROM Log__c LIMIT 1];
        CSUtils.itShouldBe('Expected number of records in Log Object', 0, logBeforeAPICall.size());

        Test.startTest();
        UrjanetResponse response = new GetUtilityStatementFilesResponseParser().parseResponse(null);
        Test.stopTest();

        List<Log__c> logAfterAPICall = [SELECT Id, Message__c, LogTitle__c FROM Log__c LIMIT 1];
        CSUtils.itShouldBe('Number of records in Log Object', 1, logAfterAPICall.size());
        CSUtils.itShouldBe('Error message', (response.ex).getMessage(), logAfterAPICall[0].Message__c.trim());
        CSUtils.itShouldBe(
            'Error message in Log title',
            UrjanetConstants.GET_UTILITY_STATEMENT_FILES_ERROR_MESSAGE,
            logAfterAPICall[0].LogTitle__c
        );
    }

    @isTest
    static void getUtilityStatmentFileTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'GetUtilityStatementFilesResponse',
            200
        );
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());

        Test.startTest();
        UrjanetResponse response = new GetUtilityStatementFilesResponseParser().parseResponse(mockHttpResponse);
        Test.stopTest();

        CSUtils.itShouldBe('There should be no error message ', null, response.errorMsg);
        CSUtils.itShouldBe(
            'Response Type should match ',
            UrjanetEnums.RequestType.STATEMENT_FILES_BY_ENTITY_ID.name(),
            response.responseType
        );
        CSUtils.itShouldBe(
            'FileName should match ',
            'TestFile',
            ((GetUtilityStatementFilesResponse) response).embedded.files[0].fileName
        );
        CSUtils.itShouldBe(
            'ProviderName should match ',
            'HCL',
            ((GetUtilityStatementFilesResponse) response).embedded.files[0].providerName
        );
    }

    @isTest
    static void getUtilityStatmentErrorTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('GenericFailureResponse', 400);
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());

        Test.startTest();
        UrjanetResponse response = new GetUtilityStatementFilesResponseParser().parseResponse(mockHttpResponse);
        Test.stopTest();

        CSUtils.itShouldBe('Error message should be ', '400 Request Failed', response.errorMsg);
    }
}
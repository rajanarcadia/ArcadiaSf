@isTest
private class GetAccountsByStatementIdsRspParserTest {
    @isTest
    static void testSuccessfulResponseParsing() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'GetAccountsByStatementIdsResponse',
            200
        );
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());

        Test.startTest();
        GetAccountsByCredsResponse response = (GetAccountsByCredsResponse) new GetAccountsByStatementIdsResponseParser()
            .parseResponse(mockHttpResponse);
        Test.stopTest();

        CSUtils.itShouldBe('Error message Should be null ', null, response.errorMsg);
        CSUtils.itShouldBe('Status should be 200', 200, response.status);
        CSUtils.itShouldBe('Message Should be success', 'Success', response.message);
    }

    @isTest
    static void testErrorResponseParsing() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'GetAccountsByStatementIdsResponseFailure',
            400
        );

        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());

        Test.startTest();
        GetAccountsByCredsResponse response = (GetAccountsByCredsResponse) new GetAccountsByStatementIdsResponseParser()
            .parseResponse(mockHttpResponse);
        Test.stopTest();

        CSUtils.itShouldBe('Should be 400 Bad request ', '400 Bad request', response.errorMsg);
        CSUtils.itShouldBe('Status should be 400', 400, response.status);
    }
}
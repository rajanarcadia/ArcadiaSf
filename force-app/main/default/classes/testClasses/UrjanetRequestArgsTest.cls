@isTest
public with sharing class UrjanetRequestArgsTest {
    @isTest
    static void testGetRequestParams() {
        Test.startTest();
        UrjanetRequestArgs args = new UrjanetRequestArgs();
        args.requestParams = new List<String>{ 'test' };

        Test.stopTest();

        CSUtils.itShouldBe('Request Params Get', 'test', args.requestParams.get(0));
    }

    @isTest
    static void testNullRequestParams() {
        Test.startTest();
        UrjanetRequestArgs args = new UrjanetRequestArgs();
        List<String> testList = args.requestParams;

        Test.stopTest();

        CSUtils.itShouldNotBe('Request Params Null Get', null, testList);
    }
}
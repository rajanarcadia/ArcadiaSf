@isTest
public with sharing class ArcadiaStatementUploadCalloutServiceTest {
    @isTest
    static void uploadStatementTest() {
        ArcadiaStatementUploadCalloutService service = ArcadiaStatementUploadCalloutService.getInstance();

        ArcadiaStatementUploadCalloutResources.UploadStatementResponse calloutResponse = new ArcadiaStatementUploadCalloutResources.UploadStatementResponse();
        LoginResponse loginResponse = new LoginResponse();
        loginResponse.token = 'test access token';

        TestUtility.GenericStub stub = new TestUtility.GenericStub(
            new Map<String, Object>{
                'GetContentType' => 'test/content', //helper
                'getFileResponseDetails' => calloutResponse, //callout
                'getUploadStatementBody' => Blob.valueOf('test data'), //callout
                'getAccessToken' => loginResponse // client
            }
        );
        service.helper = (ArcadiaMultiPartBodyHelper) Test.createStub(ArcadiaMultiPartBodyHelper.class, stub);
        service.callout = (ArcadiaStatementUploadCalloutResources) Test.createStub(
            ArcadiaStatementUploadCalloutResources.class,
            stub
        );
        service.client = (UrjanetApiClient) Test.createStub(UrjanetApiClient.class, stub);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Map<String, Object> fileDetails = new Map<String, Object>();

        Test.startTest();
        ArcadiaStatementUploadCalloutResources.UploadStatementResponse actualResponse;
        actualResponse = service.UploadStatement(JSON.serialize(fileDetails),'TestFileName.pdf');
        Test.stopTest();

        System.assert(actualResponse != null, 'UploadStatement must return a result');
    }

    @isTest
    static void uploadStatementExceptionTest() {
        ArcadiaStatementUploadCalloutService service = ArcadiaStatementUploadCalloutService.getInstance();

        ArcadiaStatementUploadCalloutResources.UploadStatementResponse calloutResponse = new ArcadiaStatementUploadCalloutResources.UploadStatementResponse();
        LoginResponse loginResponse = new LoginResponse();
        loginResponse.token = 'test access token';

        TestUtility.GenericStub stub = new TestUtility.GenericStub(
            new Map<String, Object>{
                'GetContentType' => new ArcadiaCalloutServiceException('test error', 'test error code'), //helper
                'getFileResponseDetails' => calloutResponse, //callout
                'getUploadStatementBody' => Blob.valueOf('test data'), //callout
                'getAccessToken' => loginResponse // client
            }
        );
        service.helper = (ArcadiaMultiPartBodyHelper) Test.createStub(ArcadiaMultiPartBodyHelper.class, stub);
        service.callout = (ArcadiaStatementUploadCalloutResources) Test.createStub(
            ArcadiaStatementUploadCalloutResources.class,
            stub
        );
        service.client = (UrjanetApiClient) Test.createStub(UrjanetApiClient.class, stub);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Map<String, Object> fileDetails = new Map<String, Object>();

        Test.startTest();
        try {
            ArcadiaStatementUploadCalloutResources.UploadStatementResponse actualResponse;
            actualResponse = service.UploadStatement(JSON.serialize(fileDetails),'TestFileName.pdf');
        } catch (ArcadiaCalloutServiceException e) {
            //Happy Path
            System.assertEquals('test error', e.getMessage(), 'Unexpected exception caught');
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception caught');
        }
        Test.stopTest();
    }

    @isTest
    static void uploadStatementErrorCodeTest() {
        ArcadiaStatementUploadCalloutService service = ArcadiaStatementUploadCalloutService.getInstance();

        ArcadiaStatementUploadCalloutResources.UploadStatementResponse calloutResponse = new ArcadiaStatementUploadCalloutResources.UploadStatementResponse();
        LoginResponse loginResponse = new LoginResponse();
        loginResponse.token = 'test access token';

        TestUtility.GenericStub stub = new TestUtility.GenericStub(
            new Map<String, Object>{
                'GetContentType' => new ArcadiaCalloutServiceException('test error', 'test error code'), //helper
                'getFileResponseDetails' => calloutResponse, //callout
                'getUploadStatementBody' => Blob.valueOf('test data'), //callout
                'getAccessToken' => loginResponse // client
            }
        );
        service.helper = (ArcadiaMultiPartBodyHelper) Test.createStub(ArcadiaMultiPartBodyHelper.class, stub);
        service.callout = (ArcadiaStatementUploadCalloutResources) Test.createStub(
            ArcadiaStatementUploadCalloutResources.class,
            stub
        );
        service.client = (UrjanetApiClient) Test.createStub(UrjanetApiClient.class, stub);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500));

        Map<String, Object> fileDetails = new Map<String, Object>();

        Test.startTest();
        try {
            ArcadiaStatementUploadCalloutResources.UploadStatementResponse actualResponse;
            actualResponse = service.UploadStatement(JSON.serialize(fileDetails),'TestFileName.pdf');
        } catch (ArcadiaCalloutServiceException e) {
            //Happy Path
            System.assertEquals('test error', e.getMessage(), 'Unexpected exception caught');
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception caught');
        }
        Test.stopTest();
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public Integer statusCode { get; set; }

        public MockHttpResponseGenerator() {
            this(200);
        }

        public MockHttpResponseGenerator(Integer statusCode) {
            this.statusCode = statusCode;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }
}
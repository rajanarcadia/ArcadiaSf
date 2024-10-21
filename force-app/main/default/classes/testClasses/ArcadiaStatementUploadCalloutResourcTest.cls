@isTest
public with sharing class ArcadiaStatementUploadCalloutResourcTest {
    @isTest
    static void getUploadStatementBodyTest() {
        ArcadiaStatementUploadCalloutResources res = new ArcadiaStatementUploadCalloutResources();

        TestUtility.GenericStub stub = new TestUtility.GenericStub(
            new Map<String, Object>{
                'WriteBoundary' => EncodingUtil.base64Encode(Blob.valueOf('1')),
                'WriteBodyParameter' => EncodingUtil.base64Encode(Blob.valueOf('2')),
                'WriteBlobBodyParameter' => EncodingUtil.base64Encode(Blob.valueOf('3')),
                'WriteEndingBoundary' => EncodingUtil.base64Encode(Blob.valueOf('4'))
            }
        );
        res.helper = (ArcadiaMultiPartBodyHelper) Test.createStub(ArcadiaMultiPartBodyHelper.class, stub);

        Map<String, Object> fileDetails = new Map<String, Object>{
            'fileName' => 'TestFileName.pdf',
            'fileContent' => Blob.valueOf('Test Blob Value')
        };

        String jsonFileDetails=JSON.serialize(fileDetails);

        Test.startTest();
        Blob body = res.getUploadStatementBody(jsonFileDetails,'TestFileName.pdf');
        Test.stopTest();

        System.assertEquals(2, stub.methodCallCount.get('WriteBoundary'), 'WriteBoundary should be called 2 times');
        System.assertEquals(
            1,
            stub.methodCallCount.get('WriteBodyParameter'),
            'WriteBodyParameter should be called 1 times'
        );
        System.assertEquals(
            1,
            stub.methodCallCount.get('WriteBlobBodyParameter'),
            'WriteBlobBodyParameter should be called 1 times'
        );
        System.assertEquals(
            1,
            stub.methodCallCount.get('WriteEndingBoundary'),
            'WriteEndingBoundary should be called 1 times'
        );
        System.assert(body != null, 'function returned body should not be null');
    }

    @isTest
    static void getFileResponseDetailsTest() {
        ArcadiaStatementUploadCalloutResources res = new ArcadiaStatementUploadCalloutResources();

        String fileResponseJSON =
            '{' +
            '"_embedded":{' +
            '"files":[' +
            '{' +
            '"createdDate":"2012-04-23T18:25:43.511Z",' +
            '"createdBy":"TestUser",' +
            '"entityId":"12345",' +
            '"fileName":"TestFileName",' +
            '"fileStatus":"TestStatus",' +
            '"id":"12345",' +
            '"_links":{' +
            '"statement":{' +
            '"href":"/statements/54321"' +
            '}' +
            '}' +
            '}' +
            ']' +
            '}' +
            '}';

        Test.startTest();
        ArcadiaStatementUploadCalloutResources.UploadStatementResponse resp = res.getFileResponseDetails(
            fileResponseJSON,
            0
        );
        UtilityStatementFile__c usf = resp.toUtilityStatementRecord();
        Test.stopTest();

        System.assertEquals('TestFileName', usf.Name, 'Name does not match');
        System.assertEquals('12345', usf.EntityId__c, 'EntityId does not match');
        System.assertEquals('TestStatus', usf.Status__c, 'Status does not match');
        System.assertEquals(
            UrjanetUtils.getDateTime('2012-04-23T18:25:43.511Z'),
            usf.CreatedDateInArcadia__c,
            'Created Date does not match'
        );
        System.assertEquals('54321', usf.StatementId__c, 'StatementId does not match');
    }
}
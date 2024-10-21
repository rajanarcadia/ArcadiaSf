@isTest
public with sharing class ArcadiaMultiPartBodyHelperTest {
    @isTest
    static void getContentTypeTest() {
        ArcadiaMultiPartBodyHelper helper = new ArcadiaMultiPartBodyHelper();

        Test.startTest();
        string contentType = helper.GetContentType();
        Test.stopTest();

        Boolean test = contentType.contains(ArcadiaMultiPartBodyHelper.strBoundary);
        System.assert(test, 'content type malformed');
    }

    @isTest
    static void writeBoundaryTest() {
        ArcadiaMultiPartBodyHelper helper = new ArcadiaMultiPartBodyHelper();

        Test.startTest();
        string boundary = helper.WriteBoundary();
        Test.stopTest();

        String testData = EncodingUtil.base64Decode(boundary).toString();
        Boolean test = testData.contains(ArcadiaMultiPartBodyHelper.strBoundary);
        System.assert(test, 'boundary malformed');
    }

    @isTest
    static void writeEndingBoundaryCrLfTest() {
        ArcadiaMultiPartBodyHelper helper = new ArcadiaMultiPartBodyHelper();

        Test.startTest();
        string boundary = helper.WriteEndingBoundary(ArcadiaMultiPartBodyHelper.EndingType.CrLf);
        Test.stopTest();

        String testData = EncodingUtil.base64Decode(boundary).toString();
        System.assert(testData.startsWith('--'), 'Malformed ending boundary start'); //CrLf test

        Boolean test = testData.contains(ArcadiaMultiPartBodyHelper.strBoundary);
        System.assert(test, 'boundary malformed');
    }

    @isTest
    static void writeEndingBoundaryCrTest() {
        ArcadiaMultiPartBodyHelper helper = new ArcadiaMultiPartBodyHelper();

        Test.startTest();
        string boundary = helper.WriteEndingBoundary(ArcadiaMultiPartBodyHelper.EndingType.Cr);
        Test.stopTest();

        String testData = EncodingUtil.base64Decode(boundary).toString();
        System.assert(testData.startsWith('\n--'), 'Malformed ending boundary start'); //Cr test

        Boolean test = testData.contains(ArcadiaMultiPartBodyHelper.strBoundary);
        System.assert(test, 'boundary malformed');
    }

    @isTest
    static void writeEndingBoundaryNoneTest() {
        ArcadiaMultiPartBodyHelper helper = new ArcadiaMultiPartBodyHelper();

        Test.startTest();
        string boundary = helper.WriteEndingBoundary(ArcadiaMultiPartBodyHelper.EndingType.None);
        Test.stopTest();

        String testData = EncodingUtil.base64Decode(boundary).toString();
        System.assert(testData.startsWith('\r\n--'), 'Malformed ending boundary start'); //CrLf test

        Boolean test = testData.contains(ArcadiaMultiPartBodyHelper.strBoundary);
        System.assert(test, 'boundary malformed');
    }

    @isTest
    static void writeBodyParameterTest() {
        ArcadiaMultiPartBodyHelper helper = new ArcadiaMultiPartBodyHelper();

        String key = 'test key';
        String value = 'test value';

        Test.startTest();
        string body = helper.WriteBodyParameter(key, value);
        Test.stopTest();

        String testData = EncodingUtil.base64Decode(body).toString();
        System.assert(testData.contains(key), 'body malformed missing key');
        System.assert(testData.contains(value), 'body malformed missing value');
    }

    @isTest
    static void writeBodyParameterBadFileNameTest() {
        ArcadiaMultiPartBodyHelper helper = new ArcadiaMultiPartBodyHelper();

        String key = 'test key';
        String file = 'test file';
        String file64 = EncodingUtil.base64Encode(Blob.valueOf(file));
        String filename = 'TestFileName.pdf';

        Map<String,Object> mapFileDetails = new Map<String,Object>();
        mapFileDetails.put('fileName',filename);
        mapFileDetails.put('fileContent',file64);
        String strJsonFileDetails = JSON.serialize(mapFileDetails);

        try {
            Test.startTest();
            string body = helper.WriteBlobBodyParameter(key,strJsonFileDetails);
            Test.stopTest();
        } catch (ArcadiaMultiPartBodyHelper.InvalidMimeTypeException ihe) {
            //Happy Path!
        } catch (Exception e) {
            System.assert(false, 'Expected InvalidMimeTypeException');
        }
    }

    @isTest
    static void writeBodyParameterNoneTest() {
        ArcadiaMultiPartBodyHelper helper = new ArcadiaMultiPartBodyHelper();

        String key = 'test key';
        String file = 'test file'; //byte count matters for none
        String file64 = EncodingUtil.base64Encode(Blob.valueOf(file));
        String filename = 'testfilename.pdf';
        
        Map<String,Object> mapFileDetails = new Map<String,Object>();
        mapFileDetails.put('fileName',filename);
        mapFileDetails.put('fileContent',file64);
        String strJsonFileDetails = JSON.serialize(mapFileDetails);

        Test.startTest();
        string body = helper.WriteBlobBodyParameter(key,strJsonFileDetails);
        Test.stopTest();

        String testData = EncodingUtil.base64Decode(body).toString();
        System.assert(testData.contains(key), 'body malformed missing key');
        System.assert(testData.contains(file), 'body malformed missing file64');
        System.assert(testData.contains(filename), 'body malformed missing filename');
    }

    @isTest
    static void writeBodyParameterCrLfTest() {
        ArcadiaMultiPartBodyHelper helper = new ArcadiaMultiPartBodyHelper();

        String key = 'test key';
        String file = 'test file=='; //byte count matters for crlf
        String file64 = EncodingUtil.base64Encode(Blob.valueOf(file));
        String filename = 'test filename.pdf';

        Map<String,Object> mapFileDetails = new Map<String,Object>();
        mapFileDetails.put('fileName',filename);
        mapFileDetails.put('fileContent',file64);
        String strJsonFileDetails = JSON.serialize(mapFileDetails);

        Test.startTest();
        string body = helper.WriteBlobBodyParameter(key, strJsonFileDetails);
        Test.stopTest();

        String testData = EncodingUtil.base64Decode(body).toString();
        System.assert(testData.contains(key), 'body malformed missing key');
        System.assert(testData.contains(file), 'body malformed missing file');
        System.assert(testData.contains(filename), 'body malformed missing filename');
    }

    @isTest
    static void writeBodyParameterCrTest() {
        ArcadiaMultiPartBodyHelper helper = new ArcadiaMultiPartBodyHelper();

        String key = 'test key';
        String file = 'test file='; //byte count matters for cr
        String file64 = EncodingUtil.base64Encode(Blob.valueOf(file));
        String filename = 'testfilename.pdf';

        Map<String,Object> mapFileDetails = new Map<String,Object>();
        mapFileDetails.put('fileName',filename);
        mapFileDetails.put('fileContent',file64);
        String strJsonFileDetails = JSON.serialize(mapFileDetails);

        Test.startTest();
        string body = helper.WriteBlobBodyParameter(key, strJsonFileDetails);
        Test.stopTest();

        String testData = EncodingUtil.base64Decode(body).toString();
        System.assert(testData.contains(key), 'body malformed missing key');
        System.assert(testData.contains(file), 'body malformed missing file');
        System.assert(testData.contains(filename), 'body malformed missing filename');
    }
}
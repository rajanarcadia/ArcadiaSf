@isTest
public with sharing class ArcadiaStatementUploadCtrlTest {
    @TestSetup
    static void makeData() {
        User adminUser = TestUtility.createUserAdmin('urjanetAdmin@urjanettest.com');
    }

    @isTest
    static void uploadFileTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            Account account = new Account();
            account.Name = 'Test Account';
            insert account;

            Supplier supplier = new Supplier();
            supplier.Name = 'Test Supplier';
            supplier.AccountId = account.Id;
            insert supplier;

            Map<String, Object> fileDetails = new Map<String, Object>();
            fileDetails.put('fileName', 'TestFileName.pdf');
            fileDetails.put('fileContent', EncodingUtil.base64Encode(Blob.valueOf('test file')));

            String supplierId = supplier.id;

            Test.setMock(HttpCalloutMock.class, new ArcadiaStatementUploadResponseMock());
            Test.startTest();
            ArcadiaStatementUploadCtrl.uploadFile(fileDetails, supplierId, 'TestFileName.pdf');
            Test.stopTest();

            List<UtilityStatementFile__c> lstFile = [SELECT id FROM UtilityStatementFile__c];
            System.assertEquals(1, lstFile.size());
        }
    }
    @isTest
    static void uploadFileExceptionHandlingTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            Account account = new Account();
            account.Name = 'Test Account';
            insert account;

            Supplier supplier = new Supplier();
            supplier.Name = 'Test Supplier';
            supplier.AccountId = account.Id;
            insert supplier;

            Test.setMock(HttpCalloutMock.class, new ArcadiaStatementUploadResponseMock());
            Test.startTest();
            try {
                ArcadiaStatementUploadCtrl.uploadFile(null, null, 'TestFileName.pdf');
            } catch (Exception e) {
                System.assertEquals('File is empty', e.getMessage(), 'The Exception Message Should match');
            }
            Test.stopTest();
        }
    }
    @isTest
    static void uploadFileExceptionTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            Account account = new Account();
            account.Name = 'Test Account';
            insert account;

            Supplier supplier = new Supplier();
            supplier.Name = 'Test Supplier';
            supplier.AccountId = account.Id;
            insert supplier;

            Map<String, Object> fileDetails = new Map<String, Object>{};
            fileDetails.put('fileName', 'TestFileName.pdf');
            fileDetails.put('fileContent', EncodingUtil.base64Encode(Blob.valueOf('test file')));
            String supplierId = supplier.id;

            Test.setMock(HttpCalloutMock.class, new ArcadiaStatementUploadResponseErrorMock());
            Test.startTest();
            ArcadiaStatementUploadCtrl.uploadFile(fileDetails, supplierId, 'TestFileName.pdf');
            Test.stopTest();

            List<Log__c> lstLogs = [SELECT id FROM Log__c];
            System.assertEquals(false, lstLogs.isEmpty());
        }
    }
}
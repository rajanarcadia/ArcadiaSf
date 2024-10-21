@isTest
public with sharing class ArcadiaStatementUploadServiceTest {
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

            Map<String, Object> fileDetails = new Map<String, Object>{};
            fileDetails.put('fileName','TestFileName.pdf');
            fileDetails.put('fileContent',EncodingUtil.base64Encode(Blob.valueOf('test file')));

            String supplierId = supplier.Id;
    
            Test.setMock(HttpCalloutMock.class, new ArcadiaStatementUploadResponseMock());
            Test.startTest();
                ArcadiaStatementUploadService.uploadFile(JSON.serialize(fileDetails), supplierId,'TestFileName.pdf');
            Test.stopTest();

            List<UtilityStatementFile__c> lstFile=[SELECT id FROM UtilityStatementFile__c];
            System.assertEquals(1, lstFile.size());
        }
    }
}
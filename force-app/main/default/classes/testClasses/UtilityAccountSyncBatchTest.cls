@IsTest
public with sharing class UtilityAccountSyncBatchTest {
    @TestSetup
    static void makeData() {
        User adminUser = TestUtility.createUserAdmin('urjanetAdmin@urjanettest.com');
        System.runAs(adminUser) {
            Account account = new Account();
            account.Name = 'Test Account';
            insert account;

            Supplier supplier = new Supplier();
            supplier.Name = 'Test Supplier';
            supplier.AccountId = account.Id;
            insert supplier;

            UtilityCredential__c credential = new UtilityCredential__c();
            credential.Name = 'Test Credential';
            credential.Username__c = 'test';
            credential.ProviderName__c = supplier.Id;
            insert credential;

            UtilityAccount__c utilityAccount = new UtilityAccount__c();
            utilityAccount.UrjanetId__c = 'AccountId';
            utilityAccount.UtilityCredential__c = credential.Id;
            insert utilityAccount;
        }
    }
    @IsTest
    public static void utilityAccountSyncTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            Supplier supplier = [SELECT Id FROM Supplier LIMIT 1];

            Integer batchSize = UrjanetUtils.getBatchSize(false);
            Test.startTest();
            Database.executeBatch(new UtilityAccountSyncBatch(), batchSize);
            Test.stopTest();
            List<AsyncApexJob> AsyncApexJobList = [
                SELECT Id, Status, JobType, ApexClass.Name
                FROM AsyncApexJob
                WHERE JobType = 'BatchApex'
            ];
            CSUtils.itShouldBe('AsyncApexJobList size ', 1, AsyncApexJobList.size());
            CSUtils.itShouldBe(
                'AsyncApexJobList.ApexClass name ',
                'UtilityAccountSyncBatch',
                AsyncApexJobList[0].ApexClass.Name
            );

            UtilityAccount__c result = [
                SELECT Id, UrjanetId__c, Supplier__c
                FROM UtilityAccount__c
                WHERE UrjanetId__c = 'AccountId'
            ];
            CSUtils.itShouldBe('UtilityAccount__c.Supplier Id ', supplier.Id, result.Supplier__c);
        }
    }
}
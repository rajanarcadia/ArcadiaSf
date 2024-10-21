@IsTest
public with sharing class UtilityAccountSyncServiceTest {
    @TestSetup
    static void makeData() {
        User adminUser = TestUtility.createUserAdmin('urjanetAdmin@urjanettest.com');
        System.runAs(adminUser) {
            UtilityAccount__c account = new UtilityAccount__c();
            account.UrjanetId__c = '1234abcd-2345-cd34-1234-1232434cdede';
            insert account;
        }
    }
    @IsTest
    public static void utilityCredentialSyncTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            Integer batchSize = UrjanetUtils.getBatchSize(false);
            UtilityAccount__c result = [SELECT Id, UrjanetId__c FROM UtilityAccount__c LIMIT 1];
            Test.startTest();
            Database.executeBatch(new UtilityAccountSyncBatch(), batchSize);
            Test.stopTest();
            List<AsyncApexJob> AsyncApexJobList = [
                SELECT Id, Status, JobType, ApexClass.Name
                FROM AsyncApexJob
                WHERE JobType = 'BatchApex'
            ];
            System.assertEquals(1, AsyncApexJobList.size(), 'Should have 1 AsyncApexJob created');
            System.assertEquals(
                'UtilityAccountSyncBatch',
                AsyncApexJobList[0].ApexClass.Name,
                'Name Should be UtilityMeterSyncBatch'
            );
        }
    }
}
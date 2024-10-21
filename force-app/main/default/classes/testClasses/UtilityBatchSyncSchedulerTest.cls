/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class UtilityBatchSyncSchedulerTest {
    @TestSetup
    static void makeData() {
        User adminUser = TestUtility.createUserAdmin('urjanetAdmin@urjanettest.com');
        System.runAs(adminUser) {
            UtilityCredential__c credential = new UtilityCredential__c(
                Name = 'Test Utility Credential',
                CorrelationId__c = '001TestCorrelationId'
            );
            insert credential;
        }
    }

    @IsTest
    public static void utilityCredentialSyncTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityCredential__c credential = [
                SELECT ID, CorrelationId__c
                FROM UtilityCredential__c
                WHERE Name = 'Test Utility Credential'
            ];

            CredentialResponseMock.credentialId = credential.CorrelationId__c;
            Integer batchSize = UrjanetUtils.getBatchSize(false);
            Test.setMock(HttpCalloutMock.class, new CredentialResponseMock());
            Test.startTest();
            Database.executeBatch(new UtilityCredentialSyncBatch(), batchSize);
            Test.stopTest();
            UtilityCredential__c updateCredential = [
                SELECT
                    ID,
                    Name,
                    CorrelationId__c,
                    NextScheduledRun__c,
                    Status__c,
                    StatusDetail__c,
                    Username__c,
                    Username2__c,
                    Username3__c,
                    urjanetId__c
                FROM UtilityCredential__c
                WHERE Id = :credential.Id
            ];
            CSUtils.itShouldBe('Correlation Id ', credential.CorrelationId__c, updateCredential.correlationId__c);
            CSUtils.itShouldBe('Status ', 'OK', updateCredential.Status__c);
            CSUtils.itShouldBe('Status Detail ', 'NO_ACTION_REQUIRED', updateCredential.StatusDetail__c);
            CSUtils.itShouldBe('Username ', 'Test_Name_1', updateCredential.Username__c);
            CSUtils.itShouldBe('Username 2 ', 'test_user_name2', updateCredential.Username2__c);
            CSUtils.itShouldBe('Username 3 ', 'test_user_name3', updateCredential.Username3__c);
            CSUtils.itShouldBe('Urjanet Id ', '1234abcd-1234-abc0-12ab-ab3242342332', updateCredential.urjanetId__c);
        }
    }

    @isTest
    static void testInvalidAccessTokenScheduleBatchJob() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityCredential__c credential = [
                SELECT ID, CorrelationId__c
                FROM UtilityCredential__c
                WHERE Name = 'Test Utility Credential'
            ];
            CredentialResponseMock.credentialId = credential.CorrelationId__c;
            Test.setMock(HttpCalloutMock.class, new CredentialResponseMock());
            Test.startTest();
            String jobId = UtilityBatchSyncScheduler.scheduleJob();
            Test.stopTest();
            CronTrigger scheduledRec = [SELECT Id FROM CronTrigger WHERE Id = :jobId];
            CSUtils.itShouldBe('Job Id ', jobId, scheduledRec.Id);
        }
    }

    @isTest
    static void testScheduleBatchJob() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityCredential__c credential = [
                SELECT ID, CorrelationId__c
                FROM UtilityCredential__c
                WHERE Name = 'Test Utility Credential'
            ];
            CredentialResponseMock.credentialId = credential.CorrelationId__c;
            Test.setMock(HttpCalloutMock.class, new CredentialResponseMock());
            insertAccessToken();
            TestUtility.insertLastSyncDetails();
            Test.startTest();
            String jobId = UtilityBatchSyncScheduler.scheduleJob();
            Test.stopTest();
            CronTrigger scheduledRec = [SELECT Id FROM CronTrigger WHERE Id = :jobId];
            CSUtils.itShouldBe('Job Id ', jobId, scheduledRec.Id);
        }
    }

    public static void insertAccessToken() {
        DateTime dt = System.Now();
        AccessToken__c accessTokenSetting = new AccessToken__c(
            Name = 'Default',
            Token1__c = 'This is token',
            Message__c = 'This is message',
            ExpirationTime__c = Datetime.newInstance(dt.year(), dt.month(), dt.day(), dt.hour() + 1, dt.minute(), 0)
        );
        insert accessTokenSetting;
    }
}
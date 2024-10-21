@IsTest
public with sharing class UtilityCredentialSyncServiceTest {
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

    @IsTest
    static void testSchedulable() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('LoginResponse', 200);
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
            String jobId = System.schedule(
                'Test Utility Credential Sync',
                UrjanetUtils.getSchedulerExpression(DateTime.Now().addDays(1)),
                new UtilityCredentialSyncScheduler()
            );
            Test.stopTest();
            CronTrigger scheduledRec = [SELECT Id FROM CronTrigger WHERE Id = :jobId];
            CSUtils.itShouldBe('Job Id ', jobId, scheduledRec.Id);
        }
    }

    @IsTest
    static void testScheduleJob() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('LoginResponse', 200);
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
            String jobId = UtilityCredentialSyncScheduler.scheduleJob();
            Test.stopTest();
            CronTrigger scheduledRec = [SELECT Id FROM CronTrigger WHERE Id = :jobId];
            CSUtils.itShouldBe('Job Id ', jobId, scheduledRec.Id);
        }
    }

    @IsTest
    static void testScheduleJobWithCron() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('LoginResponse', 200);
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
            String jobId = UtilityCredentialSyncScheduler.scheduleJob(
                'test schedule job',
                UrjanetUtils.getSchedulerExpression(DateTime.Now().addDays(1))
            );
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
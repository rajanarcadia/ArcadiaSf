@isTest
private class UtilityCredentialSyncBatchControllerTest {
    @TestSetup
    static void makeData() {
        User adminUser = TestUtility.createUserAdmin('urjanetAdmin@urjanettest.com');
        System.runAs(adminUser) {
            List<SObject> lstElectricityEmissionFactorSet = Test.loadData(
                ElectricityEmssnFctrSet.sObjectType,
                'ElectricityEmissionFactorSet'
            );
            List<SObject> lstOtherEmissionFactorSet = Test.loadData(
                OtherEmssnFctrSet.sObjectType,
                'OtherEmissionFactorSet'
            );
            StnryAssetEnvrSrc site = new StnryAssetEnvrSrc(
                UrjanetId__c = null,
                ElectricityEmssnFctrId = lstElectricityEmissionFactorSet[0].Id,
                OtherEmssnFctrId = lstOtherEmissionFactorSet[0].Id,
                Name = 'Test Site',
                LastUrjanetSyncDateTime__c = Datetime.now()
            );
            insert site;
        }
    }

    @isTest
    static void testPushSitesToUrjanet() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('PostSiteResponse', 202);
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) { 
            Test.startTest();
            UtilityCredentialSyncBatchController.pushSitesToUrjanet();
            Test.stopTest();
            List<StnryAssetEnvrSrc> sites = [SELECT Id, UrjanetId__c FROM StnryAssetEnvrSrc];
            CSUtils.itShouldBe(
                'UrjanetId__c should exist and match',
                '1ece6d51-dd82-d644-8a08-d23d6f619b36',
                sites[0].UrjanetId__c
            );
        }
    }
    @isTest
    static void testPushSitesToUrjanetErrorResponse() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('PostSiteResponseFailure', 400);
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            List<Log__c> logbeforeAPICall = [SELECT Id FROM Log__c LIMIT 1];
            CSUtils.itShouldBe('Expected number of records in Log Object', 0, logBeforeAPICall.size());
            Test.startTest();
            UtilityCredentialSyncBatchController.pushSitesToUrjanet();
            Test.stopTest();

            List<Log__c> logAfterAPICall = [SELECT Id, Message__c FROM Log__c LIMIT 1];
            CSUtils.itShouldBe('Number of records in Log Object', 1, logAfterAPICall.size());
            CSUtils.itShouldBe('Error message', '400 Bad request', logAfterAPICall[0].Message__c.trim());
        }
    }
    @isTest
    static void testExecuteBatchJob() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('LoginResponse', 200);
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            insertAccessToken();
            TestUtility.insertLastSyncDetails();
            Test.startTest();
            UtilityCredentialSyncBatchController.executeBatchJob(false);
            Integer batchSize = UrjanetUtils.getBatchSize(false);
            Test.stopTest();
            List<AsyncApexJob> bathcJobs = [SELECT Id, JobType, Status FROM AsyncApexJob WHERE JobType = 'BatchApex'];

            CSUtils.itShouldBe('There should be 7 batch jobs', 7, bathcJobs.size());
            CSUtils.itShouldBe('Batch size should be 20', 20, batchSize);

            for (AsyncApexJob job : bathcJobs) {
                CSUtils.itShouldBe('Job should be completed', 'Completed', job.Status);
            }
        }
    }

    @isTest
    static void testExecuteBatchAuthFailJob() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('LoginResponseFailure', 401);
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            UtilityCredentialSyncBatchController.executeBatchJob(false);
            Test.stopTest();
            List<AsyncApexJob> bathcJobs = [SELECT Id, JobType, Status FROM AsyncApexJob WHERE JobType = 'BatchApex'];

            for (AsyncApexJob job : bathcJobs) {
                System.assertEquals('Completed', job.Status, 'Job should be completed');
            }
        }
    }
    @isTest
    static void testExecuteBatchJobExceptionHandling() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('LoginResponse', 200);
        System.runAs(adminUser) {
            insertAccessToken();
            TestUtility.insertLastSyncDetails();
            Test.startTest();
            try {
                UtilityCredentialSyncBatchController.executeBatchJob(true);
            } catch (Exception e) {
                CSUtils.itShouldBe('Exception message should match', 'batchSize must not be null', e.getMessage());
            }
            Test.stopTest();
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

    @isTest
    static void testBatchCompleted() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            TestUtility.insertLastSyncDetails();
        }
        Test.startTest();
        Boolean batchstatus = UtilityCredentialSyncBatchController.isBatchExecutionCompleted(true);
        Test.stopTest();
        CSUtils.itShouldBe('There are no batches running currenlty', true, batchstatus);
    }

    @isTest
    static void testBatchCompletedRunningJobs() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('LoginResponse', 200);
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            insertAccessToken();
            TestUtility.insertLastSyncDetails();
            Test.startTest();
            UtilityCredentialSyncBatchController.executeBatchJob(false);
            Boolean batchstatus = UtilityCredentialSyncBatchController.isBatchExecutionCompleted(true);
            Test.stopTest();
            List<AsyncApexJob> bathcJobs = [SELECT Id, JobType, Status FROM AsyncApexJob WHERE JobType = 'BatchApex'];
            CSUtils.itShouldBe('There should be 7 batch jobs running', 7, bathcJobs.size());
            CSUtils.itShouldBe('exisiting batches are running currenlty', false, batchstatus);
        }
    }

    @isTest
    static void testBatchCompletedRunningQueItems() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            List<QueueItem__c> qis = new List<QueueItem__c>();
            for (Integer i = 0; i < 3; i++) {
                QueueItem__c qi = new QueueItem__c();
                qi.ClassName__c = QueueItemUtils.getNamespaceWithDot() + 'QueueItemTriggerTest.QueueItemTestProcessor';
                qis.add(qi);
            }
            Test.startTest();
            insert qis;
            Boolean batchstatus = UtilityCredentialSyncBatchController.isBatchExecutionCompleted(true);
            Test.stopTest();
            CSUtils.itShouldBe('exisiting batches are running currenlty', false, batchstatus);
        }
    }
}
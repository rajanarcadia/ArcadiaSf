@IsTest
private class UtilityStatementFileServiceTest {
    @TestSetup
    static void makeData() {
        User adminUser = TestUtility.createUserAdmin('urjanetAdmin@urjanettest.com');
        System.runAs(adminUser) {
            UtilityStatementFile__c fileObj = new UtilityStatementFile__c(
                Name = 'testFile',
                entityId__c = '1edabf9f-90a6-dddd-b173-2e3846f367a4',
                Status__c = 'PENDING'
            );
            UtilityStatementFile__c fileObj2 = new UtilityStatementFile__c(
                Name = 'testFile2',
                EntityId__c = '002TestFileId',
                StatementId__c = 'statementId123',
                Status__c = 'SUCCESS'
            );
            insert fileObj;
            insert fileObj2;
        }
    }

    @IsTest
    static void testStatementFileUpdate() {
        List<UtilityStatementFile__c> lstUpdateFile = [SELECT Id, Status__c FROM UtilityStatementFile__c LIMIT 1];
        lstUpdateFile[0].Status__c = 'FAILURE';
        update lstUpdateFile;
    }

    @IsTest
    static void testScheduleJob() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            TestUtility.insertLastSyncDetails();
            Test.setMock(HttpCalloutMock.class, new UtilityStatementFileResponseMock());
            Test.startTest();
            String jobId = UtilityCredentialSyncScheduler.scheduleJob();
            Test.stopTest();
            CronTrigger scheduledRec = [SELECT Id FROM CronTrigger WHERE Id = :jobId];
            CSUtils.itShouldBe('Job Id ', jobId, scheduledRec.Id);
        }
    }

    @IsTest
    static void testQueItemCreation() {
        QueueItemProcessor.suppressDuringTestRuns = true;
        String randomId = TestUtility.getRandomId(UtilityStatementFile__c.SObjectType);
        UtilityStatementFile__c fileObj = new UtilityStatementFile__c();
        fileObj.Id = Id.valueOf(randomId);

        Test.startTest();
        UtilityStatementFileService.createQueueItemsForUtilityStatementFiles(
            new List<UtilityStatementFile__c>{ fileObj }
        );
        Test.stopTest();

        Integer logCount = [SELECT COUNT() FROM Log__c];
        CSUtils.itShouldBe('No errors should exist', 0, logCount);
    }

    @IsTest
    static void testUpdateSuccess() {
        UtilityStatementFile__c file = [SELECT Id, Status__c FROM UtilityStatementFile__c LIMIT 1];
        file.StatementId__c = '123456789';
        file.Status__c = 'SUCCESS';

        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('AccountsByCredsResponse', 200);
        Test.startTest();
        update file;
        Test.stopTest();

        UtilityAccount__c utilityAccount = [SELECT Id, Name, AccountNumber__c FROM UtilityAccount__c];
        CSUtils.itShouldBe('Account Name', 'Xcel Energy - 5187939528', utilityAccount.Name);
        CSUtils.itShouldBe('Account Number', '5187939528', utilityAccount.AccountNumber__c);
    }

    @IsTest
    static void testUpdateSuccessAPIError() {
        UtilityStatementFile__c file = [SELECT Id, Status__c FROM UtilityStatementFile__c LIMIT 1];
        file.StatementId__c = '123456789';
        file.Status__c = 'SUCCESS';

        List<Log__c> logbeforeAPICall = [SELECT Id FROM Log__c LIMIT 1];
        CSUtils.itShouldBe('Expected number of records in Log Object', 0, logBeforeAPICall.size());

        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('GenericFailureMessageResponse', 400);
        Test.startTest();
        update file;
        Test.stopTest();

        List<Log__c> logAfterAPICall = [SELECT Id, Message__c FROM Log__c LIMIT 1];
        CSUtils.itShouldBe('Error message', '400 Request Failed', logAfterAPICall[0].Message__c.trim());
    }

    @IsTest
    static void testUtilityStatementFileSyncBatch() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('UtilityStatementFilesResponse', 200);

        Test.startTest();
        Database.executeBatch(new UtilityStatementFileSyncBatch(), 20);
        Test.stopTest();

        UtilityStatementFile__c utilityStatementFile = [
            SELECT Id, Status__c, EntityId__c, StatementId__c
            FROM UtilityStatementFile__c
            WHERE entityId__c = '1edabf9f-90a6-dddd-b173-2e3846f367a4'
        ];
    }

    @IsTest
    static void testLinkUtilityStatementFilesWithAccount() {
        List<UtilityStatementFile__c> files = [SELECT Id FROM UtilityStatementFile__c WHERE Status__C = 'SUCCESS'];
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('AccountsByCredsResponse', 200);

        Test.startTest();
        UtilityStatementFileService.linkUtilityStatementFilesWithAccount(files);
        Test.stopTest();

        UtilityAccount__c utilityAccount = [SELECT Id, Name, AccountNumber__c FROM UtilityAccount__c];
        CSUtils.itShouldBe('Account Name', 'Xcel Energy - 5187939528', utilityAccount.Name);
        CSUtils.itShouldBe('Account Number', '5187939528', utilityAccount.AccountNumber__c);
        Utility_File_Account_Association__c fileAccount = [
            SELECT Id, Utility_Statement_File__c, Utility_Account__c
            FROM Utility_File_Account_Association__c
        ];
        CSUtils.itShouldBe('Utility Account Id', utilityAccount.Id, fileAccount.Utility_Account__c);
        CSUtils.itShouldBe('Utility Statement Id', files[0].Id, fileAccount.Utility_Statement_File__c);
    }
}
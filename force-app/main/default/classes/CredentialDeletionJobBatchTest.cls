@isTest
public class CredentialDeletionJobBatchTest {
    @testSetup
    static void testSetupMethod() {
        User adminUser = TestUtility.createUserAdmin('arcadiaAdmin1@test.com');
        System.runAs(adminUser) {
            UtilityCredential__c cred = new UtilityCredential__c(
                UrjanetId__c = TestUtility.CREDENTIAL_ID,
                CorrelationId__c = 'test-correlation-Id',
                Name = 'Test Cred'
            );
            insert cred;
            List<Credential_Deletion_Log__c> deletionLogs = new List<Credential_Deletion_Log__c>();
            Credential_Deletion_Log__c deletionLog = new Credential_Deletion_Log__c(
                Status__c = UrjanetConstants.CRED_DEL_STATUS_INPROGRESS,
                Credential_Id__c = cred.Id,
                Deletion_Log_Id__c = 'test-deletionlog-id'
            );
            deletionLogs.add(deletionLog);
            Credential_Deletion_Log__c deletionLogWithOutDeleiotnLogId = new Credential_Deletion_Log__c(
                Status__c = UrjanetConstants.CRED_DEL_STATUS_INPROGRESS,
                Credential_Id__c = cred.Id
            );
            deletionLogs.add(deletionLogWithOutDeleiotnLogId);
            insert deletionLogs;
        }
    }
    @isTest
    static void testCredentialDeletionJobBatch() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            Test.StartTest();
            TestUtility.getStaticResourceCalloutMock('CredentialDeletionJobApiResponse', 200);
            Integer batchSize = UrjanetUtils.getBatchSize(false);
            try {
                CredentialDeletionJobBatch batch = new CredentialDeletionJobBatch();
                Database.executeBatch(batch, batchSize);
            } catch (Exception e) {
                system.debug('Exception :' + e.getMessage());
            }
            Test.stopTest();
            List<AsyncApexJob> AsyncApexJobList = [
                SELECT Id, Status, JobType, ApexClass.Name
                FROM AsyncApexJob
                WHERE JobType = 'BatchApex'
            ];
            CSUtils.itShouldBe('AsyncApexJobList size ', 1, AsyncApexJobList.size());
            CSUtils.itShouldBe(
                'AsyncApexJobList.ApexClass name ',
                'CredentialDeletionJobBatch',
                AsyncApexJobList[0].ApexClass.Name
            );
            List<Credential_Deletion_Log__c> deletionLogs = [SELECT Id FROM Credential_Deletion_Log__c];
            CSUtils.itShouldBe('deletionLogs size should be 1 as one gets deleted ', 1, deletionLogs.size());
        }

    }
    @isTest
    static void testCredentialDeletionJobBatchFailure() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            Test.StartTest();
            Integer batchSize = UrjanetUtils.getBatchSize(false);
            TestUtility.getStaticResourceCalloutMock('GenericFailureResponse', 400);
            try {
                CredentialDeletionJobBatch batch = new CredentialDeletionJobBatch();
                Database.executeBatch(batch, batchSize);
            } catch (Exception e) {
            }
            Test.stopTest();
            List<AsyncApexJob> AsyncApexJobList = [
                SELECT Id, Status, JobType, ApexClass.Name
                FROM AsyncApexJob
                WHERE JobType = 'BatchApex'
            ];
            CSUtils.itShouldBe('AsyncApexJobList size ', 1, AsyncApexJobList.size());
            CSUtils.itShouldBe(
                'AsyncApexJobList.ApexClass name ',
                'CredentialDeletionJobBatch',
                AsyncApexJobList[0].ApexClass.Name
            );
            List<Credential_Deletion_Log__c> deletionLogs = [SELECT Id FROM Credential_Deletion_Log__c];
            CSUtils.itShouldBe('deletionLogs size should be 2 as no one gets deleted ', 2, deletionLogs.size());
        }
    }
    @isTest
    static void testCredentialDeletionJobBatchMalformedJson() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            CredentialDeletionJobResponseParser parser = new CredentialDeletionJobResponseParser();
            Test.startTest();
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('[{"correlationId":""}]');
            UrjanetResponse res = new UrjanetResponse();
            try {
                res = parser.parseResponse(response);
            } catch (Exception e) {
                system.debug('Exception ' + e.getMessage());
            }
            Test.stopTest();
            CSUtils.itShouldBe(
                'Error message should contain Malformed JSON:',
                true,
                res.ex.getMessage().contains('Malformed JSON:')
            );
        }
    }
}
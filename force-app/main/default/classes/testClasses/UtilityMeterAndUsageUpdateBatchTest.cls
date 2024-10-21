@IsTest
private class UtilityMeterAndUsageUpdateBatchTest {
    
    @TestSetup
    static void setup() {
        // Create admin user
        User adminUser = TestUtility.createUserAdmin('urjanetAdmin@urjanettest.com');
    }

    @IsTest
    public static void testUtilityMeterAndUsageUpdateBatch() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            Integer batchSize = UrjanetUtils.getBatchSize(false);
            Test.startTest();
            Database.executeBatch(new UtilityMeterAndUsageUpdateBatch(), batchSize);
            Test.stopTest();
            List<AsyncApexJob> AsyncApexJobList = [
                SELECT Id, Status, JobType, ApexClass.Name
                FROM AsyncApexJob
                WHERE JobType = 'BatchApex'
            ];
            CSUtils.itShouldBe('AsyncApexJobList size ', 2, AsyncApexJobList.size());
            CSUtils.itShouldBe(
                'AsyncApexJobList.ApexClass name ',
                'UtilityMeterAndUsageUpdateBatch',
                AsyncApexJobList[0].ApexClass.Name
            );
        }
    }
}

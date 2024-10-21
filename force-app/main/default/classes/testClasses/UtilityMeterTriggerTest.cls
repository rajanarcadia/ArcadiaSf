/**
 * Created by mike on 5/10/22.
 */

@IsTest
private class UtilityMeterTriggerTest {
    // This test is really just for coverage because triggers are required to have coverage. The logic performed
    // as a result of the triggers is tested thoroughly in test classes corresponding to the services that do the
    // work
    @IsTest
    static void givenUtilityMeterRecordsInsertedUtilityMeterRecordsExist() {
        UtilityMeter__c meter = new UtilityMeter__c();
        meter.LastUrjanetSyncDateTime__c = Datetime.now();

        Test.startTest();
        insert meter;
        Test.stopTest();

        List<UtilityMeter__c> meters = [SELECT Id FROM UtilityMeter__c];
        CSUtils.itShouldBe('A meter record should exist', 1, meters.size());
    }

    @IsTest
    static void givenUtilityMeterRecordsUpdatedUtilityMeterRecordsUpdatedOnDatabase() {
        UtilityMeter__c meter = new UtilityMeter__c();
        meter.LastUrjanetSyncDateTime__c = Datetime.now();
        insert meter;

        meter.Name = 'TestMeter';

        Test.startTest();
        update meter;
        Test.stopTest();

        List<UtilityMeter__c> meters = [SELECT Id, Name FROM UtilityMeter__c];
        CSUtils.itShouldBe('Meter name should be updated', 'TestMeter', meters[0].Name);
    }
}
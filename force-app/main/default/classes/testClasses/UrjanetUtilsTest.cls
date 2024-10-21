/**
 * Created by mike on 5/10/22.
 */

@IsTest
private class UrjanetUtilsTest {
    @IsTest
    static void givenRecordsWithDifferentSyncFieldTrueReturned() {
        String randomId = TestUtility.getRandomId(UtilityMeter__c.SObjectType);
        UtilityMeter__c updatedMeter = new UtilityMeter__c();
        updatedMeter.LastUrjanetSyncDateTime__c = Datetime.now();
        updatedMeter.Id = Id.valueOf(randomId);

        UtilityMeter__c oldMeter = new UtilityMeter__c();
        oldMeter.LastUrjanetSyncDateTime__c = Datetime.now().addMinutes(-1);
        oldMeter.Id = Id.valueOf(randomId);

        Map<Id, UtilityMeter__c> oldMap = new Map<Id, UtilityMeter__c>();
        oldMap.put(Id.valueOf(randomId), oldMeter);

        Test.startTest();
        Boolean hasRecordChanged = UrjanetUtils.hasSyncFieldUpdated(
            updatedMeter,
            oldMap,
            UtilityMeter__c.LastUrjanetSyncDateTime__c
        );
        Test.stopTest();

        CSutils.itShouldBe('Record Change Boolean should be true', true, hasRecordChanged);
    }

    @IsTest
    static void givenRecordsWithSameSyncFieldFalseReturned() {
        String randomId = TestUtility.getRandomId(UtilityMeter__c.SObjectType);
        DateTime lastSyncDateTime = DateTime.now();
        UtilityMeter__c updatedMeter = new UtilityMeter__c();
        updatedMeter.LastUrjanetSyncDateTime__c = lastSyncDateTime;
        updatedMeter.Id = Id.valueOf(randomId);

        UtilityMeter__c oldMeter = new UtilityMeter__c();
        oldMeter.LastUrjanetSyncDateTime__c = lastSyncDateTime;
        oldMeter.Id = Id.valueOf(randomId);

        Map<Id, UtilityMeter__c> oldMap = new Map<Id, UtilityMeter__c>();
        oldMap.put(Id.valueOf(randomId), oldMeter);

        Test.startTest();
        Boolean hasRecordChanged = UrjanetUtils.hasSyncFieldUpdated(
            updatedMeter,
            oldMap,
            UtilityMeter__c.LastUrjanetSyncDateTime__c
        );
        Test.stopTest();

        CSutils.itShouldBe('Record Change Boolean should be false', false, hasRecordChanged);
    }

    @isTest
    static void testProcessErrorHandling() {
        GetAccountsByCredsResponse response = new GetAccountsByCredsResponse();
        response.errorMsg = 'Error Message Test';
        response.status = 500;

        try {
            Test.startTest();
            QueueItem__c queueItem = new QueueItem__c(
                RecordId__c = 'RecordId123',
                PageNumber__c = 1,
                RequestType__c = UrjanetEnums.RequestType.ACCOUNTS_BY_CREDS.name()
            );
            insert queueItem;
            UrjanetUtils.handleApiError(
                queueItem,
                response.errorMsg,
                response.message,
                response.status,
                UtilityCredentialProcessor.class.getName()
            );
            Test.stopTest();
            System.assert(false, 'Expected exception to be thrown');
        } catch (ArcadiaCalloutServiceException e) {
            System.assertEquals('Error Message Test', e.getMessage(), 'Error is expected');
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception occurred: ' + e.getMessage());
        }
    }

    @isTest
    static void testGetDateRanges() {
        UtilityMeterUsage__c meterUsage = new UtilityMeterUsage__c();
        meterUsage.PeriodStart__c = Date.newInstance(2018, 1, 1);
        meterUsage.PeriodEnd__c = Date.newInstance(2018, 1, 31);
        List<UrjanetUtils.SplitDateDetails> expectedDateRanges = new List<UrjanetUtils.SplitDateDetails>();
        expectedDateRanges.add(
            new UrjanetUtils.SplitDateDetails(Date.newInstance(2018, 1, 1), Date.newInstance(2018, 1, 31))
        );
        List<UrjanetUtils.SplitDateDetails> actualDateRanges = UrjanetUtils.getDateRanges(meterUsage);
        CSutils.itShouldBe('Expected Date Ranges Size ', 1, actualDateRanges.size());
        CSutils.itShouldBe(
            'Expected Start Date ',
            expectedDateRanges.get(0).startDate,
            actualDateRanges.get(0).startDate
        );
        CSutils.itShouldBe(
            'Expected End Date ',
            expectedDateRanges.get(0).startDate,
            actualDateRanges.get(0).startDate
        );
    }

    @isTest
    static void testGetDateRangesForThreeMonths() {
        UtilityMeterUsage__c meterUsage = new UtilityMeterUsage__c();
        meterUsage.PeriodStart__c = Date.newInstance(2018, 1, 15);
        meterUsage.PeriodEnd__c = Date.newInstance(2018, 3, 10);
        List<UrjanetUtils.SplitDateDetails> expectedDateRanges = new List<UrjanetUtils.SplitDateDetails>();
        expectedDateRanges.add(
            new UrjanetUtils.SplitDateDetails(Date.newInstance(2018, 1, 15), Date.newInstance(2018, 1, 31))
        );
        expectedDateRanges.add(
            new UrjanetUtils.SplitDateDetails(Date.newInstance(2018, 2, 1), Date.newInstance(2018, 2, 28))
        );
        expectedDateRanges.add(
            new UrjanetUtils.SplitDateDetails(Date.newInstance(2018, 3, 1), Date.newInstance(2018, 3, 10))
        );
        List<UrjanetUtils.SplitDateDetails> actualDateRanges = UrjanetUtils.getDateRanges(meterUsage);
        CSutils.itShouldBe('Expected Date Ranges Size ', 3, actualDateRanges.size());
        CSutils.itShouldBe(
            'Expected Start Date 1 ',
            expectedDateRanges.get(0).startDate,
            actualDateRanges.get(0).startDate
        );
        CSutils.itShouldBe(
            'Expected End Date 1 ',
            expectedDateRanges.get(0).startDate,
            actualDateRanges.get(0).startDate
        );
        CSutils.itShouldBe(
            'Expected Start Date 2 ',
            expectedDateRanges.get(1).startDate,
            actualDateRanges.get(1).startDate
        );
        CSutils.itShouldBe(
            'Expected End Date 2 ',
            expectedDateRanges.get(1).startDate,
            actualDateRanges.get(1).startDate
        );
        CSutils.itShouldBe(
            'Expected Start Date 3 ',
            expectedDateRanges.get(2).startDate,
            actualDateRanges.get(2).startDate
        );
        CSutils.itShouldBe(
            'Expected End Date 3 ',
            expectedDateRanges.get(2).startDate,
            actualDateRanges.get(2).startDate
        );
    }

    @isTest
    static void testGetDateRangesForSameDate() {
        UtilityMeterUsage__c meterUsage = new UtilityMeterUsage__c();
        meterUsage.PeriodStart__c = Date.newInstance(2018, 1, 15);
        meterUsage.PeriodEnd__c = Date.newInstance(2018, 1, 15);
        List<UrjanetUtils.SplitDateDetails> expectedDateRanges = new List<UrjanetUtils.SplitDateDetails>();
        expectedDateRanges.add(
            new UrjanetUtils.SplitDateDetails(Date.newInstance(2018, 1, 15), Date.newInstance(2018, 1, 15))
        );
        List<UrjanetUtils.SplitDateDetails> actualDateRanges = UrjanetUtils.getDateRanges(meterUsage);

        CSutils.itShouldBe('Expected Date Ranges Size ', 1, actualDateRanges.size());
        CSutils.itShouldBe(
            'Expected Start Date ',
            expectedDateRanges.get(0).startDate,
            actualDateRanges.get(0).startDate
        );
        CSutils.itShouldBe(
            'Expected End Date ',
            expectedDateRanges.get(0).startDate,
            actualDateRanges.get(0).startDate
        );
    }

    @isTest
    static void testGetDateRangesForOneMonthAndOneDay() {
        UtilityMeterUsage__c meterUsage = new UtilityMeterUsage__c();
        meterUsage.PeriodStart__c = Date.newInstance(2018, 1, 2);
        meterUsage.PeriodEnd__c = Date.newInstance(2018, 2, 1);
        List<UrjanetUtils.SplitDateDetails> expectedDateRanges = new List<UrjanetUtils.SplitDateDetails>();
        expectedDateRanges.add(
            new UrjanetUtils.SplitDateDetails(Date.newInstance(2018, 1, 2), Date.newInstance(2018, 1, 31))
        );
        expectedDateRanges.add(
            new UrjanetUtils.SplitDateDetails(Date.newInstance(2018, 2, 1), Date.newInstance(2018, 2, 1))
        );
        List<UrjanetUtils.SplitDateDetails> actualDateRanges = UrjanetUtils.getDateRanges(meterUsage);
        CSutils.itShouldBe('Expected Date Ranges Size ', 2, actualDateRanges.size());
        CSutils.itShouldBe(
            'Expected Start Date 1 ',
            expectedDateRanges.get(0).startDate,
            actualDateRanges.get(0).startDate
        );
        CSutils.itShouldBe(
            'Expected End Date 1 ',
            expectedDateRanges.get(0).startDate,
            actualDateRanges.get(0).startDate
        );
        CSutils.itShouldBe(
            'Expected Start Date 2 ',
            expectedDateRanges.get(1).startDate,
            actualDateRanges.get(1).startDate
        );
        CSutils.itShouldBe(
            'Expected End Date 2 ',
            expectedDateRanges.get(1).startDate,
            actualDateRanges.get(1).startDate
        );
    }
}
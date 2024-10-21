@IsTest
private class UtilityMeterServiceTest {
    @TestSetup
    static void setup() {
        User adminUser = TestUtility.createUserAdmin('urjanetAdmin@urjanettest.com');
        System.runAs(adminUser) {
            ElectricityEmssnFctrSet electricityEmissionFactor = new ElectricityEmssnFctrSet(
                Name = 'Test Electric Emission Factor set',
                LocationBasedGasMixPct = 100,
                MarketBasedGasMixPct = 100
            );
            insert electricityEmissionFactor;

            OtherEmssnFctrSet otherEmissionFactor = new OtherEmssnFctrSet(Name = 'Test Other Emission Factor set');
            insert otherEmissionFactor;

            StnryAssetEnvrSrc site1 = new StnryAssetEnvrSrc(
                UrjanetId__c = TestUtility.SITE_ID,
                ElectricityEmssnFctrId = electricityEmissionFactor.Id,
                OtherEmssnFctrId = otherEmissionFactor.Id,
                Name = 'Test-Site-1'
            );
            StnryAssetEnvrSrc site2 = new StnryAssetEnvrSrc(
                UrjanetId__c = TestUtility.SITE_ID + 'a',
                ElectricityEmssnFctrId = electricityEmissionFactor.Id,
                OtherEmssnFctrId = otherEmissionFactor.Id,
                Name = 'Test-Site-2'
            );
            insert new List<StnryAssetEnvrSrc>{ site1, site2 };

            UtilityAccount__c utilityAccount = new UtilityAccount__c(
                UrjanetId__c = 'TestUtility.ACCOUNT_ID',
                Name = 'Test-Account'
            );
            insert utilityAccount;

            Account providerAccount = new Account();
            providerAccount.Name = 'Test Provider Account';
            insert providerAccount;

            Supplier provider = new Supplier();
            provider.Name = 'Test Provider';
            provider.AccountId = providerAccount.Id;
            provider.OtherEmissionsFactors__c = otherEmissionFactor.Id;
            provider.ElectricityEmissionsFactors__c = electricityEmissionFactor.Id;
            insert provider;
        }
    }

    @IsTest
    static void givenUpdatedUtilityMetersWhenGetMetersToRefreshCorrectRecordsReturned() {
        List<StnryAssetEnvrSrc> site = [SELECT Id, UrjanetId__c FROM StnryAssetEnvrSrc LIMIT 2];
        UtilityMeter__c updatedMeter = new UtilityMeter__c();
        DateTime oldDateTime = Datetime.now();
        updatedMeter.LastUrjanetSyncDateTime__c = Datetime.now();
        updatedMeter.StationaryAssetEnvironmentalSource__c = site[0].Id;
        insert updatedMeter;

        DateTime latestDateTime = Datetime.now().addMinutes(-10);
        updatedMeter.LastUrjanetSyncDateTime__c = latestDateTime;
        update updatedMeter;

        CSUtils.itShouldNotBe(
            'LastUrjanetSyncDateTime__c should be changed',
            oldDateTime,
            updatedMeter.LastUrjanetSyncDateTime__c
        );
    }

    @IsTest
    static void givenUpdatedUtilityMetersWheGetMetersToUpdateSiteRecordsReturned() {
        List<StnryAssetEnvrSrc> site = [SELECT Id, UrjanetId__c FROM StnryAssetEnvrSrc LIMIT 2];
        UtilityMeter__c updatedMeter = new UtilityMeter__c();
        updatedMeter.LastUrjanetSyncDateTime__c = Datetime.now();
        updatedMeter.StationaryAssetEnvironmentalSource__c = site[0].Id;
        insert updatedMeter;

        UtilityMeter__c oldMeter = new UtilityMeter__c();
        oldMeter.StationaryAssetEnvironmentalSource__c = Site[1].Id;
        oldMeter.LastUrjanetSyncDateTime__c = Datetime.now().addMinutes(-20);
        oldMeter.Id = updatedMeter.Id;

        Map<Id, UtilityMeter__c> oldMap = new Map<Id, UtilityMeter__c>();
        oldMap.put(updatedMeter.Id, oldMeter);

        Test.startTest();
        List<UtilityMeter__c> metersToUpdateSites = UtilityMeterService.getMetersToUpdateSite(
            new List<UtilityMeter__c>{ updatedMeter, oldMeter },
            oldMap
        );
        Test.stopTest();

        CSUtils.itShouldBe('Meters to update site should have 1 record', 1, metersToUpdateSites.size());
    }

    @IsTest
    static void givenUpdatedUtilityMetersWheGetMetersToUpdateSiteRecordsNotReturned() {
        UtilityMeter__c updatedMeter = new UtilityMeter__c();
        updatedMeter.LastUrjanetSyncDateTime__c = Datetime.now();
        insert updatedMeter;

        UtilityMeter__c oldMeter = new UtilityMeter__c();
        oldMeter.LastUrjanetSyncDateTime__c = Datetime.now().addMinutes(-20);
        oldMeter.Id = updatedMeter.Id;

        Map<Id, UtilityMeter__c> oldMap = new Map<Id, UtilityMeter__c>();
        oldMap.put(updatedMeter.Id, oldMeter);

        Test.startTest();
        List<UtilityMeter__c> metersToUpdateSites = UtilityMeterService.getMetersToUpdateSite(
            new List<UtilityMeter__c>{ updatedMeter, oldMeter },
            oldMap
        );
        Test.stopTest();

        CSUtils.itShouldBe('Meters to update site should not return any 1 record', 0, metersToUpdateSites.size());
    }

    @IsTest
    static void givenUpdatedUtilityMetersWhenCreateQueueItemsForMetersQueueItemsCreated() {
        QueueItemProcessor.suppressDuringTestRuns = true;
        String randomId = TestUtility.getRandomId(UtilityMeter__c.SObjectType);
        UtilityMeter__c updatedMeter = new UtilityMeter__c();
        updatedMeter.LastUrjanetSyncDateTime__c = Datetime.now();
        updatedMeter.Id = Id.valueOf(randomId);

        Test.startTest();
        UtilityMeterService.createQueueItemsForUtilityMeters(new List<UtilityMeter__c>{ updatedMeter });
        Test.stopTest();

        Integer logCount = [SELECT COUNT() FROM Log__c];
        CSUtils.itShouldBe('No errors should exist', 0, logCount);
    }

    @IsTest
    static void givenFailureSaveResultsWhenLogFailuresFailuresLogged() {
        // Intentionally not setting required field on account
        List<Database.SaveResult> saveResults = Database.insert(new List<Account>{ new Account() }, false);
        CSUtils.itShouldBe('Save should have failed', false, saveResults[0].isSuccess());

        Test.startTest();
        UrjanetUtils.logFailures(
            UtilityMeterService.class.getName(),
            String.valueOf(UtilityMeter__c.SObjectType),
            saveResults
        );
        Test.stopTest();

        Integer logCount = [SELECT COUNT() FROM Log__c];
        CSUtils.itShouldBe('One log should exist', 1, logCount);
    }

    @IsTest
    static void insertMetersForMetersByAccountCalloutTest() {
        GetMetersByAccountResponse mockResponse = getMetersByAccountMockDetailsResponse();
        System.runAs(TestUtility.createUserAdmin('123123123131231@test.com')) {
            Test.startTest();
            List<UtilityMeter__c> meterList = UtilityMeterService.createMeterFromDataResponse(mockResponse);
            UtilityMeterService.upsertMeterList(meterList);
            Test.stopTest();
            Integer utilityMeterCount = [SELECT COUNT() FROM UtilityMeter__c];
            System.assertEquals(true, utilityMeterCount > 0, 'Should be utilitymeter records created');
        }
    }

    @IsTest
    static void insertProviderDetailsForMetersByAccountCalloutTest() {
        GetMetersByAccountResponse mockResponse = getMetersByAccountMockDetailsResponse();
        System.runAs(TestUtility.createUserAdmin('arcadiaAdmin1@test.com')) {
            Test.startTest();
            List<UtilityMeter__c> meterList = UtilityMeterService.createMeterFromDataResponse(mockResponse);
            UtilityMeterService.upsertMeterList(meterList);
            Test.stopTest();
            Integer utilityMeterCount = [SELECT COUNT() FROM UtilityMeter__c];
            System.assertEquals(true, utilityMeterCount > 0, 'Should be utilitymeter records created');
            System.assertEquals(
                'San Francisco Public Utilty Commission',
                meterList[0].ProviderName__c,
                'Provider Name should be same'
            );
            System.assertEquals(
                '36e14460-ea0a-11e0-b6bb-12313d2b6294',
                meterList[0].ProviderId__c,
                'Provider Id should be same'
            );
        }
    }

    @IsTest
    static void insertMetersAndRelationsForMetersByAccountCalloutTest() {
        GetMetersByAccountResponse mockResponse = getMetersByAccountMockDetailsResponse();
        UtilityAccount__c account = [SELECT Id, UrjanetId__c, Supplier__c FROM UtilityAccount__c LIMIT 1];

        System.runAs(TestUtility.createUserAdmin('arcadiaAdmin1@test.com')) {
            Test.startTest();

            Supplier provider = [SELECT Id FROM Supplier LIMIT 1];
            account.Supplier__c = provider.id;
            update account;

            List<UtilityMeter__c> meterList = UtilityMeterService.createMeterFromDataResponse(mockResponse);
            UtilityMeterService.upsertMeterListForAccountProcessed(meterList, account);
            Test.stopTest();

            List<UtilityMeter__c> meters = [SELECT Id FROM UtilityMeter__c];
            List<Utility_Account_Meter_Relation__c> meterAccountsRelation = [
                SELECT Id, Utility_Meter__c, Utility_Account__c
                FROM Utility_Account_Meter_Relation__c
            ];

            System.assertEquals(true, meters.size() > 0, 'utilitymeter records should be created');
            System.assertEquals(
                true,
                meterAccountsRelation.size() > 0,
                'meterAccountsRelation records should be created'
            );

            System.assertEquals(
                meterAccountsRelation[0].Utility_Account__c,
                account.Id,
                'Linked Account Id should be same'
            );
            System.assertEquals(
                meterAccountsRelation[0].Utility_Meter__c,
                meters[0].Id,
                'Linked Meter Id should be same'
            );
        }
    }
    @IsTest
    static void insertDistinctMetersAndRelationsForMetersByAccountCalloutTest() {
        GetMetersByAccountResponse mockResponse = getMetersByAccountMockDetailsResponse();
        UtilityAccount__c account = [SELECT Id, UrjanetId__c, Supplier__c FROM UtilityAccount__c LIMIT 1];

        System.runAs(TestUtility.createUserAdmin('arcadiaAdmin1@test.com')) {
            Test.startTest();

            Supplier provider = [SELECT Id FROM Supplier LIMIT 1];
            account.Supplier__c = provider.id;
            update account;

            List<UtilityMeter__c> meterList = UtilityMeterService.createMeterFromDataResponse(mockResponse);
            UtilityMeterService.upsertMeterListForAccountProcessed(meterList, account);
            UtilityMeterService.upsertMeterListForAccountProcessed(meterList, account);
            Test.stopTest();

            List<UtilityMeter__c> meters = [SELECT Id FROM UtilityMeter__c];
            List<Utility_Account_Meter_Relation__c> meterAccountsRelation = [
                SELECT Id, Utility_Meter__c, Utility_Account__c
                FROM Utility_Account_Meter_Relation__c
            ];

            System.assertEquals(1, meters.size(), 'Distinct utilitymeter records should be created');
            System.assertEquals(
                1,
                meterAccountsRelation.size(),
                'Distinct meterAccountsRelation records should be created'
            );

            System.assertEquals(
                meterAccountsRelation[0].Utility_Account__c,
                account.Id,
                'Linked Account Id should be same'
            );
            System.assertEquals(
                meterAccountsRelation[0].Utility_Meter__c,
                meters[0].Id,
                'Linked Meter Id should be same'
            );
        }
    }

    @IsTest
    static void updateMetersWhenMetersByAccountCalloutTest() {
        GetMetersByAccountResponse mockResponse = getMetersByAccountMockDetailsResponse();
        mockResponse.embedded.meters[0].meterStatus = 'CURRENT';

        System.runAs(TestUtility.createUserAdmin('123123123131231@test.com')) {
            Test.startTest();
            List<UtilityMeter__c> meterList = UtilityMeterService.createMeterFromDataResponse(mockResponse);
            UtilityMeterService.upsertMeterList(meterList);
            Test.stopTest();
            List<UtilityMeter__c> utilityMeterList = [
                SELECT Id, MeterStatus__c
                FROM UtilityMeter__c
                LIMIT 1
            ];
            System.assertEquals(
                'CURRENT',
                utilityMeterList[0].MeterStatus__c,
                'Should be utilitymeter records updated'
            );
        }
    }

    @IsTest
    static void updateSiteinMetersInUrjanetWhenSiteChanged() {
        MeterResponseMock mock = new MeterResponseMock();
        Test.setMock(HttpCalloutMock.class, new MeterResponseMock());

        List<StnryAssetEnvrSrc> site = [
            SELECT Id, UrjanetId__c
            FROM StnryAssetEnvrSrc
            ORDER BY UrjanetId__c ASC
            LIMIT 2
        ];

        MeterResponseMock.entityId = TestUtility.SITE_ID + 'a';

        System.runAs(TestUtility.createUserAdmin('123123123131231@test.com')) {
            String randomId = TestUtility.getRandomId(UtilityMeter__c.SObjectType);
            UtilityMeter__c updatedMeter = new UtilityMeter__c();
            updatedMeter.StationaryAssetEnvironmentalSource__c = site[0].Id;
            insert updatedMeter;

            UtilityMeter__c oldMeter = new UtilityMeter__c();
            oldmeter.StationaryAssetEnvironmentalSource__c = site[1].Id;
            oldMeter.Id = updatedMeter.Id;

            Map<Id, UtilityMeter__c> oldMap = new Map<Id, UtilityMeter__c>();
            oldMap.put(updatedMeter.Id, oldMeter);

            Test.startTest();
            List<UtilityMeter__c> metersToUpdateSites = UtilityMeterService.getMetersToUpdateSite(
                new List<UtilityMeter__c>{ updatedMeter, oldMeter },
                oldMap
            );
            Test.stopTest();
            CSUtils.itShouldBe('Meters to update site should be ', 1, metersToUpdateSites.size());
            CSUtils.itShouldBe(
                'Should update the sites in Urjanet',
                true,
                mock.getMeterResponseString().contains(site[1].UrjanetId__c)
            );
        }
    }

    @IsTest
    static void updateSiteinMetersWhenSiteNotYetPushed() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('PostSiteResponse', 202);

        System.runAs(TestUtility.createUserAdmin('adminArcadia@test.com')) {
            UtilityMeter__c meter = new UtilityMeter__c();
            meter.UrjanetId__c = TestUtility.METER_ID;
            insert meter;

            ElectricityEmssnFctrSet emf = [
                SELECT Id
                FROM ElectricityEmssnFctrSet
                LIMIT 1
            ];
            OtherEmssnFctrSet oef = [
                SELECT Id
                FROM OtherEmssnFctrSet
                LIMIT 1
            ];
            StnryAssetEnvrSrc site = new StnryAssetEnvrSrc(
                // Site not yet pushed to Arcadia
                ElectricityEmssnFctrId = emf.Id,
                OtherEmssnFctrId = oef.Id,
                Name = 'Test-Site-3'
            );
            insert site;

            Test.startTest();
            meter.StationaryAssetEnvironmentalSource__c = site.Id;
            update meter;
            Test.stopTest();

            StnryAssetEnvrSrc updatedSite = [
                SELECT Id, UrjanetId__c
                FROM StnryAssetEnvrSrc
                WHERE Name = 'Test-Site-3'
            ];
            // Site should be created at Arcadia
            CSUtils.itShouldBe('UrjanetId ', '1ece6d51-dd82-d644-8a08-d23d6f619b36', updatedSite.UrjanetId__c);

            UtilityMeter__c updatedMeter = [
                SELECT Id, UrjanetId__c, StationaryAssetEnvironmentalSource__r.UrjanetId__c
                FROM UtilityMeter__c
                WHERE Id = :meter.Id
            ];
            // Site should be linked with meter
            CSUtils.itShouldBe(
                'UrjanetId of Site linked with meter ',
                '1ece6d51-dd82-d644-8a08-d23d6f619b36',
                updatedMeter.StationaryAssetEnvironmentalSource__r.UrjanetId__c
            );
        }
    }

    @IsTest
    static void testCreateQueueItemsForSiteUpdate() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('LinkMetersAndSiteResponse', 200);

        List<StnryAssetEnvrSrc> site = [
            SELECT Id, UrjanetId__c
            FROM StnryAssetEnvrSrc
            ORDER BY UrjanetId__c ASC
            LIMIT 2
        ];

        System.runAs(TestUtility.createUserAdmin('123123123131231@test.com')) {
            UtilityMeter__c meter = new UtilityMeter__c();
            meter.StationaryAssetEnvironmentalSource__c = site[1].Id;
            meter.UrjanetId__c = TestUtility.METER_ID;
            insert meter;

            Test.startTest();
            meter.StationaryAssetEnvironmentalSource__c = site[0].Id;
            update meter;
            Test.stopTest();
            List<UtilityMeter__c> meters = [
                SELECT Id, UrjanetId__c, StationaryAssetEnvironmentalSource__r.Id
                FROM UtilityMeter__c
            ];

            CSUtils.itShouldBe(
                'Updated Site for the meter ',
                site[0].Id,
                meters[0].StationaryAssetEnvironmentalSource__r.Id
            );
        }
    }

    @IsTest
    static void testCreateQueueItemsForSiteUpdateErrorResponse() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('GenericFailureMessageResponse', 400);

        List<StnryAssetEnvrSrc> site = [
            SELECT Id, UrjanetId__c
            FROM StnryAssetEnvrSrc
            ORDER BY UrjanetId__c ASC
            LIMIT 2
        ];

        System.runAs(TestUtility.createUserAdmin('123123123131231@test.com')) {
            UtilityMeter__c meter = new UtilityMeter__c();
            meter.StationaryAssetEnvironmentalSource__c = site[1].Id;
            meter.UrjanetId__c = TestUtility.METER_ID;
            insert meter;
            List<Log__c> logbeforeAPICall = [SELECT Id FROM Log__c LIMIT 1];
            CSUtils.itShouldBe('Expected number of records in Log Object', 0, logBeforeAPICall.size());

            Test.startTest();
            meter.StationaryAssetEnvironmentalSource__c = site[0].Id;
            update meter;
            Test.stopTest();
            List<UtilityMeter__c> meters = [
                SELECT Id, UrjanetId__c, StationaryAssetEnvironmentalSource__r.Id
                FROM UtilityMeter__c
            ];

            CSUtils.itShouldBe(
                'Updated Site for the meter ',
                site[0].Id,
                meters[0].StationaryAssetEnvironmentalSource__r.Id
            );
            List<Log__c> logAfterAPICall = [SELECT Id, Message__c FROM Log__c LIMIT 1];
            CSUtils.itShouldBe('Number of records in Log Object', 1, logAfterAPICall.size());
            CSUtils.itShouldBe('Error message', '400 Request Failed', logAfterAPICall[0].Message__c.trim());
        }
    }

    @IsTest
    static void testCreateQueueItemsForSiteUpdateUrjanetIdNull() {
        List<StnryAssetEnvrSrc> site = [
            SELECT Id, UrjanetId__c
            FROM StnryAssetEnvrSrc
            ORDER BY UrjanetId__c ASC
            LIMIT 2
        ];

        System.runAs(TestUtility.createUserAdmin('123123123131231@test.com')) {
            UtilityMeter__c meter = new UtilityMeter__c();
            meter.StationaryAssetEnvironmentalSource__c = site[1].Id;
            insert meter;
            List<Log__c> logbeforeAPICall = [SELECT Id FROM Log__c LIMIT 1];
            CSUtils.itShouldBe('Expected number of records in Log Object', 0, logBeforeAPICall.size());

            Test.startTest();
            meter.StationaryAssetEnvironmentalSource__c = site[0].Id;
            update meter;
            Test.stopTest();
            List<UtilityMeter__c> meters = [
                SELECT Id, UrjanetId__c, StationaryAssetEnvironmentalSource__r.Id
                FROM UtilityMeter__c
            ];

            CSUtils.itShouldBe(
                'Updated Site for the meter ',
                site[0].Id,
                meters[0].StationaryAssetEnvironmentalSource__r.Id
            );
        }
    }

    @IsTest
    static void testProcessUtilityMeterQueueSuccess() {
        List<StnryAssetEnvrSrc> site = [SELECT Id, UrjanetId__c FROM StnryAssetEnvrSrc LIMIT 2];
        UtilityMeter__c updatedMeter = new UtilityMeter__c();
        DateTime oldDateTime = Datetime.now();
        updatedMeter.LastUrjanetSyncDateTime__c = Datetime.now();
        updatedMeter.StationaryAssetEnvironmentalSource__c = site[0].Id;
        updatedMeter.UrjanetId__c = TestUtility.METER_ID;
        insert updatedMeter;

        QueueItem__c queueItem = new QueueItem__c(RecordId__c = updatedMeter.Id, PageNumber__c = 1);
        insert queueItem;
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('RetrieveMeterDetailsResponse', 200);

        Test.startTest();
        UtilityMeterService.processUtilityMeterQueue(queueItem);
        Test.stopTest();

        List<UtilityMeterUsage__c> usages = [SELECT Id FROM UtilityMeterUsage__c];
        CSUtils.itShouldBe('Utility Meter Usages should not be 0 ', true, usages.size() > 0);
    }

    @IsTest
    static void testProcessUtilityMeterQueueSuccessMultiplePages() {
        List<StnryAssetEnvrSrc> site = [SELECT Id, UrjanetId__c FROM StnryAssetEnvrSrc LIMIT 2];
        UtilityMeter__c updatedMeter = new UtilityMeter__c();
        DateTime oldDateTime = Datetime.now();
        updatedMeter.LastUrjanetSyncDateTime__c = Datetime.now();
        updatedMeter.StationaryAssetEnvironmentalSource__c = site[0].Id;
        updatedMeter.UrjanetId__c = TestUtility.METER_ID;
        insert updatedMeter;

        QueueItem__c queueItem = new QueueItem__c(RecordId__c = updatedMeter.Id, PageNumber__c = null);
        insert queueItem;
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'RetrieveMeterUsageDetailsForDeletingRecords',
            200
        );

        Test.startTest();
        UtilityMeterService.processUtilityMeterQueue(queueItem);
        Test.stopTest();

        List<UtilityMeterUsage__c> usages = [SELECT Id FROM UtilityMeterUsage__c];
        CSUtils.itShouldBe('Utility Meter Usages should not be 0 ', true, usages.size() > 0);
    }

    private static GetMetersByAccountResponse getMetersByAccountMockDetailsResponse() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('MetersByAccountResponse', 200);
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());
        GetMetersByAccountResponse mockResponse = (GetMetersByAccountResponse) new GetMetersByAccountResponseParser()
            .parseResponse(mockHttpResponse);
        return mockResponse;
    }
}
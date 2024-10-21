/**
 * Created by mike on 5/11/22.
 */

@IsTest
private class UtilityMeterUsageServiceTest {
    @TestSetup
    static void setup() {
        User adminUser = TestUtility.createUserAdmin('arcadiaAdmin1@test.com');
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
                ElectricityEmssnFctrId = lstElectricityEmissionFactorSet[0].Id,
                OtherEmssnFctrId = lstOtherEmissionFactorSet[0].Id,
                Name = 'Test Site',
                LastUrjanetSyncDateTime__c = Datetime.now()
            );
            insert site;

            UtilityMeter__c meter = new UtilityMeter__c();
            meter.UrjanetId__c = TestUtility.METER_ID;
            meter.ServiceType__c = 'electric';
            meter.StationaryAssetEnvironmentalSource__c = site.Id;
            insert meter;
        }
    }

    @IsTest
    public static void testDisableMeters() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            StnryAssetEnvrSrc site = [SELECT Id FROM StnryAssetEnvrSrc LIMIT 1];
            List<UtilityMeter__c> test2UtilityMeters =  TestUtility.createUtilityMeters(site.Id, 'Test Meter Disabling', 0 , 2, true, true, 'Electric');
            List<UtilityMeterUsage__c> test2UtilityMeterUsages =  TestUtility.createUtilityMeterUsages(test2UtilityMeters, 0, 2, true, 100, false, 'Supply');

            StnryAssetEnrgyUse electricActivity1 = new StnryAssetEnrgyUse();
            electricActivity1.StnryAssetEnvrSrcId = site.Id;
            electricActivity1.Name = 'Test Energy Activity 1';
            electricActivity1.FuelType = 'Electricity';
            electricActivity1.UtilityMeterUsage__c = test2UtilityMeterUsages[0].Id;
            insert electricActivity1;

            List<UtilityMeterUsage__c>  usages  = [
                                                SELECT Id, UsageUnit__c, MeasuredUsage__c, MeasuredUsageInText__c, PeriodStart__c, PeriodEnd__c, Arcadia_Statement_ID__c, To_Be_Ignored__c, UtilityMeter__c, UtilityMeter__r.PodNumber__c, UtilityMeter__r.ServiceType__c, UtilityMeter__r.StationaryAssetEnvironmentalSource__c, UtilityMeter__r.Enabled__c 
                                                FROM UtilityMeterUsage__c 
                                                WHERE To_Be_Ignored__c = false AND MeasuredUsage__c != null
                                                AND UtilityMeter__r.Name = 'Test Meter Disabling'
                                         ];

            Test.startTest();
            UtilityMeterUsageService.validateMeterAndUsages(usages);
            Test.stopTest();
            List<UtilityMeter__c> metersAfterUpdate = [
                SELECT Id, Name, UrjanetId__c, ServiceType__c , Enabled__c , PodNumber__c, StationaryAssetEnvironmentalSource__c
                FROM UtilityMeter__c
                WHERE Name = 'Test Meter Disabling'
            ];
            List<UtilityMeterUsage__c> firstMeterUsages = [
                SELECT Id, Name, DeregulationStatus__c, AccountType__c, To_Be_Ignored__c , UtilityMeter__c, Arcadia_Statement_ID__c
                FROM UtilityMeterUsage__c
                WHERE UtilityMeter__r.UrjanetId__c = 'Test Urjanet Id 0'
            ];

            List<UtilityMeterUsage__c> secondMeterUsages = [
                SELECT Id, Name, DeregulationStatus__c, AccountType__c, To_Be_Ignored__c , UtilityMeter__c, Arcadia_Statement_ID__c
                FROM UtilityMeterUsage__c
                WHERE UtilityMeter__r.UrjanetId__c = 'Test Urjanet Id 1'
            ];

            // for first meter
            System.assertEquals(true, metersAfterUpdate[0].Enabled__c, 'One meters should be disabled');
                        
            System.assertEquals(false, firstMeterUsages[0].To_Be_Ignored__c, 'One usages should not updated to be ignored for the first meter');

            System.assertEquals(true, firstMeterUsages[1].To_Be_Ignored__c, 'All other usages should updated to be ignored for the first meter');

            // for second meter
            System.assertEquals(false, metersAfterUpdate[1].Enabled__c, 'One meters should remain enabled');

            System.assertEquals(true, secondMeterUsages[0].To_Be_Ignored__c, 'All usages should updated to be ignored for the second meter');

            System.assertEquals(true, secondMeterUsages[1].To_Be_Ignored__c, 'All usages should updated to be ignored for the second meter');
        }
    }
    @IsTest
    static void testValidateMeterAndUsages() {
        Test.startTest();
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            StnryAssetEnvrSrc site = [SELECT Id FROM StnryAssetEnvrSrc LIMIT 1];
            // Creating 2 utility meter records, with different pod number , linked to same site
            List<UtilityMeter__c> utilityMeters = TestUtility.createUtilityMeters(site.Id, 'Test Meter', 0, 2, true, false, 'Electric'); 
                                                                                //  site,  meterName,  count,  enabled, samePodNumber

            // Creating 3 utility meter usage records for each meters with same statement id. Total 2 Test Meters and 6 Usages with same statement id
            List<UtilityMeterUsage__c> utilityMeterUsages =  TestUtility.createUtilityMeterUsages(utilityMeters, 0, 3, true, 100, false, 'Supply'); 
                                                                                // meters , NumberOfUsage , sameStatementId , measuredUsage, toBeIgnored, DeregulationStatus

            List<UtilityMeterUsage__c>  usages  = [
                                                SELECT Id, UsageUnit__c ,MeasuredUsage__c, MeasuredUsageInText__c, PeriodStart__c, PeriodEnd__c, Arcadia_Statement_ID__c, To_Be_Ignored__c, UtilityMeter__c, UtilityMeter__r.PodNumber__c, UtilityMeter__r.ServiceType__c, UtilityMeter__r.StationaryAssetEnvironmentalSource__c, UtilityMeter__r.Enabled__c 
                                                FROM UtilityMeterUsage__c
                                                WHERE To_Be_Ignored__c = false AND MeasuredUsage__c != null
                                                AND UtilityMeter__r.Name = 'Test Meter'
                                         ];
            UtilityMeterUsageService.validateMeterAndUsages(usages);
        }
        Test.stopTest();

        List<UtilityMeterUsage__c> updatedUtilityMeterUsages = [
            SELECT Id, To_Be_Ignored__c
            FROM UtilityMeterUsage__c
            WHERE To_Be_Ignored__c = true
            AND UtilityMeter__r.Name = 'Test Meter'
        ];
        System.assertEquals(5, updatedUtilityMeterUsages.size(), 'All duplicate utility meter usage records should be marked as to be ignored, except first usage');
    }

    @IsTest
    public static void testDeletionOfUsageAndDownstreamData(){
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            StnryAssetEnvrSrc site = [SELECT Id FROM StnryAssetEnvrSrc LIMIT 1];
            List<UtilityMeter__c> disabledMeters =  TestUtility.createUtilityMeters(site.Id, 'Test Meter Disabled', 0 , 1, false, true, 'Electric');
                                                                                        //  site,  meterName,  count,  enabled, samePodNumber , Service Type
            List<UtilityMeterUsage__c> test2UtilityMeterUsages =  TestUtility.createUtilityMeterUsages(disabledMeters, 0, 2, true, 100, true, 'Supply');
                                                                // meters , NumberOfUsage , sameStatementId , measuredUsage, toBeIgnored, DeregulationStatus


            StnryAssetEnrgyUse electricActivity1 = new StnryAssetEnrgyUse();
            electricActivity1.StnryAssetEnvrSrcId = site.Id;
            electricActivity1.Name = 'Test Energy Activity 1';
            electricActivity1.FuelType = 'Electricity';
            electricActivity1.UtilityMeterUsage__c = test2UtilityMeterUsages[0].Id;
            insert electricActivity1;

            StnryAssetEnrgyUse electricActivity2 = new StnryAssetEnrgyUse();
            electricActivity2.StnryAssetEnvrSrcId = site.Id;
            electricActivity2.Name = 'Test Energy Activity 2';
            electricActivity2.FuelType = 'Electricity';
            electricActivity2.UtilityMeterUsage__c = test2UtilityMeterUsages[1].Id;
            insert electricActivity2;

            List<UtilityMeterUsage__c>  usages  = [
                                                SELECT Id, UsageUnit__c , MeasuredUsageInText__c, PeriodStart__c, PeriodEnd__c, Arcadia_Statement_ID__c, To_Be_Ignored__c, UtilityMeter__c, UtilityMeter__r.PodNumber__c, UtilityMeter__r.ServiceType__c, UtilityMeter__r.StationaryAssetEnvironmentalSource__c, UtilityMeter__r.Enabled__c 
                                                FROM UtilityMeterUsage__c 
                                                WHERE To_Be_Ignored__c = true AND MeasuredUsage__c != null
                                                AND UtilityMeter__r.Name = 'Test Meter Disabled'
                                         ];
                                         
            Test.startTest();
            UtilityMeterUsageService.deleteDownstreamData(usages);
            Test.stopTest();

            List<UtilityMeterUsage__c> updatedUtilityMeterUsages = [
                SELECT Id, To_Be_Ignored__c
                FROM UtilityMeterUsage__c
                WHERE UtilityMeter__r.Name = 'Test Meter Disabled'
            ];
            List<StnryAssetEnrgyUse> lstEnergyUse = [
                SELECT Id, UtilityMeterUsage__c
                FROM StnryAssetEnrgyUse
                WHERE UtilityMeterUsage__c IN :updatedUtilityMeterUsages
            ];
            
            System.assertEquals(0, updatedUtilityMeterUsages.size(), 'All utility meter usage records should be deleted for disabledMeters');
            System.assertEquals(0, lstEnergyUse.size(), 'All StnryAssetEnrgyUse records should be deleted alongwith usages for disabledMeters');

        }
    }

    @IsTest
    public static void testDownstreamDataDeletion(){
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            StnryAssetEnvrSrc site = [SELECT Id FROM StnryAssetEnvrSrc LIMIT 1];
            List<UtilityMeter__c> enabledMeters =  TestUtility.createUtilityMeters(site.Id, 'Test Meter Enabled', 0 , 1, true, false, 'Electric');
                                                                                        //  site,  meterName,  count,  enabled, samePodNumber, ServiceType
            List<UtilityMeterUsage__c> test2UtilityMeterUsages =  TestUtility.createUtilityMeterUsages(enabledMeters, 0, 2, true, 100, true, 'Supply');
                                                                // meters , NumberOfUsage , sameStatementId , measuredUsage, toBeIgnored, DeregulationStatus

            StnryAssetEnrgyUse electricActivity1 = new StnryAssetEnrgyUse();
            electricActivity1.StnryAssetEnvrSrcId = site.Id;
            electricActivity1.Name = 'Test Energy Activity 1';
            electricActivity1.FuelType = 'Electricity';
            electricActivity1.UtilityMeterUsage__c = test2UtilityMeterUsages[0].Id;
            insert electricActivity1;

            StnryAssetEnrgyUse electricActivity2 = new StnryAssetEnrgyUse();
            electricActivity2.StnryAssetEnvrSrcId = site.Id;
            electricActivity2.Name = 'Test Energy Activity 2';
            electricActivity2.FuelType = 'Electricity';
            electricActivity2.UtilityMeterUsage__c = test2UtilityMeterUsages[1].Id;
            insert electricActivity2;

            List<UtilityMeterUsage__c>  usages  = [
                                                SELECT Id, UsageUnit__c, MeasuredUsageInText__c, PeriodStart__c, PeriodEnd__c, Arcadia_Statement_ID__c, To_Be_Ignored__c, UtilityMeter__c, UtilityMeter__r.PodNumber__c, UtilityMeter__r.ServiceType__c, UtilityMeter__r.StationaryAssetEnvironmentalSource__c, UtilityMeter__r.Enabled__c 
                                                FROM UtilityMeterUsage__c 
                                                WHERE To_Be_Ignored__c = true AND MeasuredUsage__c != null
                                                AND UtilityMeter__r.Name = 'Test Meter Enabled'
                                         ];
                                         
            Test.startTest();
            UtilityMeterUsageService.deleteDownstreamData(usages);
            Test.stopTest();

            List<UtilityMeterUsage__c> updatedUtilityMeterUsages = [
                SELECT Id, To_Be_Ignored__c
                FROM UtilityMeterUsage__c
                WHERE UtilityMeter__r.Name = 'Test Meter Enabled'
            ];
            List<StnryAssetEnrgyUse> lstEnergyUse = [
                SELECT Id, UtilityMeterUsage__c
                FROM StnryAssetEnrgyUse
                WHERE UtilityMeterUsage__c IN :updatedUtilityMeterUsages
            ];
            System.assertEquals(2, updatedUtilityMeterUsages.size(), 'All utility meter usage records should be not be deleted for EnabledMeters');
            System.assertEquals(0, lstEnergyUse.size(), 'All StnryAssetEnrgyUse records should be deleted for ignored Meter Usages');

        }
    }
    
    @IsTest
    public static void utilityUtilityMeterSyncBatchTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            Integer batchSize = UrjanetUtils.getBatchSize(false);
            RetrieveMeterDetailsResponse mockResponse = getMockDetailsResponse();
            UtilityMeter__c parentMeter = [SELECT Id, UrjanetId__c FROM UtilityMeter__c LIMIT 1];
            UtilityMeterUsage__c initialUsage = new UtilityMeterUsage__c(
                Name = '28707791 - 2021-08-08 - 2021-10-07',
                UtilityMeter__c = parentMeter.Id,
                DeregulationStatus__c = null,
                AccountType__c = null,
                MeasuredUsage__c = 377.000,
                PeriodStart__c = Date.valueOf('2021-08-08'),
                PeriodEnd__c = Date.valueOf('2021-10-07'),
                UsageUnit__c = 'kWh'
            );

            insert initialUsage;
            Test.startTest();
            Database.executeBatch(new UtilityMeterSyncBatch(), batchSize);
            Test.stopTest();
            List<AsyncApexJob> AsyncApexJobList = [
                SELECT Id, Status, JobType, ApexClass.Name
                FROM AsyncApexJob
                WHERE JobType = 'BatchApex'
            ];
            System.assertEquals(1, AsyncApexJobList.size(), 'Should have 1 AsyncApexJob created');
            System.assertEquals(
                'UtilityMeterSyncBatch',
                AsyncApexJobList[0].ApexClass.Name,
                'Name Should be UtilityMeterSyncBatch'
            );
        }
    }

    @IsTest
    static void givenNoExistingUsageRecordsWhenCreateUsageRecordsAllCreated() {
        UtilityMeter__c parentMeter = [SELECT Id, UrjanetId__c FROM UtilityMeter__c LIMIT 1];

        RetrieveMeterDetailsResponse mockResponse = getMockDetailsResponse();
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            UtilityMeterUsageService.createMeterUsageFromMeterDataResponse(
                mockResponse,
                parentMeter,
                '0',
                new Set<String>()
            );
            Test.stopTest();
            List<UtilityMeterUsage__c> meterUsages = [
                SELECT Id, Name, DeregulationStatus__c, AccountType__c, UrjanetId__c
                FROM UtilityMeterUsage__c
            ];
            System.assertEquals(2, meterUsages.size(), '2 Usage record should be created');
            System.assertEquals('28707791 - 2021-08-08 - 2021-10-07', meterUsages[0].Name, 'Name should match');
            System.assertEquals('28707791 - 2021-11-01 - 2021-11-30', meterUsages[1].Name, 'Name should match');
            System.assertEquals('delivery', meterUsages[0].DeregulationStatus__c, 'Deregulation Status should match');
            System.assertEquals(
                'full_service',
                meterUsages[1].DeregulationStatus__c,
                'Deregulation Status should match'
            );
            System.assertEquals('NORMAL', meterUsages[0].AccountType__c, 'Account Type should match');
            System.assertEquals('SUB_ACCOUNT', meterUsages[1].AccountType__c, 'Account Type should match');
            System.assertEquals(
                '1ee97dee-de1d-dc77-be86-5a0222741fd9',
                meterUsages[0].UrjanetId__c,
                'Entity Id should match'
            );
            System.assertEquals(
                '1ee97dee-de1d-dc77-be86-5a0222741fd8',
                meterUsages[1].UrjanetId__c,
                'Entity Id should match'
            );
        }
    }

    private static RetrieveMeterDetailsResponse getMockDetailsResponse() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('RetrieveMeterDetailsResponse', 200);
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());
        RetrieveMeterDetailsResponse mockResponse = (RetrieveMeterDetailsResponse) new RetrieveMeterDetailsResponseParser()
            .parseResponse(mockHttpResponse);
        return mockResponse;
    }

    private static RetrieveMeterDetailsResponse getMockDetailsFailureResponse() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'RetrieveMeterDetailsResponseFailure',
            200
        );
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());
        RetrieveMeterDetailsResponse mockResponse = (RetrieveMeterDetailsResponse) new RetrieveMeterDetailsResponseParser()
            .parseResponse(mockHttpResponse);
        return mockResponse;
    }

    private static RetrieveMeterDetailsResponse getMockDetailsUsageNullResponse() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'RetrieveMeterDetailsMeasuredUsageNullResponse',
            200
        );
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());
        RetrieveMeterDetailsResponse mockResponse = (RetrieveMeterDetailsResponse) new RetrieveMeterDetailsResponseParser()
            .parseResponse(mockHttpResponse);
        return mockResponse;
    }
    private static RetrieveMeterDetailsResponse getMockDetailsUsageNullValuesResponse() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'RetrieveMeterDetailsMeasuredUsageNullValuesResponse',
            200
        );
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());
        RetrieveMeterDetailsResponse mockResponse = (RetrieveMeterDetailsResponse) new RetrieveMeterDetailsResponseParser()
            .parseResponse(mockHttpResponse);
        return mockResponse;
    }
    private static RetrieveMeterDetailsResponse getMockDetailsWith2TRCUsageResponse() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'RetrieveMeterDetailsResponseWith2TRC',
            200
        );
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());
        RetrieveMeterDetailsResponse mockResponse = (RetrieveMeterDetailsResponse) new RetrieveMeterDetailsResponseParser()
            .parseResponse(mockHttpResponse);
        return mockResponse;
    }

    @IsTest(SeeAllData=false)
    static void updateMeterUsageTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityMeter__c parentMeter = [
                SELECT Id, UrjanetId__c, UtilityMeter__c.Name, ServiceType__c
                FROM UtilityMeter__c
                LIMIT 1
            ];
            RetrieveMeterDetailsResponse mockResponse = getMockDetailsResponse();
            TestUtility.insertDuplicateMeterUsage(
                parentMeter.Id, // Parent Meter ID
                '28707791 - 2021-08-08 - 2021-10-07', // Usage Name
                377.000, // Measured Usage
                Date.valueOf('2021-08-08'), // Period Start Date
                Date.valueOf('2021-10-07'), // Period End Date
                null, // DeregulationStatus__c
                null // AccountType__c
            );

            Test.startTest();
            UtilityMeterUsageService.updateMeterUsage(new List<UtilityMeter__c>{ parentMeter });
            Test.stopTest();
            List<UtilityMeterUsage__c> updatedUsage = [
                SELECT Id, Name, DeregulationStatus__c, AccountType__c
                FROM UtilityMeterUsage__c
                WHERE UtilityMeter__c = :parentMeter.Id
            ];

            System.assertEquals(1, updatedUsage.size(), 'Duplicate Meter Usage Should be deleted');
            System.assertEquals(
                'delivery',
                updatedUsage[0].DeregulationStatus__c,
                'Deregulation Status should be updated'
            );
            System.assertEquals('NORMAL', updatedUsage[0].AccountType__c, 'Account Type should be updated');
        }
    }

    @IsTest
    static void deleteDuplicateMeterUsageStnryAssetEnrgyUseTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
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
                ElectricityEmssnFctrId = lstElectricityEmissionFactorSet[0].Id,
                OtherEmssnFctrId = lstOtherEmissionFactorSet[0].Id,
                Name = 'Test Site',
                LastUrjanetSyncDateTime__c = Datetime.now()
            );
            insert site;

            UtilityMeter__c parentMeter = [
                SELECT Id, UrjanetId__c, UtilityMeter__c.Name, ServiceType__c
                FROM UtilityMeter__c
                LIMIT 1
            ];

            TestUtility.insertDuplicateMeterUsage(
                parentMeter.Id, // Parent Meter ID
                '28707791 - 2021-08-08 - 2021-10-07', // Usage Name
                377.000, // Measured Usage
                Date.valueOf('2021-08-08'), // Period Start Date
                Date.valueOf('2021-10-07'), // Period End Date
                null, // DeregulationStatus__c
                null // AccountType__c
            );

            List<UtilityMeterUsage__c> intialMeterUsages = [
                SELECT Id, Name, DeregulationStatus__c, AccountType__c
                FROM UtilityMeterUsage__c
                WHERE UtilityMeter__c = :parentMeter.Id
            ];

            StnryAssetEnrgyUse electricActivity1 = new StnryAssetEnrgyUse();
            electricActivity1.StnryAssetEnvrSrcId = site.Id;
            electricActivity1.Name = 'Test Energy Activity 1';
            electricActivity1.FuelType = 'Electricity';
            electricActivity1.UtilityMeterUsage__c = intialMeterUsages[0].Id;
            insert electricActivity1;

            StnryAssetEnrgyUse electricActivity2 = new StnryAssetEnrgyUse();
            electricActivity2.StnryAssetEnvrSrcId = site.Id;
            electricActivity2.FuelType = 'Electricity';
            electricActivity2.Name = 'Test Energy Activity 2';
            electricActivity2.UtilityMeterUsage__c = intialMeterUsages[1].Id;
            insert electricActivity2;

            Test.startTest();
            RetrieveMeterDetailsResponse mockResponse = getMockDetailsResponse();
            UtilityMeterUsageService.updateMeterUsage(new List<UtilityMeter__c>{ parentMeter });
            Test.stopTest();
            List<UtilityMeterUsage__c> updatedUsage = [
                SELECT Id, Name, DeregulationStatus__c, AccountType__c
                FROM UtilityMeterUsage__c
                WHERE UtilityMeter__c = :parentMeter.Id
            ];

            List<StnryAssetEnrgyUse> lstEnergyUse = [
                SELECT Id, UtilityMeterUsage__c
                FROM StnryAssetEnrgyUse
                WHERE UtilityMeterUsage__c IN :updatedUsage
            ];
            System.assertEquals(1, lstEnergyUse.size(), 'Duplicate Meter Usage StnryAssetEnrgyUse Should be deleted');

            System.assertEquals(1, updatedUsage.size(), 'Duplicate Meter Usage Should be deleted');
            System.assertEquals(
                'delivery',
                updatedUsage[0].DeregulationStatus__c,
                'Deregulation Status should be updated'
            );
            System.assertEquals('NORMAL', updatedUsage[0].AccountType__c, 'Account Type should be updated');
        }
    }

    @IsTest
    static void testSingleDayDuplicates() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityMeter__c meter = [
                SELECT Id, UrjanetId__c, UtilityMeter__c.Name, ServiceType__c
                FROM UtilityMeter__c
                LIMIT 1
            ];
            RetrieveMeterDetailsResponse mockResponse = getMeterDetailsResponseSingleDay();
            UtilityMeterUsage__c initialUsage = new UtilityMeterUsage__c(
                Name = '28707791 - 2021-08-08 - 2021-08-08',
                UtilityMeter__c = meter.Id,
                DeregulationStatus__c = 'delivery',
                AccountType__c = 'NORMAL',
                MeasuredUsage__c = 377.000,
                PeriodStart__c = Date.valueOf('2021-08-08'),
                PeriodEnd__c = Date.valueOf('2021-08-08')
            );
            insert initialUsage;

            Test.startTest();
            UtilityMeterUsageService.createMeterUsageFromMeterDataResponse(mockResponse, meter, '0', new Set<String>());
            Test.stopTest();
            List<UtilityMeterUsage__c> meterUsages = [SELECT Id, Name FROM UtilityMeterUsage__c];
            CSUtils.itShouldBe('Number of meter Usage records ', 1, meterUsages.size());
            // new duplicate record should not have been created
        }
    }

    @IsTest(SeeAllData=false)
    static void updateMeterUsageFailureResponseTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityMeter__c parentMeter = [
                SELECT Id, UrjanetId__c, UtilityMeter__c.Name, ServiceType__c
                FROM UtilityMeter__c
                LIMIT 1
            ];
            RetrieveMeterDetailsResponse mockResponse = getMockDetailsFailureResponse();
            TestUtility.insertDuplicateMeterUsage(
                parentMeter.Id, // Parent Meter ID
                '28707791 - 2021-08-08 - 2021-10-07', // Usage Name
                377.000, // Measured Usage
                Date.valueOf('2021-08-08'), // Period Start Date
                Date.valueOf('2021-10-07'), // Period End Date
                null, // DeregulationStatus__c
                null // AccountType__c
            );

            Test.startTest();
            UtilityMeterUsageService.updateMeterUsage(new List<UtilityMeter__c>{ parentMeter });
            Test.stopTest();
            List<UtilityMeterUsage__c> updatedUsage = [
                SELECT Id, Name, DeregulationStatus__c, AccountType__c
                FROM UtilityMeterUsage__c
                WHERE UtilityMeter__c = :parentMeter.Id
            ];

            System.assertEquals(2, updatedUsage.size(), 'Duplicate Meter Usage Should not deleted');
            System.assertEquals(
                null,
                updatedUsage[0].DeregulationStatus__c,
                'Deregulation Status should not be updated'
            );
            System.assertEquals(null, updatedUsage[0].AccountType__c, 'Account Type should not be updated');
            List<Log__c> logAfterAPICall = [SELECT Id, Message__c FROM Log__c LIMIT 1];
            System.assertEquals(1, logAfterAPICall.size(), ' Number of records in Log Object');
            System.assertEquals(mockResponse.errorMsg, logAfterAPICall[0].Message__c.trim(), 'Error Message');
        }
    }

    @IsTest
    static void preventMeterUsageWithNullMeasuredUsageCreationTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityMeter__c parentMeter = [
                SELECT Id, UrjanetId__c, UtilityMeter__c.Name, ServiceType__c
                FROM UtilityMeter__c
                LIMIT 1
            ];
            RetrieveMeterDetailsResponse mockResponse = getMockDetailsUsageNullResponse();
            Test.startTest();
            UtilityMeterUsageService.createMeterUsageFromMeterDataResponse(
                mockResponse,
                parentMeter,
                '0',
                new Set<String>()
            );
            Test.stopTest();
            List<UtilityMeterUsage__c> meterUsageCreated = [
                SELECT Id, Name, DeregulationStatus__c, AccountType__c
                FROM UtilityMeterUsage__c
                WHERE UtilityMeter__c = :parentMeter.Id
            ];

            System.assertEquals(
                0,
                meterUsageCreated.size(),
                'Meter Usages with null measuredUsage should not be created'
            );
        }
    }
    @IsTest
    static void priotizeMeterUsageWithKWHMeasuredUsageCreationTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityMeter__c parentMeter = [
                SELECT Id, UrjanetId__c, UtilityMeter__c.Name, ServiceType__c
                FROM UtilityMeter__c
                LIMIT 1
            ];
            RetrieveMeterDetailsResponse mockResponse = getMockDetailsWith2TRCUsageResponse();
            Test.startTest();
            UtilityMeterUsageService.createMeterUsageFromMeterDataResponse(
                mockResponse,
                parentMeter,
                '0',
                new Set<String>()
            );
            Test.stopTest();
            List<UtilityMeterUsage__c> meterUsageCreated = [
                SELECT Id, Name, DeregulationStatus__c, AccountType__c, UsageUnit__c
                FROM UtilityMeterUsage__c
                WHERE UtilityMeter__c = :parentMeter.Id
            ];

            System.assertEquals(1, meterUsageCreated.size(), 'Meter Usages should not be created');
            System.assertEquals(
                'kWh',
                meterUsageCreated[0].UsageUnit__c,
                'Meter Usages created should have the usage unit equal to kWh'
            );
        }
    }

    @IsTest
    static void deleteMeterUsageWithNullMeasuredUsageTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityMeter__c parentMeter = [
                SELECT Id, UrjanetId__c, UtilityMeter__c.Name, ServiceType__c
                FROM UtilityMeter__c
                LIMIT 1
            ];
            TestUtility.insertDuplicateMeterUsage(
                parentMeter.Id, // Parent Meter ID
                '28707791 - 2021-08-08 - 2021-10-07', // Usage Name
                null, // MeasuredUsage__c
                Date.valueOf('2021-08-08'), // Period Start Date
                Date.valueOf('2021-10-07'), // Period End Date
                null, // DeregulationStatus__c
                null // AccountType__c
            );

            RetrieveMeterDetailsResponse mockResponse = getMockDetailsResponse();

            Test.startTest();
            UtilityMeterUsageService.updateMeterUsage(new List<UtilityMeter__c>{ parentMeter });
            Test.stopTest();
            List<UtilityMeterUsage__c> meterUsage = [
                SELECT Id, Name, DeregulationStatus__c, AccountType__c
                FROM UtilityMeterUsage__c
                WHERE UtilityMeter__c = :parentMeter.Id
            ];

            System.assertEquals(0, meterUsage.size(), 'Meter Usages with Measured Usage null should be Deleted');
        }
    }
    @IsTest
    static void skipMeterUsageProcessingWithNullMeterValueTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityMeter__c parentMeter = [
                SELECT Id, UrjanetId__c, UtilityMeter__c.Name, ServiceType__c
                FROM UtilityMeter__c
                LIMIT 1
            ];
            parentMeter.Name = null;
            TestUtility.insertDuplicateMeterUsage(
                parentMeter.Id, // Parent Meter ID
                '28707791 - 2021-08-08 - 2021-10-07', // Usage Name
                377.000, // Measured Usage
                Date.valueOf('2021-08-08'), // Period Start Date
                Date.valueOf('2021-10-07'), // Period End Date
                null, // DeregulationStatus__c
                null // AccountType__c
            );

            RetrieveMeterDetailsResponse mockResponse = getMockDetailsUsageNullValuesResponse();

            Test.startTest();
            UtilityMeterUsageService.updateMeterUsage(new List<UtilityMeter__c>{ parentMeter });
            Test.stopTest();
            List<UtilityMeterUsage__c> updatedUsage = [
                SELECT Id, Name, DeregulationStatus__c, AccountType__c
                FROM UtilityMeterUsage__c
                WHERE UtilityMeter__c = :parentMeter.Id
            ];

            System.assertEquals(2, updatedUsage.size(), 'Meter Usage Should not be processed');
            System.assertEquals(
                null,
                updatedUsage[0].DeregulationStatus__c,
                'Deregulation Status should not be updated'
            );
            System.assertEquals(null, updatedUsage[0].AccountType__c, 'Account Type should not be updated');
        }
    }
    @IsTest
    static void skipMeterUsageProcessingWithNullValueInResponseTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityMeter__c parentMeter = [
                SELECT Id, UrjanetId__c, UtilityMeter__c.Name, ServiceType__c
                FROM UtilityMeter__c
                LIMIT 1
            ];
            TestUtility.insertDuplicateMeterUsage(
                parentMeter.Id, // Parent Meter ID
                '28707791 - 2021-08-08 - 2021-10-07', // Usage Name
                377.000, // Measured Usage
                Date.valueOf('2021-08-08'), // Period Start Date
                Date.valueOf('2021-10-07'), // Period End Date
                null, // DeregulationStatus__c
                null // AccountType__c
            );

            RetrieveMeterDetailsResponse mockResponse = getMockDetailsUsageNullValuesResponse();

            Test.startTest();
            UtilityMeterUsageService.updateMeterUsage(new List<UtilityMeter__c>{ parentMeter });
            Test.stopTest();
            List<UtilityMeterUsage__c> updatedUsage = [
                SELECT Id, Name, DeregulationStatus__c, AccountType__c
                FROM UtilityMeterUsage__c
                WHERE UtilityMeter__c = :parentMeter.Id
            ];

            System.assertEquals(2, updatedUsage.size(), 'Meter Usage Should not be processed');
            System.assertEquals(
                null,
                updatedUsage[0].DeregulationStatus__c,
                'Deregulation Status should not be updated'
            );
            System.assertEquals(null, updatedUsage[0].AccountType__c, 'Account Type should not be updated');
        }
    }

    @IsTest(SeeAllData=false)
    static void growthPackageNotPresentTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityMeter__c parentMeter = [
                SELECT Id, UrjanetId__c, UtilityMeter__c.Name, ServiceType__c
                FROM UtilityMeter__c
                LIMIT 1
            ];

            parentMeter.ServiceType__c = 'water';
            upsert parentMeter;

            RetrieveMeterDetailsResponse mockResponse = getMockDetailsResponse();
            TestUtility.insertDuplicateMeterUsage(
                parentMeter.Id, // Parent Meter ID
                '28707791 - 2021-08-08 - 2021-10-07', // Usage Name
                377.000, // Measured Usage
                Date.valueOf('2021-08-08'), // Period Start Date
                Date.valueOf('2021-10-07'), // Period End Date
                null, // DeregulationStatus__c
                null // AccountType__c
            );
            Test.startTest();
            try {
                UtilityMeterUsageService.updateMeterUsage(new List<UtilityMeter__c>{ parentMeter });
            } catch (Exception e) {
                System.assert(false, 'An exception was thrown: ' + e.getMessage());
            }
            Test.stopTest();

            List<UtilityMeterUsage__c> updatedUsage = [
                SELECT Id, Name, DeregulationStatus__c, AccountType__c, UrjanetId__c
                FROM UtilityMeterUsage__c
            ];
            System.assertEquals(
                'delivery',
                updatedUsage[0].DeregulationStatus__c,
                'Deregulation Status should be updated'
            );
            System.assertEquals('NORMAL', updatedUsage[0].AccountType__c, 'Account Type should be updated');
        }
    }

    @IsTest
    static void testUpdateAfterRecordLocked() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityMeterUsage__c meterUsage = new UtilityMeterUsage__c();
            meterUsage.Arcadia_Statement_ID__c = 'statmentID1234';
            meterUsage.Name = 'username';

            insert meterUsage;
            meterUsage.IsRecordLocked__c = true;
            update meterUsage;

            Test.startTest();

            try {
                UtilityMeterUsage__c meterUsage2 = [
                    SELECT Name, IsRecordLocked__c
                    FROM UtilityMeterUsage__c
                    WHERE Arcadia_Statement_ID__c = :meterUsage.Arcadia_Statement_ID__c
                ];
                meterUsage2.Name = 'username2';
                update meterUsage2;
            } catch (DmlException e) {
                String expectedErrorMessage = System.Label.Arcadia_LockedRecordsUpdate_ErrorMessage;
                System.assert(e.getMessage().contains(expectedErrorMessage), 'Validation error message found.');
            }
            Test.stopTest();
        }

    }

    @IsTest
    static void testUpdateAfterRecordNotLocked() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityMeterUsage__c meterUsage = new UtilityMeterUsage__c();
            meterUsage.Arcadia_Statement_ID__c = 'statmentID1234';
            meterUsage.Name = 'username';

            insert meterUsage;

            Test.startTest();

            try {
                UtilityMeterUsage__c meterUsage2 = [
                    SELECT Name, IsRecordLocked__c
                    FROM UtilityMeterUsage__c
                    WHERE Arcadia_Statement_ID__c = :meterUsage.Arcadia_Statement_ID__c
                ];
                meterUsage2.Name = 'username2';
                update meterUsage2;
            } catch (DmlException e) {
            }
            UtilityMeterUsage__c meterUsage2 = [
                SELECT Name, IsRecordLocked__c
                FROM UtilityMeterUsage__c
                WHERE Arcadia_Statement_ID__c = :meterUsage.Arcadia_Statement_ID__c
            ];
            System.assertEquals('username2', meterUsage2.Name);
            System.assertEquals(false, meterUsage2.IsRecordLocked__c);
            Test.stopTest();
        }

    }

    @IsTest
    static void testUpdateAfterRecordLockedMultipleRecords() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityMeterUsage__c meterUsage = new UtilityMeterUsage__c();
            meterUsage.Arcadia_Statement_ID__c = 'oldId';
            meterUsage.Name = 'name1';

            UtilityMeterUsage__c meterUsage2 = new UtilityMeterUsage__c();
            meterUsage2.Arcadia_Statement_ID__c = 'oldId';
            meterUsage2.Name = 'name2';

            UtilityMeterUsage__c meterUsage3 = new UtilityMeterUsage__c();
            meterUsage3.Arcadia_Statement_ID__c = 'oldId';
            meterUsage3.Name = 'name3';

            List<UtilityMeterUsage__c> lstMeterUsage = new List<UtilityMeterUsage__c>();

            lstMeterUsage.add(meterUsage);
            lstMeterUsage.add(meterUsage2);
            lstMeterUsage.add(meterUsage3);

            insert lstMeterUsage;

            lstMeterUsage[0].IsRecordLocked__c = true;
            lstMeterUsage[1].IsRecordLocked__c = true;
            update lstMeterUsage;

            List<String> namesList = new List<String>();
            for (UtilityMeterUsage__c meterUsageObject : lstMeterUsage) {
                namesList.add(meterUsageObject.Name);
            }
            Test.startTest();

            try {
                Database.DMLOptions option = new Database.DMLOptions();
                List<UtilityMeterUsage__c> meterUsagesList = [
                    SELECT Name, IsRecordLocked__c, Arcadia_Statement_ID__c
                    FROM UtilityMeterUsage__c
                    WHERE Name IN :namesList
                ];
                for (UtilityMeterUsage__c meterUsageObject : meterUsagesList) {
                    meterUsageObject.Arcadia_Statement_ID__c = 'newId';
                }
                Data.upsurt(meterUsagesList, Schema.UtilityMeterUsage__c.fields.Name, option, true, true, true, null);
            } catch (DmlException e) {
                String expectedErrorMessage = System.Label.Arcadia_LockedRecordsUpdate_ErrorMessage;
                System.assert(e.getMessage().contains(expectedErrorMessage), 'Validation error message found.');
            }
            List<UtilityMeterUsage__c> meterUsagesList = [
                SELECT Name, IsRecordLocked__c, Arcadia_Statement_ID__c
                FROM UtilityMeterUsage__c
                WHERE Name IN :namesList
            ];
            for (UtilityMeterUsage__c meterUsageObject : meterUsagesList) {
                if (meterUsageObject.IsRecordLocked__c) {
                    System.assertEquals('oldId', meterUsageObject.Arcadia_Statement_ID__c);
                } else {
                    System.assertEquals('newId', meterUsageObject.Arcadia_Statement_ID__c);
                }
            }
            Test.stopTest();
        }

    }

    @IsTest
    static void deleteMeterUsageWithNullUrjanetIdTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        RetrieveMeterDetailsResponse mockResponse = getMockDetailsResponse();

        System.runAs(adminUser) {
            Test.startTest();
            List<SObject> lstElectricityEmissionFactorSet = Test.loadData(
                ElectricityEmssnFctrSet.sObjectType,
                'ElectricityEmissionFactorSet'
            );
            List<SObject> lstOtherEmissionFactorSet = Test.loadData(
                OtherEmssnFctrSet.sObjectType,
                'OtherEmissionFactorSet'
            );
            StnryAssetEnvrSrc site = new StnryAssetEnvrSrc(
                ElectricityEmssnFctrId = lstElectricityEmissionFactorSet[0].Id,
                OtherEmssnFctrId = lstOtherEmissionFactorSet[0].Id,
                Name = 'Test Site',
                LastUrjanetSyncDateTime__c = Datetime.now()
            );
            insert site;

            UtilityMeter__c parentMeter = [
                SELECT Id, UrjanetId__c, UtilityMeter__c.Name, ServiceType__c
                FROM UtilityMeter__c
                LIMIT 1
            ];
            parentMeter.ServiceType__c = 'electric';
            upsert parentMeter;

            UtilityMeterUsageService.createMeterUsageFromMeterDataResponse(
                mockResponse,
                parentMeter,
                '0',
                new Set<String>()
            );
            List<UtilityMeterUsage__c> meterUsages = [
                SELECT Id, Name, DeregulationStatus__c, AccountType__c, UrjanetId__c
                FROM UtilityMeterUsage__c
                WHERE UtilityMeter__c = :parentMeter.Id
            ];

            StnryAssetEnrgyUse electricActivity1 = new StnryAssetEnrgyUse();
            electricActivity1.StnryAssetEnvrSrcId = site.Id;
            electricActivity1.Name = 'Test Energy Activity 1';
            electricActivity1.FuelType = 'Electricity';
            electricActivity1.UtilityMeterUsage__c = meterUsages[0].Id;
            insert electricActivity1;

            StnryAssetEnrgyUse electricActivity2 = new StnryAssetEnrgyUse();
            electricActivity2.StnryAssetEnvrSrcId = site.Id;
            electricActivity2.FuelType = 'Electricity';
            electricActivity2.Name = 'Test Energy Activity 2';
            electricActivity2.UtilityMeterUsage__c = meterUsages[1].Id;
            insert electricActivity2;

            for (UtilityMeterUsage__c meterUsage : meterUsages) {
                meterUsage.UrjanetId__c = null;
                upsert meterUsage;
            }

            UtilityMeterUsageService.checkForMeterWithUsageIdNullAndDelete(new List<UtilityMeter__c>{ parentMeter });
            Test.stopTest();

            List<UtilityMeterUsage__c> updatedMeterUsages = [
                SELECT Id, Name, DeregulationStatus__c, AccountType__c, UrjanetId__c
                FROM UtilityMeterUsage__c
                WHERE UtilityMeter__c = :parentMeter.Id AND UrjanetId__c = NULL
            ];

            List<StnryAssetEnrgyUse> lstStnryAssetEnrgyUse = [
                SELECT Id, UtilityMeterUsage__c, StnryAssetEnvrSrcId
                FROM StnryAssetEnrgyUse
                WHERE UtilityMeterUsage__c IN :updatedMeterUsages
            ];

            System.assertEquals(2, meterUsages.size(), 'Meter Usages with UrjanetId__c null should 2');
            System.assertEquals(
                0,
                lstStnryAssetEnrgyUse.size(),
                'Related Meter Usage StnryAssetEnrgyUse Should be deleted'
            );
            System.assertEquals(0, updatedMeterUsages.size(), 'Meter Usages with UrjanetId__c null should be Deleted');
        }
    }

    @IsTest
    static void testMeterUsageManualUpdate() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityMeter__c parentMeter = [
                SELECT Id, UrjanetId__c, UtilityMeter__c.Name, ServiceType__c
                FROM UtilityMeter__c
                LIMIT 1
            ];

            UtilityMeterUsage__c initialUsage = new UtilityMeterUsage__c(
                Name = '28707791 - 2021-08-08 - 2021-08-18',
                UtilityMeter__c = parentMeter.Id,
                MeasuredUsage__c = 377.000,
                PeriodStart__c = Date.valueOf('2021-08-08'),
                PeriodEnd__c = Date.valueOf('2021-08-18'),
                UsageUnit__c = 'kWh'
            );
            insert initialUsage;
            Test.startTest();
            initialUsage.UsageUnit__c = 'mwh';
            update initialUsage;
            Test.stopTest();

            Utilitymeterusage__c updatedUsage = [
                SELECT Id, Name, Manually_Updated__c
                FROM UtilityMeterUsage__c
                WHERE UtilityMeter__c = :parentMeter.Id
            ];

            CSutils.itShouldBe('Manually_Updated field ', true, updatedUsage.Manually_Updated__c);

            List<StnryAssetEnrgyUse> lstEnergyUseAfter = [
                SELECT Id, UtilityMeterUsage__c, FuelConsumption, FuelConsumptionUnit
                FROM StnryAssetEnrgyUse
                WHERE UtilityMeterUsage__c = :initialUsage.Id
            ];

            CSutils.itShouldBe('Number of Energy Use records ', 1, lstEnergyUseAfter.size());
            // mwh to kwh conversion is 1->1000
            CSutils.itShouldBe('Fuel Consumption ', 377000, lstEnergyUseAfter[0].FuelConsumption.intValue());
            CSutils.itShouldBe('Fuel Consumption Unit ', 'kWh', lstEnergyUseAfter[0].FuelConsumptionUnit);
        }
    }

    @IsTest
    public static void stationaryAssetEnergyUseServiceTest() {
        System.runAs(TestUtility.createUserAdmin('123123123131231@test.com')) {
            UtilityMeter__c parentMeter = [
                SELECT Id, UrjanetId__c, UtilityMeter__c.Name, ServiceType__c
                FROM UtilityMeter__c
                LIMIT 1
            ];
            RetrieveMeterDetailsResponse mockResponse = getMeterDetailsResponse();
            Test.startTest();
            UtilityMeterUsageService.createMeterUsageFromMeterDataResponse(
                mockResponse,
                parentMeter,
                '0',
                new Set<String>()
            );
            Test.stopTest();

            List<StnryAssetEnrgyUse> energyUseList = [
                SELECT Id, UtilityMeterUsage__c, StnryAssetEnvrSrcId, SupplierId
                FROM StnryAssetEnrgyUse
            ];
            CSUtils.itShouldBe('number of energy use records ', 4, energyUseList.size());
        }
    }

    @IsTest
    public static void stationaryAssetEnergyUseServiceTestGas() {
        System.runAs(TestUtility.createUserAdmin('123123123131231@test.com')) {
            UtilityMeter__c parentMeter = [
                SELECT Id, UrjanetId__c, UtilityMeter__c.Name, ServiceType__c
                FROM UtilityMeter__c
                LIMIT 1
            ];
            RetrieveMeterDetailsResponse mockResponse = getGasMeterDetailsResponse();
            Test.startTest();
            UtilityMeterUsageService.createMeterUsageFromMeterDataResponse(
                mockResponse,
                parentMeter,
                '0',
                new Set<String>()
            );
            Test.stopTest();

            List<StnryAssetEnrgyUse> energyUseList = [
                SELECT Id, UtilityMeterUsage__c, StnryAssetEnvrSrcId, SupplierId, StartDate, EndDate, FuelConsumption
                FROM StnryAssetEnrgyUse
            ];
            CSUtils.itShouldBe('number of energy use records ', 1, energyUseList.size());
            CSUtils.itShouldBe(' Start Date  ', Date.newInstance(2023, 7, 1), energyUseList[0].StartDate);
            CSUtils.itShouldBe(' End Date  ', Date.newInstance(2023, 7, 31), energyUseList[0].EndDate);
            CSUtils.itShouldBe(' Fuel Consumption  ', 3003, energyUseList[0].FuelConsumption.intValue());
        }
    }

    @IsTest
    public static void stationaryAssetEnergyUseServiceTestSingleDay() {
        System.runAs(TestUtility.createUserAdmin('123123123131231@test.com')) {
            UtilityMeter__c parentMeter = [
                SELECT Id, UrjanetId__c, UtilityMeter__c.Name, ServiceType__c
                FROM UtilityMeter__c
                LIMIT 1
            ];
            RetrieveMeterDetailsResponse mockResponse = getMeterDetailsResponseSingleDay();
            Test.startTest();
            UtilityMeterUsageService.createMeterUsageFromMeterDataResponse(
                mockResponse,
                parentMeter,
                '0',
                new Set<String>()
            );
            Test.stopTest();

            List<StnryAssetEnrgyUse> energyUseList = [
                SELECT Id, UtilityMeterUsage__c, StnryAssetEnvrSrcId, SupplierId, StartDate, EndDate, FuelConsumption
                FROM StnryAssetEnrgyUse
            ];
            CSUtils.itShouldBe('number of energy use records ', 1, energyUseList.size());
            CSUtils.itShouldBe(' Start Date  ', Date.newInstance(2021, 8, 8), energyUseList[0].StartDate);
            CSUtils.itShouldBe(' End Date  ', Date.newInstance(2021, 8, 8), energyUseList[0].EndDate);
            CSUtils.itShouldBe(' Fuel Consumption  ', 377, energyUseList[0].FuelConsumption.intValue());
        }
    }

    @IsTest
    public static void stationaryAssetEnergyUseServiceTestDuplicates() {
        System.runAs(TestUtility.createUserAdmin('123123123131231@test.com')) {
            UtilityMeter__c parentMeter = [
                SELECT Id, UrjanetId__c, UtilityMeter__c.Name, ServiceType__c
                FROM UtilityMeter__c
                LIMIT 1
            ];
            RetrieveMeterDetailsResponse mockResponse = getDuplicateMeterDetailsResponse();
            Test.startTest();
            UtilityMeterUsageService.createMeterUsageFromMeterDataResponse(
                mockResponse,
                parentMeter,
                '0',
                new Set<String>()
            );
            Test.stopTest();

            List<UtilityMeterUsage__c> meterUsages = [SELECT Id, Name FROM UtilityMeterUsage__c];
            CSUtils.itShouldBe('number of meter Usage records ', 1, meterUsages.size());
            CSUtils.itShouldBe('Name of meter Usage record ', '2028947 - 2023-07-18 - 2023-08-17', meterUsages[0].Name);

            List<StnryAssetEnrgyUse> energyUseList = [
                SELECT Id, UtilityMeterUsage__c, StnryAssetEnvrSrcId, SupplierId, StartDate, EndDate, FuelConsumption
                FROM StnryAssetEnrgyUse
            ];
            CSUtils.itShouldBe('number of energy use records ', 2, energyUseList.size());
        }
    }

    private static RetrieveMeterDetailsResponse getDuplicateMeterDetailsResponse() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'RetrieveDuplicateMeterDetailsResponse',
            200
        );

        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());
        RetrieveMeterDetailsResponse mockResponse = (RetrieveMeterDetailsResponse) new RetrieveMeterDetailsResponseParser()
            .parseResponse(mockHttpResponse);
        return mockResponse;
    }

    private static RetrieveMeterDetailsResponse getMeterDetailsResponse() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('RetrieveMeterDetailsResponse', 200);

        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());
        RetrieveMeterDetailsResponse mockResponse = (RetrieveMeterDetailsResponse) new RetrieveMeterDetailsResponseParser()
            .parseResponse(mockHttpResponse);
        return mockResponse;
    }

    private static RetrieveMeterDetailsResponse getGasMeterDetailsResponse() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'RetrieveGasMeterDetailsResponse',
            200
        );

        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());
        RetrieveMeterDetailsResponse mockResponse = (RetrieveMeterDetailsResponse) new RetrieveMeterDetailsResponseParser()
            .parseResponse(mockHttpResponse);
        return mockResponse;
    }

    @IsTest
    static void testUpdateRecordsBasedOnLastModifedDate() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityMeter__c meter = [
                SELECT Id, UrjanetId__c, UtilityMeter__c.Name, ServiceType__c
                FROM UtilityMeter__c
                LIMIT 1
            ];
            RetrieveMeterDetailsResponse mockResponse = getMeterDetailsResponseSingleDayMultipleRecords();
            UtilityMeterUsage__c initialUsage = new UtilityMeterUsage__c(
                Name = '28707791 - 2021-07-08 - 2021-07-08',
                UtilityMeter__c = meter.Id,
                DeregulationStatus__c = 'delivery',
                AccountType__c = 'NORMAL',
                MeasuredUsage__c = 999.000,
                PeriodStart__c = Date.valueOf('2021-08-08'),
                PeriodEnd__c = Date.valueOf('2021-08-08'),
                UrjanetId__c = '1ee9bdd3-a384-ddc0-aa72-82b8f4cc1c50',
                LastModifiedInUrjanet__c = Date.valueOf('2024-03-13')
            );

            insert initialUsage;
            Test.startTest();
            UtilityMeterUsageService.createMeterUsageFromMeterDataResponse(mockResponse, meter, '0', new Set<String>());
            Test.stopTest();
            UtilityMeterUsage__c meterUsages = [
                SELECT Id, Name, MeasuredUsage__c, UrjanetId__c
                FROM UtilityMeterUsage__c
                WHERE UrjanetId__c = :initialUsage.UrjanetId__c
            ];
            CsUtils.itShouldBe(
                'measuredUsage for the usage record should be updated',
                67.000,
                meterUsages.MeasuredUsage__c
            );
        }
    }

    @IsTest
    static void testSingleDayDuplicatesDiffMeasuredUsage() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityMeter__c meter = [
                SELECT Id, UrjanetId__c, UtilityMeter__c.Name, ServiceType__c
                FROM UtilityMeter__c
                LIMIT 1
            ];
            RetrieveMeterDetailsResponse mockResponse = getMeterDetailsResponseSingleDayMultipleRecords();
            UtilityMeterUsage__c initialUsage = new UtilityMeterUsage__c(
                Name = '28707791 - 2021-08-08 - 2021-08-08',
                UtilityMeter__c = meter.Id,
                DeregulationStatus__c = 'delivery',
                AccountType__c = 'NORMAL',
                MeasuredUsage__c = 999.000,
                PeriodStart__c = Date.valueOf('2021-08-08'),
                PeriodEnd__c = Date.valueOf('2021-08-08'),
                UrjanetId__c = '1ee9bdd3-a384-ddc0-aa72-82b8f4cc1c50',
                LastModifiedInUrjanet__c = Date.valueOf('2024-03-16')
            );

            insert initialUsage;
            Test.startTest();
            UtilityMeterUsageService.createMeterUsageFromMeterDataResponse(mockResponse, meter, '0', new Set<String>());
            Test.stopTest();
            List<UtilityMeterUsage__c> meterUsages = [SELECT Id, Name, UrjanetId__c FROM UtilityMeterUsage__c];
            CSUtils.itShouldBe('Number of meter Usage records ', 2, meterUsages.size());
            // new record should be created as measured usage is different
        }
    }

    @IsTest
    static void testDeleteMeasuredUsageWithPaginationResponse() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityMeter__c meter = [
                SELECT Id, UrjanetId__c, UtilityMeter__c.Name, ServiceType__c
                FROM UtilityMeter__c
                LIMIT 1
            ];
            RetrieveMeterDetailsResponse mockResponse = getRetrieveMeterUsageDetailsForDeletingRecords();
            UtilityMeterUsage__c initialUsage = new UtilityMeterUsage__c(
                Name = '28707791 - 2021-08-08 - 2021-08-08',
                UtilityMeter__c = meter.Id,
                DeregulationStatus__c = 'delivery',
                AccountType__c = 'NORMAL',
                MeasuredUsage__c = 999.000,
                PeriodStart__c = Date.valueOf('2021-08-08'),
                PeriodEnd__c = Date.valueOf('2021-08-08'),
                UrjanetId__c = '1ee9bdd3-a384-ddc0-aa72-82b8f4cc1c50',
                LastModifiedInUrjanet__c = Date.valueOf('2024-03-16')
            );

            insert initialUsage;
            List<UtilityMeterUsage__c> meterUsages = [SELECT Id, Name, UrjanetId__c FROM UtilityMeterUsage__c];
            CSUtils.itShouldBe('Number of meter Usage records ', 1, meterUsages.size());
            CSUtils.itShouldBe(
                'exisitng usage meter Id should be ',
                initialUsage.UrjanetId__c,
                meterUsages[0].UrjanetId__c
            );
            Test.startTest();
            UtilityMeterUsageService.createMeterUsageFromMeterDataResponse(mockResponse, meter, '1', new Set<String>());
            Test.stopTest();
            meterUsages = [SELECT Id, Name, UrjanetId__c FROM UtilityMeterUsage__c];
            CSUtils.itShouldBe('Number of meter Usage records ', 2, meterUsages.size());
            List<String> meterUsageIds = new List<String>();
            for (UtilityMeterUsage__c meterUsage : meterUsages) {
                meterUsageIds.add(meterUsage.UrjanetId__c);
            }
            CSUtils.itShouldBe(
                'initial usage record should not present',
                true,
                !meterUsageIds.contains(initialUsage.UrjanetId__c)
            );
        }
    }

    private static RetrieveMeterDetailsResponse getMeterDetailsResponseSingleDay() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'RetrieveMeterDetailsResponseSingleDay',
            200
        );
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());
        RetrieveMeterDetailsResponse mockResponse = (RetrieveMeterDetailsResponse) new RetrieveMeterDetailsResponseParser()
            .parseResponse(mockHttpResponse);
        return mockResponse;
    }

    private static RetrieveMeterDetailsResponse getMeterDetailsResponseSingleDayMultipleRecords() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'RetrieveMeterDetailsResponseSingleDayMultipleRecords',
            200
        );
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());
        RetrieveMeterDetailsResponse mockResponse = (RetrieveMeterDetailsResponse) new RetrieveMeterDetailsResponseParser()
            .parseResponse(mockHttpResponse);
        return mockResponse;
    }

    private static RetrieveMeterDetailsResponse getRetrieveMeterUsageDetailsForDeletingRecords() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'RetrieveMeterUsageDetailsForDeletingRecords',
            200
        );
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());
        RetrieveMeterDetailsResponse mockResponse = (RetrieveMeterDetailsResponse) new RetrieveMeterDetailsResponseParser()
            .parseResponse(mockHttpResponse);
        return mockResponse;
    }
}
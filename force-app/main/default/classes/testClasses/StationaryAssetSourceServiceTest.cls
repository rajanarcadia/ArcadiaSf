@IsTest
public with sharing class StationaryAssetSourceServiceTest {
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

            Account providerAccount = new Account();
            providerAccount.Name = 'Test Provider Account';
            insert providerAccount;

            Supplier provider = new Supplier();
            provider.Name = 'Test Provider';
            provider.OtherEmissionsFactors__c = lstOtherEmissionFactorSet[0].Id;
            provider.ElectricityEmissionsFactors__c = lstElectricityEmissionFactorSet[0].Id;
            provider.AccountId = providerAccount.Id;
            insert provider;

            UtilityCredential__c credential = new UtilityCredential__c();
            credential.UrjanetId__c = TestUtility.CREDENTIAL_ID;
            credential.ProviderName__c = provider.Id;
            insert credential;

            UtilityAccount__c account = new UtilityAccount__c();
            account.UtilityCredential__c = credential.Id;
            account.UrjanetId__c = '1234abcd-2345-cd34-1234-1232434cdede';
            account.Supplier__c = provider.id;
            insert account;
        }
    }

    @IsTest
    static void postSiteResponseUpdateTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityAccount__c account = [
                SELECT
                    Id,
                    urjanetId__c,
                    UtilityCredential__r.ProviderName__r.OtherEmissionsFactors__c,
                    UtilityCredential__r.ProviderName__r.ElectricityEmissionsFactors__c,
                    Supplier__c,
                    Supplier__r.Name,
                    Supplier__r.OtherEmissionsFactors__c,
                    Supplier__r.ElectricityEmissionsFactors__c
                FROM UtilityAccount__c
                LIMIT 1
            ];
            StnryAssetEnvrSrc site = new StnryAssetEnvrSrc();
            site.City = 'San Ramon';
            site.Country = 'US';
            site.StationaryAssetType = 'Office';
            site.PostalCode = '94583';
            site.BusinessRegion = 'AMER';
            site.UrjanetSiteCode__c = '123789';
            site.Name = 'Urjanet Test';
            site.UrjanetSiteNumber__c = 'NZC12345';
            site.UrjanetSubRegion__c = 'NorCal';
            site.State = 'CA';
            site.StreetAddress = '340 main st';
            site.StreetAddress2 = 'suite #13';
            site.UtilityAccount__c = account.Id;
            site.ElectricityEmssnFctrId = account.UtilityCredential__r.ProviderName__r.ElectricityEmissionsFactors__c;
            site.OtherEmssnFctrId = account.UtilityCredential__r.ProviderName__r.OtherEmissionsFactors__c;
            insert site;

            Test.startTest();
            StationaryAssetSourceService.updateSiteDetailsFromResponse(getMockPostSiteResponse(), site.Id);
            Test.stopTest();
            StnryAssetEnvrSrc stationaryAssetSource = [
                SELECT
                    Name,
                    UrjanetId__c,
                    LastModifiedInUrjanet__c,
                    LastModifiedByInUrjanet__c,
                    CreatedDateInUrjanet__c,
                    CreatedByInUrjanet__c
                FROM StnryAssetEnvrSrc
                LIMIT 1
            ];
            CSUtils.itShouldBe('Site Name ', 'Urjanet Test', stationaryAssetSource.Name);
            CSUtils.itShouldBe(
                'Urjanet Id ',
                '1ece6d51-dd82-d644-8a08-d23d6f619b36',
                stationaryAssetSource.UrjanetId__c
            );
            CSUtils.itShouldBe(
                'Last Modified ',
                UrjanetUtils.getDateTime('2022-06-08T02:45:54.539+00:00'),
                stationaryAssetSource.LastModifiedInUrjanet__c
            );
            CSUtils.itShouldBe('Last Modified By ', 'Urjanet.test', stationaryAssetSource.LastModifiedByInUrjanet__c);
            CSUtils.itShouldBe(
                'Created Date ',
                UrjanetUtils.getDateTime('2022-06-08T02:45:54.539+00:00'),
                stationaryAssetSource.CreatedDateInUrjanet__c
            );
            CSUtils.itShouldBe('Created By ', 'Urjanet.test', stationaryAssetSource.CreatedByInUrjanet__c);
        }
    }

    private static PostSiteResponse getMockPostSiteResponse() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('PostSiteResponse', 202);

        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());
        PostSiteResponse mockResponse = (PostSiteResponse) new PostSiteResponseParser().parseResponse(mockHttpResponse);
        return mockResponse;
    }

    @isTest
    static void mapToUrjanetCountryCodeTest() {
        Test.StartTest();
        StationaryAssetSourceService.createQueueItemsToSendStationaryAssetSource();
        String countryCode3Digit = StationaryAssetSourceService.mapToUrjanetCountryCode('US');
        CSUtils.itShouldBe('Country 3 Digit Code would be :', 'USA', countryCode3Digit);
        Test.StopTest();
    }
}
@IsTest
public with sharing class UtilityAccountTriggerTest {
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
        }
    }
    @IsTest
    static void UtilityAccountTriggerInsertTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        Supplier supplierObj = [SELECT Id FROM Supplier LIMIT 1];

        System.runAs(adminUser) {
            UtilityCredential__c credential = [
                SELECT Id
                FROM UtilityCredential__c
                WHERE UrjanetId__c = :TestUtility.CREDENTIAL_ID
            ];
            UtilityAccount__c account = new UtilityAccount__c();
            account.UtilityCredential__c = credential.Id;
            account.UrjanetId__c = '1234abcd-2345-cd34-1234-1232434cdede';
            account.Supplier__c = supplierObj.Id;

            StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('MetersByAccountResponse', 200);
            Test.startTest();
            insert account;
            Test.stopTest();
            UtilityAccount__c accountQueried = [SELECT Id, UrjanetId__c FROM UtilityAccount__c LIMIT 1];
            CSUtils.itShouldBe(
                'Utility Account Urjanet Id ',
                '1234abcd-2345-cd34-1234-1232434cdede',
                accountQueried.UrjanetId__c
            );
        }
    }

    @IsTest
    static void UtilityAccountTriggerUpdateTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        Supplier supplierObj = [SELECT Id FROM Supplier LIMIT 1];
        System.runAs(adminUser) {
            UtilityCredential__c credential = [
                SELECT Id
                FROM UtilityCredential__c
                WHERE UrjanetId__c = :TestUtility.CREDENTIAL_ID
            ];
            UtilityAccount__c account = new UtilityAccount__c();
            account.UtilityCredential__c = credential.Id;
            account.UrjanetId__c = '1234abcd-2345-cd34-1234-1232434cdede';
            account.Supplier__c = supplierObj.Id;
            account.LastModifiedInUrjanet__c = Datetime.now().addMinutes(-1);
            StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('MetersByAccountResponse', 200);
            insert account;

            account.Name = 'test Updated';
            account.LastModifiedInUrjanet__c = Datetime.now();
            Test.startTest();
            update account;
            Test.stopTest();
            UtilityAccount__c accountQueried = [SELECT Id, Name, UrjanetId__c FROM UtilityAccount__c LIMIT 1];
            CSUtils.itShouldBe('Utility Account Name ', 'test Updated', accountQueried.Name);
            List<UtilityMeter__c> meterQueried = [SELECT Id, UrjanetId__c FROM UtilityMeter__c];
            CSUtils.itShouldBe('Meter Id ', '1ecd6c27-b21e-d108-ba69-12345678', meterQueried[0].UrjanetId__c);
        }
    }

    @IsTest
    static void UtilityAccountTriggerUpdateTestErrorResponse() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        Supplier supplierObj = [SELECT Id FROM Supplier LIMIT 1];
        System.runAs(adminUser) {
            UtilityCredential__c credential = [
                SELECT Id
                FROM UtilityCredential__c
                WHERE UrjanetId__c = :TestUtility.CREDENTIAL_ID
            ];
            TestUtility.insertLastSyncDetails();
            UtilityAccount__c account = new UtilityAccount__c();
            account.UtilityCredential__c = credential.Id;
            account.UrjanetId__c = '1234abcd-2345-cd34-1234-1232434cdede';
            account.Supplier__c = supplierObj.Id;

            StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
                'MetersByAccountResponseFailure',
                400
            );
            insert account;
            List<Log__c> logbeforeAPICall = [SELECT Id FROM Log__c LIMIT 1];
            CSUtils.itShouldBe('Expected number of records in Log Object', 0, logBeforeAPICall.size());

            account.Name = 'test Updated';
            Test.startTest();
            update account;
            Test.stopTest();
            UtilityAccount__c accountQueried = [SELECT Id, Name, UrjanetId__c FROM UtilityAccount__c LIMIT 1];
            CSUtils.itShouldBe('Utility Account Name ', 'test Updated', accountQueried.Name);
            List<Log__c> logAfterAPICall = [SELECT Id, Message__c FROM Log__c LIMIT 1];
            CSUtils.itShouldBe('Error message', '400 Bad request', logAfterAPICall[0].Message__c.trim());
        }
    }
    @IsTest
    static void UtilityAccountTriggerUpdateTestNullId() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        Supplier supplierObj = [SELECT Id FROM Supplier LIMIT 1];
        System.runAs(adminUser) {
            UtilityCredential__c credential = [
                SELECT Id
                FROM UtilityCredential__c
                WHERE UrjanetId__c = :TestUtility.CREDENTIAL_ID
            ];
            UtilityAccount__c account = new UtilityAccount__c();
            account.UtilityCredential__c = credential.Id;
            account.UrjanetId__c = '1234abcd-2345-cd34-1234-1232434cdede';
            account.Supplier__c = supplierObj.Id;

            insert account;
            List<Log__c> logbeforeAPICall = [SELECT Id FROM Log__c LIMIT 1];
            CSUtils.itShouldBe('Expected number of records in Log Object', 0, logBeforeAPICall.size());

            account.Name = 'test Updated';
            account.UrjanetId__c = null;

            Test.startTest();
            update account;
            Test.stopTest();
            UtilityAccount__c accountQueried = [SELECT Id, Name, UrjanetId__c FROM UtilityAccount__c LIMIT 1];
            CSUtils.itShouldBe('Utility Account Name ', 'test Updated', accountQueried.Name);
        }
    }
}
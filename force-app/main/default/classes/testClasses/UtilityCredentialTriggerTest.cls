/**
 * Created by Alagu on 5/12/22.
 */

@IsTest
private class UtilityCredentialTriggerTest {
    @TestSetup
    static void makeData() {
        User adminUser = TestUtility.createUserAdmin('urjanetAdmin12@urjanettest.com');
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
        }
    }
    // This test is really just for coverage because triggers are required to have coverage. The logic performed
    // as a result of the triggers is tested thoroughly in test classes corresponding to the services that do the
    // work
    @IsTest
    static void givenUtilityCredentialRecordsInsertedUtilityCredentialRecordsExist() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin12@urjanettest.com' LIMIT 1];
        UtilityCredential__c credential = new UtilityCredential__c();

        System.runAs(adminUser) {
            credential.LastUrjanetSyncDateTime__c = Datetime.now();

            Test.startTest();
            insert credential;
            Test.stopTest();
        }

        List<UtilityCredential__c> credentials = [SELECT Id FROM UtilityCredential__c];
        CSUtils.itShouldBe('A credential record should exist', 1, credentials.size());
    }

    @IsTest
    static void givenUtilityCredentialRecordsUpdatedUtilityCredentialRecordsUpdatedOnDatabase() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin12@urjanettest.com' LIMIT 1];
        UtilityCredential__c credential = new UtilityCredential__c();
        credential.LastUrjanetSyncDateTime__c = Datetime.now();
        System.runAs(adminUser) {
            insert credential;

            credential.Name = 'Testcredential';

            Test.startTest();
            update credential;
            Test.stopTest();
        }

        List<UtilityCredential__c> credentials = [SELECT Id, Name FROM UtilityCredential__c];
        CSUtils.itShouldBe('credential name should be updated', 'Testcredential', credentials[0].Name);
    }
    @IsTest
    static void processMethodHandlesFaliureApiCall() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'AccountsByCredsResponseFailure',
            200
        );
        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());
        GetAccountsByCredsResponse response = (GetAccountsByCredsResponse) new GetAccountsByCredsResponseParser()
            .parseResponse(mockHttpResponse);

        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin12@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityCredential__c credential = new UtilityCredential__c();
            credential.UrjanetId__c = TestUtility.CREDENTIAL_ID;

            Test.startTest();
            insert credential;
            Test.stopTest();
            List<Log__c> logAfterAPICall = [SELECT Id, Message__c FROM Log__c LIMIT 1];
            CSUtils.itShouldBe('Number of records in Log Object', 1, logAfterAPICall.size());
            CSUtils.itShouldBe('Error message', response.errorMsg, logAfterAPICall[0].Message__c.trim());
        }
    }
}
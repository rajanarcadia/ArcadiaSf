@IsTest
private class UtilityAccountServiceTest {
    @TestSetup
    static void setup() {
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
            credential.ProviderName__c = provider.id;
            insert credential;

            UtilityStatementFile__c statementFile = new UtilityStatementFile__c();
            statementFile.Name = 'My Utility Statement';
            statementFile.Supplier__c = provider.Id;
            insert statementFile;
        }
    }

    @IsTest
    static void newUtilityCredentialsIsConsideredForUpdate() {
        String randomId = TestUtility.getRandomId(UtilityAccount__c.SObjectType);
        UtilityAccount__c updatedAccount = new UtilityAccount__c();
        updatedAccount.LastModifiedInUrjanet__c = Datetime.now();
        updatedAccount.Id = Id.valueOf(randomId);

        UtilityAccount__c oldAccount = new UtilityAccount__c();
        oldAccount.LastModifiedInUrjanet__c = Datetime.now().addMinutes(-1);
        oldAccount.Id = Id.valueOf(randomId);

        Map<Id, UtilityAccount__c> oldMap = new Map<Id, UtilityAccount__c>();
        oldMap.put(Id.valueOf(randomId), oldAccount);

        Test.startTest();
        List<UtilityAccount__c> AccountsToRefresh = UtilityAccountService.getAccountsToRefresh(
            new List<UtilityAccount__c>{ updatedAccount, oldAccount },
            oldMap
        );
        Test.stopTest();
        CSUtils.itShouldBe('Accounts to refresh should have 1 record', 1, AccountsToRefresh.size());
    }

    @IsTest
    static void givenNoExistingAcctRecordsWhenCreateAcctRecordsAllCreated() {
        UtilityCredential__c credential = [SELECT Id, UrjanetId__c, ProviderName__c FROM UtilityCredential__c LIMIT 1];

        GetAccountsByCredsResponse mockResponse = getMockDetailsResponse();

        System.runAs(TestUtility.createUserAdmin('123123123131231@test.com')) {
            Test.startTest();
            UtilityAccountService.createAccountFromDataResponse(mockResponse, credential);
            Test.stopTest();
            Integer utilityAccountCount = [SELECT COUNT() FROM UtilityAccount__c];
            System.assertEquals(true, utilityAccountCount > 0, 'Should be utilityaccount records created');
        }
    }

    @IsTest
    static void givenExistingAcctRecordsWhenUpdateAcctRecordsAllUpdated() {
        UtilityCredential__c credential = [SELECT Id, UrjanetId__c, ProviderName__c FROM UtilityCredential__c LIMIT 1];

        GetAccountsByCredsResponse mockResponse = getMockDetailsResponse();
        mockResponse.embedded.accounts[0].statusDetail = 'Test Status Detail';

        System.runAs(TestUtility.createUserAdmin('123123123131231@test.com')) {
            Test.startTest();
            UtilityAccountService.createAccountFromDataResponse(mockResponse, credential);
            Test.stopTest();
            List<UtilityAccount__c> utilityAccountList = [SELECT Id, StatusDetail__c FROM UtilityAccount__c LIMIT 1];
            System.assertEquals(
                'Test Status Detail',
                utilityAccountList[0].StatusDetail__c,
                'Should be utilityaccount records updated'
            );
        }
    }

    private static GetAccountsByCredsResponse getMockDetailsResponse() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('AccountsByCredsResponse', 200);

        HttpResponse mockHttpResponse = mock.respond(new HttpRequest());
        GetAccountsByCredsResponse mockResponse = (GetAccountsByCredsResponse) new GetAccountsByCredsResponseParser()
            .parseResponse(mockHttpResponse);
        return mockResponse;
    }

    @IsTest
    static void testCreateAccountFromDataResponseStatement() {
        UtilityStatementFile__c stateFile = [SELECT Id, Name, Supplier__c FROM UtilityStatementFile__c LIMIT 1];
        GetAccountsByCredsResponse mockResponse = getMockDetailsResponse();
        Test.StartTest();
        UtilityAccountService.createAccountFromDataResponse(mockResponse, stateFile);
        Test.StopTest();

        List<UtilityAccount__c> utilityAccountList = [SELECT Id, StatusDetail__c FROM UtilityAccount__c LIMIT 1];
        CSUtils.itShouldBe(
            'Status Detail should be matched ',
            'NO_ACTION_REQUIRED',
            utilityAccountList[0].StatusDetail__c
        );
    }

    @IsTest
    static void testCreateAccountFromDataResponseStatementDuplicate() {
        UtilityStatementFile__c stateFile = [SELECT Id, Name, Supplier__c FROM UtilityStatementFile__c LIMIT 1];
        GetAccountsByCredsResponse mockResponse = getMockDetailsResponse();
        Test.StartTest();
        UtilityAccountService.createAccountFromDataResponse(mockResponse, stateFile);
        // call 2 times to check duplicate
        UtilityAccountService.createAccountFromDataResponse(mockResponse, stateFile);
        Test.StopTest();

        List<UtilityAccount__c> utilityAccountList = [SELECT Id, StatusDetail__c FROM UtilityAccount__c];
        CSUtils.itShouldBe('utilityAccountList size ', 1, utilityAccountList.size());
        CSUtils.itShouldBe(
            'Status Detail should be matched ',
            'NO_ACTION_REQUIRED',
            utilityAccountList[0].StatusDetail__c
        );
        List<Utility_File_Account_Association__c> fileAccounts = [
            SELECT Id, Utility_Statement_File__c, Utility_Account__c
            FROM Utility_File_Account_Association__c
        ];
        CSUtils.itShouldBe('fileAccounts size ', 1, fileAccounts.size());
        CSUtils.itShouldBe('Utility Account Id', utilityAccountList[0].Id, fileAccounts[0].Utility_Account__c);
        CSUtils.itShouldBe('Utility Statement Id', stateFile.Id, fileAccounts[0].Utility_Statement_File__c);
    }
}
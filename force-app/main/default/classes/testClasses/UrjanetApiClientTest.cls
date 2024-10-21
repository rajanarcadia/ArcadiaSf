@isTest
public with sharing class UrjanetApiClientTest {
    @isTest
    static void getAccessTokenTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('LoginResponse', 200);

        Test.startTest();
        LoginResponse response = (LoginResponse) new UrjanetApiClient().getAccessToken();
        Test.stopTest();

        CSUtils.itShouldBe('Access Token Status', 200, response.status);
        CSUtils.itShouldBe('Login Callout response', 'Authentication Successful', response.message);
    }

    @isTest
    static void getAccessTokenFailureTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('LoginResponseFailure', 401);
        Test.startTest();
        LoginResponse response = (LoginResponse) new UrjanetApiClient().getAccessToken();
        Test.stopTest();
        List<Log__c> logAfterAPICall = [SELECT Id, Message__c, LogTitle__c FROM Log__c LIMIT 1];
        CSUtils.itShouldBe('Number of records in Log Object', 1, logAfterAPICall.size());
        CSUtils.itShouldBe(
            'Error message in Log title',
            UrjanetConstants.LOGIN_FAILURE,
            logAfterAPICall[0].LogTitle__c
        );
        CSUtils.itShouldBe('Login Callout response', '401 Unauthorized', response.errorMsg);
    }

    @isTest
    static void getCredentialsTest() {
        User adminUser = TestUtility.createUserAdmin('urjanetAdmin@urjanettest.com');
        System.runAs(adminUser) {
            UtilityCredential__c credential = new UtilityCredential__c(
                Name = 'Test Utility Credential',
                CorrelationId__c = 'test-correlation-Id'
            );
            insert credential;

            CredentialResponseMock.credentialId = credential.CorrelationId__c;
            Test.setMock(HttpCalloutMock.class, new CredentialResponseMock());
            Test.startTest();
            List<String> requestParams = new List<String>{ 'test-correlation-Id' };
            GetCredentialsResponse response = (GetCredentialsResponse) new UrjanetApiClient()
                .getUrjanetResponse(
                    UrjanetEnums.RequestType.CREDENTIALS_BY_CORRELATION_ID,
                    UrjanetEnums.ApiMethod.GET,
                    requestParams
                );
            Test.stopTest();

            CSUtils.itShouldBe('Number of credentials ', 1, response.embedded.credentials.size());
            CSUtils.itShouldBe('User name', 'Test_Name_1', response.embedded.credentials[0].userName);
            CSUtils.itShouldBe('User name2', 'test_user_name2', response.embedded.credentials[0].username2);
            CSUtils.itShouldBe('User name3', 'test_user_name3', response.embedded.credentials[0].username3);
            CSUtils.itShouldBe('User name4', 'test_user_name4', response.embedded.credentials[0].username4);
            CSUtils.itShouldBe('Correlation id', 'test-correlation-Id', response.embedded.credentials[0].correlationId);
            CSUtils.itShouldBe('Status', 'OK', response.embedded.credentials[0].status);
            CSUtils.itShouldBe('Status detail', 'NO_ACTION_REQUIRED', response.embedded.credentials[0].statusDetail);
            CSUtils.itShouldBe('Enabled', true, response.embedded.credentials[0].enabled);
            CSUtils.itShouldBe(
                'Nex scheduled run',
                '2022-04-30T00:30:50.000+00:00',
                response.embedded.credentials[0].nextScheduledRun
            );
            CSUtils.itShouldBe('Provider name', 'Xcel Energy', response.embedded.credentials[0].providerName);
            CSUtils.itShouldBe(
                'Last modified',
                '2022-04-25T00:30:50.000+00:00',
                response.embedded.credentials[0].lastModifiedDate
            );
            CSUtils.itShouldBe(
                'Created',
                '2022-04-01T15:56:11.000+00:00',
                response.embedded.credentials[0].createdDate
            );
            CSUtils.itShouldBe('Created by', 'urjanet-connect', response.embedded.credentials[0].createdBy);
            CSUtils.itShouldBe('Last modified by', 'system', response.embedded.credentials[0].lastModifiedBy);
            CSUtils.itShouldBe('Run history', false, response.embedded.credentials[0].runHistory);
            CSUtils.itShouldBe('Mock', false, response.embedded.credentials[0].mock);
            CSUtils.itShouldBe('Custom data', '2345', response.embedded.credentials[0].customData);
            CSUtils.itShouldBe('Total accounts', 2, response.embedded.credentials[0].totalAccounts);
            CSUtils.itShouldBe('User Name', 'Test_Name_1', response.embedded.credentials[0].userName);
            CSUtils.itShouldBe(
                'Credential self link',
                'https://test.urjanet.com/utility/credentials/1234abcd-1234-abc0-12ab-ab3242342332',
                response.embedded.credentials[0].links.self.href
            );
            CSUtils.itShouldBe(
                'Credential account link',
                'https://test.urjanet.com/utility/credentials/1234abcd-1234-abc0-12ab-ab3242342332/accounts',
                response.embedded.credentials[0].links.accounts.href
            );
            CSUtils.itShouldBe(
                'Credential consent link',
                'https://test.urjanet.com/utility/credentials/1234abcd-1234-abc0-12ab-ab3242342332/consent',
                response.embedded.credentials[0].links.consent.href
            );
            CSUtils.itShouldBe(
                'Credential events link',
                'https://test.urjanet.com/utility/credentials/1234abcd-1234-abc0-12ab-ab3242342332/events',
                response.embedded.credentials[0].links.events.href
            );
            CSUtils.itShouldBe(
                'Credential passwords link',
                'https://test.urjanet.com/utility/credentials/1234abcd-1234-abc0-12ab-ab3242342332/passwords',
                response.embedded.credentials[0].links.passwords.href
            );
            CSUtils.itShouldBe(
                'Credential provider link',
                'https://test.urjanet.com/utility/providers/36edc6f1-ea0a-11e0-b6bb-12313d2b6294',
                response.embedded.credentials[0].links.provider.href
            );
            CSUtils.itShouldBe(
                'Credential update url link',
                'https://test.urjanet.com/utility/credentials/1234abcd-1234-abc0-12ab-ab3242342332/updateUrl',
                response.embedded.credentials[0].links.updateUrl.href
            );
            CSUtils.itShouldBe(
                'Self link',
                'https://test.urjanet.com/utility/credentials?search=correlationId%3Din%3D(TEST00001,+SAMPLE00011)&page=0&size=20',
                response.links.self.href
            );
            CSUtils.itShouldBe('Attributes of Page details', 0, response.page.numbers);
            CSUtils.itShouldBe('Attributes of Page details', 1, response.page.totalPages);
            CSUtils.itShouldBe('Attributes of Page details', 2, response.page.totalElements);
            CSUtils.itShouldBe('Attributes of Page details', 20, response.page.size);
        }
    }

    @isTest
    static void getCredentialsFailureTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('GetCredentialsResponseFailure', 400);
        Test.startTest();
        List<String> requestParams = new List<String>{ 'test-correlation-Id' };
        GetCredentialsResponse response = (GetCredentialsResponse) new UrjanetApiClient()
            .getUrjanetResponse(
                UrjanetEnums.RequestType.CREDENTIALS_BY_CORRELATION_ID,
                UrjanetEnums.ApiMethod.GET,
                requestParams
            );
        Test.stopTest();

        CSUtils.itShouldBe('Error message', '400 Bad request', response.errorMsg);
    }

    @isTest
    static void getAccountsByCredTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('AccountsByCredsResponse', 200);
        Test.startTest();
        List<String> requestParams = new List<String>{ 'test-Credential-Id' };
        GetAccountsByCredsResponse response = (GetAccountsByCredsResponse) new UrjanetApiClient()
            .getUrjanetResponse(UrjanetEnums.RequestType.ACCOUNTS_BY_CREDS, UrjanetEnums.ApiMethod.GET, requestParams);
        Test.stopTest();

        CSUtils.itShouldBe('Number of accounts', 1, response.embedded.accounts.size());
        CSUtils.itShouldBe('Account Number ', 'Test-account-Id', response.embedded.accounts[0].accountNumber);
        CSUtils.itShouldBe('Provider Name ', 'Xcel Energy', response.embedded.accounts[0].providerName);
        CSUtils.itShouldBe(
            'Normalized Account Number ',
            '5187939528',
            response.embedded.accounts[0].normalizedAccountNumber
        );
        CSUtils.itShouldBe('status Detail ', 'NO_ACTION_REQUIRED', response.embedded.accounts[0].statusDetail);
        CSUtils.itShouldBe('Enabled ', true, response.embedded.accounts[0].enabled);
        CSUtils.itShouldBe('Prepaid ', false, response.embedded.accounts[0].prepaid);
        CSUtils.itShouldBe('Type ', 'NORMAL', response.embedded.accounts[0].type);
        CSUtils.itShouldBe(
            'Last Modified ',
            '2022-04-28T00:17:57.000+00:00',
            response.embedded.accounts[0].lastModifiedDate
        );
        CSUtils.itShouldBe('created ', '2022-04-01T19:54:20.000+00:00', response.embedded.accounts[0].createdDate);
        CSUtils.itShouldBe('created By ', 'system', response.embedded.accounts[0].createdBy);
        CSUtils.itShouldBe('Last Modified By ', 'system', response.embedded.accounts[0].lastModifiedBy);
        CSUtils.itShouldBe(
            'Latest New Statement ',
            '2022-04-22T00:15:06.000+00:00',
            response.embedded.accounts[0].latestNewStatement
        );
        CSUtils.itShouldBe('Latest Statement Date ', '2022-04-20', response.embedded.accounts[0].latestStatementDate);
        CSUtils.itShouldBe('Status ', 'OK', response.embedded.accounts[0].status);
        CSUtils.itShouldBe(
            'Self link ',
            'https://api.urjanet.com/utility/accounts/test-self',
            response.embedded.accounts[0].links.self.href
        );
        CSUtils.itShouldBe(
            'provider link ',
            'https://api.urjanet.com/utility/providers/36edc6f1-ea0a-11e0-b6bb-12313d2b6294',
            response.embedded.accounts[0].links.provider.href
        );
        CSUtils.itShouldBe(
            'Self link ',
            'https://api.urjanet.com/utility/accounts/Test-account-Id/credentials',
            response.embedded.accounts[0].links.credentials.href
        );
        CSUtils.itShouldBe(
            'events link ',
            'https://api.urjanet.com/utility/accounts/Test-account-Id/events',
            response.embedded.accounts[0].links.events.href
        );
        CSUtils.itShouldBe(
            'accountData link ',
            'https://api.urjanet.com/utility/accounts/Test-account-Id/accountData',
            response.embedded.accounts[0].links.accountData.href
        );
        CSUtils.itShouldBe(
            'meters link ',
            'https://api.urjanet.com/utility/accounts/Test-account-Id/meters',
            response.embedded.accounts[0].links.meters.href
        );
        CSUtils.itShouldBe(
            'sites link ',
            'https://api.urjanet.com/utility/accounts/Test-account-Id/sites',
            response.embedded.accounts[0].links.sites.href
        );
        CSUtils.itShouldBe(
            'statements link ',
            'https://api.urjanet.com/utility/accounts/Test-account-Id/statements',
            response.embedded.accounts[0].links.statements.href
        );
        CSUtils.itShouldBe(
            'payments link ',
            'https://api.urjanet.com/utility/accounts/Test-account-Id/payments',
            response.embedded.accounts[0].links.payments.href
        );

        CSUtils.itShouldBe(
            'Self link ',
            'https://api.urjanet.com/utility/credentials/Test-credential-Id/accounts?page=0&size=20',
            response.links.self.href
        );
        CSUtils.itShouldBe('Attributes of Page details', 1, response.page.totalElements);
        CSUtils.itShouldBe('Attributes of Page details', 20, response.page.size);
    }

    @isTest
    static void getAccountsByCredsFailureTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'AccountsByCredsResponseFailure',
            400
        );
        Test.startTest();
        List<String> requestParams = new List<String>{ 'Test-credential-Id' };
        GetAccountsByCredsResponse response = (GetAccountsByCredsResponse) new UrjanetApiClient()
            .getUrjanetResponse(UrjanetEnums.RequestType.ACCOUNTS_BY_CREDS, UrjanetEnums.ApiMethod.GET, requestParams);
        Test.stopTest();

        CSUtils.itShouldBe('Error message', '400 Bad request', response.errorMsg);
    }

    @isTest
    static void getMetersByAccountTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('MetersByAccountResponse', 200);
        Test.startTest();
        List<String> requestParams = new List<String>{ 'Test-account-Id' };
        GetMetersByAccountResponse response = (GetMetersByAccountResponse) new UrjanetApiClient()
            .getUrjanetResponse(UrjanetEnums.RequestType.METERS_BY_ACCOUNT, UrjanetEnums.ApiMethod.GET, requestParams);
        Test.stopTest();

        CSUtils.itShouldBe('Number of meters', 1, response.embedded.meters.size());
        CSUtils.itShouldBe('Account Number size ', 1, response.embedded.meters[0].accountNumbers.size());
        CSUtils.itShouldBe('Account Ids size ', 1, response.embedded.meters[0].accountIds.size());
        CSUtils.itShouldBe('Entity Id ', '1ecd6c27-b21e-d108-ba69-12345678', response.embedded.meters[0].entityId);
        CSUtils.itShouldBe(
            'Provider Name ',
            'San Francisco Public Utilty Commission',
            response.embedded.meters[0].providerName
        );
        CSUtils.itShouldBe('Meter Status ', 'CURRENT', response.embedded.meters[0].meterStatus);
        CSUtils.itShouldBe('Pod Number ', '1486032306', response.embedded.meters[0].podNumber);
        CSUtils.itShouldBe('Normalized PodNumber ', '1486032306', response.embedded.meters[0].normalizedPodNumber);
        CSUtils.itShouldBe('Next Expected Post date ', '2022-06-11', response.embedded.meters[0].nextExpectedPostDate);
        CSUtils.itShouldBe('Service Type ', 'electric', response.embedded.meters[0].serviceType);
        CSUtils.itShouldBe(
            'Last Modified ',
            '2022-05-18T15:52:20.000+00:00',
            response.embedded.meters[0].lastModifiedDate
        );
        CSUtils.itShouldBe('created ', '2022-05-18T15:52:12.000+00:00', response.embedded.meters[0].createdDate);
        CSUtils.itShouldBe('created By ', 'system', response.embedded.meters[0].createdBy);
        CSUtils.itShouldBe('Last Modified By ', 'system', response.embedded.meters[0].lastModifiedBy);
        CSUtils.itShouldBe('Address Type ', 'PARTIAL', response.embedded.meters[0].serviceAddress.addressType);
        CSUtils.itShouldBe(
            'Street Line 1 ',
            '350 MISSION ST RETAIL',
            response.embedded.meters[0].serviceAddress.streetLine1
        );
        CSUtils.itShouldBe('Street Line 1 ', 'LOBBY', response.embedded.meters[0].serviceAddress.streetLine2);
        CSUtils.itShouldBe('City ', null, response.embedded.meters[0].serviceAddress.city);
        CSUtils.itShouldBe('State ', null, response.embedded.meters[0].serviceAddress.state);
        CSUtils.itShouldBe('Postal code ', null, response.embedded.meters[0].serviceAddress.postalCode);
        CSUtils.itShouldBe('Country ', null, response.embedded.meters[0].serviceAddress.country);
        CSUtils.itShouldBe(
            'Full Address ',
            '350 MISSION ST RETAIL, LOBBY',
            response.embedded.meters[0].serviceAddress.fullAddress
        );
        CSUtils.itShouldBe(
            'Self link ',
            'https://test.urjanet.com/utility/meters/1ecd6c27-b21e-d108-ba69-12345678',
            response.embedded.meters[0].links.self.href
        );
        CSUtils.itShouldBe(
            'Account link ',
            'https://test.urjanet.com/utility/meters/1ecd6c27-b21e-d108-ba69-12345678/accounts',
            response.embedded.meters[0].links.accounts.href
        );
        CSUtils.itShouldBe(
            'meterdata link ',
            'https://test.urjanet.com/utility/meters/1ecd6c27-b21e-d108-ba69-12345678/meterData',
            response.embedded.meters[0].links.meterData.href
        );
        CSUtils.itShouldBe(
            'credentials link ',
            'https://test.urjanet.com/utility/meters/1ecd6c27-b21e-d108-ba69-12345678/credentials',
            response.embedded.meters[0].links.credentials.href
        );
        CSUtils.itShouldBe(
            'provider link ',
            'https://test.urjanet.com/utility/providers/1e6316a3-b385-d289-8704-22000b109b8b',
            response.embedded.meters[0].links.provider.href
        );
        CSUtils.itShouldBe(
            'statements link ',
            'https://test.urjanet.com/utility/meters/1ecd6c27-b21e-d108-ba69-12345678/statements',
            response.embedded.meters[0].links.statements.href
        );
        CSUtils.itShouldBe(
            'Self link ',
            'https://test.urjanet.com/utility/accounts/1ecd6c27-b1e3-d774-ba69-12345678/meters?search=site.id%3Disnull%3Dtrue&page=0&size=20',
            response.links.self.href
        );
        CSUtils.itShouldBe('Attributes of Page details', 1, response.page.totalElements);
        CSUtils.itShouldBe('Attributes of Page details', 20, response.page.size);
    }

    @isTest
    static void getMetersByAccountFailureTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'MetersByAccountResponseFailure',
            400
        );
        Test.startTest();
        List<String> requestParams = new List<String>{ 'Test-account-Id' };
        GetMetersByAccountResponse response = (GetMetersByAccountResponse) new UrjanetApiClient()
            .getUrjanetResponse(UrjanetEnums.RequestType.METERS_BY_ACCOUNT, UrjanetEnums.ApiMethod.GET, requestParams);
        Test.stopTest();

        CSUtils.itShouldBe('Error message', '400 Bad request', response.errorMsg);
    }

    @isTest
    static void retrieveMeterDetailsTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('RetrieveMeterDetailsResponse', 200);
        Test.startTest();
        List<String> requestParams = new List<String>{ 'test-meter-Id' };
        RetrieveMeterDetailsResponse response = (RetrieveMeterDetailsResponse) new UrjanetApiClient()
            .getUrjanetResponse(
                UrjanetEnums.RequestType.RETRIEVE_METER_DETAILS,
                UrjanetEnums.ApiMethod.GET,
                requestParams
            );
        Test.stopTest();

        CSUtils.itShouldBe('Number of meters', 2, response.embedded.meters.size());
        CSUtils.itShouldBe('Number of meters', 2, response.embedded.meters[0].charges.size());
        CSUtils.itShouldBe('Number of meters', 4, response.embedded.meters[0].usages.size());
        CSUtils.itShouldBe('created', '2022-04-01T19:54:45.000+00:00', response.embedded.meters[0].createdDate);
        CSUtils.itShouldBe('Service type', 'electric', response.embedded.meters[0].serviceType);
        CSUtils.itShouldBe('Meter read date', '2021-08-08', response.embedded.meters[0].meterReadDate);
        CSUtils.itShouldBe('Next read date', '2021-10-07', response.embedded.meters[0].nextReadDate);
        CSUtils.itShouldBe('Previous read date', '2021-08-05', response.embedded.meters[0].prevReadDate);
        CSUtils.itShouldBe('Meter number', '28707791', response.embedded.meters[0].meterNumber);
        CSUtils.itShouldBe('Normalized meter number', '28707791', response.embedded.meters[0].normalizedMeterNumber);
        CSUtils.itShouldBe('Previous meter number', '12345', response.embedded.meters[0].previousMeterNumber);
        CSUtils.itShouldBe(
            'Normalized previous meter number',
            '23456',
            response.embedded.meters[0].normalizedPreviousMeterNumber
        );
        CSUtils.itShouldBe(
            'Rate or tariff actual name',
            'unknown_tariff',
            response.embedded.meters[0].rateOrTariffActualName
        );
        CSUtils.itShouldBe('Pod number', '303682599', response.embedded.meters[0].podNumber);
        CSUtils.itShouldBe('Normalized pod number', '303682599', response.embedded.meters[0].normalizedPodNumber);
        CSUtils.itShouldBe(
            'Service description',
            'Test service description',
            response.embedded.meters[0].serviceDescription
        );
        CSUtils.itShouldBe('Read type as printed', 'Estimate', response.embedded.meters[0].readTypeAsPrinted);
        CSUtils.itShouldBe('Deregulation status', 'delivery', response.embedded.meters[0].deregulationStatus);
        CSUtils.itShouldBe('recipient', 'Test Recipient', response.embedded.meters[0].serviceAddress.recipient);
        CSUtils.itShouldBe('street line1', '123 DOVER CV', response.embedded.meters[0].serviceAddress.streetLine1);
        CSUtils.itShouldBe('street line2', 'EDEN', response.embedded.meters[0].serviceAddress.streetLine2);
        CSUtils.itShouldBe('City', 'CHARLOTTE', response.embedded.meters[0].serviceAddress.city);
        CSUtils.itShouldBe('State', 'NC', response.embedded.meters[0].serviceAddress.state);
        CSUtils.itShouldBe('Country', 'US', response.embedded.meters[0].serviceAddress.country);
        CSUtils.itShouldBe('Postal code', '55347-1073', response.embedded.meters[0].serviceAddress.postalCode);
        CSUtils.itShouldBe(
            'Full address',
            '123 DOVER CV, EDEN, CHARLOTTE, NC, 55347-1073, US',
            response.embedded.meters[0].serviceAddress.fullAddress
        );
        CSUtils.itShouldBe('Address type', 'FULL', response.embedded.meters[0].serviceAddress.addressType);
        CSUtils.itShouldBe('Meter constant multiplier', 23, response.embedded.meters[0].meterConstantMultiplier);
        CSUtils.itShouldBe(
            'Previous meter constant multiplier',
            15,
            response.embedded.meters[0].previousMeterConstantMultiplier
        );
        CSUtils.itShouldBe('Meter conversion multiplier', 12, response.embedded.meters[0].meterConversionMultiplier);
        CSUtils.itShouldBe('Energy carry forward', 25, response.embedded.meters[0].energyCarryForward);
        CSUtils.itShouldBe('Energy new carry forward', 30, response.embedded.meters[0].energyNewCarryForward);
        CSUtils.itShouldBe('Energy anniversary date', null, response.embedded.meters[0].energyAnniversaryDate);
        CSUtils.itShouldBe('Line loss', 5, response.embedded.meters[0].lineLoss);
        CSUtils.itShouldBe('Grid point line loss', 5, response.embedded.meters[0].gridPointLineLoss);
        CSUtils.itShouldBe('Power factor', 3, response.embedded.meters[0].powerFactor);
        CSUtils.itShouldBe('Bulb type', 'Softlight', response.embedded.meters[0].bulbType);
        CSUtils.itShouldBe('Bulb Quantity', 5, response.embedded.meters[0].bulbQuantity);
        CSUtils.itShouldBe('Pipe type', 'Test pipe type', response.embedded.meters[0].pipeType);
        CSUtils.itShouldBe('Amount due', 23.00, response.embedded.meters[0].amountDue);
        CSUtils.itShouldBe('Amount due after due date', 15.00, response.embedded.meters[0].amountDueAfterDueDate);
        CSUtils.itShouldBe('Amount due before due date', 8.00, response.embedded.meters[0].amountDueBeforeDueDate);
        CSUtils.itShouldBe('Discount before due date', 7.00, response.embedded.meters[0].discountBeforeDueDate);
        CSUtils.itShouldBe('Previous balance', 82.00, response.embedded.meters[0].previousBalance);
        CSUtils.itShouldBe('Outstanding balance', 0, response.embedded.meters[0].outstandingBalance);
        CSUtils.itShouldBe('Total charges', -75.51, response.embedded.meters[0].totalCharges);
        CSUtils.itShouldBe('New charges', 81.00, response.embedded.meters[0].newCharges);
        CSUtils.itShouldBe('Customer number', '12345', response.embedded.meters[0].customerNumber);
        CSUtils.itShouldBe('Cycle number', '23455', response.embedded.meters[0].cycleNumber);
        CSUtils.itShouldBe('Facility number', '234567', response.embedded.meters[0].facilityNumber);
        CSUtils.itShouldBe('Facility name', 'Test facility', response.embedded.meters[0].facilityName);
        CSUtils.itShouldBe('Final bill notice', 'Final bill', response.embedded.meters[0].finalBillNotice);
        CSUtils.itShouldBe('Map number', '23424', response.embedded.meters[0].mapNumber);
        CSUtils.itShouldBe('Amount due by date', 22.00, response.embedded.meters[0].amountDueByDate);
        CSUtils.itShouldBe('Disconnect date', null, response.embedded.meters[0].disconnectDate);
        CSUtils.itShouldBe('Total usage', '377', response.embedded.meters[0].totalUsage);
        CSUtils.itShouldBe('Total usage unit', 'kWh', response.embedded.meters[0].totalUsageUnit);
        CSUtils.itShouldBe(
            'Usage created',
            '2022-04-01T19:54:45.000+00:00',
            response.embedded.meters[0].usages[0].createdDate
        );
        CSUtils.itShouldBe('Cited usage', null, response.embedded.meters[0].usages[0].citedUsage);
        CSUtils.itShouldBe('Measured usage', 377, response.embedded.meters[0].usages[0].measuredUsage);
        CSUtils.itShouldBe('Non coincidental usage', null, response.embedded.meters[0].usages[0].noncoincidentalUsage);
        CSUtils.itShouldBe('Hours of use', 15, response.embedded.meters[0].usages[0].hoursOfUse);
        CSUtils.itShouldBe('Load factor', 2, response.embedded.meters[0].usages[0].loadFactor);
        CSUtils.itShouldBe('Power factor', 2, response.embedded.meters[0].usages[0].powerFactor);
        CSUtils.itShouldBe('Previous usage', 890, response.embedded.meters[0].usages[0].previousUsage);
        CSUtils.itShouldBe('Meter reading raw', 8476, response.embedded.meters[0].usages[0].meterReadingRaw);
        CSUtils.itShouldBe('Meter reading delta', 23, response.embedded.meters[0].usages[0].meterReadingDelta);
        CSUtils.itShouldBe(
            'Meter reading raw previous',
            8099,
            response.embedded.meters[0].usages[0].meterReadingRawPrevious
        );
        CSUtils.itShouldBe(
            'Meter reading delta previous',
            25,
            response.embedded.meters[0].usages[0].meterReadingDeltaPrevious
        );
        CSUtils.itShouldBe('Number of days in period', 34, response.embedded.meters[0].usages[0].numberOfDaysInPeriod);
        CSUtils.itShouldBe('Pressure multiplier', 2, response.embedded.meters[0].usages[0].pressureMultiplier);
        CSUtils.itShouldBe(
            'Meter constant multiplier',
            23,
            response.embedded.meters[0].usages[0].meterConstantMultiplier
        );
        CSUtils.itShouldBe(
            'Meter conversion multiplier',
            24,
            response.embedded.meters[0].usages[0].meterConversionMultiplier
        );
        CSUtils.itShouldBe('Calorific value', 2300, response.embedded.meters[0].usages[0].calorificValue);
        CSUtils.itShouldBe('Load type', 'Test load', response.embedded.meters[0].usages[0].loadType);
        CSUtils.itShouldBe('Read type as printed', 'Estimate', response.embedded.meters[0].usages[0].readTypeAsPrinted);
        CSUtils.itShouldBe(
            'Previous read type as printed',
            'Actual',
            response.embedded.meters[0].usages[0].previousReadTypeAsPrinted
        );
        CSUtils.itShouldBe(
            'Rate or tariff actual name',
            'Test Tariff',
            response.embedded.meters[0].usages[0].rateOrTariffActualName
        );
        CSUtils.itShouldBe('Usage actual name', 'Total Energy', response.embedded.meters[0].usages[0].usageActualName);
        CSUtils.itShouldBe('Reading schedule', 'Every month', response.embedded.meters[0].usages[0].readingSchedule);
        CSUtils.itShouldBe('Outage block', 'none', response.embedded.meters[0].usages[0].outageBlock);
        CSUtils.itShouldBe('Meter read date', '2021-09-08', response.embedded.meters[0].usages[0].meterReadDate);
        CSUtils.itShouldBe('Previous read date', '2021-08-05', response.embedded.meters[0].usages[0].prevReadDate);
        CSUtils.itShouldBe(
            'Contribution status',
            'CONTRIBUTING',
            response.embedded.meters[0].usages[0].contributionStatus
        );
        CSUtils.itShouldBe('Usage unit', 'kWh', response.embedded.meters[0].usages[0].usageUnit);
        CSUtils.itShouldBe(
            'Meter reading delta usage unit',
            'kWh',
            response.embedded.meters[0].usages[0].meterReadingDeltaUsageUnit
        );
        CSUtils.itShouldBe(
            'Measurement type',
            'general_consumption',
            response.embedded.meters[0].usages[0].measurementType
        );
        CSUtils.itShouldBe('Meter read type', 'estimated', response.embedded.meters[0].usages[0].meterReadType);
        CSUtils.itShouldBe(
            'Previous meter read type',
            'actual',
            response.embedded.meters[0].usages[0].previousMeterReadType
        );
        CSUtils.itShouldBe(
            'Tariff name',
            'unknown_tariff',
            response.embedded.meters[0].usages[0].tariffRateComponents[0].tariffName
        );
        CSUtils.itShouldBe(
            'Tariff rate component type',
            'total',
            response.embedded.meters[0].usages[0].tariffRateComponents[0].tariffRateComponentType
        );
        CSUtils.itShouldBe(
            'Charges created',
            '2022-04-01T19:54:45.000+00:00',
            response.embedded.meters[0].charges[0].createdDate
        );
        CSUtils.itShouldBe('Charge amount', 11.68, response.embedded.meters[0].charges[0].chargeAmount);
        CSUtils.itShouldBe('Average unit cost', 28.00, response.embedded.meters[0].charges[0].averageUnitCost);
        CSUtils.itShouldBe(
            'Charge actual name',
            'On-Peak Energy ChSumme',
            response.embedded.meters[0].charges[0].chargeActualName
        );
        CSUtils.itShouldBe(
            'Charge group heading',
            'Test charge group',
            response.embedded.meters[0].charges[0].chargeGroupHeading
        );
        CSUtils.itShouldBe(
            'Charge name',
            'ch.energy_charge_on_peak',
            response.embedded.meters[0].charges[0].chargeName
        );
        CSUtils.itShouldBe('Life cycle stage', null, response.embedded.meters[0].charges[0].lifecycleStage);
        CSUtils.itShouldBe(
            'Charge amount currency',
            'USD',
            response.embedded.meters[0].charges[0].chargeAmountCurrency
        );
        CSUtils.itShouldBe('Charge rate currency', 'cent', response.embedded.meters[0].charges[0].chargeRateCurrency);
        CSUtils.itShouldBe('Measurement type', 'power', response.embedded.meters[0].charges[0].measurementType);
        CSUtils.itShouldBe('Usage unit', 'kWh', response.embedded.meters[0].charges[0].usageUnit);
        CSUtils.itShouldBe('Charge units used', 57, response.embedded.meters[0].charges[0].chargeUnitsUsed);
        CSUtils.itShouldBe('Charge rate', 0.20497, response.embedded.meters[0].charges[0].chargeRate);
        CSUtils.itShouldBe('Charge rate base', 7, response.embedded.meters[0].charges[0].chargeRateBase);
        CSUtils.itShouldBe('Charge rate adder', 5, response.embedded.meters[0].charges[0].chargeRateAdder);
        CSUtils.itShouldBe('Units per rate', 2, response.embedded.meters[0].charges[0].unitsPerRate);
        CSUtils.itShouldBe(
            'Additional rate multiplier',
            3,
            response.embedded.meters[0].charges[0].additionalRateMultiplier
        );
        CSUtils.itShouldBe(
            'Tariff name',
            'unknown_tariff',
            response.embedded.meters[0].charges[0].tariffRateComponents[0].tariffName
        );
        CSUtils.itShouldBe(
            'Tariff rate component type',
            'on_peak',
            response.embedded.meters[0].charges[0].tariffRateComponents[0].tariffRateComponentType
        );
        CSUtils.itShouldBe(
            'Tariff created',
            '2022-02-25T02:25:58.000+00:00',
            response.embedded.meters[0].charges[0].tariff.createdDate
        );
        CSUtils.itShouldBe('Tariff name', 'unknown_tariff', response.embedded.meters[0].charges[0].tariff.tariffName);
        CSUtils.itShouldBe(
            'Tariff provider alias',
            'XcelEnergy',
            response.embedded.meters[0].charges[0].tariff.providerAlias
        );
        CSUtils.itShouldBe(
            'Tariff provider name',
            'Xcel Energy',
            response.embedded.meters[0].charges[0].tariff.providerName
        );
        CSUtils.itShouldBe(
            'Contribution status',
            'CONTRIBUTING',
            response.embedded.meters[0].charges[0].contributionStatus
        );
        CSUtils.itShouldBe('Charge type', 'DEBIT', response.embedded.meters[0].charges[0].chargeType);
        CSUtils.itShouldBe(
            'meter link',
            'https://test.urjanet.com/utility/meters/1234abcd-401c-d3c9-9598-6ae1802271dd',
            response.embedded.meters[0].links.meter.href
        );
        CSUtils.itShouldBe(
            'Statement link',
            'https://test.urjanet.com/utility/statements/1234abcd-3a09-d0ec-a275-e2e53158f011',
            response.embedded.meters[0].links.statement.href
        );
        CSUtils.itShouldBe(
            'Self link',
            'https://test.urjanet.com/utility/meters/1234abcd-401c-d3c9-9598-6ae1802271dd/meterData?page=0&size=20',
            response.links.self.href
        );
        CSUtils.itShouldBe('Attributes of Page details', 0, response.page.numbers);
        CSUtils.itShouldBe('Attributes of Page details', 1, response.page.totalPages);
        CSUtils.itShouldBe('Attributes of Page details', 1, response.page.totalElements);
        CSUtils.itShouldBe('Attributes of Page details', 20, response.page.size);
    }

    @isTest
    static void retrieveMeterDetailsFailureTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'RetrieveMeterDetailsResponseFailure',
            400
        );
        Test.startTest();
        List<String> requestParams = new List<String>{ 'test-meter-Id' };
        RetrieveMeterDetailsResponse response = (RetrieveMeterDetailsResponse) new UrjanetApiClient()
            .getUrjanetResponse(
                UrjanetEnums.RequestType.RETRIEVE_METER_DETAILS,
                UrjanetEnums.ApiMethod.GET,
                requestParams
            );
        Test.stopTest();

        CSUtils.itShouldBe('Error message', '400 Bad request', response.errorMsg);
    }

    @isTest
    static void getUpdateUrlByCredentialTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('UpdateUrlByCredsResponse', 200);
        Test.startTest();
        List<String> requestParams = new List<String>{ 'test-credential-Id' };
        GetUpdateUrlByCredentialResponse response = (GetUpdateUrlByCredentialResponse) new UrjanetApiClient()
            .getUrjanetResponse(
                UrjanetEnums.RequestType.UPDATE_URL_BY_CREDENTIAL,
                UrjanetEnums.ApiMethod.GET,
                requestParams
            );
        Test.stopTest();

        CSUtils.itShouldBe(
            'Update Url',
            'https://connect.urjanet.com/TestUpdatelUrl?app=RECURRING_UTILITY',
            response.updateUrl
        );
        CSUtils.itShouldBe('Expiration ', '2022-05-06T02:42:25.366+00:00', response.expiration);
    }

    @isTest
    static void getUpdateUrlByCredentialFailureTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'UpdateUrlByCredsResponseFailure',
            400
        );
        Test.startTest();
        List<String> requestParams = new List<String>{ 'test-credential-Id' };
        GetUpdateUrlByCredentialResponse response = (GetUpdateUrlByCredentialResponse) new UrjanetApiClient()
            .getUrjanetResponse(
                UrjanetEnums.RequestType.UPDATE_URL_BY_CREDENTIAL,
                UrjanetEnums.ApiMethod.GET,
                requestParams
            );
        Test.stopTest();

        CSUtils.itShouldBe('Error message', '400 Bad request', response.errorMsg);
    }

    @isTest
    static void PostSiteTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('PostSiteResponse', 202);
        Test.startTest();
        List<String> requestParams = new List<String>{
            'San Ramon',
            'United States',
            'Office',
            '94583',
            'North West',
            '123789',
            'Urjanet Test',
            'NZC12345',
            'NorCal',
            'CA',
            '340 main st',
            'suite #13'
        };
        PostSiteResponse response = (PostSiteResponse) new UrjanetApiClient()
            .getUrjanetResponse(UrjanetEnums.RequestType.CREATE_SITE, UrjanetEnums.ApiMethod.POST, requestParams);
        Test.stopTest();

        CSUtils.itShouldBe('Urjanet Id', '1ece6d51-dd82-d644-8a08-d23d6f619b36', response.entityId);
        CSUtils.itShouldBe('Created Date ', '2022-06-08T02:45:54.539+00:00', response.createdDate);
    }

    @isTest
    static void postSiteFailureTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('PostSiteResponseFailure', 400);
        Test.startTest();
        List<String> requestParams = new List<String>{
            'San Ramon',
            'United States',
            'Office',
            '94583',
            'North West',
            '123789',
            'Urjanet Test',
            'NZC12345',
            'NorCal',
            'CA',
            '340 main st',
            'suite #13'
        };
        PostSiteResponse response = (PostSiteResponse) new UrjanetApiClient()
            .getUrjanetResponse(UrjanetEnums.RequestType.CREATE_SITE, UrjanetEnums.ApiMethod.POST, requestParams);
        Test.stopTest();

        CSUtils.itShouldBe('Error message', 'Site with the same Address already exists', response.errorMsg);
    }

    @isTest
    static void getArcadiaServiceProviderTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
            'ArcadiaServiceProviderResponse',
            200
        );
        Test.startTest();

        List<String> lstReqParams = new List<String>{ String.valueOf(20), String.valueOf(0) };
        GetArcadiaServiceProvidersResponse response = (GetArcadiaServiceProvidersResponse) new UrjanetApiClient()
            .getUrjanetResponse(UrjanetEnums.RequestType.LIST_PROVIDERS, UrjanetEnums.ApiMethod.GET, lstReqParams);
        Test.stopTest();

        CSUtils.itShouldBe('Number of Providers ', 2, response.embedded.providers.size());
        CSUtils.itShouldBe(
            'Provider Id',
            '03b89751-b5af-11e3-8311-22000aa40d1f',
            response.embedded.providers[0].providerId
        );
        CSUtils.itShouldBe('Provider Name', 'City of Oxnard, California', response.embedded.providers[0].providerName);
        CSUtils.itShouldBe(
            'Provider Website',
            'https://oxna-egov.aspgov.com/Click2GovCX/logonuser.html',
            response.embedded.providers[0].website
        );
        CSUtils.itShouldBe(
            'Provider Id',
            'da52b6e0-898b-11e3-ae56-22000aa40d1f',
            response.embedded.providers[1].providerId
        );
        CSUtils.itShouldBe('Provider Name', 'Georgia Power', response.embedded.providers[1].providerName);
        CSUtils.itShouldBe('Provider Website', 'https://georgia-power.com', response.embedded.providers[1].website);
    }

    @isTest
    static void getArcadiaServiceProviderFailureTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('GenericFailureMessageResponse', 400);
        Test.startTest();

        List<String> lstReqParams = new List<String>{ String.valueOf(20), String.valueOf(0) };
        GetArcadiaServiceProvidersResponse response = (GetArcadiaServiceProvidersResponse) new UrjanetApiClient()
            .getUrjanetResponse(UrjanetEnums.RequestType.LIST_PROVIDERS, UrjanetEnums.ApiMethod.GET, lstReqParams);
        Test.stopTest();

        CSUtils.itShouldBe('Error message', '400 Request Failed', response.errorMsg);
    }

    @isTest
    static void postBulkCredentialsTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('PostBulkCredentialsResponse', 202);
        Test.startTest();

        String jsonCredentialDetails = '[{"credentialName":"UnitTest1","userName1":"UnitTest1","password1":"Password12345","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"SupplierID","websiteURL":null},{"credentialName":"UnitTest2","userName1":"UnitTest2","password1":"Password12345","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"SupplierID"}]';
        List<String> requestParams = new List<String>{ jsonCredentialDetails };
        PostBulkCredentialsResponse response = (PostBulkCredentialsResponse) new UrjanetApiClient()
            .getUrjanetResponse(
                UrjanetEnums.RequestType.CREATE_BULK_CREDENTIALS,
                UrjanetEnums.ApiMethod.POST,
                requestParams
            );
        Test.stopTest();

        CSUtils.itShouldBe('Job Type', 'BULK_CREDENTIAL_UPLOAD', response.jobType);
        CSUtils.itShouldBe('Status', 'SCHEDULED', response.status);
        CSUtils.itShouldBe('Status Detail', 'Some Status Detail', response.statusDetail);
        CSUtils.itShouldBe('Job Results', 'Some Job Results', response.jobResults);
    }

    @isTest
    static void postBulkCredentialsFailureMessageTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('GenericFailureMessageResponse', 400);
        Test.startTest();

        String jsonCredentialDetails = '[{"credentialName":"UnitTest1","userName1":"UnitTest1","password1":"Password12345","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"SupplierID","websiteURL":null},{"credentialName":"UnitTest2","userName1":"UnitTest2","password1":"Password12345","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"SupplierID"}]';
        List<String> requestParams = new List<String>{ jsonCredentialDetails };
        PostBulkCredentialsResponse response = (PostBulkCredentialsResponse) new UrjanetApiClient()
            .getUrjanetResponse(
                UrjanetEnums.RequestType.CREATE_BULK_CREDENTIALS,
                UrjanetEnums.ApiMethod.POST,
                requestParams
            );
        Test.stopTest();

        CSUtils.itShouldBe('Error message', 'Server Down', response.errorMsg);
    }

    @isTest
    static void postBulkCredentialsFailureTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('GenericFailureResponse', 400);
        Test.startTest();

        String jsonCredentialDetails = '[{"credentialName":"UnitTest1","userName1":"UnitTest1","password1":"Password12345","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"SupplierID","websiteURL":null},{"credentialName":"UnitTest2","userName1":"UnitTest2","password1":"Password12345","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"SupplierID"}]';
        List<String> requestParams = new List<String>{ jsonCredentialDetails };
        PostBulkCredentialsResponse response = (PostBulkCredentialsResponse) new UrjanetApiClient()
            .getUrjanetResponse(
                UrjanetEnums.RequestType.CREATE_BULK_CREDENTIALS,
                UrjanetEnums.ApiMethod.POST,
                requestParams
            );
        Test.stopTest();

        CSUtils.itShouldBe('Error message', '400 Request Failed', response.errorMsg);
    }

    @isTest
    static void getUtilityStatementFilesTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('UtilityStatementFilesResponse', 200);
        Test.startTest();

        GetUtilityStatementFilesResponse response = (GetUtilityStatementFilesResponse) new UrjanetApiClient()
            .getUrjanetResponse(
                UrjanetEnums.RequestType.STATEMENT_FILES_BY_ENTITY_ID,
                UrjanetEnums.ApiMethod.GET,
                new List<String>{ 'FileId' }
            );
        Test.stopTest();
        CSUtils.itShouldBe('Number of Files ', 1, response.embedded.files.size());
        CSUtils.itShouldBe('Entity Id', '1edabf9f-90a6-dddd-b173-2e3846f367a4', response.embedded.files[0].entityId);
        CSUtils.itShouldBe('File Status', 'SUCCESS', response.embedded.files[0].fileStatus);
        CSUtils.itShouldBe(
            'File Name',
            'single-meter-with-sewer-YDI_69788-CityOfPortlandOR_1.pdf',
            response.embedded.files[0].fileName
        );
        CSUtils.itShouldBe('File Details', '(Some File Details)', response.embedded.files[0].fileDetails.toString());
    }

    @isTest
    static void getUtilityStatementFilesFailureTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('GenericFailureMessageResponse', 400);
        Test.startTest();

        GetUtilityStatementFilesResponse response = (GetUtilityStatementFilesResponse) new UrjanetApiClient()
            .getUrjanetResponse(
                UrjanetEnums.RequestType.STATEMENT_FILES_BY_ENTITY_ID,
                UrjanetEnums.ApiMethod.GET,
                new List<String>{ 'FileId' }
            );
        Test.stopTest();

        CSUtils.itShouldBe('Error message', '400 Request Failed', response.errorMsg);
    }
}
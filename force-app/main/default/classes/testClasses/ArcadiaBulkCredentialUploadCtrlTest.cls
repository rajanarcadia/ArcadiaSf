@isTest
public with sharing class ArcadiaBulkCredentialUploadCtrlTest {
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
        }
    }

    @isTest
    static void getArcadiaServiceProviders() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            Test.setMock(HttpCalloutMock.class, new ArcadiaServiceProvidersResponseMock());
            Test.startTest();
            List<GetArcadiaServiceProvidersResponse.ProviderDetails> lstResults = ArcadiaBulkCredentialUploadCtrl.getArcadiaProviders();
            CSUtils.itShouldBe('Two Service Providers Should return', 2, lstResults.size());
            Test.stopTest();
        }
    }

    @isTest
    static void createSalesforceCredentialsWithDifferentUniqueKeyAndWithDifferentCorrelationIdsTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        List<Supplier> lstSuppliers = [SELECT Id FROM Supplier LIMIT 1];
        System.runAs(adminUser) {
            Test.setMock(HttpCalloutMock.class, new ArcadiaServiceProvidersResponseMock());
            Test.startTest();
            ArcadiaBulkCredentialUploadService.BulkCredentialsCreationResponse response = ArcadiaBulkCredentialUploadCtrl.createSalesforceCredentials(
                '[{"credentialName":"UnitTest1","userName1":"UnitTest1","password1":"Password12345","correlationID":"correlationID1","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"' +
                    lstSuppliers[0].Id +
                    '","websiteURL":null},{"credentialName":"UnitTest2","userName1":"UnitTest2","password1":"Password12345","correlationID":"correlationID2","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"' +
                    lstSuppliers[0].Id +
                    '"}]'
            );
            CSUtils.itShouldBe('Two Utility Credentials should be created', 2, response.lstCredentials.size());
            CSUtils.itShouldBe('The Csv content is valid ', true, response.isValidCsv);

            List<UtilityCredential__c> lstCreds = [SELECT Id FROM UtilityCredential__c];
            CSUtils.itShouldBe('Two Credentials are expected to be returned ', 2, lstCreds.size());

            ArcadiaBulkCredentialUploadCtrl.deleteSalesforceCredentials(JSON.serialize(response.lstCredentials));
            lstCreds = [SELECT Id FROM UtilityCredential__c];
            CSUtils.itShouldBe('Two Credentials should have been deleted ', 0, lstCreds.size());
            Test.stopTest();
        }
    }

    @isTest
    static void createSalesforceCredentialsWithSameUniqueKeyAndWithDifferentCorrelationIdsTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        List<Supplier> lstSuppliers = [SELECT Id FROM Supplier LIMIT 1];
        System.runAs(adminUser) {
            Test.setMock(HttpCalloutMock.class, new ArcadiaServiceProvidersResponseMock());
            Test.startTest();
            ArcadiaBulkCredentialUploadService.BulkCredentialsCreationResponse response = ArcadiaBulkCredentialUploadCtrl.createSalesforceCredentials(
                '[{"credentialName":"UnitTest1","userName1":"UnitTest1","password1":"Password12345","correlationID":"correlationID1","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"' +
                    lstSuppliers[0].Id +
                    '","websiteURL":null},{"credentialName":"UnitTest1","userName1":"UnitTest1","password1":"Password12345","correlationID":"correlationID2","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"' +
                    lstSuppliers[0].Id +
                    '"}]'
            );
            CSUtils.itShouldBe('one Utility Credentials should be created', 1, response.lstCredentials.size());
            CSUtils.itShouldBe('The Csv content is valid ', true, response.isValidCsv);

            List<UtilityCredential__c> lstCreds = [SELECT Id FROM UtilityCredential__c];
            CSUtils.itShouldBe('one Credentials are expected to be returned ', 1, lstCreds.size());

            ArcadiaBulkCredentialUploadCtrl.deleteSalesforceCredentials(JSON.serialize(response.lstCredentials));
            lstCreds = [SELECT Id FROM UtilityCredential__c];
            CSUtils.itShouldBe('one Credentials should have been deleted ', 0, lstCreds.size());
            Test.stopTest();
        }
    }

    @isTest
    static void createSalesforceCredentialsWithDifferentUniqueKeyAndWithSameCorrelationIdsTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        List<Supplier> lstSuppliers = [SELECT Id FROM Supplier LIMIT 1];
        System.runAs(adminUser) {
            Test.setMock(HttpCalloutMock.class, new ArcadiaServiceProvidersResponseMock());
            Test.startTest();
            ArcadiaBulkCredentialUploadService.BulkCredentialsCreationResponse response = ArcadiaBulkCredentialUploadCtrl.createSalesforceCredentials(
                '[{"credentialName":"UnitTest1","userName1":"UnitTest1","password1":"Password12345","correlationID":"correlationID1","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"' +
                    lstSuppliers[0].Id +
                    '","websiteURL":null},{"credentialName":"UnitTest2","userName1":"UnitTest2","password1":"Password12345","correlationID":"correlationID1","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"' +
                    lstSuppliers[0].Id +
                    '"}]'
            );
            CSUtils.itShouldBe('one Utility Credentials should be created', 1, response.lstCredentials.size());
            CSUtils.itShouldBe('The Csv content is valid ', true, response.isValidCsv);

            List<UtilityCredential__c> lstCreds = [SELECT Id FROM UtilityCredential__c];
            CSUtils.itShouldBe('one Credentials are expected to be returned ', 1, lstCreds.size());

            ArcadiaBulkCredentialUploadCtrl.deleteSalesforceCredentials(JSON.serialize(response.lstCredentials));
            lstCreds = [SELECT Id FROM UtilityCredential__c];
            CSUtils.itShouldBe('one Credentials should have been deleted ', 0, lstCreds.size());
            Test.stopTest();
        }
    }

    @isTest
    static void createSalesforceCredentialsWithDifferentUniqueKeyAndWithNullCorrelationIdsTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        List<Supplier> lstSuppliers = [SELECT Id FROM Supplier LIMIT 1];
        System.runAs(adminUser) {
            Test.setMock(HttpCalloutMock.class, new ArcadiaServiceProvidersResponseMock());
            Test.startTest();
            ArcadiaBulkCredentialUploadService.BulkCredentialsCreationResponse response = ArcadiaBulkCredentialUploadCtrl.createSalesforceCredentials(
                '[{"credentialName":"UnitTest1","userName1":"UnitTest1","password1":"Password12345","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"' +
                    lstSuppliers[0].Id +
                    '","websiteURL":null},{"credentialName":"UnitTest2","userName1":"UnitTest2","password1":"Password12345","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"' +
                    lstSuppliers[0].Id +
                    '"}]'
            );
            CSUtils.itShouldBe('Utility Credentials should be created', 2, response.lstCredentials.size());
            CSUtils.itShouldBe('The Csv content is valid ', true, response.isValidCsv);

            List<UtilityCredential__c> lstCreds = [SELECT Id FROM UtilityCredential__c];
            CSUtils.itShouldBe('Credentials are expected to be returned ', 2, lstCreds.size());
            Test.stopTest();
        }
    }

    @isTest
    static void createInvalidSalesforceCredentialsTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            Test.setMock(HttpCalloutMock.class, new ArcadiaServiceProvidersResponseMock());
            Test.startTest();
            ArcadiaBulkCredentialUploadService.BulkCredentialsCreationResponse response = ArcadiaBulkCredentialUploadCtrl.createSalesforceCredentials(
                '[{"credentialName":"","userName1":"UnitTest1","password1":"Password12345","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa4FAKE","salesforceSupplierID":"0eM5D00000000WFAKE","websiteURL":null},' +
                    '{"credentialName":"UnitTest2","userName1":"","password1":"Password12345","arcadiaServiceProviderID":"fakeb6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"fakeId"},' +
                    '{"credentialName":"UnitTest3","userName1":"UnitTest1","password1":"","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa4FAKE","salesforceSupplierID":"0eM5D00000000WFAKE","websiteURL":null}]'
            );
            Test.stopTest();
            CSUtils.itShouldBe('No Valid Credentials', 0, response.lstCredentials.size());
            CSUtils.itShouldBe('Empty rows', '2, 3, 4', response.strEmptyRows);
            CSUtils.itShouldBe('Invalid Provider Rows ', '2, 3, 4', response.strInvalidProviderRows);
            CSUtils.itShouldBe('Invalid Supplier Rows ', '2, 3, 4', response.strInvalidSupplierRows);
        }
    }

    @isTest
    static void uploadCredentialsTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        List<Supplier> lstSuppliers = [SELECT Id FROM Supplier LIMIT 1];
        System.runAs(adminUser) {
            Test.setMock(HttpCalloutMock.class, new PostBulkCredentialsResponseMock());
            Test.startTest();
            boolean isUploaded = ArcadiaBulkCredentialUploadCtrl.uploadBulkCredentials(
                '[{"credentialName":"UnitTest1","userName1":"UnitTest1","password1":"Password12345","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"' +
                    lstSuppliers[0].Id +
                    '","websiteURL":null},{"credentialName":"UnitTest2","userName1":"UnitTest2","password1":"Password12345","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"' +
                    lstSuppliers[0].Id +
                    '"}]'
            );
            CSUtils.itShouldBe('Credential Should be Uploaded Succesfully ', true, isUploaded);
            Test.stopTest();
        }
    }
    @isTest
    static void uploadCredentialsTestErrorResponse() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        List<Supplier> lstSuppliers = [SELECT Id FROM Supplier LIMIT 1];
        System.runAs(adminUser) {
            StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
                'GenericFailureMessageResponse',
                400
            );

            Test.startTest();
            try {
                boolean isUploaded = ArcadiaBulkCredentialUploadCtrl.uploadBulkCredentials(
                    '[{"credentialName":"UnitTest1","userName1":"UnitTest1","password1":"Password12345","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"' +
                        lstSuppliers[0].Id +
                        '","websiteURL":null},{"credentialName":"UnitTest2","userName1":"UnitTest2","password1":"Password12345","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"' +
                        lstSuppliers[0].Id +
                        '"}]'
                );
            } catch (Exception e) {
                CSUtils.itShouldBe(
                    'Exception message ',
                    'We have run into an error. Please contact your administrator. Error Code: 400',
                    e.getMessage()
                );
            }
            Test.stopTest();
        }
    }
    @isTest
    static void uploadCredentialsTestExceptionResponse() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        List<Supplier> lstSuppliers = [SELECT Id FROM Supplier LIMIT 1];
        System.runAs(adminUser) {
            StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock(
                'GenericFailureMessageResponse',
                500
            );

            Test.startTest();
            try {
                boolean isUploaded = ArcadiaBulkCredentialUploadCtrl.uploadBulkCredentials(
                    '[{"credentialName":"UnitTest1","userName1":"UnitTest1","password1":"Password12345","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"' +
                        lstSuppliers[0].Id +
                        '","websiteURL":null},{"credentialName":"UnitTest2","userName1":"UnitTest2","password1":"Password12345","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"' +
                        lstSuppliers[0].Id +
                        '"}]'
                );
                List<Log__c> logAfterAPICall = [SELECT Id, Message__c FROM Log__c LIMIT 1];
                CSUtils.itShouldBe('Error message', '400 Request Failed', logAfterAPICall[0].Message__c.trim());
                CSUtils.itShouldBe('Credential Upload', false, isUploaded);
            } catch (Exception e) {
                CSUtils.itShouldBe(
                    'Exception message ',
                    'We have run into an error. Please contact your administrator. Error Code: 400',
                    e.getMessage()
                );
            }

            Test.stopTest();
        }
    }
    @isTest
    static void duplicateCredentialsTest() {
        UtilityCredential__c credential = new UtilityCredential__c(
            Name = 'Test Utility Credential',
            CorrelationId__c = 'TestCorrelationId',
            Username__c = 'UnitTest1 ',
            ArcadiaServiceProviderId__c = 'da52b6e0-898b-11e3-ae56-22000aa40d1f'
        );
        insert credential;

        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];

        List<Supplier> lstSuppliers = [SELECT Id FROM Supplier LIMIT 1];
        System.runAs(adminUser) {
            Test.setMock(HttpCalloutMock.class, new ArcadiaServiceProvidersResponseMock());
            Test.startTest();
            ArcadiaBulkCredentialUploadService.BulkCredentialsCreationResponse response = ArcadiaBulkCredentialUploadCtrl.createSalesforceCredentials(
                '[{"credentialName":"UnitTest1","userName1":"UnitTest1 ","password1":"Password12345","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"' +
                    lstSuppliers[0].Id +
                    '","websiteURL":null},{"credentialName":"UnitTest2","userName1":"UnitTest2","password1":"Password12345","arcadiaServiceProviderID":"da52b6e0-898b-11e3-ae56-22000aa40d1f","salesforceSupplierID":"' +
                    lstSuppliers[0].Id +
                    '"}]'
            );
            Test.stopTest();
            List<UtilityCredential__c> creds = [SELECT Id, Name FROM UtilityCredential__c];
            CSUtils.itShouldBe('Number of records in Log Object', 2, creds.size());
            // Only 1 should be created as the other one is duplicate.
            CSUtils.itShouldBe('Cred 1 Name', 'Test Utility Credential', creds[0].Name.trim());
            CSUtils.itShouldBe('Cred 2 Name', 'UnitTest2', creds[1].Name.trim());
        }
    }
}
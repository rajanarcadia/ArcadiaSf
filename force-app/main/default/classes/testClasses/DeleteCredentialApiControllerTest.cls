@isTest
public class DeleteCredentialApiControllerTest {
    @testSetup
    static void testSetupMethod() {
        User adminUser = TestUtility.createUserAdmin('arcadiaAdmin1@test.com');
        System.runAs(adminUser) {
            UtilityCredential__c cred = new UtilityCredential__c(
                UrjanetId__c = TestUtility.CREDENTIAL_ID,
                CorrelationId__c = 'test-correlation-Id',
                Name = 'Test Cred'
            );
            insert cred;
            UtilityAccount__c utilityAccount = new UtilityAccount__c();
            utilityAccount.UrjanetId__c = 'AccountId';
            utilityAccount.UtilityCredential__c = cred.Id;
            insert utilityAccount;
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
            Utility_Account_Meter_Relation__c accountMeter = new Utility_Account_Meter_Relation__c();
            accountMeter.Utility_Account__c = utilityAccount.Id;
            accountMeter.Utility_Meter__c = meter.Id;
            insert accountMeter;
        }
    }
    @isTest
    static void testdeleteCredentialMethod() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityCredential__c cred = [SELECT Id, Name, UrjanetId__c FROM UtilityCredential__c LIMIT 1];
            TestUtility.getStaticResourceCalloutMock('DeleteCredentialApiResponse', 202);
            DeletePlugApiResponse.DeleteApiUiResponse response = new DeletePlugApiResponse.DeleteApiUiResponse();
            Test.startTest();
            try {
                response = DeleteCredentialApiController.deleteCredentialMethod(
                    cred.Id,
                    UrjanetConstants.DELETE_IN_BOTH
                );
            } catch (Exception e) {
            }
            Test.stopTest();
            CSUtils.itShouldBe(
                'Status should not be null becausing not mocking the disable response',
                null,
                response.statusCode
            );
        }
    }
    @isTest
    static void testdeleteCredentialOnlyinNZCMethod() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityCredential__c cred = [SELECT Id, Name, UrjanetId__c FROM UtilityCredential__c LIMIT 1];
            DeletePlugApiResponse.DeleteApiUiResponse response = new DeletePlugApiResponse.DeleteApiUiResponse();
            Test.startTest();
            try {
                response = DeleteCredentialApiController.deleteCredentialMethod(
                    cred.Id,
                    UrjanetConstants.DELETE_IN_SFDC
                );
            } catch (Exception e) {
            }
            Test.stopTest();
            List<UtilityCredential__c> creds = [
                SELECT Id, Name, UrjanetId__c
                FROM UtilityCredential__c
                WHERE Id = :cred.Id
                LIMIT 1
            ];
            CSUtils.itShouldBe('Credential got Deleted so no Credential is Present', true, creds.isEmpty());
        }

    }
    @isTest
    static void testdeleteCredentialWithOutArcadiaIdMethod() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityCredential__c cred = new UtilityCredential__c(
                CorrelationId__c = 'test-correlation-Id-2',
                Name = 'Test Cred 2'
            );
            insert cred;
            TestUtility.getStaticResourceCalloutMock('DeleteCredentialApiResponse', 202);
            DeletePlugApiResponse.DeleteApiUiResponse response = new DeletePlugApiResponse.DeleteApiUiResponse();
            Test.startTest();
            try {
                response = DeleteCredentialApiController.deleteCredentialMethod(
                    cred.Id,
                    UrjanetConstants.DELETE_IN_BOTH
                );
            } catch (Exception e) {
            }
            Test.stopTest();
            CSUtils.itShouldBe(
                'Status should  be Failure becausing there is no Arcadia ID',
                UrjanetConstants.FAILURE_MESSAGE,
                response.statusCode
            );
        }
    }
    @isTest
    static void testDeletecredentialApiSuccessCallout() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityCredential__c cred = [SELECT Id, Name, UrjanetId__c FROM UtilityCredential__c LIMIT 1];
            QueueHttpMock mock = new QueueHttpMock();
            HttpResponse tokenResponse = new HttpResponse();
            tokenResponse.setHeader('Content-Type', 'application/json');
            String tokenJson = '{"message": "Authentication Successful","token": "crd_1eeadfa0-95c0-da3a-97d2-6e017a462c16", "status": "200","type": "Bearer"}';
            tokenResponse.setBody(tokenJson);
            tokenResponse.setStatusCode(200);
            HttpResponse disableResponse = new HttpResponse();
            disableResponse.setHeader('Content-Type', 'application/json');
            String disableJson = '{"correlationId": null,"id": "crd_1eeadfa0-95c0-da3a-97d2-6e017a462c16", "status": "OK","statusDetail": "NO_ACTION_REQUIRED"}';
            disableResponse.setBody(disableJson);
            disableResponse.setStatusCode(202);
            HttpResponse tokenResponse2 = new HttpResponse();
            tokenResponse2.setHeader('Content-Type', 'application/json');
            String tokenJson2 = '{"message": "Authentication Successful","token": "crd_1eeadfa0-95c0-da3a-97d2-6e017a462c16", "status": "200","type": "Bearer"}';
            tokenResponse2.setBody(tokenJson2);
            tokenResponse2.setStatusCode(200);
            HttpResponse deleteResponse = new HttpResponse();
            String deleteJson =
                '{' +
                '"credentialId": "crd_1eeae12b-41c4-d5f7-97d2-6e017a462c16",' +
                '"id": "del_1eeaeb3b-617d-dc5b-ac7a-aaaaf6a2235d",' +
                '"status": "SCHEDULED"' +
                '}';
            deleteResponse.setHeader('Content-Type', 'application/json');
            deleteResponse.setBody(deleteJson);
            deleteResponse.setStatusCode(200);
            mock.addResponse(tokenResponse);
            mock.addResponse(disableResponse);
            mock.addResponse(tokenResponse2);
            mock.addResponse(deleteResponse);
            Test.setMock(HttpCalloutMock.class, mock);
            DeletePlugApiResponse.DeleteApiUiResponse response = new DeletePlugApiResponse.DeleteApiUiResponse();
            Test.startTest();
            try {
                response = DeleteCredentialApiController.deleteCredentialApiCallout(cred.UrjanetId__c);
            } catch (Exception e) {
            }
            Test.stopTest();
            CSUtils.itShouldNotBe('Status should not be null', null, response.statusCode);
            CSUtils.itShouldBe('Status should be SCHEDULED', UrjanetConstants.SUCCESS_MESSAGE, response.statusCode);
        }

    }
    @isTest
    static void testDeletecredentialApiSuccessWithLog() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityCredential__c cred = [SELECT Id, Name, UrjanetId__c FROM UtilityCredential__c LIMIT 1];
            Credential_Deletion_Log__c delLog = DeleteCredentialApiController.prepareCredentialDeletionLogRecord(
                cred.UrjanetId__c,
                '1eeaeb3b-617d-dc5b-ac7a-aaaaf6a2235d',
                ''
            );
            insert delLog;
            DeletePlugApiResponse.DeleteApiUiResponse response = new DeletePlugApiResponse.DeleteApiUiResponse();
            Test.startTest();
            try {
                response = DeleteCredentialApiController.deleteCredentialApiCallout(cred.UrjanetId__c);
            } catch (Exception e) {
            }
            Test.stopTest();
            CSUtils.itShouldNotBe('Status should not be null', null, response.statusCode);
            CSUtils.itShouldBe('Status should be SCHEDULED', UrjanetConstants.SUCCESS_MESSAGE, response.statusCode);
        }

    }
    @isTest
    static void testDeletecredentialApiFailureCallout() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityCredential__c cred = [SELECT Id, Name, UrjanetId__c FROM UtilityCredential__c LIMIT 1];
            TestUtility.getStaticResourceCalloutMock('DeleteCredentialApiFailureResponse', 400);
            DeletePlugApiResponse.DeleteApiUiResponse response = new DeletePlugApiResponse.DeleteApiUiResponse();
            Test.startTest();
            try {
                response = DeleteCredentialApiController.deleteCredentialApiCallout(cred.UrjanetId__c);
            } catch (Exception e) {
            }
            Test.stopTest();
            CSUtils.itShouldBe('Status should be null because of Thrown Exception', null, response.statusCode);
        }

    }
    @isTest
    static void testDeletecredentialApiFailureCallout3() {
        User adminUser = [SELECT Id FROM User WHERE email = 'arcadiaAdmin1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityCredential__c cred = [SELECT Id, Name, UrjanetId__c FROM UtilityCredential__c LIMIT 1];
            DeleteCredentialResponseParser parser = new DeleteCredentialResponseParser();
            Test.startTest();
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('[{"correlationId":""}]');
            UrjanetResponse res = new UrjanetResponse();
            try {
                res = parser.parseResponse(response);
            } catch (Exception e) {
            }
            Test.stopTest();
            CSUtils.itShouldBe(
                'Error message should contain Malformed JSON:',
                true,
                res.ex.getMessage().contains('Malformed JSON:')
            );
        }

    }
}
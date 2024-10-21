@isTest
public class DisableCredentialApiControllerTest {
    @testSetup
    static void testSetupMethod() {
        UtilityCredential__c cred = new UtilityCredential__c();
        cred.UrjanetId__c = TestUtility.CREDENTIAL_ID;
        cred.CorrelationId__c = 'test-correlation-Id';
        cred.Name = 'Test Cred';
        insert cred;
    }

    @isTest
    static void testDisableCredentialApiSuccessCallout() {
        UtilityCredential__c cred = [SELECT Id, Name, UrjanetId__c FROM UtilityCredential__c LIMIT 1];

        TestUtility.getStaticResourceCalloutMock('DisableCredentialApiResponse', 202);

        Test.startTest();
        DisablePlugApiResponse response = DisableCredentialApiController.disableCredentialApiCallout(cred.UrjanetId__c);
        Test.stopTest();

        CSUtils.itShouldBe('Status should be OK ', 'OK', response.status);
        CSUtils.itShouldBe('statusDetail should be  NO_ACTION_REQUIRED', 'NO_ACTION_REQUIRED', response.statusDetail);
    }

    @isTest
    static void testDisableCredentialApiFailureCallout() {
        UtilityCredential__c cred = [SELECT Id, Name, UrjanetId__c FROM UtilityCredential__c LIMIT 1];

        TestUtility.getStaticResourceCalloutMock('DisableCredentialApiResponse', 400);
        DisablePlugApiResponse response = new DisablePlugApiResponse();
        Test.startTest();
        try {
            response = DisableCredentialApiController.disableCredentialApiCallout(cred.UrjanetId__c);
        } catch (Exception e) {
        }
        Test.stopTest();
        CSUtils.itShouldNotBe('response should not be null ', null, response);
        CSUtils.itShouldBe('response should be null ', null, response.status);
        CSUtils.itShouldBe('response should be null ', null, response.statusDetail);
    }

    @isTest
    static void testDisableCredentialApiFailureCallout2() {
        UtilityCredential__c cred = [SELECT Id, Name, UrjanetId__c FROM UtilityCredential__c LIMIT 1];

        DisableCredentialResponseParser parser = new DisableCredentialResponseParser();
        Test.startTest();
        HttpResponse response = new HttpResponse();
        response.setStatusCode(202);
        response.setBody('[{"correlationId":""]}');
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
/**
 * Created by Alagu on 5/21/22.
 */

@IsTest
private class UrjanetCanvasAppControllerTest {
    @IsTest
    static void getInitialCredentialLinkWithoutIdTest() {
        String orgId = 'test org Id';
        String name = 'test correlation';
        User adminUser = TestUtility.createUserAdmin('urjanetAdmin@urjanettest.com');
        System.runAs(adminUser) {
            UtilityCredential__c utilityCredential = new UtilityCredential__c(Name = name);
            insert utilityCredential;
            UrjanetSettings__c settings = new UrjanetSettings__c();
            settings.OrganizationId__c = orgId;
            insert settings;

            Test.startTest();
            ApexPages.currentPage().getParameters().put('id', String.valueOf(utilityCredential.Id));
            UrjanetCanvasAppController controller = new UrjanetCanvasAppController();
            Test.stopTest();
            String initialCredentialLink =
                '{"path":"/test org Id/canvas?correlationId=NZC-ARC-' +
                utilityCredential.Id +
                '&hideFinalButtons=true&salesforce=true"}';

            CSutils.itShouldBe('Initial credential link', initialCredentialLink, controller.pathString);
        }
    }

    @IsTest
    static void getInitialCredentialLinkWithIdTest() {
        String orgId = 'test org Id';
        String correlationId = 'test correlation Id';
        User adminUser = TestUtility.createUserAdmin('urjanetAdmin@urjanettest.com');
        System.runAs(adminUser) {
            UtilityCredential__c utilityCredential = new UtilityCredential__c(CorrelationId__c = correlationId);
            insert utilityCredential;
            UrjanetSettings__c settings = new UrjanetSettings__c();
            settings.OrganizationId__c = orgId;
            insert settings;

            Test.startTest();
            ApexPages.currentPage().getParameters().put('id', String.valueOf(utilityCredential.Id));
            UrjanetCanvasAppController controller = new UrjanetCanvasAppController();
            Test.stopTest();
            String initialCredentialLink =
                '{"path":"/test org Id/canvas?correlationId=test+correlation+Id' +
                '&hideFinalButtons=true&salesforce=true"}';

            CSutils.itShouldBe('Initial credential link', initialCredentialLink, controller.pathString);
        }
    }

    @IsTest
    static void getNullCredentialLinkTest() {
        String orgId = 'test org Id';
        String correlationId = 'test correlation Id';
        User adminUser = TestUtility.createUserAdmin('urjanetAdmin@urjanettest.com');
        System.runAs(adminUser) {
            UtilityCredential__c utilityCredential = new UtilityCredential__c(
                CorrelationId__c = correlationId,
                Status__c = UrjanetConstants.CREDENTIAL_STATUS
            );
            insert utilityCredential;

            UrjanetSettings__c settings = new UrjanetSettings__c();
            settings.OrganizationId__c = orgId;
            insert settings;

            Test.startTest();
            ApexPages.currentPage().getParameters().put('id', String.valueOf(utilityCredential.Id));
            UrjanetCanvasAppController controller = new UrjanetCanvasAppController();
            Test.stopTest();

            CSutils.itShouldBe('Null Credential Link', '{"path":null}', controller.pathString);
        }
    }

    @IsTest
    static void getAlternateCredentialLinkTest() {
        StaticResourceCalloutMock mock = TestUtility.getStaticResourceCalloutMock('UpdateUrlByCredsResponse', 200);
        String orgId = 'test org Id';
        String correlationId = 'test correlation Id';
        String updateUrl = '/TestUpdatelUrl?app=RECURRING_UTILITY';
        User adminUser = TestUtility.createUserAdmin('urjanetAdmin@urjanettest.com');
        System.runAs(adminUser) {
            UtilityCredential__c utilityCredential = new UtilityCredential__c(
                CorrelationId__c = correlationId,
                Status__c = 'OK',
                UrjanetId__c = 'Test Urjanet Id'
            );
            insert utilityCredential;

            UrjanetSettings__c settings = new UrjanetSettings__c();
            settings.OrganizationId__c = orgId;
            insert settings;

            String recredentialLink = '{"path":"' + updateUrl + '&hideFinalButtons=true&salesforce=true"}';

            Test.startTest();
            ApexPages.currentPage().getParameters().put('id', String.valueOf(utilityCredential.Id));
            UrjanetCanvasAppController controller = new UrjanetCanvasAppController();
            Test.stopTest();

            CSutils.itShouldBe('Null Credential Link', recredentialLink, controller.pathString);
        }
    }

    @IsTest
    static void updateCredentialStatus() {
        String orgId = 'test org Id';
        String correlationId = 'test correlation Id';
        User adminUser = TestUtility.createUserAdmin('urjanetAdmin@urjanettest.com');
        System.runAs(adminUser) {
            UtilityCredential__c utilityCredential = new UtilityCredential__c(CorrelationId__c = correlationId);
            insert utilityCredential;

            UrjanetSettings__c settings = new UrjanetSettings__c();
            settings.OrganizationId__c = orgId;
            insert settings;

            Test.startTest();
            ApexPages.currentPage().getParameters().put('id', String.valueOf(utilityCredential.Id));
            UrjanetCanvasAppController controller = new UrjanetCanvasAppController();
            controller.updateCredentialStatus();
            Test.stopTest();

            List<UtilityCredential__c> credentialList = [SELECT Id, Status__c FROM UtilityCredential__c LIMIT 1];

            CSutils.itShouldBe(
                'Utility Credential Status',
                UrjanetConstants.CREDENTIAL_STATUS,
                credentialList[0].Status__c
            );
        }
    }
}
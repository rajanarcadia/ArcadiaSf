@isTest
public with sharing class UtilityCredentialDomainTest {
    @TestSetup
    static void makeData() {
        User adminUser = TestUtility.createUserAdmin('urjanetAdmin@urjanettest.com');
    }

    @IsTest
    public static void utilityCredentialInsertTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityCredential__c credential = new UtilityCredential__c();
            credential.Name = 'Test Utility Credential';
            Test.startTest();
            insert credential;
            Test.stopTest();
            UtilityCredential__c credentialQueried = [
                SELECT Id, CorrelationId__c
                FROM UtilityCredential__c
                WHERE Id = :credential.Id
            ];
            CSUtils.itShouldBe(
                'Utility Credential Correlation Id ',
                'NZC-ARC-' + credential.Id,
                credentialQueried.CorrelationId__c
            );
        }
    }

    @IsTest
    public static void utilityCredentialUpdateTest() {
        User adminUser = [SELECT Id FROM User WHERE email = 'urjanetAdmin@urjanettest.com' LIMIT 1];
        System.runAs(adminUser) {
            UtilityCredential__c credential = new UtilityCredential__c();
            credential.Name = 'Test Utility Credential';
            insert credential;
            Test.startTest();
            credential.CorrelationId__c = '';
            update credential;
            Test.stopTest();
            UtilityCredential__c credentialQueried = [
                SELECT Id, CorrelationId__c
                FROM UtilityCredential__c
                WHERE Id = :credential.Id
            ];
            CSUtils.itShouldBe(
                'Utility Credential Correlation Id ',
                'NZC-ARC-' + credentialQueried.Id,
                credentialQueried.CorrelationId__c
            );
        }
    }
}
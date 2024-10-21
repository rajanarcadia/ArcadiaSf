@isTest
private class ArcadiaGenericControllerTest {
    @isTest
    static void testHandleException() {
        String testClass = 'ArcadiaGenericControllerTest';
        String testValue = 'test value';

        Exception testException = null;

        Test.startTest();
        try {
            try {
                throw new GenericControllerTestException(testValue);
            } catch (Exception e1) {
                throw ArcadiaGenericController.handleException(testClass, e1);
            }
        } catch (Exception e2) {
            testException = e2;
        }
        Test.stopTest();

        System.assertNotEquals(null, testException, 'Expected testException not null');
        System.assertEquals(
            true,
            testException instanceof ArcadiaGenericController.GenericControllerException,
            'Expected type ArcadiaGenericControllerException'
        );

        Log__c log = [SELECT ClassName__c, Message__c FROM Log__c LIMIT 1];
        System.assertEquals(testClass, log.ClassName__c, 'ClassName did not match.');
        System.assertEquals(testValue, log.Message__c, 'Message did not match.');
    }

    @isTest
    static void testHandleExceptionMap() {
        String testClass = 'ArcadiaGenericControllerTest';
        String testValue = 'test value';
        Map<String, String> testMap = new Map<String, String>{ 'testKey' => 'testValue' };

        Exception testException = null;

        Test.startTest();
        try {
            try {
                throw new ArcadiaGenericController.GenericControllerException(testValue);
            } catch (Exception e1) {
                throw ArcadiaGenericController.handleException(testClass, e1, testMap);
            }
        } catch (Exception e2) {
            testException = e2;
        }
        Test.stopTest();

        System.assertNotEquals(null, testException, 'Expected testException not null');
        System.assertEquals(
            true,
            testException instanceof ArcadiaGenericController.GenericControllerException,
            'Expected type GenericControllerException'
        );
        System.assertEquals('test value', testException.getMessage(), 'Expected Message to match');
    }

    @isTest
    static void testHandleExceptionMapArcadiaCalloutServiceException() {
        String testClass = 'ArcadiaGenericControllerTest';
        String testValue = 'test value';
        String testCode = 'test Code';
        Map<String, String> testMap = new Map<String, String>{ 'testKey' => 'testValue' };

        Exception testException = null;

        Test.startTest();
        try {
            try {
                throw new ArcadiaCalloutServiceException(testValue, testCode);
            } catch (Exception e1) {
                throw ArcadiaGenericController.handleException(testClass, e1, testMap);
            }
        } catch (Exception e2) {
            testException = e2;
        }
        Test.stopTest();

        System.assertNotEquals(null, testException, 'Expected testException not null');
        System.assertEquals(
            true,
            testException instanceof ArcadiaGenericController.GenericControllerException,
            'Expected type GenericControllerException'
        );
        System.assertEquals(
            'We have run into an error. Please contact your administrator. Error Code: test Code',
            testException.getMessage(),
            'Expected Message to match'
        );
    }

    @isTest
    static void testhandleDMLErrorsSaveResult() {
        Database.SaveResult sr = (Database.SaveResult) JSON.deserialize(
            '{"success":false,"errors":[{"message":"You cannot do this.","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}',
            Database.SaveResult.class
        );
        Exception testException = null;
        Test.startTest();
        try {
            ArcadiaGenericController.handleDMLErrors(sr);
        } catch (Exception e2) {
            testException = e2;
        }
        Test.stopTest();
        System.assertNotEquals(null, testException, 'Expected testException not null');
        System.assertEquals(
            true,
            testException instanceof ArcadiaGenericController.GenericDMLException,
            'Expected type GenericDMLException'
        );
        System.assertEquals(
            '["FIELD_CUSTOM_VALIDATION_EXCEPTION : You cannot do this."]',
            testException.getMessage(),
            'Expected Message to match'
        );
    }

    @isTest
    static void testhandleDMLErrorsUpsertResult() {
        Database.UpsertResult sr = (Database.UpsertResult) JSON.deserialize(
            '{"success":false,"errors":[{"message":"You cannot do this.","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}',
            Database.UpsertResult.class
        );
        Exception testException = null;
        Test.startTest();
        try {
            ArcadiaGenericController.handleDMLErrors(sr);
        } catch (Exception e2) {
            testException = e2;
        }
        Test.stopTest();
        System.assertNotEquals(null, testException, 'Expected testException not null');
        System.assertEquals(
            true,
            testException instanceof ArcadiaGenericController.GenericDMLException,
            'Expected type GenericDMLException'
        );
        System.assertEquals(
            '["FIELD_CUSTOM_VALIDATION_EXCEPTION : You cannot do this."]',
            testException.getMessage(),
            'Expected Message to match'
        );
    }
    public class GenericControllerTestException extends Exception {
    }
}
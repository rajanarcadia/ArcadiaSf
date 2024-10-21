@IsTest
public with sharing class ArcadiaCalloutServiceExceptionTest {
    @IsTest
    static void constructorStringExceptionString() {
        String message = 'test message';
        String errorCode = 'test error code';
        Exception e = new ArcadiaCalloutServiceException('test', '');

        Test.startTest();
        ArcadiaCalloutServiceException ex = new ArcadiaCalloutServiceException(message, e, errorCode);
        Test.stopTest();

        System.assertEquals(message, ex.getMessage(), 'Message did not match');
        System.assertEquals(errorCode, ex.errorCode, 'Error code did not match');
        System.assertEquals(e.getMessage(), ex.getCause().getMessage(), 'Inner Exception did not match');
    }

    @IsTest
    static void constructorStringString() {
        String message = 'test message';
        String errorCode = 'test error code';

        Test.startTest();
        ArcadiaCalloutServiceException ex = new ArcadiaCalloutServiceException(message, errorCode);
        Test.stopTest();

        System.assertEquals(message, ex.getMessage(), 'Message did not match');
        System.assertEquals(errorCode, ex.errorCode, 'Error code did not match');
    }
}
@isTest
private class LoggerTest {
    @isTest
    static void testSimpleLog() {
        Test.startTest();

        Logger logInstance = Logger.getInstance();
        logInstance.log('LoggerTest', 'Simple log test');

        Test.stopTest();

        List<Log__c> logs = [SELECT ClassName__c, Level__c, Message__c, User__c FROM Log__c];
        System.assertEquals(1, logs.size(), 'Number of logs is not 1');
        System.assertEquals('LoggerTest', logs[0].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('ERROR', logs[0].Level__c, 'Level of Log is not ERROR');
        System.assertEquals('Simple log test', logs[0].Message__c, 'Message of Log is not correct');
        System.assertEquals(UserInfo.getUserId(), logs[0].User__c, 'User of Log is not correct');
    }

    @isTest
    static void testSimpleLogWithTitle() {
        Test.startTest();

        Logger logInstance = Logger.getInstance();
        logInstance.log('LoggerTest', 'Log Title test', Logger.Level.ERROR, 'Simple log test');

        Test.stopTest();

        List<Log__c> logs = [SELECT ClassName__c, Level__c, Message__c, User__c, LogTitle__c FROM Log__c];
        System.assertEquals(1, logs.size(), 'Number of logs is not 1');
        System.assertEquals('LoggerTest', logs[0].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('Log Title test', logs[0].LogTitle__c, 'Log Title of Log is not Log Title test');
        System.assertEquals('ERROR', logs[0].Level__c, 'Level of Log is not ERROR');
        System.assertEquals('Simple log test', logs[0].Message__c, 'Message of Log is not correct');
        System.assertEquals(UserInfo.getUserId(), logs[0].User__c, 'User of Log is not correct');
    }

    @isTest
    static void testSimpleLogWithLevel() {
        Test.startTest();

        Logger logInstance = Logger.getInstance();
        logInstance.log('LoggerTest', Logger.Level.ERROR, 'Simple log test');

        Test.stopTest();

        List<Log__c> logs = [SELECT ClassName__c, Level__c, Message__c, User__c FROM Log__c];
        System.assertEquals(1, logs.size(), 'Number of logs is not 1');
        System.assertEquals('LoggerTest', logs[0].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('ERROR', logs[0].Level__c, 'Level of Log is not ERROR');
        System.assertEquals('Simple log test', logs[0].Message__c, 'Message of Log is not correct');
        System.assertEquals(UserInfo.getUserId(), logs[0].User__c, 'User of Log is not correct');
    }

    @isTest
    static void testSimpleLogWithJSON() {
        Test.startTest();
        Map<String, String> testMap = new Map<String, String>{ '1' => 'Test 1', '2' => 'Test 2', '3' => 'Test 3' };

        Logger logInstance = Logger.getInstance();
        logInstance.log('LoggerTest', 'Simple log test', JSON.serialize(testMap));

        Test.stopTest();

        List<Log__c> logs = [SELECT ClassName__c, Level__c, Message__c, User__c, JSON__c FROM Log__c];
        System.assertEquals(1, logs.size(), 'Number of logs is not 1');
        System.assertEquals('LoggerTest', logs[0].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('ERROR', logs[0].Level__c, 'Level of Log is not ERROR');
        System.assertEquals('Simple log test', logs[0].Message__c, 'Message of Log is not correct');
        System.assertEquals(UserInfo.getUserId(), logs[0].User__c, 'User of Log is not correct');
        System.assert(String.isNotBlank(logs[0].JSON__c));
    }

    @isTest
    static void testSimpleLogWithLevelAndJSON() {
        Test.startTest();
        Map<String, String> testMap = new Map<String, String>{ '1' => 'Test 1', '2' => 'Test 2', '3' => 'Test 3' };

        Logger logInstance = Logger.getInstance();
        logInstance.log('LoggerTest', Logger.Level.ERROR, 'Simple log test', JSON.serialize(testMap));

        Test.stopTest();

        List<Log__c> logs = [SELECT ClassName__c, Level__c, Message__c, User__c, JSON__c FROM Log__c];
        System.assertEquals(1, logs.size(), 'Number of logs is not 1');
        System.assertEquals('LoggerTest', logs[0].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('ERROR', logs[0].Level__c, 'Level of Log is not ERROR');
        System.assertEquals('Simple log test', logs[0].Message__c, 'Message of Log is not correct');
        System.assertEquals(UserInfo.getUserId(), logs[0].User__c, 'User of Log is not correct');
        System.assert(String.isNotBlank(logs[0].JSON__c));
    }

    @isTest
    static void testSimpleLogWithObjectIdList() {
        Test.startTest();
        List<Id> testIDs = new List<Id>{ '00100000000asdfjkl', '00100000000asdfjkm', '00100000000asdfjkn' };

        Logger logInstance = Logger.getInstance();
        logInstance.log('LoggerTest', 'Account', testIDs, 'Simple log test');

        Test.stopTest();

        List<Log__c> logs = [
            SELECT ClassName__c, Level__c, Message__c, User__c, ObjectIDs__c, ObjectName__c
            FROM Log__c
        ];
        System.assertEquals(1, logs.size(), 'Number of logs is not 1');
        System.assertEquals('LoggerTest', logs[0].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('ERROR', logs[0].Level__c, 'Level of Log is not ERROR');
        System.assertEquals('Simple log test', logs[0].Message__c, 'Message of Log is not correct');
        System.assertEquals(UserInfo.getUserId(), logs[0].User__c, 'User of Log is not correct');
        System.assertEquals('Account', logs[0].ObjectName__c, 'ObjectName of Log is not correct');
        System.assertEquals(
            '00100000000asdfjkl,00100000000asdfjkm,00100000000asdfjkn',
            logs[0].ObjectIDs__c,
            'ObjectIDs of Log is not correct'
        );
    }

    @isTest
    static void testSimpleLogWithObjectIdSet() {
        Test.startTest();
        Set<Id> testIDs = new Set<Id>{ '00100000000asdfjkl', '00100000000asdfjkm', '00100000000asdfjkn' };

        Logger logInstance = Logger.getInstance();
        logInstance.log('LoggerTest', 'Account', testIDs, 'Simple log test');

        Test.stopTest();

        List<Log__c> logs = [
            SELECT ClassName__c, Level__c, Message__c, User__c, ObjectIDs__c, ObjectName__c
            FROM Log__c
        ];
        System.assertEquals(1, logs.size(), 'Number of logs is not 1');
        System.assertEquals('LoggerTest', logs[0].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('ERROR', logs[0].Level__c, 'Level of Log is not ERROR');
        System.assertEquals('Simple log test', logs[0].Message__c, 'Message of Log is not correct');
        System.assertEquals(UserInfo.getUserId(), logs[0].User__c, 'User of Log is not correct');
        System.assertEquals('Account', logs[0].ObjectName__c, 'ObjectName of Log is not correct');
        System.assertEquals(
            '00100000000asdfjkl,00100000000asdfjkm,00100000000asdfjkn',
            logs[0].ObjectIDs__c,
            'ObjectIDs of Log is not correct'
        );
    }

    @isTest
    static void testSimpleLogWithLevelObjectIdList() {
        Test.startTest();
        List<Id> testIDs = new List<Id>{ '00100000000asdfjkl', '00100000000asdfjkm', '00100000000asdfjkn' };

        Logger logInstance = Logger.getInstance();
        logInstance.log('LoggerTest', Logger.Level.ERROR, 'Account', testIDs, 'Simple log test');

        Test.stopTest();

        List<Log__c> logs = [
            SELECT ClassName__c, Level__c, Message__c, User__c, ObjectIDs__c, ObjectName__c
            FROM Log__c
        ];
        System.assertEquals(1, logs.size(), 'Number of logs is not 1');
        System.assertEquals('LoggerTest', logs[0].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('ERROR', logs[0].Level__c, 'Level of Log is not ERROR');
        System.assertEquals('Simple log test', logs[0].Message__c, 'Message of Log is not correct');
        System.assertEquals(UserInfo.getUserId(), logs[0].User__c, 'User of Log is not correct');
        System.assertEquals('Account', logs[0].ObjectName__c, 'ObjectName of Log is not correct');
        System.assertEquals(
            '00100000000asdfjkl,00100000000asdfjkm,00100000000asdfjkn',
            logs[0].ObjectIDs__c,
            'ObjectIDs of Log is not correct'
        );
    }

    @isTest
    static void testSimpleLogWithLevelObjectIdSet() {
        Test.startTest();
        Set<Id> testIDs = new Set<Id>{ '00100000000asdfjkl', '00100000000asdfjkm', '00100000000asdfjkn' };

        Logger logInstance = Logger.getInstance();
        logInstance.log('LoggerTest', Logger.Level.ERROR, 'Account', testIDs, 'Simple log test');

        Test.stopTest();

        List<Log__c> logs = [
            SELECT ClassName__c, Level__c, Message__c, User__c, ObjectIDs__c, ObjectName__c
            FROM Log__c
        ];
        System.assertEquals(1, logs.size(), 'Number of logs is not 1');
        System.assertEquals('LoggerTest', logs[0].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('ERROR', logs[0].Level__c, 'Level of Log is not ERROR');
        System.assertEquals('Simple log test', logs[0].Message__c, 'Message of Log is not correct');
        System.assertEquals(UserInfo.getUserId(), logs[0].User__c, 'User of Log is not correct');
        System.assertEquals('Account', logs[0].ObjectName__c, 'ObjectName of Log is not correct');
        System.assertEquals(
            '00100000000asdfjkl,00100000000asdfjkm,00100000000asdfjkn',
            logs[0].ObjectIDs__c,
            'ObjectIDs of Log is not correct'
        );
    }

    @isTest
    static void testSaveLogFalse() {
        List<Account> accts = new List<Account>();
        accts.add(new Account());

        Test.startTest();

        List<Database.SaveResult> results = Database.insert(accts, false);

        Logger logInstance = Logger.getInstance();
        Boolean success = logInstance.log('LoggerTest', 'Account', results);

        Test.stopTest();

        List<Log__c> logs = [SELECT ClassName__c, Level__c, ObjectName__c, Message__c, User__c FROM Log__c];
        System.assertEquals(1, logs.size(), 'Number of logs is not 1');
        System.assertEquals('LoggerTest', logs[0].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('Account', logs[0].ObjectName__c, 'Object Name of Log is not Account');
        System.assertEquals('ERROR', logs[0].Level__c, 'Level of Log is not ERROR');
        System.assertNotEquals(null, logs[0].Message__c, 'Message is null');
        System.assertEquals(false, success, 'Method response is not as expected, expected false');
    }

    @isTest
    static void testSaveLogTrue() {
        List<Account> accts = new List<Account>();
        accts.add(new Account(Name = 'ACME'));

        Test.startTest();

        List<Database.SaveResult> results = Database.insert(accts, false);

        Logger logInstance = Logger.getInstance();
        Boolean success = logInstance.log('LoggerTest', 'Account', results);

        Test.stopTest();

        List<Log__c> logs = [SELECT ClassName__c, Level__c, ObjectName__c, Message__c, User__c FROM Log__c];

        // Not expecting logs to be inserted
        System.assertEquals(0, logs.size(), 'Number of logs is not 0');
        System.assertEquals(true, success, 'Method response is not as expected, expected true');
    }

    @isTest
    static void testUpsertLogFalse() {
        List<Account> accts = new List<Account>();
        accts.add(new Account());

        Test.startTest();

        List<Database.UpsertResult> results = Database.upsert(accts, false);

        Logger logInstance = Logger.getInstance();
        Boolean success = logInstance.log('LoggerTest', 'Account', results);

        Test.stopTest();

        List<Log__c> logs = [SELECT ClassName__c, Level__c, ObjectName__c, Message__c, User__c FROM Log__c];
        System.assertEquals(1, logs.size(), 'Number of logs is not 1');
        System.assertEquals('LoggerTest', logs[0].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('Account', logs[0].ObjectName__c, 'Object Name of Log is not Account');
        System.assertEquals('ERROR', logs[0].Level__c, 'Level of Log is not ERROR');
        System.assertNotEquals(null, logs[0].Message__c, 'Message is null');
        System.assertEquals(false, success, 'Method response is not as expected, expected false');
    }

    @isTest
    static void testUpsertLogTrue() {
        List<Account> accts = new List<Account>();
        accts.add(new Account(Name = 'ACME'));

        Test.startTest();

        List<Database.UpsertResult> results = Database.upsert(accts, false);

        Logger logInstance = Logger.getInstance();
        Boolean success = logInstance.log('LoggerTest', 'Account', results);

        Test.stopTest();

        List<Log__c> logs = [SELECT ClassName__c, Level__c, ObjectName__c, Message__c, User__c FROM Log__c];

        // Not expecting logs to be inserted
        System.assertEquals(0, logs.size(), 'Number of logs is not 0');
        System.assertEquals(true, success, 'Method response is not as expected, expected true');
    }

    @isTest
    static void testSimpleExceptionLog() {
        List<Account> accts = new List<Account>();
        accts.add(new Account());

        Test.startTest();

        try {
            insert accts;
        } catch (Exception e) {
            Logger logInstance = Logger.getInstance();
            logInstance.log('LoggerTest', e);
        }

        Test.stopTest();

        List<Log__c> logs = [
            SELECT ClassName__c, Level__c, ObjectName__c, Message__c, StackTrace__c, User__c
            FROM Log__c
        ];
        System.assertEquals(1, logs.size(), 'Number of logs is not 1');
        System.assertEquals('LoggerTest', logs[0].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('ERROR', logs[0].Level__c, 'Level of Log is not ERROR');
        System.assertNotEquals(null, logs[0].Message__c, 'Message is null');
        System.assertNotEquals(null, logs[0].StackTrace__c, 'Stack Trace is null');
    }

    @isTest
    static void testSimpleExceptionLogWithTitle() {
        List<Account> accts = new List<Account>();
        accts.add(new Account());

        Test.startTest();

        try {
            insert accts;
        } catch (Exception e) {
            Logger logInstance = Logger.getInstance();
            logInstance.log('LoggerTest', 'Log Title test', Logger.Level.ERROR, e);
        }

        Test.stopTest();

        List<Log__c> logs = [
            SELECT ClassName__c, Level__c, ObjectName__c, Message__c, StackTrace__c, User__c, LogTitle__c
            FROM Log__c
        ];
        System.assertEquals(1, logs.size(), 'Number of logs is not 1');
        System.assertEquals('LoggerTest', logs[0].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('Log Title test', logs[0].LogTitle__c, 'Log Title of Log is not Log Title test');
        System.assertEquals('ERROR', logs[0].Level__c, 'Level of Log is not ERROR');
        System.assertNotEquals(null, logs[0].Message__c, 'Message is null');
        System.assertNotEquals(null, logs[0].StackTrace__c, 'Stack Trace is null');
    }

    @isTest
    static void testExceptionLogWithObjectName() {
        List<Account> accts = new List<Account>();
        accts.add(new Account());

        Test.startTest();

        try {
            insert accts;
        } catch (Exception e) {
            Logger logInstance = Logger.getInstance();
            logInstance.log('LoggerTest', 'Account', e);
        }

        Test.stopTest();

        List<Log__c> logs = [
            SELECT ClassName__c, Level__c, ObjectName__c, Message__c, StackTrace__c, User__c
            FROM Log__c
        ];
        System.assertEquals(1, logs.size(), 'Number of logs is not 1');
        System.assertEquals('LoggerTest', logs[0].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('Account', logs[0].ObjectName__c, 'Object Name of Log is not Account');
        System.assertEquals('ERROR', logs[0].Level__c, 'Level of Log is not ERROR');
        System.assertNotEquals(null, logs[0].Message__c, 'Message is null');
        System.assertNotEquals(null, logs[0].StackTrace__c, 'Stack Trace is null');
    }

    @isTest
    static void testExceptionLogWithObjectNameAndJSON() {
        List<Account> accts = new List<Account>();
        accts.add(new Account());

        Test.startTest();
        Map<String, String> testMap = new Map<String, String>{ '1' => 'Test 1', '2' => 'Test 2', '3' => 'Test 3' };

        try {
            insert accts;
        } catch (Exception e) {
            Logger logInstance = Logger.getInstance();
            logInstance.log('LoggerTest', 'Account', e, JSON.serialize(testMap));
        }

        Test.stopTest();

        List<Log__c> logs = [
            SELECT ClassName__c, Level__c, ObjectName__c, Message__c, StackTrace__c, User__c, JSON__c
            FROM Log__c
        ];
        System.assertEquals(1, logs.size(), 'Number of logs is not 1');
        System.assertEquals('LoggerTest', logs[0].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('Account', logs[0].ObjectName__c, 'Object Name of Log is not Account');
        System.assertEquals('ERROR', logs[0].Level__c, 'Level of Log is not ERROR');
        System.assert(String.isNotBlank(logs[0].JSON__c));
        System.assertNotEquals(null, logs[0].Message__c, 'Message is null');
        System.assertNotEquals(null, logs[0].StackTrace__c, 'Stack Trace is null');
    }

    @isTest
    static void testPruning() {
        List<Log__c> logsToInsert = new List<Log__c>();
        DateTime now = DateTime.now();
        Integer subtractMinutes = -20;

        for (Integer i = 0; i < 10; i++) {
            Log__c log = new Log__c(Message__c = 'Test ' + i);
            logsToInsert.add(log);
        }
        insert logsToInsert;

        // Subtract CreatedDate Time for each log to ensure different CreatedDate values
        for (Integer k = 0; k < 10; k++) {
            Test.setCreatedDate(logsToInsert[k].Id, now.addMinutes(subtractMinutes));
            subtractMinutes++;
        }

        Test.startTest();

        Log__c extraLog = new Log__c(Message__c = 'New Log');
        insert extraLog;

        Test.stopTest();

        List<Log__c> logs = [SELECT Message__c, CreatedDate FROM Log__c ORDER BY CREATEDDATE ASC];
        System.assertEquals(10, logs.size(), 'Number of logs is not 10');
        System.assertEquals('Test 1', logs[0].Message__c, 'Message of the first log is not Test 1');
    }

    @isTest
    static void testMultipleLogs() {
        Test.startTest();

        Logger logInstance = Logger.getInstance(true);
        logInstance.log('LoggerTest1', 'Simple log test');
        logInstance.log('LoggerTest2', 'Another Simple log test');
        logInstance.finalize();

        Test.stopTest();

        List<Log__c> logs = [SELECT ClassName__c, Level__c, Message__c, User__c FROM Log__c ORDER BY ClassName__c];
        System.assertEquals(2, logs.size(), 'Number of logs is not 2');
        System.assertEquals('LoggerTest1', logs[0].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('ERROR', logs[0].Level__c, 'Level of Log is not ERROR');
        System.assertEquals('Simple log test', logs[0].Message__c, 'Message of Log is not correct');
        System.assertEquals(UserInfo.getUserId(), logs[0].User__c, 'User of Log is not correct');
        System.assertEquals('Another Simple log test', logs[1].Message__c, 'Message of Log 2 is not correct');
    }

    @isTest
    static void testByPassPlatformEvent() {
        Test.startTest();

        Logger logInstance = Logger.getInstance(true, true);
        logInstance.log('LoggerTest1', 'Simple log test');
        logInstance.log('LoggerTest2', 'Another Simple log test');
        logInstance.finalize();

        Test.stopTest();

        List<Log__c> logs = [SELECT ClassName__c, Level__c, Message__c, User__c FROM Log__c ORDER BY ClassName__c];
        System.assertEquals(2, logs.size(), 'Number of logs is not 2');
        System.assertEquals('LoggerTest1', logs[0].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('ERROR', logs[0].Level__c, 'Level of Log is ERROR');
        System.assertEquals('Simple log test', logs[0].Message__c, 'Message of Log is not correct');
        System.assertEquals(UserInfo.getUserId(), logs[0].User__c, 'User of Log is not correct');
        System.assertEquals('Another Simple log test', logs[1].Message__c, 'Message of Log 2 is not correct');
    }

    @isTest
    static void testErrorLogLevel() {
        Test.startTest();

        Logger logInstance = Logger.getInstance(Logger.Level.ERROR.name());
        logInstance.log('LoggerTest', 'Log Title test', Logger.Level.ERROR, 'Simple Error log test');
        logInstance.log('LoggerTest', 'Log Title test', Logger.Level.WARN, 'Simple Warn log test');
        logInstance.log('LoggerTest', 'Log Title test', Logger.Level.INFO, 'Simple Info log test');
        logInstance.log('LoggerTest', 'Log Title test', Logger.Level.DEBUG, 'Simple Debug log test');

        Test.stopTest();

        List<Log__c> logs = [SELECT ClassName__c, Level__c, Message__c, User__c FROM Log__c ORDER BY ClassName__c];
        System.assertEquals(1, logs.size(), 'Number of logs is not 1');

        System.assertEquals('LoggerTest', logs[0].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('ERROR', logs[0].Level__c, 'Level of Log is not ERROR');
        System.assertEquals('Simple Error log test', logs[0].Message__c, 'Message of Log is not correct');
        System.assertEquals(UserInfo.getUserId(), logs[0].User__c, 'User of Log is not correct');
    }

    @isTest
    static void testWarnLogLevel() {
        Test.startTest();

        Logger logInstance = Logger.getInstance(Logger.Level.WARN.name());
        logInstance.log('LoggerTest', 'Log Title test', Logger.Level.ERROR, 'Simple Error log test');
        logInstance.log('LoggerTest', 'Log Title test', Logger.Level.WARN, 'Simple Warn log test');
        logInstance.log('LoggerTest', 'Log Title test', Logger.Level.INFO, 'Simple Info log test');
        logInstance.log('LoggerTest', 'Log Title test', Logger.Level.DEBUG, 'Simple Debug log test');

        Test.stopTest();

        List<Log__c> logs = [SELECT ClassName__c, Level__c, Message__c, User__c FROM Log__c ORDER BY ClassName__c];
        System.assertEquals(2, logs.size(), 'Number of logs is not 2');

        System.assertEquals('LoggerTest', logs[1].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('WARN', logs[1].Level__c, 'Level of Log is not WARN');
        System.assertEquals('Simple Warn log test', logs[1].Message__c, 'Message of Log is not correct');
        System.assertEquals(UserInfo.getUserId(), logs[1].User__c, 'User of Log is not correct');

        System.assertEquals('LoggerTest', logs[0].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('ERROR', logs[0].Level__c, 'Level of Log is not ERROR');
        System.assertEquals('Simple Error log test', logs[0].Message__c, 'Message of Log is not correct');
        System.assertEquals(UserInfo.getUserId(), logs[0].User__c, 'User of Log is not correct');
    }

    @isTest
    static void testInfoLogLevel() {
        Test.startTest();

        Logger logInstance = Logger.getInstance(Logger.Level.INFO.name());
        logInstance.log('LoggerTest', 'Log Title test', Logger.Level.ERROR, 'Simple Error log test');
        logInstance.log('LoggerTest', 'Log Title test', Logger.Level.WARN, 'Simple Warn log test');
        logInstance.log('LoggerTest', 'Log Title test', Logger.Level.INFO, 'Simple Info log test');
        logInstance.log('LoggerTest', 'Log Title test', Logger.Level.DEBUG, 'Simple Debug log test');

        Test.stopTest();

        List<Log__c> logs = [SELECT ClassName__c, Level__c, Message__c, User__c FROM Log__c ORDER BY ClassName__c];
        System.assertEquals(3, logs.size(), 'Number of logs is not 3');

        System.assertEquals('LoggerTest', logs[2].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('INFO', logs[2].Level__c, 'Level of Log is not INFO');
        System.assertEquals('Simple Info log test', logs[2].Message__c, 'Message of Log is not correct');
        System.assertEquals(UserInfo.getUserId(), logs[2].User__c, 'User of Log is not correct');

        System.assertEquals('LoggerTest', logs[1].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('WARN', logs[1].Level__c, 'Level of Log is not WARN');
        System.assertEquals('Simple Warn log test', logs[1].Message__c, 'Message of Log is not correct');
        System.assertEquals(UserInfo.getUserId(), logs[1].User__c, 'User of Log is not correct');

        System.assertEquals('LoggerTest', logs[0].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('ERROR', logs[0].Level__c, 'Level of Log is not ERROR');
        System.assertEquals('Simple Error log test', logs[0].Message__c, 'Message of Log is not correct');
        System.assertEquals(UserInfo.getUserId(), logs[0].User__c, 'User of Log is not correct');
    }

    @isTest
    static void testDebugLogLevel() {
        Test.startTest();

        Logger logInstance = Logger.getInstance(Logger.Level.DEBUG.name());
        logInstance.log('LoggerTest', 'Log Title test', Logger.Level.ERROR, 'Simple Error log test');
        logInstance.log('LoggerTest', 'Log Title test', Logger.Level.WARN, 'Simple Warn log test');
        logInstance.log('LoggerTest', 'Log Title test', Logger.Level.INFO, 'Simple Info log test');
        logInstance.log('LoggerTest', 'Log Title test', Logger.Level.DEBUG, 'Simple Debug log test');

        Test.stopTest();

        List<Log__c> logs = [SELECT ClassName__c, Level__c, Message__c, User__c FROM Log__c ORDER BY ClassName__c];
        System.assertEquals(4, logs.size(), 'Number of logs is not 4');

        System.assertEquals('LoggerTest', logs[3].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('DEBUG', logs[3].Level__c, 'Level of Log is not DEBUG');
        System.assertEquals('Simple Debug log test', logs[3].Message__c, 'Message of Log is not correct');
        System.assertEquals(UserInfo.getUserId(), logs[3].User__c, 'User of Log is not correct');

        System.assertEquals('LoggerTest', logs[2].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('INFO', logs[2].Level__c, 'Level of Log is not INFO');
        System.assertEquals('Simple Info log test', logs[2].Message__c, 'Message of Log is not correct');
        System.assertEquals(UserInfo.getUserId(), logs[2].User__c, 'User of Log is not correct');

        System.assertEquals('LoggerTest', logs[1].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('WARN', logs[1].Level__c, 'Level of Log is not WARN');
        System.assertEquals('Simple Warn log test', logs[1].Message__c, 'Message of Log is not correct');
        System.assertEquals(UserInfo.getUserId(), logs[1].User__c, 'User of Log is not correct');

        System.assertEquals('LoggerTest', logs[0].ClassName__c, 'Class Name of Log is not LoggerTest');
        System.assertEquals('ERROR', logs[0].Level__c, 'Level of Log is not ERROR');
        System.assertEquals('Simple Error log test', logs[0].Message__c, 'Message of Log is not correct');
        System.assertEquals(UserInfo.getUserId(), logs[0].User__c, 'User of Log is not correct');
    }
}
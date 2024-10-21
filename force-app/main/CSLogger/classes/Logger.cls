@namespaceAccessible
public with sharing class Logger {
    @namespaceAccessible
    public enum Level {
        ERROR,
        WARN,
        DEBUG,
        INFO
    }

    private static Logger LOGGER_INSTANCE = null;

    private Boolean allowMultiple = false;
    private LoggerMsg.LoggerSettings settings;
    private List<LoggerMsg.Log> loggerMsgList;
    private List<LogEvent__e> logEvents;

    /**
     *  Constructor that sets the allowing of multiple logs, and gets the settings
     * @param  inMultiple TRUE if we allow multiple logs in one instance, FALSE if we want to publish immediately
     */
    @namespaceAccessible
    public Logger(Boolean inMultiple) {
        this.allowMultiple = inMultiple;
        this.logEvents = new List<LogEvent__e>();
        this.settings = new LoggerMsg.LoggerSettings(false, null);
        this.loggerMsgList = new List<LoggerMsg.Log>();
    }

    /**
     * Private constructor same as above - added platformEvent parameter to pass it to LoggerSettings
     * @param  inMultiple TRUE if we allow multiple logs in one instance, FALSE if we want to publish immediately
     *         platformEvent  TRUE to bypass Platform Event for unit testing
     */
    private Logger(Boolean inMultiple, Boolean platformEvent) {
        this.allowMultiple = inMultiple;
        this.logEvents = new List<LogEvent__e>();
        this.settings = new LoggerMsg.LoggerSettings(platformEvent, null);
        this.loggerMsgList = new List<LoggerMsg.Log>();
    }
    private Logger(String logLevel) {
        this.logEvents = new List<LogEvent__e>();
        this.settings = new LoggerMsg.LoggerSettings(false, logLevel);
        this.loggerMsgList = new List<LoggerMsg.Log>();
    }
    @namespaceAccessible
    public static Logger getPlatformLogger() {
        Logger log = new Logger(false);
        if (!Test.isRunningTest()) {
            log.settings.bypassPlatformEvents = false;
        }
        return log;
    }

    /**
     * Public getter of an instance. Really used to get the same instance across multiple classes like triggers
     * @param  inMultiple TRUE if we allow multiple logs in one instance, FALSE if we want to publish immediately
     * @return            A Logger instance
     */
    @namespaceAccessible
    public static Logger getInstance(Boolean inMultiple) {
        if (LOGGER_INSTANCE == null) {
            LOGGER_INSTANCE = new Logger(inMultiple);
        }
        return LOGGER_INSTANCE;
    }

    /**
     * Public getter of an instance same as above. Really used to get the same instance across multiple classes like triggers
     * @param  inMultiple TRUE if we allow multiple logs in one instance, FALSE if we want to publish immediately
     *         platformEvent  TRUE to bypass Platform Event for unit testing
     * @return            A Logger instance
     */
    @namespaceAccessible
    public static Logger getInstance(Boolean inMultiple, Boolean platformEvent) {
        if (LOGGER_INSTANCE == null) {
            LOGGER_INSTANCE = new Logger(inMultiple, platformEvent);
        }
        return LOGGER_INSTANCE;
    }

    @namespaceAccessible
    public static Logger getInstance(String logLevel) {
        if (LOGGER_INSTANCE == null) {
            LOGGER_INSTANCE = new Logger(logLevel);
        }
        return LOGGER_INSTANCE;
    }
    @namespaceAccessible
    public static Logger getInstance() {
        return Logger.getInstance(false);
    }

    /**
     * Creates a Log Platform Event if bypass Platform event is false and logging is enabled, that will then create a Log object outside of the current process or
     * create a LoggerMsg Object if bypass Platform event is true and logging is enabled, that will then create a Log object within current process
     * @param  className    Class Name (where this action happened)
     * @param  level        Level enum (ERROR, WARN, DEBUG, INFO)
     * @param  objectName   Object Name (if we are doing DML statements)
     * @param  objectIdList List of Object IDs Affected
     * @param  message      Message
     * @param  stackTrace   Exception Stack Trace
     * @param  inJSON       JSON From API
     */
    @namespaceAccessible
    public void log(
        String className,
        String logTitle,
        Level level,
        String objectName,
        List<Id> objectIdList,
        String message,
        String stackTrace,
        String inJSON
    ) {
        if (!isLoggable(level))
            return;

        String objectIds;
        if ((objectIdList != null) && (!objectIdList.isEmpty())) {
            objectIds = String.join(objectIdList, ',');
        }

        LoggerMsg.Log loggerMsg = new LoggerMsg.Log(
            className,
            logTitle,
            level.name(),
            objectName,
            objectIds,
            message,
            stackTrace,
            inJson,
            userInfo.getUserId()
        );

        if (settings.logToSystemDebug) {
            System.debug(JSON.serialize(loggerMsg));
        }

        if (settings.enableLogging) {
            if (settings.bypassPlatformEvents) {
                if (this.allowMultiple) {
                    loggerMsgList.add(loggerMsg);
                } else {
                    List<LoggerMsg.Log> logList = new List<LoggerMsg.Log>{ loggerMsg };
                    write(logList);
                }
            } else {
                LogEvent__e le = loggerMsg.toPlatformEvent();

                if (this.allowMultiple) {
                    logEvents.add(le);
                } else {
                    EventBus.publish(le);
                }
            }
        }
    }

    /**
     * Creates a Log Platform Event if bypass Platform event is false and logging is enabled, that will then create a Log object outside of the current process or
     * create a LoggerMsg Object if bypass Platform event is true and logging is enabled, that will then create a Log object within current process
     * @param  className    Class Name (where this action happened)
     * @param  level        Level enum (ERROR, WARN, DEBUG, INFO)
     * @param  objectName   Object Name (if we are doing DML statements)
     * @param  objectIdList List of Object IDs Affected
     * @param  message      Message
     * @param  stackTrace   Exception Stack Trace
     * @param  inJSON       JSON From API
     * @param  errorCode    An identifier for the error generated
     */
    @namespaceAccessible
    public void log(
        String className,
        String logTitle,
        Level level,
        String objectName,
        List<Id> objectIdList,
        String message,
        String stackTrace,
        String inJSON,
        String errorCode
    ) {
        String objectIds;
        if ((objectIdList != null) && (!objectIdList.isEmpty())) {
            objectIds = String.join(objectIdList, ',');
        }

        LoggerMsg.Log loggerMsg = new LoggerMsg.Log(
            className,
            logTitle,
            level.name(),
            objectName,
            objectIds,
            message,
            stackTrace,
            inJson,
            userInfo.getUserId(),
            errorCode
        );

        if (settings.logToSystemDebug) {
            System.debug(JSON.serialize(loggerMsg));
        }

        if (settings.enableLogging) {
            if (settings.bypassPlatformEvents) {
                if (this.allowMultiple) {
                    loggerMsgList.add(loggerMsg);
                } else {
                    List<LoggerMsg.Log> logList = new List<LoggerMsg.Log>{ loggerMsg };
                    write(logList);
                }
            } else {
                LogEvent__e le = loggerMsg.toPlatformEvent();

                if (this.allowMultiple) {
                    logEvents.add(le);
                } else {
                    EventBus.publish(le);
                }
            }
        }
    }

    /**
     * Called at the end of an execution context to bulkify the publishing of log events/LoggerMsg in the case of allowMultiple = TRUE
     */
    @namespaceAccessible
    public void finalize() {
        if (this.allowMultiple) {
            if (!logEvents.isEmpty()) {
                EventBus.publish(logEvents);
            }
            if (!loggerMsgList.isEmpty()) {
                write(loggerMsgList);
            }
        }
    }

    // Overrides
    @namespaceAccessible
    public void log(String className, String logTitle, Level level, String message) {
        log(className, logTitle, level, null, null, message, null, null);
    }
    @namespaceAccessible
    public void log(String className, String message) {
        log(className, null, Level.ERROR, null, null, message, null, null);
    }
    @namespaceAccessible
    public void log(String className, Level level, String message) {
        log(className, null, level, null, null, message, null, null);
    }
    @namespaceAccessible
    public void log(String className, String message, String inJSON) {
        log(className, null, Level.ERROR, null, null, message, null, inJSON);
    }
    @namespaceAccessible
    public void log(String className, Level level, String message, String inJSON) {
        log(className, null, level, null, null, message, null, inJSON);
    }
    @namespaceAccessible
    public void log(String className, String objectName, List<Id> objectIdList, String message) {
        log(className, null, Level.ERROR, objectName, objectIdList, message, null, null);
    }
    @namespaceAccessible
    public void log(String className, String objectName, Set<Id> objectIdSet, String message) {
        List<Id> objectIdList;
        if (objectIdSet != null) {
            objectIdList = new List<Id>(objectIdSet);
        }
        log(className, null, Level.ERROR, objectName, objectIdList, message, null, null);
    }
    @namespaceAccessible
    public void log(String className, Level level, String objectName, List<Id> objectIdList, String message) {
        log(className, null, level, objectName, objectIdList, message, null, null);
    }
    @namespaceAccessible
    public void log(String className, Level level, String objectName, Set<Id> objectIdSet, String message) {
        List<Id> objectIdList;
        if (objectIdSet != null) {
            objectIdList = new List<Id>(objectIdSet);
        }
        log(className, null, level, objectName, objectIdList, message, null, null);
    }

    // Exception handling
    @namespaceAccessible
    public void log(String className, String logTitle, Level level, Exception e) {
        log(className, logTitle, level, null, null, e.getMessage(), e.getStackTraceString(), null);
    }
    @namespaceAccessible
    public void log(String className, Exception e) {
        log(className, null, Level.ERROR, null, null, e.getMessage(), e.getStackTraceString(), null);
    }
    @namespaceAccessible
    public void log(String className, Exception e, String inJSON) {
        log(className, null, Level.ERROR, null, null, e.getMessage(), e.getStackTraceString(), inJSON);
    }
    @namespaceAccessible
    public void log(String className, Exception e, String inJSON, String errorCode) {
        log(className, null, Level.ERROR, null, null, e.getMessage(), e.getStackTraceString(), inJSON, errorCode);
    }
    @namespaceAccessible
    public void log(String className, String objectName, Exception e) {
        log(className, null, Level.ERROR, objectName, null, e.getMessage(), e.getStackTraceString(), null);
    }
    @namespaceAccessible
    public void log(String className, String objectName, Exception e, String inJSON) {
        log(className, null, Level.ERROR, objectName, null, e.getMessage(), e.getStackTraceString(), inJSON);
    }

    // DML Error Handling
    @namespaceAccessible
    public Boolean log(String className, String objectName, List<Database.SaveResult> results) {
        Boolean result = true;
        for (Database.SaveResult sr : results) {
            if (!sr.isSuccess()) {
                String errorMsg = '';
                for (Database.Error err : sr.getErrors()) {
                    errorMsg += err.getMessage() + '\n';
                }
                log(className, null, Level.ERROR, objectName, null, errorMsg, null, null);
                result = false;
            }
        }
        return result;
    }
    @namespaceAccessible
    public Boolean log(String className, String objectName, List<Database.UpsertResult> results) {
        Boolean result = true;
        for (Database.UpsertResult sr : results) {
            if (!sr.isSuccess()) {
                String errorMsg = '';
                for (Database.Error err : sr.getErrors()) {
                    errorMsg += err.getMessage() + '\n';
                }
                log(className, null, Level.ERROR, objectName, null, errorMsg, null, null);
                result = false;
            }
        }
        return result;
    }
    @namespaceAccessible
    public Boolean log(String className, String objectName, List<Database.DeleteResult> results) {
        Boolean result = true;
        for (Database.DeleteResult deleteResultObj : results) {
            if (!deleteResultObj.isSuccess()) {
                String errorMsg = '';
                for (Database.Error err : deleteResultObj.getErrors()) {
                    errorMsg += err.getMessage() + '\n';
                }
                log(className, null, Level.ERROR, objectName, null, errorMsg, null, null);
                result = false;
            }
        }
        return result;
    }

    /**
     * Check the custom metadata type if pruning is enabled to prevent org limits
     */
    @namespaceAccessible
    public void pruneLogs() {
        Log__c firstLogToPrune;

        // If it's off, end here
        if (!settings.enablePruning) {
            return;
        }

        // Running in System context, ignore CRUD/FLS and Sharing
        Integer logCount = Data.countQuery(
            'SELECT COUNT() FROM Log__c LIMIT :maxLogs',
            new Map<String, Object>{ 'maxLogs' => settings.maxLogs },
            false,
            false,
            false
        );

        // If it's less than the max, end here
        if (logCount < settings.maxLogs) {
            return;
        }

        // Get the CreatedDate of the first log to prune
        try {
            String query =
                'SELECT CreatedDate FROM Log__c ORDER BY CreatedDate DESC LIMIT 1 OFFSET ' + settings.maxLogs;

            //run query without enforcing CRUD/FLS/Sharing because this is a system process
            firstLogToPrune = (Log__c) Data.read(query, new Map<String, Object>(), false, false, false)[0];
        } catch (Exception e) {
            // If this throws an exception, then there's a mismatch or some other race condition. Just exit and it'll correct
            // itself on the next run.
            return;
        }

        // Seed the Queueable and queue it up
        LogPruneQueueable lpq = new LogPruneQueueable(firstLogToPrune.CreatedDate);
        System.enqueueJob(lpq);
    }

    /**
     * Check the custom metadata type for the interfaced classes and call them in order
     * @param  LoggerMsgList updated from Log method
     */
    @namespaceAccessible
    public void write(List<loggerMsg.Log> loggerMsgList) {
        if (loggerMsgList.size() > 0) {
            List<String> values = settings.classOrder.split(',');

            for (String v : values) {
                try {
                    ILogWriter customType = (ILogWriter) Type.forName(v).newInstance();
                    customType.write(loggerMsgList);
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }
            }
        }
    }
    private Boolean isLoggable(Level logMessageLevel) {
        List<String> logLevelHierarchy = new List<String>{ 'ERROR', 'WARN', 'INFO', 'DEBUG' };
        String currentLogLevel = settings.logLevel.toUpperCase();
        String messageLogLevel = logMessageLevel.name().toUpperCase();
        Integer currentIndex = logLevelHierarchy.indexOf(currentLogLevel);
        Integer messageIndex = logLevelHierarchy.indexOf(messageLogLevel);

        return messageIndex >= 0 && messageIndex <= currentIndex;
    }
}
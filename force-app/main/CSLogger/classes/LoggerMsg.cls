/**
 * ClassName : LoggerMsg
 * Description : This is the wrapper class for the Log Object and LoggerSetting Metadata and it is used in IlogWriter
 * Interface
 */
public with sharing class LoggerMsg {
    /**
     * Wrapper class for Log Object
     */
    public class Log {
        public String className { get; set; }
        public String logTitle { get; set; }
        public String level { get; set; }
        public String objectName { get; set; }
        public String objectIds { get; set; }
        public String message { get; set; }
        public String stackTrace { get; set; }
        public String inJson { get; set; }
        public String user { get; set; }
        public String errorCode { get; set; }

        /**
         * Constructor for Log Class
         */
        public Log(
            String className,
            String logTitle,
            String level,
            String objectName,
            String objectIds,
            String message,
            String stackTrace,
            String inJSON,
            String user
        ) {
            this.className = className;
            this.logTitle = logTitle;
            this.level = level;
            this.objectName = objectName;
            this.objectIds = objectIds;
            this.message = message;
            this.stackTrace = stackTrace;
            this.inJson = inJson;
            this.user = user;
        }

        /**
         * Constructor for Log Class
         */
        public Log(
            String className,
            String logTitle,
            String level,
            String objectName,
            String objectIds,
            String message,
            String stackTrace,
            String inJSON,
            String user,
            String errorCode
        ) {
            this.className = className;
            this.logTitle = logTitle;
            this.level = level;
            this.objectName = objectName;
            this.objectIds = objectIds;
            this.message = message;
            this.stackTrace = stackTrace;
            this.inJson = inJson;
            this.user = user;
            this.errorCode = errorCode;
        }

        /**
         * Overloaded Constructor that takes LogEvent__e and parses it
         */
        public Log(LogEvent__e le) {
            this.className = le.ClassName__c;
            this.logTitle = le.LogTitle__c;
            this.level = le.Level__c;
            this.objectName = le.ObjectName__c;
            this.objectIds = le.ObjectIDs__c;
            this.message = le.Message__c;
            this.stackTrace = le.StackTrace__c;
            this.inJson = le.JSON__c;
            this.user = le.CreatedbyId;
            this.errorCode = le.ErrorCode__c;
        }

        /**
         * Method to create the LogEvent__e instance and pass it to Logger Class
         */
        public LogEvent__e toPlatformEvent() {
            return new LogEvent__e(
                ClassName__c = this.className,
                LogTitle__c = this.logTitle,
                Level__c = this.level,
                ObjectName__c = this.objectName,
                ObjectIDs__c = this.objectIds,
                Message__c = this.message,
                StackTrace__c = this.stackTrace,
                JSON__c = this.inJSON,
                ErrorCode__c = this.errorCode
            );
        }

        /**
         * Method to create the Log__c instance and pass it to LogToObject Class
         */
        public Log__c toLogObject() {
            return new Log__c(
                ClassName__c = this.className,
                logTitle__c = this.logTitle,
                Level__c = this.level,
                ObjectName__c = this.objectName,
                ObjectIDs__c = this.objectIds,
                Message__c = this.message,
                StackTrace__c = this.stackTrace,
                JSON__c = this.inJson,
                User__c = this.user,
                ErrorCode__c = this.errorCode
            );
        }
    }

    /**
     * Wrapper class for Metadata
     * Modify the constructor of this class if you wish to use something other than a Custom Metadata Type
     * to store these settings
     */
    public inherited sharing class LoggerSettings {
        public Boolean enableLogging;
        public Boolean enablePruning;
        public String classOrder;
        public Integer maxLogs;
        public Boolean bypassPlatformEvents;
        public Boolean logToSystemDebug;
        public String logLevel;

        public LoggerSettings(Boolean platformEvent, String logLevel) {
            // If we are in a Unit Test, we want to fake the settings. Custom Metadata runs with SeeAllData=true
            if (Test.isRunningTest()) {
                this.enableLogging = true;
                this.enablePruning = true;
                this.classOrder = 'LogToObject';
                this.maxLogs = 10;
                this.bypassPlatformEvents = false;
                if (platformEvent) {
                    this.bypassPlatformEvents = true;
                }
                this.logToSystemDebug = false;
                this.logLevel = logLevel != null ? logLevel : 'ERROR';
            } else {
                // not enforcing security here because this is custom metatdata query and system process
                Log_Settings__mdt lsSettings = [
                    SELECT
                        Enable_Logging__c,
                        Enable_Pruning__c,
                        Interfaced_Class_Order__c,
                        Max_Number_Of_Logs__c,
                        Bypass_Platform_Events__c,
                        Log_To_System_Debug__c,
                        Log_Level__c
                    FROM Log_Settings__mdt
                    ORDER BY Created_Date__c DESC
                    LIMIT 1
                ];
                this.enableLogging = lsSettings.Enable_Logging__c;
                this.enablePruning = lsSettings.Enable_Pruning__c;
                this.classOrder = lsSettings.Interfaced_Class_Order__c;
                this.maxLogs = Integer.valueOf(lsSettings.Max_Number_Of_Logs__c);
                this.bypassPlatformEvents = lsSettings.Bypass_Platform_Events__c;
                this.logToSystemDebug = lsSettings.Log_To_System_Debug__c;
                this.logLevel = lsSettings.Log_Level__c;
            }
        }
    }
}
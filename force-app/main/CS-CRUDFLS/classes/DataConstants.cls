@namespaceAccessible
public with sharing class DataConstants {
    /*
		projects may wish to declaratively enable/disable CRUD/FLS/SHR checks
		via a protected custom setting. Update the line below to point to the
		PCS.
		
		Example:

		ENABLED = CustomSetting__c.getOrgDefaults().CRUDFLS_Enabled__c;
	 */
    @namespaceAccessible
    public static Boolean ENABLED = true;
    @namespaceAccessible
    public static System.LoggingLevel LOGGING_LEVEL = LoggingLevel.DEBUG;

    @namespaceAccessible
    public enum SecurityOperation {
        READ,
        CREATE,
        MODIFY,
        REMOVE,
        UNREMOVE
    }
}
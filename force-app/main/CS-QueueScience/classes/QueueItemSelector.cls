public with sharing class QueueItemSelector extends Selector {
    /**
     * Constructor that assumes we are enforcing CRUD/FLS/Sharing
     */
    public QueueItemSelector() {
        super(Schema.QueueItem__c.SObjectType);
    }

    /**
     * Constructor that allows us to specify the CRUD/FLS/Sharing for this instance
     * @param  enforceCRUD Enforce CRUD
     * @param  enforceFLS  Enforce FLS
     * @param  enforceShr  Enforce Sharing
     */
    public QueueItemSelector(Boolean enforceCRUD, Boolean enforceFLS, Boolean enforceShr) {
        super(Schema.QueueItem__c.SObjectType, enforceCRUD, enforceFLS, EnforceShr);
    }

    /**
     * Returns a set of strings that has all default values.
     * @return   return Set of default SELECT values
     */
    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'ClassName__c', // contains class name
            'Context__c',
            'ErrorCount__c', // count of errors
            'ErrorMessageShort__c',
            'Object__c', // sObject name to process
            'Priority__c', // default 0, higher process first
            'Process_After__c', // defaults to immediate
            'RecordId__c', // record it to process
            'Status__c', // NEW is processed
            'PageNumber__c', //the page number to get in case of pagination
            'TotalPagesNumber__c', //the total number of pages to get in case of pagination
            'StaleDataIdsList__c', // the list of ids to use to get the stale data
            'RequestType__c' //the request type to run in case of pagination and queue item processor calls multiple APIs
        };
    }

    /**
     * Retrieve a list of ContentVersion records filtered on ContentDocumentId
     * @param  contentDocuments A list of ContentDocumentId's
     * @return                  A list of ContentVersion records
     */
    public List<QueueItem__c> getNextQueueItem(Integer rowLimit, DateTime processingTimeBoundary) {
        List<String> queryFields = new List<String>(this.getDefaultFields());

        Map<String, Object> queryArgs = new Map<String, Object>{
            'rowLimit' => rowLimit,
            'processingTimeBoundary' => processingTimeBoundary,
            'processingStatus' => 'NEW'
        };

        String query =
            'SELECT ' +
            String.join(queryFields, ', ') +
            ' FROM QueueItem__c' +
            ' WHERE Process_After__c <= :processingTimeBoundary' +
            ' AND Status__c = :processingStatus' +
            ' ORDER BY Priority__c DESC, Process_After__c ASC, Id' +
            ' LIMIT :rowLimit';

        return new List<QueueItem__c>(
            (List<QueueItem__c>) Data.read(
                query,
                queryArgs,
                this.isEnforcingCRUD(),
                this.isEnforcingFLS(),
                this.isEnforcingShr()
            )
        );
    }
}
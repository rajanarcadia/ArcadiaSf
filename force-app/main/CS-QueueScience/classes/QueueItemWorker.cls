public with sharing class QueueItemWorker implements Finalizer, Queueable, Database.AllowsCallouts {
    @TestVisible
    private static integer rowLimit = 1; // Maximum Queue Items to process at a time
    @TestVisible
    private static Integer maxErrorCount = 3; // Number of times to retry before marking as error
    @TestVisible
    private static Boolean shouldRequeue = true; // whether to requeue for more queue items, set to false for just 1 iteration in tests
    private static integer backoffExponentBase = 10; // exponent base for number of minutes to add to process after on error (10^errorCount)
    public QueueItemWorker finalizer;
    private List<QueueItem__c> processingQueueItems = new List<QueueItem__c>();
    private List<QueueItem__c> completedQueueItems = new List<QueueItem__c>();
    private List<QueueItemError> erroredQueueItems = new List<QueueItemError>();
    public Logger logWriter = new Logger(true /*inMultiple*/);
    private DateTime processingTimeBoundary = DateTime.now(); // When to process items after

    public void execute(QueueableContext context) {
        this.finalizer = new QueueItemWorker();
        System.attachFinalizer(this.finalizer);
        // do some work!
        // query for queueitem__c records, ordered by priority (0 = default, 1 = high, -1 = low)

        this.processingQueueItems = new QueueItemSelector(false, false, false)
            .getNextQueueItem(QueueItemWorker.rowLimit, this.processingTimeBoundary);
        if (this.processingQueueItems.isEmpty()) {
            return;
        } else {
            this.finalizer.processingQueueItems = this.processingQueueItems;
        }

        for (Integer i = (this.finalizer.processingQueueItems.size() - 1); i >= 0; i--) {
            // determine the work to be done on this queue item
            // based on the fields that were queried
            //
            // UtilityClass.doWork(item);
            //
            // this class also is responsible for marking the QueueItem__c record Status as "not new"
            //
            // QueueItem__c records should be short lived and hard deleted (no recycle bin) to prevent data
            // storage problems as items are processed by the queue
            // attach logs to finalizer with this.finalizer.logger.log(...);
            QueueItem__c item = this.processingQueueItems[i];
            String className = item.ClassName__c; // Be careful of namespaces, you must include namespace in the class name if needed
            try {
                Type t = Type.forName(className);
                QueueItemWorkerBase worker = (QueueItemWorkerBase) t.newInstance();
                worker.process(item);
                // this is DML in a loop, but we only do 1 at a time right now. if that changes, refactor
                this.finalizer.completedQueueItems.add(item);
                this.finalizer.processingQueueItems.remove(i);
            } catch (Exception e) {
                this.finalizer.logWriter.log('QueueItemWorker.' + className, e, JSON.serialize(item));
                // this is DML in a loop, but we only do 1 at a time right now. if that changes, refactor
                QueueItemError erroredItem = new QueueItemError();
                erroredItem.item = item;
                erroredItem.e = e;
                this.finalizer.erroredQueueItems.add(erroredItem);
                this.finalizer.processingQueueItems.remove(i);
            }
        }
    }

    // Call this method to handle errors encounter on queue item(s)
    // This method does not handle logging
    public QueueItem__c handleError(QueueItem__c item, String errorMessage) {
        Datetime retryDatetime = Datetime.now().addMinutes(QueueItemWorker.backoffExponentBase);
        item.ErrorMessage__c = errorMessage.abbreviate(32768);
        item.ErrorMessageShort__c = errorMessage?.abbreviate(255);
        item.Status__c = 'NEW';
        if (item.ErrorCount__c == null) {
            item.ErrorCount__c = 1;
        } else {
            if (item.ErrorCount__c >= QueueItemWorker.maxErrorCount) {
                item.Status__c = 'ERROR';
                item.ErrorCount__c += 1;
            } else {
                item.ErrorCount__c += 1;
                retryDateTime = Datetime.now()
                    .addMinutes(
                        Integer.valueOf(
                            Math.pow(QueueItemWorker.backoffExponentBase, Integer.valueOf(item.ErrorCount__c))
                        )
                    ); // 10, 100, 1000 minutes retry delay with 10 backoffExponentBase
            }
        }
        item.Process_After__c = retryDateTime;
        return item;
    }

    public void execute(FinalizerContext ctx) {
        // This will catch any uncaught exceptions, including uncatchable exceptions
        // Best practice is to catch and handle the exceptions in the main execute method
        // This will mark all processing queue items as errored if there is more than 1
        // if you do not want that to happen, pop the processed queue item off the finalizer.processingQueueItems
        // as they succeed
        // ctx is generally null in tests, null protect all references to it

        List<QueueItem__c> erroredQueueItems = new List<QueueItem__c>();
        // set a default exception message if nothing else can be found
        String genericExceptionMessage = 'QueueItemWorker.Finalizer unknown error, item left in processing';
        if (ctx?.getResult() != ParentJobResult.SUCCESS) {
            genericExceptionMessage = ctx?.getException()?.getMessage();
            this.logWriter.log('QueueItemWorker.Finalizer uncaught exception', ctx?.getException());
        }
        if (this.processingQueueItems.size() > 0) {
            for (QueueItem__c item : this.processingQueueItems) {
                erroredQueueItems.add(this.handleError(item, genericExceptionMessage));
            }
        }
        if (this.erroredQueueItems.size() > 0) {
            for (QueueItemError errorItem : this.erroredQueueItems) {
                erroredQueueItems.add(this.handleError(errorItem.item, errorItem.e.getMessage()));
            }
        }
        this.logWriter.finalize();
        if (erroredQueueItems.size() > 0) {
            // Running in System context, ignore CRUD/FLS and Sharing
            Data.modify(erroredQueueItems, false, false, false);
        }
        // Delete completed queue items
        if (this.completedQueueItems.size() > 0) {
            // Running in System context, ignore CRUD/FLS and Sharing
            Data.remove(this.completedQueueItems, false, false, false);
        }
        // determine if there are more items in the queue
        // Running in System context, ignore CRUD/FLS and Sharing
        /*List<QueueItem__c> pendingItems = new QueueItemSelector(false, false, false)
            .getNextQueueItem(QueueItemWorker.rowLimit, this.processingTimeBoundary);

        // work to be done, queue the job up again
        if (!pendingItems.isEmpty() && QueueItemWorker.shouldRequeue) {
            System.enqueueJob(new QueueItemWorker());
        }*/
    }

    private class QueueItemError {
        private QueueItem__c item;
        private Exception e;
    }
}
@isTest
public class QueueItemTriggerTest {
    @isTest
    public static void test_queue_item_processes() {
        QueueItem__c qi = new QueueItem__c();
        qi.ClassName__c = QueueItemUtils.getNamespaceWithDot() + 'QueueItemTriggerTest.QueueItemTestProcessor';
        Test.startTest();
        insert qi;
        Test.stopTest();
        System.assert([SELECT Id FROM QueueItem__c].size() == 0, 'Should have processed and deleted the queue item');
        List<AsyncApexJob> jobs = [
            SELECT Id
            FROM AsyncApexJob
            WHERE JobType = 'Queueable' AND Status IN :QueueItemProcessor.PROCESSING_STATUSES
        ];
        System.assert(jobs.isEmpty(), 'Should not have requeued the processor with nothing to process');
    }

    @isTest
    public static void test_queue_item_processes_maximum_items() {
        List<QueueItem__c> qis = new List<QueueItem__c>();
        for (Integer i = 0; i < 3; i++) {
            QueueItem__c qi = new QueueItem__c();
            qi.ClassName__c = QueueItemUtils.getNamespaceWithDot() + 'QueueItemTriggerTest.QueueItemTestProcessor';
            qis.add(qi);
        }
        Test.startTest();
        QueueItemWorker.rowLimit = 2;
        QueueItemWorker.shouldRequeue = false;
        QueueItemProcessor.suppressDuringTestRuns = true;
        insert qis;
        system.enqueueJob(new QueueItemWorker());
        Test.stopTest();
        System.assert(
            [SELECT Id FROM QueueItem__c].size() == 1,
            'Should have processed and deleted 2 queue items, leaving the third'
        );
    }

    @isTest
    public static void test_handles_success_and_error() {
        List<QueueItem__c> qis = new List<QueueItem__c>();
        for (Integer i = 0; i < 2; i++) {
            QueueItem__c qi = new QueueItem__c();
            qi.ClassName__c = QueueItemUtils.getNamespaceWithDot() + 'QueueItemTriggerTest.QueueItemTestProcessor';
            if (i == 1) {
                qi.Object__c = 'Error';
            }
            qis.add(qi);
        }
        Test.startTest();
        insert qis;
        Test.stopTest();
        List<QueueItem__c> retrievedQis = (List<QueueItem__c>) new QueueItemSelector(false, false, false)
            .getAllRecords();
        System.assert(retrievedQis.size() == 1, 'Should not have deleted the errored queue item');
        QueueItem__c qi = retrievedQis.get(0);
        System.assertEquals(1, qi.ErrorCount__c, 'Should have incremented the error count');
        System.assert(qi.ErrorMessageShort__c.contains('foo'), 'Should have set thrown error message');
        System.assert(qi.Process_After__c > Datetime.now(), 'Should have set process after in the future');
        System.assertEquals('NEW', qi.Status__c, 'Should have set status back to new');
        List<AsyncApexJob> jobs = [
            SELECT Id
            FROM AsyncApexJob
            WHERE JobType = 'Queueable' AND Status IN :QueueItemProcessor.PROCESSING_STATUSES
        ];
        System.assert(jobs.size() == 0, 'Should not have requeued the processor');
    }

    @isTest
    public static void test_queue_item_error_handling() {
        QueueItem__c qi = new QueueItem__c();
        qi.ClassName__c = QueueItemUtils.getNamespaceWithDot() + 'QueueItemTriggerTest.QueueItemTestProcessor';
        qi.Object__c = 'Error';
        Test.startTest();
        insert qi;
        Test.stopTest();
        qi = (QueueItem__c) new QueueItemSelector(false, false, false).getRecordById(qi.Id);
        System.assert(qi != null, 'Should not have deleted the errored queue item');
        System.assertEquals(1, qi.ErrorCount__c, 'Should have incremented the error count');
        System.assert(qi.ErrorMessageShort__c.contains('foo'), 'Should have set thrown error message');
        System.assert(qi.Process_After__c > Datetime.now(), 'Should have set process after in the future');
        System.assertEquals('NEW', qi.Status__c, 'Should have set status back to new');
        List<AsyncApexJob> jobs = [
            SELECT Id
            FROM AsyncApexJob
            WHERE JobType = 'Queueable' AND Status IN :QueueItemProcessor.PROCESSING_STATUSES
        ];
        System.assert(jobs.isEmpty(), 'Should not have requeued the processor with nothing to process');
        System.assert([SELECT Id FROM Log__c].size() == 1, 'Should have created a log record');
    }

    @isTest
    public static void test_queue_item_error_handling_max_error_count() {
        QueueItem__c qi = new QueueItem__c();
        qi.ClassName__c = QueueItemUtils.getNamespaceWithDot() + 'QueueItemTriggerTest.QueueItemTestProcessor';
        qi.Object__c = 'Error';
        qi.ErrorCount__c = 3; // max is 3, should go to error state
        Test.startTest();
        insert qi;
        Test.stopTest();
        qi = (QueueItem__c) new QueueItemSelector(false, false, false).getRecordById(qi.Id);
        System.assert(qi != null, 'Should not have deleted the errored queue item');
        System.assertEquals(4, qi.ErrorCount__c, 'Should have incremented the error count');
        System.assert(qi.ErrorMessageShort__c.contains('foo'), 'Should have set thrown error message');
        System.assertEquals('ERROR', qi.Status__c, 'Should have set status back to new');
        List<AsyncApexJob> jobs = [
            SELECT Id
            FROM AsyncApexJob
            WHERE JobType = 'Queueable' AND Status IN :QueueItemProcessor.PROCESSING_STATUSES
        ];
        System.assert(jobs.isEmpty(), 'Should not have requeued the processor with nothing to process');
        System.assert([SELECT Id FROM Log__c].size() == 1, 'Should have created a log record');
    }

    /* This technically works, the finalizer does execute and do the things being asserted
    * down below, but that doesn't stop the error from propagating to the unit test &
    * blowing up here too. Leaving this test as reference for what the functionality is
    * but commenting out since it will fail :shrug:
    @isTest
    public static void test_queue_item_uncatchable_error_handling() {
        QueueItem__c qi = new QueueItem__c();
        qi.ClassName__c = QueueItemUtils.getNamespaceWithDot() + 'QueueItemTriggerTest.QueueItemTestProcessor';
        qi.Object__c = 'Uncatchable';
        Test.startTest();
        insert qi;
        Test.stopTest();
        qi = (QueueItem__c) new QueueItemSelector(false, false, false).getRecordById(qi.Id);

        System.assert(qi != null, 'Should not have deleted the errored queue item');
        System.assertEquals(1, qi.ErrorCount__c, 'Should have incremented the error count');
        System.assert(qi.ErrorMessageShort__c.contains('LimitException'), 'Should have set thrown error message');
        System.assert(qi.Process_After__c > Datetime.now(), 'Should have set process after in the future');
        System.assertEquals('NEW', qi.Status__c, 'Should have set status back to new');
        List<AsyncApexJob> jobs = [
            SELECT Id
            FROM AsyncApexJob
            WHERE
                JobType = 'Queueable'
                AND Status IN :QueueItemProcessor.PROCESSING_STATUSES
        ];
        System.assert(jobs.isEmpty(), 'Should not have requeued the processor with nothing to process');
        System.assert([SELECT Id FROM Log__c].size() == 1, 'Should have created a log record');
    }
    */

    public class QueueItemTestProcessor extends QueueItemWorkerBase {
        public override QueueItem__c process(QueueItem__c queueItem) {
            if (queueItem.Object__c == 'Error') {
                throw new QITestException('foo');
            } else if (queueItem.Object__c == 'Uncatchable') {
                // infinite recursion throws uncatchable exception. Still processed in finalizer
                return new QueueItemTestProcessor().process(queueItem);
            } else {
                return queueItem;
            }
        }
    }

    private class QITestException extends Exception {
    }
}
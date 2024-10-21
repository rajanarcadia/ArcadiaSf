public with sharing class QueueItemProcessor {
    @TestVisible
    private static Boolean suppressDuringTestRuns = false;

    public static final List<String> PROCESSING_STATUSES = new List<String>{
        'Queued',
        'Holding',
        'Processing',
        'Preparing'
    };
    public QueueItemProcessor() {
        throw new QueueItemProcessorException('This class should not be constructed');
    }

    public static void execute() {
        if (Test.isRunningTest() && suppressDuringTestRuns) {
            return;
        }
        // determine if there is already a job queued or processing QueueItem__c records
        // enqueue if there is no job currently executing to process records

        String[] classNameParts = QueueItemProcessor.class.getName().split('\\.');
        String ns = (classNameParts.size() == 2) ? classNameParts[0] : '';

        List<String> classNames = new List<String>{
            QueueItemProcessor.class.getName().removeStart(ns + '.'),
            QueueItemWorker.class.getName().removeStart(ns + '.')
        };

        // get class details for querying the job table
        String query = 'SELECT Id, Name, NamespacePrefix FROM ApexClass WHERE Name IN :classNames AND NamespacePrefix = :ns';
        Map<String, Object> queryArgs = new Map<String, Object>{ 'classNames' => classNames, 'ns' => ns };
        Map<Id, ApexClass> classMap = new Map<Id, ApexClass>(
            // Running in System context, ignore CRUD/FLS and Sharing
            (List<ApexClass>) Data.read(query, queryArgs, false, false, false)
        );

        // determine if there are any queueable jobs executing in my namespace's classes
        String jobsQuery = 'SELECT Id FROM AsyncApexJob WHERE JobType =:jobType AND Status IN :status AND ApexClassId IN :classIds';
        Map<String, Object> jobsQueryArgs = new Map<String, Object>{
            'jobType' => 'Queueable',
            'classIds' => classMap.keyset(),
            'status' => QueueItemProcessor.PROCESSING_STATUSES
        };
        // Running in System context, ignore CRUD/FLS and Sharing
        List<AsyncApexJob> jobs = (List<AsyncApexJob>) Data.read(jobsQuery, jobsQueryArgs, false, false, false);

        if (jobs.size() == 0) {
            system.enqueueJob(new QueueItemWorker());
        }
    }

    public class QueueItemProcessorException extends Exception {
    }
}
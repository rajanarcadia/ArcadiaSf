@isTest
public class QueueItemsBuilderTest {
    @isTest
    static void testBuildQueueItemsPerRecord() {
        Account testAccount = new Account(Name = 'Test Account');
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testAccount;
        insert testContact;

        List<SObject> testRecords = new List<SObject>{ testAccount, testContact };

        QueueItemsBuilder builder = new QueueItemsBuilder(testRecords, QueueItemsBuilder.class);

        builder.buildQueueItemsPerRecord();

        List<QueueItem__c> queueItems = builder.getRecords();
        System.assertEquals(2, queueItems.size(), 'The Size should be 2');
        System.assert(
            queueItems[0].ClassName__c.contains('QueueItemsBuilder'),
            'The Class Name should be QueueItemsBuilder'
        );
        System.assertEquals(testAccount.Id, queueItems[0].RecordId__c, 'The Record Id should be the Account Id');
        System.assertEquals('Account', queueItems[0].Object__c, 'The Object should be Account');
        System.assert(
            queueItems[1].ClassName__c.contains('QueueItemsBuilder'),
            'The Class Name should be QueueItemsBuilder'
        );
        System.assertEquals(testContact.Id, queueItems[1].RecordId__c, 'The Record Id should be the Contact Id');
        System.assertEquals('Contact', queueItems[1].Object__c, 'The Object should be Contact');
    }

    @isTest
    static void testBuildQueueItemsPerPage() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Type processorClass = QueueItemsBuilder.class;
        String requestType = 'Test Request';
        Integer numberOfPages = 5;

        QueueItemsBuilder builder = new QueueItemsBuilder(testAccount.Id, processorClass, requestType, numberOfPages);

        builder.buildQueueItemsPerPage();

        List<QueueItem__c> queueItems = builder.getRecords();
        System.assertEquals(4, queueItems.size(), 'The Size should be 4');
        System.assert(
            queueItems[1].ClassName__c.contains('QueueItemsBuilder'),
            'The Class Name should be QueueItemsBuilder'
        );
        System.assertEquals(testAccount.Id, queueItems[0].RecordId__c, 'The Record Id should be the Account Id');
        System.assertEquals('Account', queueItems[0].Object__c, 'The Object should be Account');
        System.assertEquals(requestType, queueItems[0].RequestType__c, 'The Request Type should be Test Request');
        System.assertEquals(1, queueItems[0].PageNumber__c, 'The Page Number should be 1');
    }

    @isTest
    static void testCreateRecords() {
        Account testAccount = new Account(Name = 'Test Account');
        List<SObject> testRecords = new List<SObject>{ testAccount };

        QueueItemsBuilder builder = new QueueItemsBuilder(testRecords, QueueItemsBuilder.class);

        builder.buildQueueItemsPerRecord();

        List<Database.SaveResult> saveResults = builder.createRecords();
        System.assertEquals(1, saveResults.size(), 'The Size should be 1');
        System.assertEquals(true, saveResults[0].isSuccess(), 'The Save Result should be true');
    }
}
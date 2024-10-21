trigger QueueItemTrigger on QueueItem__c(after insert, after update, after delete) {
    // a trigger typically inserts QueueItem__c records to put work into the queue
    // Priority 0 is default, set this value higher to move to the head of the processing line
    // Process After is now() by default, set this in the future to delay processing of the record
    //
    // after an item is placed in the queue, start the processor
    // Retrying error items will execute after update, go ahead and kick it off too
    QueueItemProcessor.execute();
}
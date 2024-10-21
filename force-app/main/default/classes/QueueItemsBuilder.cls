public with sharing class QueueItemsBuilder {
    private List<QueueItem__c> queueItems;
    private List<SObject> records;
    private Type processorClass;

    private Id recordId;
    private String requestType;
    private Integer numberOfPages;

    private Double pageNumber;
    private Set<String> staleDataToBeDeletedSet;

    public QueueItemsBuilder(List<SObject> records, Type processorClass) {
        this.records = records;
        this.processorClass = processorClass;
    }

    public QueueItemsBuilder(Id recordI, Type processorClass, String requestType, Integer numberOfPages) {
        this.recordId = recordI;
        this.processorClass = processorClass;
        this.requestType = requestType;
        this.numberOfPages = numberOfPages;
    }

    public QueueItemsBuilder(
        Id recordId,
        Type processorClass,
        String requestType,
        Integer numberOfPages,
        Double pageNumber,
        Set<String> staleDataToBeDeletedSet
    ) {
        this.recordId = recordId;
        this.processorClass = processorClass;
        this.requestType = requestType;
        this.numberOfPages = numberOfPages;
        this.pageNumber = pageNumber;
        this.staleDataToBeDeletedSet = staleDataToBeDeletedSet;
    }

    public QueueItemsBuilder buildQueueItemsPerRecord() {
        this.queueItems = new List<QueueItem__c>();
        for (SObject record : this.records) {
            QueueItem__c item = new QueueItem__c();
            item.ClassName__c = this.processorClass.getName();
            item.RecordId__c = record.Id;
            item.Object__c = String.valueOf(record.getSObjectType());
            this.queueItems.add(item);
        }
        return this;
    }

    public QueueItemsBuilder buildQueueItemsPerPage() {
        this.queueItems = new List<QueueItem__c>();
        for (Integer i = 1; i < this.numberOfPages; i++) {
            QueueItem__c item = new QueueItem__c();
            item.ClassName__c = this.processorClass.getName();
            item.RecordId__c = this.recordId;
            item.Object__c = String.valueOf(this.recordId.getSObjectType().getDescribe().getName());
            item.RequestType__c = this.requestType;
            item.PageNumber__c = i;
            this.queueItems.add(item);
        }
        return this;
    }

    public QueueItemsBuilder buildQueueItemsPerPageForMeterUsages() {
        this.queueItems = new List<QueueItem__c>();
        QueueItem__c item = new QueueItem__c();
        item.ClassName__c = this.processorClass.getName();
        item.RecordId__c = this.recordId;
        item.Object__c = String.valueOf(this.recordId.getSObjectType().getDescribe().getName());
        item.RequestType__c = this.requestType;
        item.PageNumber__c = this.pageNumber;
        item.TotalPagesNumber__c = this.numberOfPages;
        item.StaleDataIdsList__c = JSON.serialize(this.staleDataToBeDeletedSet);
        this.queueItems.add(item);
        return this;
    }

    public List<Database.SaveResult> createRecords() {
        if (!this.queueItems.isEmpty()) {
            // Ignoring CRUD/FLS here since this is a system process that needs to run for all users
            Database.DMLOptions option = new Database.DMLOptions();
            option.OptAllOrNone = false;
            List<Database.SaveResult> saveResult = Data.create(this.queueItems, option, false, false, false);
            Logger.getInstance(false)
                .log(
                    UtilityAccountService.class.getName(),
                    UrjanetUtils.getSObjectName(Schema.UtilityAccount__c.SObjectType),
                    saveResult
                );
            return saveResult;
        }
        return new List<Database.SaveResult>();
    }

    public List<QueueItem__c> getRecords() {
        return this.queueItems;
    }
}
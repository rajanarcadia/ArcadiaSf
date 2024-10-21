@IsTest
private class UtilityCredentialServiceTest {
    @IsTest
    static void oldUtilityCredentialsIsIgonored() {
        String randomId = TestUtility.getRandomId(UtilityCredential__c.SObjectType);
        UtilityCredential__c updatedCredential = new UtilityCredential__c();
        updatedCredential.LastModifiedInUrjanet__c = Datetime.now();
        updatedCredential.Id = Id.valueOf(randomId);

        UtilityCredential__c oldCredential = new UtilityCredential__c();
        oldCredential.LastModifiedInUrjanet__c = Datetime.now();
        oldCredential.Id = Id.valueOf(randomId);

        Map<Id, UtilityCredential__c> oldMap = new Map<Id, UtilityCredential__c>();
        oldMap.put(Id.valueOf(randomId), oldCredential);

        Test.startTest();
        List<UtilityCredential__c> CredentialsToRefresh = UtilityCredentialService.getCredentialsToRefresh(
            new List<UtilityCredential__c>{ updatedCredential, oldCredential },
            oldMap
        );
        Test.stopTest();

        CSUtils.itShouldBe('Credentials to refresh should have 0 record', 0, CredentialsToRefresh.size());
    }

    @IsTest
    static void newUtilityCredentialsIsConsideredForUpdate() {
        String randomId = TestUtility.getRandomId(UtilityCredential__c.SObjectType);
        UtilityCredential__c updatedCredential = new UtilityCredential__c();
        updatedCredential.LastModifiedInUrjanet__c = Datetime.now();
        updatedCredential.Id = Id.valueOf(randomId);

        UtilityCredential__c oldCredential = new UtilityCredential__c();
        oldCredential.LastModifiedInUrjanet__c = Datetime.now().addMinutes(-1);
        oldCredential.Id = Id.valueOf(randomId);

        Map<Id, UtilityCredential__c> oldMap = new Map<Id, UtilityCredential__c>();
        oldMap.put(Id.valueOf(randomId), oldCredential);

        Test.startTest();
        List<UtilityCredential__c> CredentialsToRefresh = UtilityCredentialService.getCredentialsToRefresh(
            new List<UtilityCredential__c>{ updatedCredential, oldCredential },
            oldMap
        );
        Test.stopTest();

        CSUtils.itShouldBe('Credentials to refresh should have 1 record', 1, CredentialsToRefresh.size());
    }

    @IsTest
    static void givenUpdatedUtilityCredentialsWhenCreateQueueItemsForCredentialsQueueItemsCreated() {
        QueueItemProcessor.suppressDuringTestRuns = true;
        String randomId = TestUtility.getRandomId(UtilityCredential__c.SObjectType);
        UtilityCredential__c updatedCredential = new UtilityCredential__c();
        updatedCredential.LastUrjanetSyncDateTime__c = Datetime.now();
        updatedCredential.Id = Id.valueOf(randomId);

        Test.startTest();
        UtilityCredentialService.createQueueItemsForUtilityCredentials(
            new List<UtilityCredential__c>{ updatedCredential }
        );
        Test.stopTest();

        Integer logCount = [SELECT COUNT() FROM Log__c];
        CSUtils.itShouldBe('No errors should exist', 0, logCount);
    }

    @IsTest
    static void testGetCorrelationIdString() {
        String correlationIdWithoutSpace = 'NZC-ARC-a071y000006He62AAC';
        String testStringWithOutSpace = UtilityCredentialService.getCorrelationIdString(
            new List<String>{ correlationIdWithoutSpace }
        );
        CSUtils.itShouldBe(
            'Output should match the format',
            '(' + '\'' + 'NZC-ARC-a071y000006He62AAC' + '\'' + ')',
            testStringWithOutSpace
        );
        CSUtils.itShouldBe(
            'Output should contain the full string',
            true,
            testStringWithOutSpace.contains(correlationIdWithoutSpace)
        );
        CSUtils.itShouldBe(
            'Output should not contain encoded charecters %20 as it doesnot have space',
            true,
            !testStringWithOutSpace.contains('%20')
        );
        String correlationIdWithSpace = 'NZC-ARC a071y000006He62AAC';
        String testStringWithSpace = UtilityCredentialService.getCorrelationIdString(
            new List<String>{ correlationIdWithSpace }
        );
        CSUtils.itShouldBe(
            'Output should match the format',
            '(' + '\'' + 'NZC-ARC%20a071y000006He62AAC' + '\'' + ')',
            testStringWithSpace
        );
        CSUtils.itShouldBe(
            'Output should not contain the full string because it should be encoded',
            false,
            testStringWithSpace.contains(correlationIdWithSpace)
        );
        CSUtils.itShouldBe('Output should contain encoded charecters %20', true, testStringWithSpace.contains('%20'));
        String testStringWithBothStrings = UtilityCredentialService.getCorrelationIdString(
            new List<String>{ correlationIdWithoutSpace, correlationIdWithSpace }
        );
        CSUtils.itShouldBe(
            'Output should match the format',
            '(' + '\'' + 'NZC-ARC-a071y000006He62AAC' + '\'' + ',\'' + 'NZC-ARC%20a071y000006He62AAC' + '\'' + ')',
            testStringWithBothStrings
        );
        CSUtils.itShouldBe(
            'Output should contain comma as its list of two strings ',
            true,
            testStringWithBothStrings.contains(',')
        );
        CSUtils.itShouldBe(
            'Output should contain full string as its not encoded as it doesnot have space',
            true,
            testStringWithBothStrings.split(',')[0].contains(correlationIdWithoutSpace)
        );
        CSUtils.itShouldBe(
            'Output should not contain full string as its  encoded as it have space',
            true,
            !testStringWithBothStrings.split(',')[1].contains(correlationIdWithSpace)
        );
        CSUtils.itShouldBe(
            'Output should contain encoded charecters %20 which replaces the space',
            true,
            testStringWithBothStrings.split(',')[1].contains('%20')
        );
    }
}
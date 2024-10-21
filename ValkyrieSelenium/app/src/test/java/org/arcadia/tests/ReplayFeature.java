package org.arcadia.tests;

import static org.arcadia.utils.TestUtilityService.*;

import org.arcadia.credentials.CredentialService;
import org.arcadia.meters.MeterService;
import org.arcadia.objects.Account;
import org.arcadia.objects.Credential;
import org.arcadia.objects.Meter;
import org.arcadia.utils.TestUtilityService;
import org.openqa.selenium.WebDriver;

public class ReplayFeature {

  public static void testReplayFeature(WebDriver driver, Credential credential) {

    CredentialService.createCredentialForReplay(driver);
    sleep(5);

    TestUtilityService.runSyncAfterBackDate(driver);
    sleep(5);

    for (Account account : credential.getAccounts()) {
      for (Meter meter : account.getMeters()) {
        MeterService.linkMeterSite(driver, meter.getMeterNumber(), meter.getSiteName());
      }
    }

    // wait for link API call to complete
    sleep(20);

    TestUtilityService.validateData(driver, credential, true);
  }

  public static void testReplayAccountUpdate(WebDriver driver, Credential credential) {

    // Updating fields of accounts via script
    String createCredQueryScript =
        """
            List<urjanet__UtilityAccount__c> accountsToUpdate = [SELECT Id, Name FROM urjanet__UtilityAccount__c WHERE urjanet__UtilityCredential__r.urjanet__CorrelationID__c = 'NZC-ARC-a071y000006He62AAC'];
                           Integer count = 1;
                           for (urjanet__UtilityAccount__c acc : accountsToUpdate)
                               acc.Name = 'Test Account ' + count;
                           update accountsToUpdate;
                           """;
    String finalScript = TestUtilityService.getPackageAgnosticScript(createCredQueryScript);
    executeScriptInAnonymousWindow(driver, finalScript);

    sleep(10);

    TestUtilityService.runSyncAfterBackDate(driver);
    sleep(20);

    // Accounts data should been updated , after the Sync

    TestUtilityService.validateData(driver, credential, false);
  }
}

package org.arcadia.admin;

import static org.arcadia.utils.Constants.*;
import static org.arcadia.utils.TestUtilityService.*;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVPrinter;
import org.apache.commons.csv.CSVRecord;
import org.arcadia.objects.Log;
import org.arcadia.utils.TestUtilityService;
import org.junit.platform.commons.util.ExceptionUtils;
import org.junit.platform.commons.util.StringUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

/*
   Add Admin Page Related tests and methods here
*/
public class AdminService {

  /*
   * This method validates the refresh sync functionality.
   */
  public static void refreshSync(WebDriver driver) {
    // navigate to admin tab
    driver.get(BASE_URL + getAdminURL());

    // find and click refresh button
    WebElement refreshButton =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//button[contains(.,'Refresh Arcadia Data')]"));
    assertTrue(refreshButton.isDisplayed());
    refreshButton.click();

    Log log =
        Log.builder()
            .className("UtilityCredentialSyncBatchController")
            .message("Sync Started")
            .build();
    sleep(10);
    checkLogMessage(driver, List.of(log));
  }

  public static void testMultipleSync(WebDriver driver) {

    driver.get(BASE_URL + getAdminURL());

    // find and click refresh button
    WebElement refreshButton =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//button[contains(.,'Refresh Arcadia Data')]"));
    assertTrue(refreshButton.isDisplayed());
    refreshButton.click();
    WebElement successToastMessage = null;
    WebElement failureToastMessage = null;
    sleep(3);
    WebElement toastClose =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//button[contains(@class, 'toastClose')]"));
    if (isElementPresent(
        driver,
        By.xpath(
            "//span[contains(., 'The data from Arcadia is now in the process of being refreshed')]"))) {
      successToastMessage =
          TestUtilityService.findElementWithRetry(
              driver,
              By.xpath(
                  "//span[contains(., 'The data from Arcadia is now in the process of being refreshed')]"));
    } else if (isElementPresent(
        driver,
        By.xpath(
            "//span[contains(., 'A sync is currently in progress. Please wait a few minutes for the current sync to complete')]"))) {
      failureToastMessage =
          TestUtilityService.findElementWithRetry(
              driver,
              By.xpath(
                  "//span[contains(., 'A sync is currently in progress. Please wait a few minutes for the current sync to complete')]"));
    }

    if (null != successToastMessage && successToastMessage.isDisplayed()) {
      toastClose.click();
      refreshButton.click();
      sleep(1);
      checkValidToastMessageDisplayed(
          driver,
          "A sync is currently in progress. Please wait a few minutes for the current sync to complete",
          null);
    } else if (null != failureToastMessage && failureToastMessage.isDisplayed()) {
      assert toastClose != null;
      toastClose.click();
    }
  }

  public static void verifyBulkCredentialInputFilesDownloaded(WebDriver driver) {
    driver.get(BASE_URL + getAdminURL());
    downloadFile(
        driver,
        "//a[contains(.,'download a list of all Arcadia Service Providers here')]",
        ARCADIA_SERVICE_PROVIDER_FILE_NAME);
    downloadFile(
        driver,
        "//a[contains(.,'Download the provided CSV template')]",
        PACKAGE
            ? NAMESPACE + ARCADIA_BULK_CREDENTIAL_TEMPLATE_NAME
            : ARCADIA_BULK_CREDENTIAL_TEMPLATE_NAME);
  }

  /*
   * This method uploads the bulk credential file and verifies the status.
   */
  public static void uploadBulkCredentialFileAndVerifyStatus(
      WebDriver driver,
      String fileName,
      String credentialName,
      String[] messageXpath,
      String serviceId,
      String supplierId,
      boolean addInvalidData,
      boolean duplicateValidData,
      boolean addMissingData,
      boolean multiErrorCase) {

    // find supplier id if not provided
    if (StringUtils.isBlank(supplierId)) {
      supplierId = findSupplierId(driver, "Test Supplier");
    }
    // find if bulk credential file is downloaded if not download it
    verifyBulkCredentialInputFilesDownloaded(driver);

    // prepare the bulk upload files path
    String bulkTemplateName =
        PACKAGE
            ? NAMESPACE + ARCADIA_BULK_CREDENTIAL_TEMPLATE_NAME
            : ARCADIA_BULK_CREDENTIAL_TEMPLATE_NAME;
    String inputFilePath = RESOURCES_ABSOLUTE_PATH + bulkTemplateName;
    String newFilePath = RESOURCES_ABSOLUTE_PATH + fileName;

    if (!isFileDownloaded(fileName)) {
      List<String[]> recordValues;
      if (addMissingData) {
        // prepare missing data for bulk upload
        recordValues = prepareMissingBulkCredentialData(supplierId, serviceId, credentialName);
      } else if (duplicateValidData) {
        // prepare duplicate data for bulk upload
        String[] testCaseData = prepareBulkCredentialData(supplierId, serviceId, credentialName);
        recordValues =
            new ArrayList<>() {
              {
                add(testCaseData);
                add(testCaseData);
              }
            };
      } else if (addInvalidData) {
        // prepare invalid data for bulk upload
        String[] testCaseData = prepareBulkCredentialData(supplierId, serviceId, credentialName);
        String[] invalidData = prepareBulkCredentialData(supplierId, "serviceId", credentialName);
        recordValues =
            new ArrayList<>() {
              {
                add(testCaseData);
                add(invalidData);
              }
            };
      } else if (multiErrorCase) {
        // prepare invalid data for bulk upload
        String[] invalidSupplierIdBulkData =
            prepareBulkCredentialData("supplierId", serviceId, credentialName);
        String[] invalidServiceIdBulkData =
            prepareBulkCredentialData(supplierId, "serviceId", credentialName);
        String[] invalidPasswordBulkData =
            prepareBulkCredentialData(supplierId, serviceId, credentialName);
        invalidPasswordBulkData[2] = null;
        recordValues =
            new ArrayList<>() {
              {
                add(invalidSupplierIdBulkData);
                add(invalidServiceIdBulkData);
                add(invalidPasswordBulkData);
              }
            };
      } else {
        String[] testCaseData = prepareBulkCredentialData(supplierId, serviceId, credentialName);
        recordValues =
            new ArrayList<>() {
              {
                add(testCaseData);
              }
            };
      }
      // create bulk upload file
      createBulkUploadFile(recordValues, inputFilePath, newFilePath);
    }

    WebElement uploadFilesButton =
        TestUtilityService.findElementWithRetry(driver, By.xpath("//input[@name='files']"));
    assertTrue(uploadFilesButton.isDisplayed());

    // upload the bulk credential file
    uploadFilesButton.sendKeys(newFilePath);

    // wait for spinner to disappear
    waitUntilSpinnerInvisible(driver);

    sleep(1);
    if (null != messageXpath) {
      for (String message : messageXpath) {
        // validate the toast message
        System.out.println("message: " + message);
        checkValidToastMessageDisplayed(driver, message, null);
      }
    }
    // delete the file
    deleteFile(newFilePath);
  }

  private static String[] prepareBulkCredentialData(
      String supplierId, String serviceProviderId, String credentialName) {

    if (StringUtils.isBlank(serviceProviderId)) {
      serviceProviderId = PROVIDER_ID;
    }
    return new String[] {
      credentialName, CRED_USERNAME, CRED_PASSWORD, serviceProviderId, supplierId
    };
  }

  private static List<String[]> prepareMissingBulkCredentialData(
      String supplierId, String serviceId, String credentialName) {
    String[] validData = prepareBulkCredentialData(supplierId, serviceId, credentialName);
    List<String[]> missingData = new ArrayList<>(5);
    for (int i = 0; i < 5; i++) {
      missingData.add(
          new String[] {validData[0], validData[1], validData[2], validData[3], validData[4]});
      missingData.get(i)[i] = null;
    }
    return missingData;
  }

  private static void createBulkUploadFile(
      List<String[]> recordValues, String inputFilePath, String outputFilePath) {

    // read csv file and update the content
    try (CSVParser parser = CSVFormat.DEFAULT.parse(new FileReader(inputFilePath));
        CSVPrinter printer = new CSVPrinter(new FileWriter(outputFilePath), CSVFormat.DEFAULT)) {
      int headersIndex = 0;
      for (CSVRecord record : parser) {
        if (headersIndex == 0) {
          // update the headers
          printer.printRecord(record);
          headersIndex++;
        } else {
          // add data for the csv file by using data from recordValues list
          recordValues.forEach(
              recordData -> {
                try {
                  String[] values = record.values();
                  assertNotNull(values);
                  values[0] = recordData[0];
                  values[1] = recordData[1];
                  values[5] = recordData[2];
                  values[9] = null;
                  values[10] = recordData[3];
                  values[11] = recordData[4];

                  printer.printRecord(record);
                } catch (IOException e) {
                  System.out.println(ExceptionUtils.readStackTrace(e));
                }
              });
        }
      }
    } catch (IOException ex) {
      System.out.println(ExceptionUtils.readStackTrace(ex));
    }
  }

  private static String[] findProviderDetails(String providerName) {

    String[] providerDetails = null;
    String inputFilePath = RESOURCES_ABSOLUTE_PATH + ARCADIA_SERVICE_PROVIDER_FILE_NAME;
    try (CSVParser parser = CSVFormat.DEFAULT.parse(new FileReader(inputFilePath))) {

      for (CSVRecord record : parser) {
        if (record.get(1).equalsIgnoreCase(providerName)) {
          providerDetails = record.values();
          break;
        }
      }
    } catch (Exception e) {
      System.out.println(ExceptionUtils.readStackTrace(e));
    }
    return providerDetails;
  }

  public static void pushSitesToArcadia(WebDriver driver) {
    driver.get(BASE_URL + getAdminURL());
    WebElement pushSitesButton =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//button[contains(.,'Push Sites to Arcadia')]"));
    assertTrue(pushSitesButton.isDisplayed());
    pushSitesButton.click();
    sleep(5);
    Log log =
        Log.builder()
            .className("StationaryAssetSourceService")
            .message("Push Sites process Started")
            .build();
    checkLogMessage(driver, List.of(log));
  }

  public static void verifyAllLogs(WebDriver driver) {
    driver.get(BASE_URL + getAdminURL());

    // find and click refresh button again to get and verify other logs
    WebElement refreshButton =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//button[contains(.,'Refresh Arcadia Data')]"));
    assertTrue(refreshButton.isDisplayed());
    refreshButton.click();

    sleep(5);
    // click again to get and verify other logs
    refreshButton.click();

    Log log1 =
        Log.builder()
            .className("UtilityCredentialSyncBatchController")
            .message("No pending jobs to be completed")
            .level("DEBUG")
            .build();
    Log log2 =
        Log.builder()
            .className("UtilityCredentialSyncBatchController")
            .message("Sync Started")
            .build();
    Log log3 =
        Log.builder()
            .className("UtilityCredentialService")
            .message("Utility Credential Sync Batch Started")
            .build();
    Log log4 =
        Log.builder()
            .className("UtilityCredentialService")
            .message("Utility Credential Sync Batch Completed")
            .build();
    Log log5 =
        Log.builder()
            .className("UtilityStatementFileSyncBatch")
            .message("Utility Statement File Sync Batch Started")
            .build();
    Log log6 =
        Log.builder()
            .className("UtilityStatementFileSyncBatch")
            .message("Utility Statement File Sync Batch Completed")
            .build();
    Log warningLog =
        Log.builder()
            .className("UtilityCredentialSyncBatchController")
            .message("Queue items processing is not completed")
            .level("WARN")
            .build();
    checkLogMessage(driver, List.of(log1, log2, log3, log4, log5, log6, warningLog));
  }

  public static void testSyncDataAfterSchedulerRun(WebDriver driver, String token) {

    if (token.equalsIgnoreCase("absent")) {
      if (PACKAGE) return;
      // delete the token to check absent case
      String deleteScript =
          """
            AccessToken__c accessTokenSetting = AccessToken__c.getInstance(UserInfo.getProfileId());
              if(accessTokenSetting!=null && accessTokenSetting.Token1__c!=null) {
                  delete accessTokenSetting;
            """;
      executeScriptInAnonymousWindow(driver, deleteScript);

    } else if (token.equalsIgnoreCase("expired")) {
      if (PACKAGE) return;
      // Expire the token to check expired case
      String expireScript =
          """
             AccessToken__c accessTokenSetting = AccessToken__c.getInstance(UserInfo.getProfileId());
             if(accessTokenSetting!=null && accessTokenSetting.ExpirationTime__c!=null){
             accessTokenSetting.ExpirationTime__c = DateTime.newInstance(2024, 1, 1, 1, 1, 1);
             upsert accessTokenSetting;
            """;
      executeScriptInAnonymousWindow(driver, expireScript);
    }
    // no need to handle present case as token will be present by default

    String fireTimeScript =
        """
                String hour = String.valueOf(Datetime.now().hour());
                //You can add any no of Minute you want to add to schedule it for next
                String min = String.valueOf(Datetime.now().addMinutes(1).minute());
                String ss = String.valueOf(Datetime.now().second());
                //parse to a cron expression
                String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                """;
    String packageScript = PACKAGE ? NAMESPACE.replace("__", ".") : " ";

    String scheduleScript =
        fireTimeScript
            + packageScript
            + "UtilityCredentialSyncScheduler.scheduleJob('Merge Job', nextFireTime);";

    String deleteJobScript =
        """
                List<CronTrigger> cronTriggers = [SELECT  Id FROM CronTrigger  where CronJobDetail.Name = 'Merge Job'];
                // Iterate over the results and delete the scheduled jobs
                for (CronTrigger ct : cronTriggers) {
                    System.abortJob(ct.Id);
                """;

    // run delete script to delete any existing job
    executeScriptInAnonymousWindow(driver, deleteJobScript);

    // run schedule script to schedule a job
    executeScriptInAnonymousWindow(driver, scheduleScript);

    sleep(80);

    // assert Scheduler started log is displayed

    Log log =
        Log.builder()
            .className("UtilityCredentialSyncScheduler")
            .message("Scheduler started.")
            .build();

    checkLogMessage(driver, List.of(log));

    sleep(80);

    // assert Sync started from Scheduler log is displayed
    log =
        Log.builder()
            .className("UtilityBatchSyncScheduler")
            .message("Sync Started from Scheduler")
            .build();

    checkLogMessage(driver, List.of(log));

    // run delete script to delete the scheduled job
    executeScriptInAnonymousWindow(driver, deleteJobScript);
  }
}

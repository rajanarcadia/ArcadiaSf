package org.arcadia.meterUsage;

import static org.arcadia.utils.Constants.*;
import static org.arcadia.utils.TestUtilityService.*;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.List;
import org.arcadia.admin.AdminService;
import org.arcadia.credentials.CredentialService;
import org.arcadia.meters.MeterService;
import org.arcadia.objects.*;
import org.arcadia.stationaryAssets.StationaryAssetsService;
import org.arcadia.utils.TestUtilityService;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

/*
   Add Meter Usage Related tests and methods here
*/
public class MeterUsageService {

  /*
   * This method validates the download statement functionality.
   */
  public static void downloadStatement(
      WebDriver driver, String meterUsageName, String statementId) {

    searchAndOpenMeterUsage(driver, meterUsageName);

    // find download button and download file and validate file is downloaded
    TestUtilityService.downloadFile(
        driver, "//button[contains(.,'Download file')]", statementId + ".pdf");

    // delete the file once it's validated and downloaded
    TestUtilityService.deleteFile(RESOURCES_ABSOLUTE_PATH + statementId + ".pdf");
  }

  /*
   * This method validates meter usage exists and its fields.
   * Also validates assets are linked to meter usage and its fields.
   */
  public static void validateMeterUsageAndAssets(WebDriver driver, MeterUsage meterUsage) {
    // navigate to meter usage tab
    searchAndOpenMeterUsage(driver, meterUsage.getMeterUsageName());

    String currentUrl = driver.getCurrentUrl();

    validateMeterUsageFields(driver, meterUsage);

    // validate all assets are linked to meter usage
    for (StationaryAsset asset : meterUsage.getAssetList()) {
      if (!currentUrl.equalsIgnoreCase(driver.getCurrentUrl())) {
        driver.get(currentUrl);
        sleep(2);
      }
      moveToRelatedTab(driver);
      sleep(2);
      WebElement assetLink =
          TestUtilityService.findElementWithRetry(
              driver, By.xpath("//a[normalize-space()='" + asset.getAssetName() + "']"));
      assertTrue(assetLink.isDisplayed());
      WebElement parentElement =
          assetLink.findElement(By.xpath("./..")).findElement(By.xpath("./.."));
      parentElement.click();
      // validate all fields of the asset
      StationaryAssetsService.validateStationaryAssetFields(driver, asset);
    }
  }

  /*
   * This method validates meter usage exists and validated fields of the meter Usage.
   */
  public static void validateMeterUsageFields(WebDriver driver, MeterUsage meterUsage) {
    // verify all fields
    validateFieldAndValue(
        driver, "Utility Meter Usage Name", meterUsage.getMeterUsageName(), false, false);
    validateFieldAndValue(
        driver, "Arcadia Statement ID", meterUsage.getStatementId(), false, false);
    validateFieldAndValue(driver, "ArcadiaId", meterUsage.getMeterUsageId(), false, false);
    validateFieldAndValue(driver, "Measured Usage", meterUsage.getMeasuredUsage(), true, false);
    validateFieldAndValue(driver, "Usage Unit", meterUsage.getMeasuredUsageUnit(), false, false);
    validateFieldAndValue(driver, "Period Start", meterUsage.getPeriodStartDate(), false, false);
    validateFieldAndValue(driver, "Period End", meterUsage.getPeriodEndDate(), false, false);
    validateFieldAndValue(driver, "Utility Meter", meterUsage.getMeterName(), false, true);
  }

  public static void validateMeterUsageExists(
      WebDriver driver, MeterUsage meterUsage, boolean checkDownStream) {
    sleep(5);
    String currentUrl = driver.getCurrentUrl();

    validateMeterUsageFields(driver, meterUsage);

    if (!checkDownStream) {
      return;
    }

    if (meterUsage.getAssetList() == null) {
      return;
    }

    // validate all assets are linked to meter usage
    for (StationaryAsset asset : meterUsage.getAssetList()) {
      if (!currentUrl.equalsIgnoreCase(driver.getCurrentUrl())) {
        driver.get(currentUrl);
        sleep(2);
      }
      moveToRelatedTab(driver);
      sleep(2);
      WebElement assetLink =
          TestUtilityService.findElementWithRetry(
              driver, By.xpath("//a[normalize-space()='" + asset.getAssetName() + "']"));
      assertTrue(assetLink.isDisplayed());
      WebElement parentElement =
          assetLink.findElement(By.xpath("./..")).findElement(By.xpath("./.."));
      parentElement.click();
      // validate all fields of the asset
      StationaryAssetsService.validateStationaryAssetFields(driver, asset);
    }
  }

  public static void testUsagesDeregulationStatus(
      WebDriver driver, Credential credential, String[] deregulationStatus) {

    driver.get(BASE_URL + getCustomListUrl(UTILITY_CREDENTIAL_OBJECT));

    // create cred if not exists
    if (!TestUtilityService.isElementPresent(driver, By.linkText(credential.getName()))) {
      CredentialService.createCredential(
          driver, credential.getName(), credential.getCorrelationId(), credential.getSupplier());

      // wait for cred to be created
      sleep(5);
      AdminService.refreshSync(driver);

      // wait for sync to run
      sleep(30);
    }

    //
    Meter meter = credential.getAccounts().get(0).getMeters().get(0);

    MeterService.linkMeterSite(driver, meter.getMeterNumber(), meter.getSiteName());

    searchMeterUsage(driver, meter.getMeterNumber());

    for (String deregulation : deregulationStatus) {
      // other deregulation status should not be present in whole page
      assertFalse(
          isElementPresent(driver, By.xpath("//span[normalize-space()='" + deregulation + "']")));
    }
  }

  public static void testReplayMeterUsageCUDOperations(WebDriver driver) {

    String meterUsage1 = "89813 - 2023-09-27 - 2023-11-04";
    String meterUsage2 = "89813 - 2023-11-04 - 2023-12-12";

    // create credential if not exists
    createCredentialUsingCorrelationId(driver, "MeterUsageReplay", "NZC-ARC-a071y000006He62AAC");

    // run sync to get the meter data
    runSyncAfterBackDate(driver);

    // link site to meter to get the meter usage data and wait till records are created
    linkSiteToMeterByScript(driver, "89813");
    sleep(15);

    // search and open meter usage record for updating the measured usage
    searchAndOpenMeterUsage(driver, meterUsage1);
    sleep(2);

    // keep the record in edit mode of updating the measured usage
    editMeterUsage(driver);
    // update the measured usage and return the old value
    String measuredUsageValue = getMeasuredUsageValueAndUpdate(driver);

    // save the record after updating the measured usage
    saveMeterUsage(driver);

    // search and open meter usage record for creating a new record
    searchAndOpenMeterUsage(driver, meterUsage1);

    // clone the record and update the arcadia id
    WebElement cloneButton =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//button[normalize-space()='Clone']"));
    assertTrue(cloneButton.isDisplayed());
    cloneButton.click();
    sleep(3);

    WebElement arcadiaId =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//input[@name='" + getPackageAgnosticString("UrjanetId__c") + "']"));
    assertTrue(arcadiaId.isDisplayed());
    String arcadiaIdValue = arcadiaId.getAttribute("value").trim();
    arcadiaId.clear();
    arcadiaId.sendKeys(arcadiaIdValue + "C");

    // save the record after updating the arcadia id
    saveMeterUsage(driver);

    // search and open meter usage record for deleting the record
    searchAndOpenMeterUsage(driver, meterUsage2);

    WebElement deleteButton =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//button[normalize-space()='Delete']"));
    assertTrue(deleteButton.isDisplayed());
    deleteButton.click();

    sleep(1);

    WebElement confirmDeleteButton =
        TestUtilityService.findElementWithRetry(driver, By.xpath("//button[@title='Delete']"));
    assertTrue(confirmDeleteButton.isDisplayed());
    confirmDeleteButton.click();
    sleep(3);

    // update the last modified date for the meter usage records whose measured usage is updated
    updatedLastMofidifedDateForMeterUsages(driver, arcadiaIdValue);

    // run sync to get the meter data
    runSyncAfterBackDate(driver);

    // confirm update operation is working
    searchAndOpenMeterUsage(driver, meterUsage1);
    String afterSyncArcadiaIdValue = getArcadiaIdInEditMode(driver);
    assertTrue(arcadiaIdValue.equalsIgnoreCase(afterSyncArcadiaIdValue));
    WebElement measuredUsage =
        TestUtilityService.findElementWithRetry(
            driver,
            By.xpath("//input[@name='" + getPackageAgnosticString("MeasuredUsage__c") + "']"));
    assertTrue(measuredUsage.isDisplayed());
    assertTrue(measuredUsage.getAttribute("value").trim().equalsIgnoreCase(measuredUsageValue));

    // confirm create operation is working
    searchAndOpenMeterUsage(driver, meterUsage2);

    // confirm delete operation is working
    findNofElementsWithSameMeterUsage(driver, meterUsage1);
  }

  private static String getMeasuredUsageValueAndUpdate(WebDriver driver) {
    WebElement measuredUsage =
        TestUtilityService.findElementWithRetry(
            driver,
            By.xpath("//input[@name='" + getPackageAgnosticString("MeasuredUsage__c") + "']"));
    assertTrue(measuredUsage.isDisplayed());
    String measuredUsageValue = measuredUsage.getAttribute("value").trim();
    Double value = Double.parseDouble(measuredUsageValue) + 100;
    measuredUsage.clear();
    measuredUsage.sendKeys(String.valueOf(value));
    return measuredUsageValue;
  }

  private static String getArcadiaIdInEditMode(WebDriver driver) {
    editMeterUsage(driver);

    WebElement arcadiaId =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//input[@name='" + getPackageAgnosticString("UrjanetId__c") + "']"));

    assertTrue(arcadiaId.isDisplayed());
    return arcadiaId.getAttribute("value").trim();
  }

  private static void searchMeterUsage(WebDriver driver, String meterUsageName) {
    driver.get(BASE_URL + getCustomListUrl(UTILITY_METER_USAGE_OBJECT));
    sleep(5);

    WebElement search =
        TestUtilityService.findElementWithRetry(
            driver,
            By.xpath(
                "//input[@name='"
                    + getPackageAgnosticString("UtilityMeterUsage__c-search-input")
                    + "']"));

    assertTrue(search.isDisplayed());
    search.sendKeys(meterUsageName);
    refreshWhileSearching(driver);
    sleep(5);
  }

  private static void searchAndOpenMeterUsage(WebDriver driver, String meterUsageName) {
    searchMeterUsage(driver, meterUsageName);

    try {
      WebElement meterUsageLink =
          TestUtilityService.findElementWithRetry(
              driver, By.xpath("//a[@title='" + meterUsageName + "']"));
      assertTrue(meterUsageLink.isDisplayed());
      meterUsageLink.click();
    } catch (org.openqa.selenium.StaleElementReferenceException ex) {
      WebElement meterUsageLink =
          TestUtilityService.findElementWithRetry(
              driver, By.xpath("//a[@title='" + meterUsageName + "']"));
      assertTrue(meterUsageLink.isDisplayed());
      meterUsageLink.click();
    }

    sleep(5);
  }

  private static void findNofElementsWithSameMeterUsage(WebDriver driver, String meterUsageName) {
    driver.get(BASE_URL + getCustomListUrl(UTILITY_METER_USAGE_OBJECT));
    sleep(2);

    WebElement search =
        TestUtilityService.findElementWithRetry(
            driver,
            By.xpath(
                "//input[@name='"
                    + getPackageAgnosticString("UtilityMeterUsage__c-search-input")
                    + "']"));

    assertTrue(search.isDisplayed());
    search.sendKeys(meterUsageName);

    List<WebElement> meterUsageLink =
        driver.findElements(By.xpath("//a[@title='" + meterUsageName + "']"));
    assertEquals(1, meterUsageLink.size());
  }

  public static void testLockRecordMeterUsageCase(WebDriver driver) {
    String meterUsage1 = "89813 - 2023-11-04 - 2023-12-12";
    // when testing in local if meter usage is not available in the org then create the meter usage
    // create credential if not exists
    // createCredentialUsingCorrelationId(driver, "MeterUsageReplay",
    // "NZC-ARC-a071y000006He62AAC");
    //
    //    // run sync to get the meter data
    //    runSyncAfterBackDate(driver);
    //
    //    // link site to meter to get the meter usage data and wait till records are created
    //    linkSiteToMeter(driver, "89813");
    //    sleep(15);

    // search and open meter usage record
    searchAndOpenMeterUsage(driver, meterUsage1);

    // keep the record in edit mode of updating the measured usage
    //        editMeterUsage(driver);

    // lock the record
    WebElement recordLockButton =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//button[@title='Edit Record Locked']"));
    assertTrue(recordLockButton.isDisplayed());
    recordLockButton.click();

    WebElement recordLock =
        TestUtilityService.findElementWithRetry(
            driver,
            By.xpath("//input[@name='" + getPackageAgnosticString("IsRecordLocked__c") + "']"));

    if (!recordLock.isSelected()) {
      recordLock.click();

      // save the record
      saveMeterUsage(driver);
    }

    //
    searchAndOpenMeterUsage(driver, meterUsage1);

    editMeterUsage(driver);

    getMeasuredUsageValueAndUpdate(driver);

    saveMeterUsage(driver);

    WebElement lockRecord =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//li[contains(text(),'Record is locked, Unlock for updating.')]"));
    assertTrue(lockRecord.isDisplayed());
  }

  private static void editMeterUsage(WebDriver driver) {
    WebElement editButton =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//button[normalize-space()='Edit']"));
    assertTrue(editButton.isDisplayed());
    editButton.click();
    sleep(3);
  }

  private static void saveMeterUsage(WebDriver driver) {
    WebElement saveButton =
        TestUtilityService.findElementWithRetry(driver, By.xpath("//button[@name='SaveEdit']"));
    assertTrue(saveButton.isDisplayed());
    saveButton.click();
    sleep(3);
  }

  public static void testMeterUsageUpdate(WebDriver driver) {

    String meterUsage = "89813 - 2024-03-12 - 2024-04-12";

    // search and open meter usage record
    searchAndOpenMeterUsage(driver, meterUsage);

    editMeterUsage(driver);

    getMeasuredUsageValueAndUpdate(driver);

    saveMeterUsage(driver);

    List<WebElement> fieldLabels =
        findElementsWithRetry(
            driver,
            By.xpath(
                "//span[(normalize-space()='Manually Updated') and (@class='test-id__field-label')] "),
            5);

    WebElement fieldLabel = fieldLabels.get(0);
    for (WebElement label : fieldLabels) {
      if (label.isDisplayed()) {
        fieldLabel = label;
        break;
      }
    }

    WebElement fieldParent =
        fieldLabel
            .findElement(By.xpath("./.."))
            .findElement(By.xpath("./.."))
            .findElement(By.xpath("./.."));

    WebElement checkBox =
        findElementWithRetry(
            fieldParent,
            By.xpath(".//lightning-primitive-input-checkbox[contains(.,'Manually Updated')]"));

    // validate Manually Updated field is checked
    assertTrue(checkBox.getAttribute("outerHTML").contains("checked"));

    // let the delete and recreation happen
    sleep(10);

    Log log =
        Log.builder()
            .className("StationaryAssetEnergyUseDeleter")
            .message("Deleting Stationary Asset Energy Usage: 2")
            .level("DEBUG")
            .build();

    TestUtilityService.checkLogMessage(driver, List.of(log));
  }

  public static void testNoDuplicateMeterUsages(WebDriver driver) {

    String duplicateQuery =
        "select Name, count(Id) from urjanet__UtilityMeterUsage__c group by name, urjanet__UtilityMeter__c having count(Id)>1";
    executeQuery(driver, duplicateQuery);

    // 0 rows means no duplicate meter usages
    WebElement result =
        findElementWithRetry(
            driver, By.xpath("//span[contains(.,'Query Results - Total Rows: 0')]"));
    assertTrue(result.isDisplayed());
  }
}

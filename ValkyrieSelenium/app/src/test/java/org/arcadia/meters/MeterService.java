package org.arcadia.meters;

import static org.arcadia.utils.Constants.*;
import static org.arcadia.utils.TestUtilityService.*;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.arcadia.meterUsage.MeterUsageService;
import org.arcadia.objects.Meter;
import org.arcadia.objects.MeterUsage;
import org.arcadia.testData.TestData;
import org.arcadia.utils.TestUtilityService;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;

/*
   Add Meter Related tests and methods here
*/
public class MeterService {
  /*
   * This method validates the link meter site functionality.
   */
  public static void linkMeterSite(WebDriver driver, String meterName, String siteName) {
    // navigate to meter tab
    driver.get(BASE_URL + getCustomListUrl(UTILITY_METER_OBJECT));
    driver.navigate().refresh();

    sleep(5);

    WebElement search =
        TestUtilityService.findElementWithRetry(
            driver,
            By.xpath(
                "//input[@name='"
                    + getPackageAgnosticString("UtilityMeter__c-search-input")
                    + "']"));
    assertTrue(search.isDisplayed());
    search.sendKeys(meterName);

    WebElement refresh =
        TestUtilityService.findElementWithRetry(driver, By.xpath("//button[@title='Refresh']"));
    assertTrue(refresh.isDisplayed());
    refresh.click();

    // wait for search to work
    sleep(5);

    WebElement meterLink = TestUtilityService.findElementWithRetry(driver, By.linkText(meterName));
    assertTrue(meterLink.isDisplayed());

    // get meter row
    WebElement meterRow =
        meterLink
            .findElement(By.xpath("./.."))
            .findElement(By.xpath("./.."))
            .findElement(By.xpath("./.."));
    Actions actions = new Actions(driver);
    // get edit Site span from meter Row`
    WebElement editSpan =
        TestUtilityService.findElementWithRetry(
            meterRow,
            By.xpath(".//span[contains(.,'Edit Stationary Asset Environmental Source: Item ')]"));

    // hover over span
    actions.moveToElement(editSpan).perform();

    // get edit button from span
    WebElement editButton =
        TestUtilityService.findElementWithRetry(
            editSpan,
            By.xpath(".//button[contains(.,'Edit Stationary Asset Environmental Source: Item ')]"));
    assertTrue(editButton.isDisplayed());
    sleep(5);
    editButton.click();

    // check if delete icon is displayed
    if (TestUtilityService.isElementPresent(driver, By.xpath("//span[@class='deleteIcon']"))) {
      if (TestUtilityService.isElementPresent(
          driver, By.xpath("//span[contains(.,'" + siteName + "')]"))) {
        // Site already linked
        return;
      }
      // delete icon is displayed, click it to delete the existing site
      WebElement deleteIcon =
          TestUtilityService.findElementWithRetry(driver, By.xpath("//span[@class='deleteIcon']"));
      assertTrue(deleteIcon.isDisplayed());
      deleteIcon.click();
    }

    // find search site input and send site name
    WebElement searchSite =
        TestUtilityService.findElementWithRetry(
            driver,
            By.xpath("//input[@placeholder='Search Stationary Asset Environmental Sources...']"));
    assertTrue(searchSite.isDisplayed());
    searchSite.sendKeys(siteName);

    // from dropdown select site matching site name
    WebElement searchSiteDropdown =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//li[contains(.,'" + siteName + "')]"));
    assertTrue(searchSiteDropdown.isDisplayed());
    sleep(5);
    searchSiteDropdown.click();

    // find and click save button
    WebElement saveButton =
        TestUtilityService.findElementWithRetry(driver, By.xpath("//button[contains(.,'Save')]"));
    assertTrue(saveButton.isDisplayed());
    saveButton.click();
    sleep(2);

    TestUtilityService.checkValidToastMessageDisplayed(
        driver, "Your changes are saved.", GREEN_TOAST_RGBA);

    // wait for link API call to complete and meter usages to come
    sleep(30);
  }

  public static void validateMeterFields(WebDriver driver, Meter meter) {
    TestUtilityService.validateFieldAndValue(
        driver, "Utility Meter Number", meter.getMeterNumber(), false, false);
    TestUtilityService.validateFieldAndValue(
        driver, "ArcadiaId", meter.getArcadiaId(), false, false);
    TestUtilityService.validateFieldAndValue(
        driver, "Stationary Asset Environmental Source", meter.getSiteName(), false, true);
    TestUtilityService.validateFieldAndValue(
        driver, "Meter Status", meter.getStatus(), false, false);
    TestUtilityService.validateFieldAndValue(
        driver, "Service Type", meter.getServiceType(), false, false);
  }

  /*
   * This method validates meters exists.
   */
  public static void validateMeterExists(WebDriver driver, Meter meter, boolean checkDownStream) {

    sleep(5);
    String currentUrl = driver.getCurrentUrl();
    // validate all fields of the meter
    validateMeterFields(driver, meter);

    if (!checkDownStream) {
      return;
    }

    for (MeterUsage meterUsage : meter.getMeterUsages()) {
      if (!currentUrl.equalsIgnoreCase(driver.getCurrentUrl())) {
        driver.get(currentUrl);
        sleep(2);
      }
      TestUtilityService.moveToRelatedTab(driver);
      sleep(2);
      WebElement meterUsageLink =
          TestUtilityService.findElementWithRetry(
              driver, By.xpath("//a[normalize-space()='" + meterUsage.getMeterUsageName() + "']"));
      assertTrue(meterUsageLink.isDisplayed());
      WebElement parentElement =
          meterUsageLink.findElement(By.xpath("./..")).findElement(By.xpath("./.."));
      parentElement.click();
      // validate all fields of the meter usage
      MeterUsageService.validateMeterUsageExists(driver, meterUsage, checkDownStream);
    }
  }

  public static void testMeterWithoutSiteListView(WebDriver driver) {
    driver.get(BASE_URL + getCustomListUrl(UTILITY_METER_OBJECT, "meterswithoutsites"));
    // no Site should be present
    assertFalse(
        isElementPresent(driver, By.xpath("//span[contains(.,'" + TestData.siteName + "')]")));
  }

  public static void createDuplicateDataForTestMeter(WebDriver driver) {

    createBaseMeterDuplicateUsage(driver);

    createGrowthMeterDuplicateUsage(driver);

    createTwoDuplicateBaseMeter(driver);

    createTwoDuplicateGrowthMeter(driver);

    createFiveDuplicateBaseMeter(driver);

    createFiveDuplicateGrowthMeter(driver);

    createFiveBaseMeterDuplicateUsages(driver);

    createFiveGrowthMeterDuplicateUsages(driver);

    createFiveBaseMeterDuplicateInPairUsages(driver);

    createFiveGrowthMeterDuplicateInPairUsages(driver);
  }

  public static void createBaseMeterDuplicateUsage(WebDriver driver) {

    // Test Meter Base
    TestUtilityService.createMeters(
        driver, "Test Meter Base 100DupUSage", 1, 1, false, true, ELECTRIC_SERVICE_TYPE);

    TestUtilityService.createDuplicateMeterUsageAndDownstreamData(
        driver,
        "Test Meter Base 100DupUSage",
        ELECTRIC_SERVICE_TYPE,
        1,
        50,
        1000.0f,
        false,
        false,
        "full_service",
        "1",
        "01",
        "2024",
        "25",
        "01",
        "2024");
  }

  public static void createGrowthMeterDuplicateUsage(WebDriver driver) {

    TestUtilityService.createMeters(
        driver, "Test Meter Growth 100DupUSage", 1, 1, false, true, WATER_SERVICE_TYPE);

    TestUtilityService.createDuplicateMeterUsageAndDownstreamData(
        driver,
        "Test Meter Growth 100DupUSage",
        WATER_SERVICE_TYPE,
        1,
        50,
        1000.0f,
        false,
        false,
        "full_service",
        "25",
        "02",
        "2024",
        "25",
        "03",
        "2024");
  }

  public static void createTwoDuplicateBaseMeter(WebDriver driver) {
    // created 2 duplicate growth meters
    TestUtilityService.createMeters(
        driver, "Test Meter Base 2Duplicate", 1, 2, true, true, ELECTRIC_SERVICE_TYPE);

    // creating 100 duplicate usages for each meter
    TestUtilityService.createDuplicateMeterUsageAndDownstreamData(
        driver,
        "Test Meter Base 2Duplicate",
        ELECTRIC_SERVICE_TYPE,
        1,
        100,
        100.0f,
        false,
        false,
        "full_service",
        "01",
        "03",
        "2024",
        "15",
        "04",
        "2024");
  }

  public static void createTwoDuplicateGrowthMeter(WebDriver driver) {
    // created 2 duplicate growth meters
    TestUtilityService.createMeters(
        driver, "Test Meter Growth 2Duplicate", 1, 2, true, true, WATER_SERVICE_TYPE);

    // creating 100 duplicate usages for each meter
    TestUtilityService.createDuplicateMeterUsageAndDownstreamData(
        driver,
        "Test Meter Growth 2Duplicate",
        WATER_SERVICE_TYPE,
        1,
        100,
        100.0f,
        false,
        false,
        "full_service",
        "01",
        "04",
        "2024",
        "25",
        "04",
        "2024");
  }

  public static void createFiveDuplicateBaseMeter(WebDriver driver) {
    // created 5 duplicate growth meters
    TestUtilityService.createMeters(
        driver, "Test Meter Base 5Duplicate", 1, 5, true, true, ELECTRIC_SERVICE_TYPE);

    // creating 100 duplicate usages for each meter
    TestUtilityService.createDuplicateMeterUsageAndDownstreamData(
        driver,
        "Test Meter Base 5Duplicate",
        ELECTRIC_SERVICE_TYPE,
        1,
        100,
        100.0f,
        false,
        false,
        "full_service",
        "05",
        "05",
        "2024",
        "25",
        "05",
        "2024");
  }

  public static void createFiveDuplicateGrowthMeter(WebDriver driver) {
    // created 2 duplicate growth meters
    TestUtilityService.createMeters(
        driver, "Test Meter Growth Duplicate", 1, 2, true, true, WATER_SERVICE_TYPE);

    // creating 100 duplicate usages for each meter
    TestUtilityService.createDuplicateMeterUsageAndDownstreamData(
        driver,
        "Test Meter Growth Duplicate",
        WATER_SERVICE_TYPE,
        1,
        100,
        100.0f,
        false,
        false,
        "full_service",
        "01",
        "06",
        "2024",
        "01",
        "07",
        "2024");
  }

  public static void createFiveBaseMeterDuplicateUsages(WebDriver driver) {
    String meterName = "Test Meter 5Base";
    // Creating 5 Base Meters
    TestUtilityService.createMeters(driver, meterName, 1, 5, false, true, ELECTRIC_SERVICE_TYPE);

    // Creating 100 Duplicate Meter Usages with same measured usage for Each Meter

    TestUtilityService.createDuplicateMeterUsageAndDownstreamData(
        driver,
        meterName,
        ELECTRIC_SERVICE_TYPE,
        1,
        100,
        100.0f,
        false,
        false,
        "full_service",
        "01",
        "08",
        "2024",
        "30",
        "08",
        "2024");

    // Expectation 1 not ignored usage
  }

  public static void createFiveGrowthMeterDuplicateUsages(WebDriver driver) {
    String meterName = "Test Meter 5Growth";
    //  Creating 5 Base Meters
    TestUtilityService.createMeters(driver, meterName, 1, 5, false, true, WATER_SERVICE_TYPE);

    // Creating 100 Duplicate Meter Usages with same measured usage for Each Meter

    TestUtilityService.createDuplicateMeterUsageAndDownstreamData(
        driver,
        meterName,
        WATER_SERVICE_TYPE,
        1,
        100,
        100.0f,
        false,
        false,
        "full_service",
        "27",
        "09",
        "2024",
        "30",
        "09",
        "2024");

    // Expectation 1 not ignored usage
  }

  public static void createFiveBaseMeterDuplicateInPairUsages(WebDriver driver) {
    String meterName = "Test Meter 5BasePair";
    // Creating 5 Base Meters
    TestUtilityService.createMeters(driver, meterName, 1, 5, false, true, ELECTRIC_SERVICE_TYPE);

    // Creating 100 Duplicate Meter Usages with different measured usage for Each Meter , ie
    // measured usgae = 101 .. 200 for 1st Meter , 101..200 for 2nd Meter so on.

    TestUtilityService.createDuplicateMeterUsageAndDownstreamData(
        driver,
        meterName,
        ELECTRIC_SERVICE_TYPE,
        1,
        100,
        1000.0f,
        true,
        false,
        "full_service",
        "29",
        "10",
        "2024",
        "23",
        "11",
        "2024");

    // Expectation 100 Usages to remain as Not Ignored and downstream deleted for remaining

  }

  public static void createFiveGrowthMeterDuplicateInPairUsages(WebDriver driver) {
    String meterName = "Test Meter 5GrowthPair";
    // Creating 5 Base Meters
    TestUtilityService.createMeters(driver, meterName, 1, 5, false, true, WATER_SERVICE_TYPE);

    // Creating 100 Duplicate Meter Usages with different measured usage for Each Meter , ie
    // measured usgae = 101 .. 200 for 1st Meter , 101..200 for 2nd Meter so on.

    TestUtilityService.createDuplicateMeterUsageAndDownstreamData(
        driver,
        meterName,
        WATER_SERVICE_TYPE,
        1,
        100,
        1000.0f,
        true,
        false,
        "full_service",
        "01",
        "04",
        "2023",
        "30",
        "05",
        "2023");

    // Expectation 100 Usages to remain as Not Ignored and downstream deleted for remaining

  }

  public static void checkDataForEachTestMeter(WebDriver driver) {
    // testBaseMeterDuplicateUsage
    TestUtilityService.checkData(
        driver, "Test Meter Base 100DupUSage", ELECTRIC_SERVICE_TYPE, 1, 0, false);

    // testGrowthMeterDuplicateUsage
    TestUtilityService.checkData(
        driver, "Test Meter Growth 100DupUSage", WATER_SERVICE_TYPE, 1, 0, false);

    // createTwoDuplicateGrowthMeter
    TestUtilityService.checkData(
        driver, "Test Meter Growth 2Duplicate", WATER_SERVICE_TYPE, 1, 1, true);

    // createTwoDuplicateGrowthMeter
    TestUtilityService.checkData(
        driver, "Test Meter Base 2Duplicate", ELECTRIC_SERVICE_TYPE, 1, 1, true);

    // createFiveDuplicateBaseMeter
    TestUtilityService.checkData(
        driver, "Test Meter Growth 5Duplicate", WATER_SERVICE_TYPE, 1, 5, true);

    // createFiveDuplicateGrowthMeter
    TestUtilityService.checkData(
        driver, "Test Meter Base 5Duplicate", ELECTRIC_SERVICE_TYPE, 1, 5, true);

    // createFiveBaseMeterDuplicateUsages
    TestUtilityService.checkData(driver, "Test Meter 5Base", ELECTRIC_SERVICE_TYPE, 1, 0, false);

    // createFiveGrowthMeterDuplicateUsages
    TestUtilityService.checkData(driver, "Test Meter 5Growth", ELECTRIC_SERVICE_TYPE, 1, 0, false);

    // createFiveBaseMeterDuplicateInPairUsages
    TestUtilityService.checkData(
        driver, "Test Meter 5BasePair", ELECTRIC_SERVICE_TYPE, 100, 0, false);

    // createFiveGrowthMeterDuplicateInPairUsages
    TestUtilityService.checkData(
        driver, "Test Meter 5GrowthPair", WATER_SERVICE_TYPE, 100, 0, false);
  }
}

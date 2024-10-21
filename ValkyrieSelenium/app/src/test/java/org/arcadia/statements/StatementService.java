package org.arcadia.statements;

import static org.arcadia.utils.Constants.*;
import static org.arcadia.utils.TestUtilityService.*;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.arcadia.accounts.AccountService;
import org.arcadia.meters.MeterService;
import org.arcadia.objects.Account;
import org.arcadia.objects.Meter;
import org.arcadia.objects.Statement;
import org.arcadia.utils.TestUtilityService;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

/*
   Add Statement Related tests and methods here
*/
public class StatementService {

  public static void testStatementUpload(WebDriver driver, Statement statement) {
    statementUpload(driver, statement.getSupplier(), statement.getName());
    validateStatementFields(driver, statement);

    String currentUrl = driver.getCurrentUrl();

    runSyncAfterBackDate(driver);

    // link meters to site
    for (Account account : statement.getAccounts()) {
      for (Meter meter : account.getMeters()) {
        MeterService.linkMeterSite(driver, meter.getMeterNumber(), meter.getSiteName());
      }
    }

    for (Account account : statement.getAccounts()) {
      if (!currentUrl.equalsIgnoreCase(driver.getCurrentUrl())) {
        driver.get(currentUrl);
        sleep(2);
      }
      moveToRelatedTab(driver);
      sleep(2);
      WebElement accountLink =
          TestUtilityService.findElementWithRetry(
              driver, By.xpath("//a[contains(.,'" + account.getName() + "')]"));
      assertTrue(accountLink.isDisplayed());
      WebElement parentElement =
          accountLink.findElement(By.xpath("./..")).findElement(By.xpath("./.."));
      parentElement.click();
      AccountService.validateAccountExists(driver, account, true);
    }
  }

  /*
   * This method validates the upload statement functionality.
   */
  public static void statementUpload(WebDriver driver, String supplierName, String fileName) {
    // navigate to supplier tab
    driver.get(BASE_URL + SUPPLIER_LIST_URL);

    // find specified supplier link and click
    WebElement supplierLink =
        TestUtilityService.findElementWithRetry(driver, By.linkText(supplierName));
    assertTrue(supplierLink.isDisplayed());
    supplierLink.click();
    sleep(5);

    if (!driver.getCurrentUrl().contains(BASE_URL + SUPPLIER_RECORD_URL)) {
      // sometimes the click does not work and does not move to the record page.
      supplierLink.click();
      sleep(5);
    }

    // find file input and send file path
    WebElement fileInput =
        TestUtilityService.findElementWithRetry(driver, By.xpath("//input[@type='file']"));

    // upload file
    fileInput.sendKeys(RESOURCES_ABSOLUTE_PATH + fileName);

    // wait for file upload API call to complete
    TestUtilityService.sleep(5);

    // navigate to supplier tab
    driver.get(BASE_URL + SUPPLIER_LIST_URL);

    // find specified supplier link and click
    supplierLink = TestUtilityService.findElementWithRetry(driver, By.linkText(supplierName));
    assertTrue(supplierLink.isDisplayed());
    supplierLink.click();

    sleep(10);

    TestUtilityService.moveToRelatedView(driver, driver.getCurrentUrl(), "UtilityStatementFile");

    // validate file is uploaded and click it to go to file detail page
    WebElement fileLink =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//a[contains(.,'" + fileName + "')]"));
    assertTrue(fileLink.isDisplayed());
    WebElement parentElement = fileLink.findElement(By.xpath("./..")).findElement(By.xpath("./.."));
    parentElement.click();

    // validate status field is displayed and has SUCCESS value
    TestUtilityService.validateFieldAndValue(driver, "Status", "SUCCESS", false, false);
  }

  /*
   * This method validates the upload statement functionality for 3 mb file.
   */
  public static void testInvalidStatementUpload(
      WebDriver driver, String supplierName, String fileName) {
    // navigate to supplier tab
    driver.get(BASE_URL + SUPPLIER_LIST_URL);

    // find specified supplier link and click
    WebElement supplierLink =
        TestUtilityService.findElementWithRetry(driver, By.linkText(supplierName));
    assertTrue(supplierLink.isDisplayed());
    supplierLink.click();

    // find file input and send file path
    WebElement fileInput =
        TestUtilityService.findElementWithRetry(driver, By.xpath("//input[@type='file']"));
    // upload file
    fileInput.sendKeys(RESOURCES_ABSOLUTE_PATH + fileName);

    TestUtilityService.checkValidToastMessageDisplayed(
        driver, "File size cannot exceed 2.5MB.", RED_TOAST_RGBA);
  }

  public static void validateStatementFields(WebDriver driver, Statement statement) {
    TestUtilityService.validateFieldAndValue(
        driver, "Supplier", statement.getSupplier(), false, true);
    TestUtilityService.validateFieldAndValue(
        driver, "Utility Statement File Name", statement.getName(), false, false);
    TestUtilityService.validateFieldAndValue(driver, "Status", statement.getStatus(), false, false);
    TestUtilityService.validateFieldAndValue(
        driver, "Entity ID", statement.getEntityId(), false, false);
    TestUtilityService.validateFieldAndValue(
        driver, "Statement Id", statement.getStatementId(), false, false);
  }
}

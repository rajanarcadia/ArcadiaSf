package org.arcadia.accounts;

import static org.arcadia.utils.Constants.*;
import static org.arcadia.utils.TestUtilityService.*;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.arcadia.meters.MeterService;
import org.arcadia.objects.Account;
import org.arcadia.objects.Meter;
import org.arcadia.utils.TestUtilityService;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

/*
   Add Account Related tests and methods here
*/
public class AccountService {
  /*
   * This method validates accounts exists.
   */
  public static void validateAccountExists(
      WebDriver driver, Account account, boolean checkDownStream) {

    sleep(5);
    String currentUrl = driver.getCurrentUrl();
    validateAccountFields(driver, account);

    if (!checkDownStream) {
      return;
    }

    for (Meter meter : account.getMeters()) {
      if (!currentUrl.equalsIgnoreCase(driver.getCurrentUrl())) {
        driver.get(currentUrl);
        sleep(2);
      }
      moveToRelatedTab(driver);
      sleep(5);
      WebElement meterLink =
          TestUtilityService.findElementWithRetry(
              driver, By.xpath("//a[normalize-space()='" + meter.getMeterNumber() + "']"));
      assertTrue(meterLink.isDisplayed());
      WebElement parentElement =
          meterLink.findElement(By.xpath("./..")).findElement(By.xpath("./.."));
      parentElement.click();
      // validate all fields of the meter
      MeterService.validateMeterExists(driver, meter, checkDownStream);
    }
  }

  public static void validateAccountFields(WebDriver driver, Account account) {
    TestUtilityService.validateFieldAndValue(
        driver, "Utility Account Name", account.getName(), false, false);
    TestUtilityService.validateFieldAndValue(
        driver, "Account Number", account.getAccountNumber(), false, false);
    TestUtilityService.validateFieldAndValue(driver, "Status", account.getStatus(), false, false);
    TestUtilityService.validateFieldAndValue(
        driver, "Status Detail", account.getStatusDetail(), false, false);
    TestUtilityService.validateFieldAndValue(
        driver, "ArcadiaId", account.getArcadiaId(), false, false);
    TestUtilityService.validateFieldAndValue(
        driver, "Supplier", account.getSupplier(), false, true);
  }
}

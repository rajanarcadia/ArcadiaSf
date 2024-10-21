package org.arcadia.credentials;

import static org.arcadia.utils.Constants.*;
import static org.arcadia.utils.TestUtilityService.*;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.time.Duration;
import java.util.List;
import org.arcadia.accounts.AccountService;
import org.arcadia.meters.MeterService;
import org.arcadia.objects.Account;
import org.arcadia.objects.Credential;
import org.arcadia.objects.Log;
import org.arcadia.objects.Meter;
import org.arcadia.utils.TestUtilityService;
import org.openqa.selenium.By;
import org.openqa.selenium.StaleElementReferenceException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

/*
   Add Credential Related tests and methods here
*/
public class CredentialService {

  public static void testCreateCredential(WebDriver driver, Credential credential) {

    createCredential(
        driver, credential.getName(), credential.getCorrelationId(), credential.getSupplier());

    // wait for cred to be created
    sleep(5);
    TestUtilityService.runSyncAfterBackDate(driver);

    // link meters to site
    for (Account account : credential.getAccounts()) {
      for (Meter meter : account.getMeters()) {
        MeterService.linkMeterSite(driver, meter.getMeterNumber(), meter.getSiteName());
      }
    }

    driver.get(BASE_URL + getCustomListUrl(UTILITY_CREDENTIAL_OBJECT));
    WebElement credentialLink =
        TestUtilityService.findElementWithRetry(driver, By.linkText(credential.getName()));
    assertTrue(credentialLink.isDisplayed());
    credentialLink.click();
    sleep(2);

    String currentUrl = driver.getCurrentUrl();
    validateCredentialFields(driver, credential);
    for (Account account : credential.getAccounts()) {
      if (!currentUrl.equalsIgnoreCase(driver.getCurrentUrl())) {
        driver.get(currentUrl);
        sleep(2);
      }
      moveToRelatedView(driver, currentUrl, UTILITY_ACCOUNT_OBJECT);
      sleep(2);
      WebElement accountLink =
          TestUtilityService.findElementWithRetry(
              driver, By.xpath("//a[normalize-space()='" + account.getName() + "']"));
      assertTrue(accountLink.isDisplayed());
      WebElement parentElement =
          accountLink.findElement(By.xpath("./..")).findElement(By.xpath("./.."));
      parentElement.click();
      AccountService.validateAccountExists(driver, account, true);
    }
  }

  /*
   * This method validates the creation credentials functionality.
   */
  public static void createCredential(
      WebDriver driver, String name, String correlationId, String supplier) {
    // delete credential if exists
    deleteCredential(driver, name);

    // navigate to credentials tab
    driver.get(BASE_URL + getCustomListUrl(UTILITY_CREDENTIAL_OBJECT));

    // find and click new button
    WebElement newButton =
        TestUtilityService.findElementWithRetry(driver, By.xpath("//a[@title='New']"));
    assertTrue(newButton.isDisplayed());
    newButton.click();

    // find input elements and send values
    WebElement nameInput =
        TestUtilityService.findElementWithRetry(driver, By.xpath("//input[@name='Name']"));
    assertTrue(nameInput.isDisplayed());
    nameInput.click();
    nameInput.sendKeys(name);

    WebElement correlationIdInput =
        TestUtilityService.findElementWithRetry(
            driver,
            By.xpath("//input[@name='" + getPackageAgnosticString("CorrelationID__c") + "']"));
    assertTrue(correlationIdInput.isDisplayed());
    correlationIdInput.click();
    correlationIdInput.sendKeys(correlationId);

    // find search supplier input and send supplier name
    WebElement searchSupplier =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//input[@placeholder='Search Suppliers...']"));
    assertTrue(searchSupplier.isDisplayed());
    searchSupplier.sendKeys(supplier);

    // from dropdown select supplier matching supplier name
    WebElement searchSupplierDropdown =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//li[contains(.,'" + supplier + "')]"));
    sleep(2);
    assertTrue(searchSupplierDropdown.isDisplayed());
    searchSupplierDropdown.click();

    // find and click save button
    WebElement saveButton =
        TestUtilityService.findElementWithRetry(driver, By.xpath("//button[@name='SaveEdit']"));
    assertTrue(saveButton.isDisplayed());
    saveButton.click();

    sleep(2); // let the credential get created and UI to move to cred detail page.

    TestUtilityService.validateFieldAndValue(driver, "Utility Credential Name", name, false, false);
  }

  /*
   * This method validates the creation credentials through Connect App functionality.
   */
  public static void createCredentialConnectApp(
      WebDriver driver, String provider, String username, String password, String supplier) {

    String name = "Test Credential Connect App";

    // delete credential if exists
    deleteCredential(driver, name);

    // navigate to credentials tab
    driver.get(BASE_URL + getCustomListUrl(UTILITY_CREDENTIAL_OBJECT));

    // find and click new button
    WebElement newButton =
        TestUtilityService.findElementWithRetry(driver, By.xpath("//a[@title='New']"));
    assertTrue(newButton.isDisplayed());
    newButton.click();

    // find input elements and send values
    WebElement nameInput =
        TestUtilityService.findElementWithRetry(driver, By.xpath("//input[@name='Name']"));
    assertTrue(nameInput.isDisplayed());
    nameInput.click();
    nameInput.sendKeys(name);

    // find search supplier input and send supplier name
    WebElement searchSupplier =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//input[@placeholder='Search Suppliers...']"));
    assertTrue(searchSupplier.isDisplayed());
    searchSupplier.sendKeys(supplier);

    // from dropdown select supplier matching supplier name
    WebElement searchSupplierDropdown =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//li[contains(.,'" + supplier + "')]"));
    assertTrue(searchSupplierDropdown.isDisplayed());
    searchSupplierDropdown.click();

    // find and click save button
    WebElement saveButton =
        TestUtilityService.findElementWithRetry(driver, By.xpath("//button[@name='SaveEdit']"));
    assertTrue(saveButton.isDisplayed());
    saveButton.click();

    sleep(2); // let the credential get created and UI to move to cred detail page.

    TestUtilityService.validateFieldAndValue(driver, "Utility Credential Name", name, false, false);

    // wait for connect app to load
    sleep(20);

    String credDetailUrl = driver.getCurrentUrl();

    // find nested iframe and switch to it
    WebElement iframeParent =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//div[contains(@class, 'iframe-parent')]"));
    WebElement iframe = findElementWithRetry(iframeParent, By.tagName("iframe"));
    driver.switchTo().frame(iframe);
    iframe = TestUtilityService.findElementWithRetry(driver, By.tagName("iframe"));
    driver.switchTo().frame(iframe);
    iframe = TestUtilityService.findElementWithRetry(driver, By.tagName("iframe"));
    driver.switchTo().frame(iframe);

    // find provider input and send values
    WebElement providerInput =
        TestUtilityService.findElementWithRetry(driver, By.xpath("//input[@id='providerName']"));
    assertTrue(providerInput.isDisplayed());
    providerInput.click();
    providerInput.sendKeys(provider);

    WebElement providerDropdown =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//span[contains(.,'" + provider + "')]"));
    assertTrue(providerDropdown.isDisplayed());
    providerDropdown.click();

    // find and click Next button
    WebElement nextButton =
        TestUtilityService.findElementWithRetry(driver, By.xpath("//button[@id='next']"));
    assertTrue(nextButton.isDisplayed());
    nextButton.click();

    WebElement usernameInput =
        TestUtilityService.findElementWithRetry(driver, By.xpath("//input[@id='Email Address']"));
    assertTrue(usernameInput.isDisplayed());
    usernameInput.click();
    usernameInput.sendKeys(username);

    WebElement passwordInput =
        TestUtilityService.findElementWithRetry(driver, By.xpath("//input[@id='Password']"));
    assertTrue(passwordInput.isDisplayed());
    passwordInput.click();
    passwordInput.sendKeys(password);

    WebElement TCcheckbox =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//input[@id='termsAndConditions-input']"));
    assertTrue(TCcheckbox.isDisplayed());
    WebElement TCcheckboxParent = TCcheckbox.findElement(By.xpath("./.."));
    TCcheckboxParent.click();

    // find and click Submit button
    WebElement submitButton =
        TestUtilityService.findElementWithRetry(driver, By.xpath("//button[@id='submit']"));
    assertTrue(submitButton.isDisplayed());
    submitButton.click();

    sleep(30);
    // to refresh and move out of iframe
    driver.get(credDetailUrl);

    TestUtilityService.validateFieldAndValue(driver, "Status", "Sent To Arcadia", false, false);
  }

  public static void deleteCredential(WebDriver driver, String credentialName) {
    // navigate to credentials list
    driver.get(BASE_URL + getCustomListUrl(UTILITY_CREDENTIAL_OBJECT));
    driver.navigate().refresh();

    // search for the credential and delete if exists
    if (TestUtilityService.isElementPresent(driver, By.linkText(credentialName))) {
      WebElement credentialObject =
          TestUtilityService.findElementWithRetry(driver, By.linkText(credentialName));
      assertTrue(credentialObject.isDisplayed());
      WebElement credRow =
          credentialObject
              .findElement(By.xpath("./.."))
              .findElement(By.xpath("./.."))
              .findElement(By.xpath("./.."));
      WebElement actionsButton = credRow.findElement(By.xpath(".//a[contains(.,'Show Actions')]"));
      actionsButton.click();
      sleep(5);
      WebElement deleteButton =
          TestUtilityService.findElementWithRetry(driver, By.xpath("//a[@title='Delete']"));
      WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));
      wait.until(ExpectedConditions.elementToBeClickable(deleteButton));
      sleep(2);
      deleteButton.click();
      sleep(5);
      WebElement confirmDeleteButton =
          TestUtilityService.findElementWithRetry(driver, By.xpath("//button[@title='Delete']"));
      assertTrue(confirmDeleteButton.isDisplayed());
      confirmDeleteButton.click();
      sleep(2);
      driver.navigate().refresh();
    }
  }

  public static void validateCredentialFields(WebDriver driver, Credential credential) {
    TestUtilityService.validateFieldAndValue(
        driver, "Utility Credential Name", credential.getName(), false, false);
    TestUtilityService.validateFieldAndValue(
        driver, "Correlation ID", credential.getCorrelationId(), false, false);
    TestUtilityService.validateFieldAndValue(
        driver, "Username", credential.getUserName(), false, false);
    TestUtilityService.validateFieldAndValue(
        driver, "Status", credential.getStatus(), false, false);
    TestUtilityService.validateFieldAndValue(
        driver, "Status Detail", credential.getStatusDetail(), false, false);
    TestUtilityService.validateFieldAndValue(
        driver, "Provider Name", credential.getSupplier(), false, true);
    TestUtilityService.validateFieldAndValue(
        driver, "ArcadiaId", credential.getArcadiaId(), false, false);
  }

  public static void createCredentialForReplay(WebDriver driver) {
    createCredentialUsingCorrelationId(driver, "MeterUsageReplay", "NZC-ARC-a071y000006He62AAC");
  }

  public static void deleteCredentialBothPlaces(WebDriver driver, String credentialName) {
    // In local testing
    runSyncAfterBackDate(driver);

    driver.get(BASE_URL + getCustomListUrl(UTILITY_CREDENTIAL_OBJECT));
    searchCredential(driver, credentialName);
    openCred(driver, credentialName);
    editCred(driver);
    WebElement arcadiaIdElement =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//input[@name='" + getPackageAgnosticString("UrjanetId__c") + "']"));
    assertTrue(arcadiaIdElement.isDisplayed());
    String arcadiaId = arcadiaIdElement.getAttribute("value");
    sleep(2);
    WebElement cancelButton =
        TestUtilityService.findElementWithRetry(driver, By.xpath("//button[@name='CancelEdit']"));
    assertTrue(cancelButton.isDisplayed());
    cancelButton.click();

    deleteCredential(
        driver,
        By.xpath(
            "//button[@name='"
                + getPackageAgnosticString("UtilityCredential__c.")
                + getPackageAgnosticString("Delete_Credential")
                + "']"));
    sleep(2);

    WebElement deleteBoth =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//button[normalize-space()='Delete from both']"));
    assertTrue(deleteBoth.isDisplayed());
    deleteBoth.click();

    sleep(4);
    driver.get(BASE_URL + getCustomListUrl(CREDENTIAL_DELETION_OBJECT));
    WebElement deleteRecord =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//span[contains(text(),'" + arcadiaId + "')]"));
    assertTrue(deleteRecord.isDisplayed());
  }

  private static void editCred(WebDriver driver) {
    WebElement editButton =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//button[normalize-space()='Edit']"));
    assertTrue(editButton.isDisplayed());
    editButton.click();
    sleep(5);
  }

  public static void deleteCredentialFromSF(WebDriver driver, String credentialName) {

    driver.get(BASE_URL + getCustomListUrl(UTILITY_CREDENTIAL_OBJECT));
    searchCredential(driver, credentialName);
    openCred(driver, credentialName);

    deleteCredential(
        driver,
        By.xpath(
            "//button[@name='"
                + getPackageAgnosticString("UtilityCredential__c.")
                + getPackageAgnosticString("Delete_Credential")
                + "']"));
    sleep(2);

    WebElement cancelButton =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//button[contains(text(),'Cancel')]"));
    assertTrue(cancelButton.isDisplayed());
    cancelButton.click();
    deleteCredential(
        driver,
        By.xpath(
            "//button[@name='"
                + getPackageAgnosticString("UtilityCredential__c.")
                + getPackageAgnosticString("Delete_Credential")
                + "']"));
    sleep(2);
    WebElement deleteInNzcButton =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//button[normalize-space()='Delete from Net Zero Cloud Only']"));
    assertTrue(deleteInNzcButton.isDisplayed());
    deleteInNzcButton.click();

    sleep(4);
    driver.get(BASE_URL + getCustomListUrl(UTILITY_CREDENTIAL_OBJECT));
    searchCredential(driver, credentialName);
    assertFalse(isElementPresent(driver, By.xpath("//a[@title='" + credentialName + "']")));
  }

  public static void createCredentialIfNotPresent(
      WebDriver driver, String credentialName, String correlationID) {
    // create credential if not exists
    createCredentialUsingCorrelationId(driver, credentialName, correlationID);
    runSyncAfterBackDate(driver);
  }

  private static void deleteCredential(WebDriver driver, By xpath) {
    WebElement deleteButton = TestUtilityService.findElementWithRetry(driver, xpath);
    assertTrue(deleteButton.isDisplayed());
    new WebDriverWait(driver, Duration.ofSeconds(5))
        .until(ExpectedConditions.elementToBeClickable(deleteButton))
        .click();
  }

  private static void searchCredential(WebDriver driver, String credentialName) {

    WebElement searchInput =
        TestUtilityService.findElementWithRetry(
            driver,
            By.xpath(
                "//input[@name='"
                    + getPackageAgnosticString("UtilityCredential__c-search-input")
                    + "']"));
    assertTrue(searchInput.isDisplayed());
    searchInput.sendKeys(credentialName);

    WebElement refresh =
        TestUtilityService.findElementWithRetry(driver, By.xpath("//button[@title='Refresh']"));
    assertTrue(refresh.isDisplayed());
    refresh.click();
  }

  private static void openCred(WebDriver driver, String credentialName) {

    try {
      WebElement credLink =
          TestUtilityService.findElementWithRetry(
              driver, By.xpath("//a[@title='" + credentialName + "']"));
      assertTrue(credLink.isDisplayed());
      credLink.click();
    } catch (StaleElementReferenceException e) {
      WebElement credLink =
          TestUtilityService.findElementWithRetry(
              driver, By.xpath("//a[@title='" + credentialName + "']"));
      assertTrue(credLink.isDisplayed());
      credLink.click();
    }
    sleep(1);
  }

  public static void deleteCredentialFailedCase(WebDriver driver, String arcadiaId) {
    String credentialName = "TestDeleteCredential" + arcadiaId;

    // navigate to credentials list
    driver.get(BASE_URL + getCustomListUrl(UTILITY_CREDENTIAL_OBJECT));
    driver.navigate().refresh();

    // search for the credential and create if not exists
    if (!TestUtilityService.isElementPresent(driver, By.linkText(credentialName))) {
      if (arcadiaId.equalsIgnoreCase("null")) {
        createCredentialUsingCorrelationId(driver, credentialName, credentialName);
      } else {
        createCredentialUsingScript(driver, credentialName, credentialName, arcadiaId);
      }
    }

    driver.get(BASE_URL + getCustomListUrl(UTILITY_CREDENTIAL_OBJECT));
    searchCredential(driver, credentialName);
    openCred(driver, credentialName);
    deleteCredential(
        driver,
        By.xpath(
            "//button[@name='"
                + getPackageAgnosticString("UtilityCredential__c.")
                + getPackageAgnosticString("Delete_Credential")
                + "']"));
    sleep(2);
    WebElement deleteInNzcButton =
        TestUtilityService.findElementWithRetry(
            driver, By.xpath("//button[normalize-space()='Delete from both']"));
    assertTrue(deleteInNzcButton.isDisplayed());
    deleteInNzcButton.click();
    Log log;

    if (arcadiaId.equalsIgnoreCase("null")) {

      log =
          Log.builder()
              .className("DeleteCredentialApiController")
              .message("ArcadiaId is null")
              .level("ERROR")
              .build();
    } else {

      log =
          Log.builder()
              .className("DeleteCredentialApiController")
              .message("Failed to disable Credential : " + arcadiaId)
              .level("ERROR")
              .build();
    }

    sleep(5);

    checkLogMessage(driver, List.of(log));

    driver.get(BASE_URL + getCustomListUrl(UTILITY_CREDENTIAL_OBJECT));
    searchCredential(driver, credentialName);
    openCred(driver, credentialName);
  }

  public static void testCredentialListViews(WebDriver driver, String listViewName) {
    driver.get(BASE_URL + getCustomListUrl(UTILITY_CREDENTIAL_OBJECT, listViewName));

    if (listViewName.equalsIgnoreCase("active")) {

      List<WebElement> enabledCheckboxes =
          findElementsWithRetry(driver, By.xpath("//span[@class='uiImage uiOutputCheckbox']"), 5);

      for (WebElement checkbox : enabledCheckboxes) {
        assertTrue(checkbox.isDisplayed());
        assertTrue(checkbox.getAttribute("innerHTML").contains("checked"));
      }

    } else if (listViewName.equalsIgnoreCase("inactive")) {
      List<WebElement> enabledCheckboxes =
          findElementsWithRetry(driver, By.xpath("//span[@class='uiImage uiOutputCheckbox']"), 5);

      for (WebElement checkbox : enabledCheckboxes) {
        assertTrue(checkbox.isDisplayed());
        assertTrue(checkbox.getAttribute("innerHTML").contains("unchecked"));
      }

    } else if (listViewName.equalsIgnoreCase("issues")) {
      assertFalse(isElementPresent(driver, By.xpath("//span[contains(.,'OK')]")));
      assertFalse(isElementPresent(driver, By.xpath("//span[contains(.,'Pending')]")));
      assertFalse(isElementPresent(driver, By.xpath("//span[contains(.,'Sent to Arcadia')]")));
    }
  }
}

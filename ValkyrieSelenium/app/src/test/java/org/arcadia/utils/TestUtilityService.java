package org.arcadia.utils;

import static org.arcadia.utils.Constants.*;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.File;
import java.time.Duration;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.*;
import org.arcadia.accounts.AccountService;
import org.arcadia.admin.AdminService;
import org.arcadia.objects.*;
import org.arcadia.objects.Log;
import org.junit.platform.commons.util.ExceptionUtils;
import org.openqa.selenium.*;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

/*
 * This class contains utility methods used in the tests.
 */
public class TestUtilityService {

  /*
   * This method returns the ChromeOptions object with the required preferences set.
   */
  public static ChromeOptions getChromeOptions() {
    // Create a map to store  preferences
    Map<String, Object> prefs = new HashMap<>();

    // add key and value to map as follows to switch off browser notification
    // Pass the argument 1 to allow and 2 to block
    prefs.put("profile.default_content_setting_values.notifications", 2);

    prefs.put("profile.default_content_settings.popups", 0);
    prefs.put("download.default_directory", RESOURCES_ABSOLUTE_PATH);

    // Create an instance of ChromeOptions
    ChromeOptions options = new ChromeOptions();
    if (GIT_ACTION) {
      options.addArguments("--no-sandbox");
      options.addArguments("--disable-dev-shm-usage");
      options.addArguments("--headless");
      options.addArguments("window-size=1920,1080");
    }
    // set ExperimentalOption - prefs
    options.setExperimentalOption("prefs", prefs);
    // uncomment to use headless chrome
    //        options.addArguments("--headless");
    return options;
  }

  /*
   * This method Tests log in to the Salesforce org.
   */
  public static void login(WebDriver driver) {
    // navigate to home page
    driver.get(BASE_URL + HOME_URL);
    if (driver.getCurrentUrl().contains(BASE_URL + HOME_URL)) {
      // if navigate to home page was successful, we are already logged in
      return;
    }

    // get username and password input fields and send username and password
    WebElement usernameInput = findElementWithRetry(driver, By.xpath("//input[@id='username']"));
    assertTrue(usernameInput.isDisplayed());
    usernameInput.click();
    usernameInput.sendKeys(USERNAME);

    WebElement passwordInput = findElementWithRetry(driver, By.xpath("//input[@id='password']"));
    assertTrue(passwordInput.isDisplayed());
    passwordInput.click();
    passwordInput.sendKeys(PASSWORD);

    // find and click login button
    WebElement loginInput = findElementWithRetry(driver, By.xpath("//input[@id='Login']"));
    assertTrue(loginInput.isDisplayed());
    loginInput.click();

    // in case of otp screen wait for 25 seconds for user to enter otp
    if (!driver.getCurrentUrl().contains(HOME_URL)) {
      sleep(25);
    }

    // confirm that login was successful
    assertTrue(driver.getCurrentUrl().contains(BASE_URL + HOME_URL));

    // assert credentialsTab is displayed to validate login
    WebElement credentialsTab =
        findElementWithRetry(driver, By.xpath("//span[contains(.,'Utility Credentials')]"));
    assertTrue(credentialsTab.isDisplayed());
  }

  /*
   * This method checks if specified element is present in the current Page.
   */
  public static boolean isElementPresent(WebDriver driver, By by) {
    boolean elementPresent;
    try {
      elementPresent = !driver.findElements(by).isEmpty();
    } catch (StaleElementReferenceException ex) {
      elementPresent = !driver.findElements(by).isEmpty();
    }
    return elementPresent;
  }

  /*
   * This method pins the All List View. use it for SF default objects.
   */
  public static void pinAllListView(WebDriver driver, String path) {
    driver.get(BASE_URL + path);
    // Check if All List View is already pinned
    if (isElementPresent(driver, By.xpath("//h1[contains(.,'All')]"))) {
      // All List View already pinned
      return;
    }

    WebElement pinAllButton =
        findElementWithRetry(driver, By.xpath("//button[contains(.,'Select a List View:')]"));
    assertTrue(pinAllButton.isDisplayed());
    pinAllButton.click();

    WebElement allFilter = findElementWithRetry(driver, By.xpath("//li[contains(.,'All')]"));
    assertTrue(allFilter.isDisplayed());
    allFilter.click();

    WebElement pinnedButton =
        findElementWithRetry(driver, By.xpath("//button[contains(.,'Pin this list view.')]"));
    assertTrue(pinnedButton.isDisplayed());
    pinnedButton.click();

    checkValidToastMessageDisplayed(driver, "All Supplier was pinned.", GREEN_TOAST_RGBA);
  }

  /*
   * This method validates related tab is displayed and moves to it.
   */
  public static void moveToRelatedTab(WebDriver driver) {
    sleep(5);
    List<WebElement> relatedLinks =
        findElementsWithRetry(driver, By.xpath("//a[contains(.,'Related')]"), 5);

    for (WebElement link : relatedLinks) {
      if (link.isDisplayed()) {
        // click to move to related tab
        link.click();
        break;
      }
    }

    // wait for related tab to load
    sleep(5);
  }

  public static void sleep(int seconds) {
    try {
      Thread.sleep(seconds * 1000L);
    } catch (InterruptedException e) {
      System.out.println("Error while Thread.sleep " + ExceptionUtils.readStackTrace(e));
    }
  }

  /*
   * This method closes the alert if present.
   */
  public static void closeAlertIfPresent(WebDriver driver) {
    try {
      driver.switchTo().alert().accept();
    } catch (NoAlertPresentException ignored) {
      // Alert not present
    }
  }

  /*
   * This method validates toast Message and background colour and closes it.
   */
  public static void checkValidToastMessageDisplayed(
      WebDriver driver, String message, String rgba) {
    WebElement toastClose =
        findElementWithRetry(driver, By.xpath("//button[contains(@class, 'toastClose')]"), 3);
    WebElement parentElement = toastClose.findElement(By.xpath("./.."));
    // assert background color
    if (null != rgba) assertEquals(rgba, parentElement.getCssValue("background-color"));
    WebElement toastMessage =
        findElementWithRetry(parentElement, By.xpath("//span[contains(., '" + message + "')]"), 1);
    // assert message is displayed
    assertTrue(toastMessage.isDisplayed());
    toastClose.click();
  }

  public static void validateFieldAndValue(
      WebDriver driver, String fieldName, String fieldValue, boolean isNumber, boolean isLink) {
    List<WebElement> fieldLabels =
        findElementsWithRetry(
            driver,
            By.xpath(
                "//span[(normalize-space()='"
                    + fieldName
                    + "') and (@class='test-id__field-label')] "),
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
    WebElement fieldValueElement;
    if (isNumber) {
      fieldValueElement =
          findElementWithRetry(
              fieldParent,
              By.xpath(".//lightning-formatted-number[normalize-space()='" + fieldValue + "']"));
    } else if (isLink) {
      fieldValueElement =
          findElementWithRetry(
              fieldParent, By.xpath(".//a[normalize-space()='" + fieldValue + "']"));
    } else {
      fieldValueElement =
          findElementWithRetry(
              fieldParent,
              By.xpath(".//lightning-formatted-text[normalize-space()='" + fieldValue + "']"));
    }
    assertTrue(fieldValueElement.isDisplayed());
  }

  public static void waitUntilSpinnerInvisible(WebDriver driver) {
    WebElement spinner =
        findElementWithRetry(
            driver, By.xpath("//lightning-spinner[@class='slds-spinner_container']"));
    assertTrue(spinner.isDisplayed());
    WebDriverWait wait =
        new WebDriverWait(driver, Duration.ofSeconds(60)); // Wait for up to 60 seconds
    wait.until(ExpectedConditions.invisibilityOf(spinner));
  }

  public static void deleteFile(String filePath) {
    File file = new File(filePath);
    if (file.delete()) {
      System.out.println("File deleted successfully");
    } else {
      System.out.println("Failed to delete the file");
    }
  }

  public static boolean isFileDownloaded(String fileName) {
    File dir = new File(Constants.RESOURCES_ABSOLUTE_PATH);
    File[] files = dir.listFiles();
    if (files == null) {
      return false;
    }
    return Arrays.stream(files).anyMatch(file -> file.getName().equals(fileName));
  }

  public static void downloadFile(WebDriver driver, String xpathExpression, String fileName) {
    if (!isFileDownloaded(fileName)) {
      WebElement fileLink = findElementWithRetry(driver, By.xpath(xpathExpression));
      assertTrue(fileLink.isDisplayed());
      fileLink.click();
      WebDriverWait wait =
          new WebDriverWait(driver, Duration.ofSeconds(60)); // Wait for up to 60 seconds
      wait.until((WebDriver d) -> isFileDownloaded(fileName));
      // validate file is downloaded
      assertTrue(isFileDownloaded(fileName));
    }
  }

  public static String findSupplierId(WebDriver driver, String supplierName) {
    driver.get(BASE_URL + SUPPLIER_LIST_URL);
    WebElement supplierObject = findElementWithRetry(driver, By.linkText(supplierName));
    assertTrue(supplierObject.isDisplayed());
    supplierObject.click();
    sleep(5);

    if (!driver.getCurrentUrl().contains(BASE_URL + SUPPLIER_RECORD_URL)) {
      // sometimes the click does not work and does not move to the record page.
      supplierObject.click();
      sleep(5);
    }

    String[] splitObjects =
        driver.getCurrentUrl() != null ? driver.getCurrentUrl().split("/") : null;
    assert splitObjects != null;
    return Arrays.stream(splitObjects).skip(splitObjects.length - 2).findFirst().orElse(null);
  }

  public static void checkLogMessage(WebDriver driver, List<Log> logs) {
    // navigate to log tab
    driver.get(BASE_URL + getCustomListUrl(LOG_OBJECT));

    sleep(5);

    for (Log log : logs) {
      WebElement logSpan =
          findElementWithRetry(driver, By.xpath("//span[contains(.,'" + log.getMessage() + "')]"));
      assertTrue(logSpan.isDisplayed());
      // get log row
      WebElement logRow = logSpan.findElement(By.xpath("./..")).findElement(By.xpath("./.."));

      ZonedDateTime currentDateTime =
          ZonedDateTime.now(ZoneId.of(DEFAULT_TIME_ZONE, ZoneId.SHORT_IDS)).plusMinutes(1);
      int attempts = 5;
      while (attempts-- > 0) {
        String currentDateTimeString = currentDateTime.format(DEFAULT_DATE_FORMAT).toLowerCase();
        try {
          // validate that Log row has current date and time
          WebElement dateSpan =
              logRow.findElement(By.xpath(".//span[contains(.,'" + currentDateTimeString + "')]"));
          assertTrue(dateSpan.isDisplayed());
          break;
        } catch (NoSuchElementException e) {
          // retry with 1 min ago
          currentDateTime = currentDateTime.minusMinutes(1);
        }
      }

      // validate that Log row has class name
      WebElement classSpan =
          logRow.findElement(By.xpath(".//span[contains(.,'" + log.getClassName() + "')]"));
      assertTrue(classSpan.isDisplayed());
      // validate that Log row has level
      WebElement levelSpan =
          logRow.findElement(By.xpath(".//span[contains(.,'" + log.getLevel() + "')]"));
      assertTrue(levelSpan.isDisplayed());
    }
  }

  public static void executeScriptInAnonymousWindow(WebDriver driver, String script) {
    driver.get(BASE_URL + DEVELOPER_CONSOLE_URL);
    sleep(3);

    if (isElementPresent(driver, By.xpath("//button[contains(.,'OK')]"))) {
      WebElement okButton = findElementWithRetry(driver, By.xpath("//button[contains(.,'OK')]"));
      if (okButton.isDisplayed()) {
        okButton.click();
      }
    }

    WebElement file =
        findElementWithRetry(driver, By.xpath("//button[@id='editorMenuEntry-btnEl']"));
    assertTrue(file.isDisplayed());
    file.click();

    WebElement closeAllFilesButton =
        findElementWithRetry(driver, By.xpath("//a[@id='closeAllFilesButton-itemEl']"));
    assertTrue(closeAllFilesButton.isDisplayed());
    closeAllFilesButton.click();

    WebElement debug = findElementWithRetry(driver, By.xpath("//button[contains(.,'Debug')]"));
    assertTrue(debug.isDisplayed());
    debug.click();

    WebElement executeAnonymousButton =
        findElementWithRetry(driver, By.xpath("//a[@id='openExecuteAnonymousWindow-itemEl']"));
    assertTrue(executeAnonymousButton.isDisplayed());
    executeAnonymousButton.click();

    // locate the CodeMirror element
    WebElement codeMirrorElement = findElementWithRetry(driver, By.className("CodeMirror"));

    // Clear the text using JavaScript
    ((JavascriptExecutor) driver)
        .executeScript("arguments[0].CodeMirror.setValue('');", codeMirrorElement);

    Actions actions = new Actions(driver);

    actions.sendKeys(script).perform();
    sleep(1);
    WebElement buttonExecuteHighlight =
        findElementWithRetry(driver, By.xpath("//div[@id='executeHighlightedButton']"));
    WebElement parentElement = buttonExecuteHighlight.findElement(By.xpath("./.."));
    WebElement executeButton =
        findElementWithRetry(parentElement, By.xpath(".//span[contains(.,'Execute')]"));
    // for local testing uncomment the below line
    //    sleep(5);
    executeButton.click();

    // wait for script to execute
    sleep(10);

    WebElement logButton = findElementWithRetry(driver, By.xpath("//button[contains(.,'Logs')]"));
    assertTrue(logButton.isDisplayed());
    logButton.click();

    // to verify script was executed successfully
    WebElement success = findElementWithRetry(driver, By.xpath("//td[contains(.,'Success')]"));
    try {
      assertTrue(success.isDisplayed());
    } catch (StaleElementReferenceException e) {
      success = findElementWithRetry(driver, By.xpath("//td[contains(.,'Success')]"));
      assertTrue(success.isDisplayed());
    }
  }

  // use to get list Url for Custom objects

  public static void runBackDatesScript(WebDriver driver) {
    String backDateScript =
        """
                    // Define datetime variables
                 Datetime updateDatetime = Datetime.newInstanceGmt(2019, 12, 17, 18, 47, 58);
                 Datetime previousUpdateDatetime = Datetime.newInstanceGmt(2019, 12, 16, 12, 30, 0);

                 // Update UtilityAccount__c records
                 List<urjanet__UtilityAccount__c> accToUpdateList = [SELECT ID, urjanet__AccountNumber__c, urjanet__LastModifiedInUrjanet__c FROM urjanet__UtilityAccount__c];

                 if(!accToUpdateList.isEmpty())
                     for(urjanet__UtilityAccount__c accToUpdate : accToUpdateList)
                         // Update the LastModifiedInUrjanet__c field
                         accToUpdate.urjanet__LastModifiedInUrjanet__c = updateDatetime;

                     // Update the records
                     if(!accToUpdateList.isEmpty())
                         update accToUpdateList;

                 // Update UtilityCredential__c records
                 List<urjanet__UtilityCredential__c> credToUpdateList = [SELECT ID, urjanet__CorrelationID__c, urjanet__LastModifiedInUrjanet__c FROM urjanet__UtilityCredential__c];

                 if(!credToUpdateList.isEmpty())
                     for(urjanet__UtilityCredential__c credToUpdate : credToUpdateList)
                         // Update the LastModifiedInUrjanet__c field
                         credToUpdate.urjanet__LastModifiedInUrjanet__c = updateDatetime;

                     // Update the records
                     if(!credToUpdateList.isEmpty())
                         update credToUpdateList;


                 // Update the custom setting instance
                 urjanet__LastSuccessfulSyncDate__c customSettingInstance = urjanet__LastSuccessfulSyncDate__c.getInstance(UserInfo.getProfileId());

                     if(customSettingInstance != null)
                         customSettingInstance.urjanet__PreviousLastSyncDate__c = previousUpdateDatetime;
                     if(customSettingInstance != null)
                         customSettingInstance.urjanet__LastSyncDate__c = updateDatetime;
                     // Update the custom setting instance
                     if(customSettingInstance != null)
                         upsert customSettingInstance;
                """;
    String finalScript = getPackageAgnosticScript(backDateScript);
    executeScriptInAnonymousWindow(driver, finalScript);
  }

  public static void createCredentialUsingCorrelationId(
      WebDriver driver, String credentialName, String correlationId) {
    String createCredQueryScript =
        """
                List<Supplier> supplier = [select ID from Supplier where Name='Test Supplier'];
                List<urjanet__UtilityCredential__c> existingCred = [select ID from urjanet__UtilityCredential__c where urjanet__CorrelationID__c='"""
            + correlationId
            + """
                '];
                urjanet__UtilityCredential__c newCred = new urjanet__UtilityCredential__c();
                newCred.urjanet__CorrelationID__c = '"""
            + correlationId
            + """
                ';
                newCred.Name = '"""
            + credentialName
            + """
                ';
                if(!supplier.isEmpty())
                newCred.urjanet__ProviderName__c = supplier.get(0).ID;

                if(!supplier.isEmpty() && existingCred.isEmpty())
                insert newCred;
                """;

    String finalScript = getPackageAgnosticScript(createCredQueryScript);
    executeScriptInAnonymousWindow(driver, finalScript);
  }

  public static void createCredentialUsingScript(
      WebDriver driver, String credentialName, String correlationId, String arcadiaId) {
    String createCredQueryScript =
        """
                    List<Supplier> supplier = [select ID from Supplier where Name='Test Supplier'];
                    List<urjanet__UtilityCredential__c> existingCred = [select ID from urjanet__UtilityCredential__c where urjanet__CorrelationID__c='"""
            + correlationId
            + """
                '];
                urjanet__UtilityCredential__c newCred = new urjanet__UtilityCredential__c();
                newCred.urjanet__CorrelationID__c = '"""
            + correlationId
            + """
                ';
                newCred.Name = '"""
            + credentialName
            + """
                ';
                newCred.urjanet__UrjanetId__c = '"""
            + arcadiaId
            + """
                ';
                if(!supplier.isEmpty())
                newCred.urjanet__ProviderName__c = supplier.get(0).ID;

                if(!supplier.isEmpty() && existingCred.isEmpty())
                insert newCred;
                """;

    String finalScript = getPackageAgnosticScript(createCredQueryScript);
    executeScriptInAnonymousWindow(driver, finalScript);
  }

  public static void updatedLastMofidifedDateForMeterUsages(
      WebDriver driver, String arcadiaIdValue) {
    String updateLastModifiedInUrjanetTime =
        """
                List<urjanet__UtilityMeterUsage__c> usages = [select urjanet__LastModifiedInUrjanet__c from urjanet__UtilityMeterUsage__c where urjanet__UrjanetId__c in ('"""
            + arcadiaIdValue
            + """
                ')];
                for(urjanet__UtilityMeterUsage__c usage: usages)
                    usage.urjanet__LastModifiedInUrjanet__c = usage.urjanet__LastModifiedInUrjanet__c.addMinutes(-15);

                update usages;
                """;
    String finalScript = getPackageAgnosticScript(updateLastModifiedInUrjanetTime);
    executeScriptInAnonymousWindow(driver, finalScript);
  }

  public static String getPackageAgnosticScript(String originalScript) {
    return PACKAGE ? originalScript : originalScript.replace("urjanet__", "");
  }

  public static void linkSiteToMeterByScript(WebDriver driver, String meterNumber) {
    String siteToMeterLinkScript =
        """
                StnryAssetEnvrSrc envSrc = [select ID, Name from StnryAssetEnvrSrc Limit 1];
                urjanet__UtilityMeter__c meter = [select ID from urjanet__UtilityMeter__c where Name='"""
            + meterNumber
            + """
                ' Limit 1];
                if(null != meter)
                    meter.urjanet__StationaryAssetEnvironmentalSource__c = envSrc.Id;

                if(null != meter)
                    update meter;
                """;
    String finalScript = getPackageAgnosticScript(siteToMeterLinkScript);
    executeScriptInAnonymousWindow(driver, finalScript);
  }

  // use to get list Url for Custom objects
  public static String getCustomListUrl(String objectName) {
    return getCustomListUrl(objectName, "All");
  }

  // use to get list Url for Custom objects
  public static String getCustomListUrl(String objectName, String listviewName) {
    if (PACKAGE) {
      return "/lightning/o/"
          + NAMESPACE
          + objectName
          + "__c/list?filterName="
          + NAMESPACE
          + listviewName;
    }
    return "/lightning/o/" + objectName + "__c/list?filterName=" + listviewName;
  }

  // use this for Strings which have package prefix in package env.
  public static String getPackageAgnosticString(String string) {
    if (PACKAGE) {
      return NAMESPACE + string;
    }
    return string;
  }

  public static String getAdminURL() {
    if (PACKAGE) {
      return ADMIN_PACKAGE_URL;
    }
    return ADMIN_URL;
  }

  public static WebElement findElementWithRetry(WebDriver driver, By by, int attempts) {
    WebElement element = null;
    while (attempts > 0) {
      try {
        element = driver.findElement(by);
        break;
      } catch (NoSuchElementException e) {
        System.out.println(
            "Exception for : "
                + by
                + " : "
                + e.getMessage()
                + " Attempt : "
                + attempts
                + " "
                + ZonedDateTime.now(ZoneId.of(DEFAULT_TIME_ZONE, ZoneId.SHORT_IDS)));
      } catch (StaleElementReferenceException e) {
        element = driver.findElement(by);
        break;
      }
      attempts--;
    }
    assert element != null;
    return element;
  }

  public static List<WebElement> findElementsWithRetry(WebDriver driver, By by, int attempts) {
    List<WebElement> elements = new ArrayList<>();
    while (attempts > 0) {
      try {
        elements = driver.findElements(by);
        if (!elements.isEmpty()) break;
      } catch (NoSuchElementException e) {
        System.out.println(
            "Exception for : "
                + e.getMessage()
                + " Attempt : "
                + attempts
                + " "
                + ZonedDateTime.now(ZoneId.of(DEFAULT_TIME_ZONE, ZoneId.SHORT_IDS)));
      } catch (StaleElementReferenceException e) {
        elements = driver.findElements(by);
        if (!elements.isEmpty()) break;
      }
      attempts--;
    }
    assert !elements.isEmpty();
    return elements;
  }

  public static WebElement findElementWithRetry(WebElement parentElement, By by, int attempts) {
    WebElement element = null;
    while (attempts > 0) {
      try {
        element = parentElement.findElement(by);
        break;
      } catch (NoSuchElementException e) {
        System.out.println(
            "NoSuchElementException for : "
                + by
                + " : "
                + e.getMessage()
                + " Attempt : "
                + attempts
                + " "
                + ZonedDateTime.now(ZoneId.of(DEFAULT_TIME_ZONE, ZoneId.SHORT_IDS)));
      } catch (StaleElementReferenceException e) {
        element = parentElement.findElement(by);
        break;
      }
      attempts--;
    }
    assert element != null;
    return element;
  }

  public static WebElement findElementWithRetry(WebElement parentElement, By by) {
    return findElementWithRetry(parentElement, by, 5);
  }

  public static WebElement findElementWithRetry(WebDriver driver, By by) {
    return findElementWithRetry(driver, by, 5);
  }

  public static void runSyncAfterBackDate(WebDriver driver) {
    runBackDatesScript(driver);

    sleep(10);

    AdminService.refreshSync(driver);

    sleep(90);
  }

  public static void validateData(
      WebDriver driver, Credential credential, boolean checkDownStream) {
    driver.get(BASE_URL + getCustomListUrl(UTILITY_CREDENTIAL_OBJECT));
    WebElement credentialLink =
        TestUtilityService.findElementWithRetry(driver, By.linkText(credential.getName()));
    assertTrue(credentialLink.isDisplayed());
    credentialLink.click();

    sleep(2);

    String currentUrl = driver.getCurrentUrl();
    for (Account account : credential.getAccounts()) {
      if (!currentUrl.equalsIgnoreCase(driver.getCurrentUrl())) {
        driver.get(currentUrl);
        sleep(2);
      }
      sleep(2);
      moveToRelatedView(driver, currentUrl, UTILITY_ACCOUNT_OBJECT);

      WebElement accountLink =
          TestUtilityService.findElementWithRetry(
              driver, By.xpath("//a[normalize-space()='" + account.getName() + "']"));
      assertTrue(accountLink.isDisplayed());

      WebElement parentElement =
          TestUtilityService.findElementWithRetry(accountLink, By.xpath("./.."))
              .findElement(By.xpath("./.."));
      parentElement.click();

      AccountService.validateAccountExists(driver, account, checkDownStream);
    }
  }

  public static void moveToRelatedView(WebDriver driver, String currentUrl, String objectName) {
    String accountRelatedView =
        currentUrl.replace("view", "related/" + getPackageAgnosticString(objectName) + "s__r/view");
    driver.get(accountRelatedView);
    sleep(5);
  }

  public static void executeQuery(WebDriver driver, String query) {

    query = getPackageAgnosticScript(query);
    driver.get(BASE_URL + DEVELOPER_CONSOLE_URL);
    sleep(3);

    if (isElementPresent(driver, By.xpath("//button[contains(.,'OK')]"))) {
      WebElement okButton = findElementWithRetry(driver, By.xpath("//button[contains(.,'OK')]"));
      if (okButton.isDisplayed()) {
        okButton.click();
      }
    }

    WebElement queryButton =
        findElementWithRetry(driver, By.xpath("//button[contains(.,'Query Editor')]"));
    queryButton.click();

    sleep(10);

    // locate the query text area element
    WebElement queryTextArea =
        findElementWithRetry(driver, By.xpath("//textarea[@id='queryEditorText-inputEl']"));

    queryTextArea.clear();

    queryTextArea.sendKeys(query);

    sleep(1);

    WebElement executeButton =
        findElementWithRetry(driver, By.xpath("//button[@id='queryExecuteButton-btnEl']"));

    executeButton.click();

    // wait for query to execute
    sleep(10);
  }

  public static String getResourcesPath() {
    File file = new File("app/src/test/resources/");
    String[] absolutePath = file.getAbsolutePath().split("/");
    long appCount =
        Arrays.stream(absolutePath).filter(data -> data.equalsIgnoreCase("app")).count();
    if (appCount > 1) {
      return file.getAbsolutePath().replaceFirst("/app", "") + "/";
    }
    return file.getAbsolutePath() + "/";
  }

  public static void refreshWhileSearching(WebDriver driver) {
    WebElement refresh =
        TestUtilityService.findElementWithRetry(driver, By.xpath("//button[@title='Refresh']"));
    assertTrue(refresh.isDisplayed());
    refresh.click();
  }

  public static void createMeters(
      WebDriver driver,
      String meterName,
      Integer startIndex,
      Integer lastIndex,
      Boolean samePodNumber,
      Boolean enabled,
      String serviceType) {
    StringBuffer createMeterScript = new StringBuffer();
    createMeterScript.append(
        "StnryAssetEnvrSrc site = [SELECT Id FROM StnryAssetEnvrSrc LIMIT 1];");
    createMeterScript.append("Id siteId = site.Id;");
    createMeterScript.append(
        "List<urjanet__UtilityMeter__c> meters = new List<urjanet__UtilityMeter__c>();");
    createMeterScript.append("for (Integer i = " + startIndex + "; i < =" + lastIndex + "; i++) {");
    createMeterScript.append("    meters.add(new urjanet__UtilityMeter__c(");
    createMeterScript.append("        Name = '" + meterName + " '+i,");
    createMeterScript.append(
        "        urjanet__UrjanetId__c = 'Test Urjanet Id " + meterName + " '+i,");
    createMeterScript.append(
        "        urjanet__PodNumber__c = "
            + (samePodNumber ? "'Test Pod Number'" : "'Test Pod Number ' + i")
            + ",");
    createMeterScript.append("        urjanet__Enabled__c = " + enabled + ",");
    createMeterScript.append("        urjanet__StationaryAssetEnvironmentalSource__c = siteId,");
    createMeterScript.append("        urjanet__ServiceType__c = '" + serviceType + "'");
    createMeterScript.append("    ));");
    createMeterScript.append("}");
    createMeterScript.append("insert meters;");
    createMeterScript.append("System.debug('Meters Created : ' + meters);");

    String finalScript = getPackageAgnosticScript(createMeterScript.toString());

    executeScriptInAnonymousWindow(driver, finalScript);

    sleep(10);
  }

  public static void createDuplicateMeterUsageAndDownstreamData(
      WebDriver driver,
      String meterName,
      String serviceType,
      Integer startIndex,
      Integer lastIndex,
      Float measuredUsage,
      Boolean differentMeasuredUsage,
      Boolean toBeIgnored,
      String deregulationStatus,
      String startDay,
      String startMonth,
      String startYear,
      String endDay,
      String endMonth,
      String endYear) {

    StringBuilder createMeterUsageScript = new StringBuilder();
    createMeterUsageScript
        .append(
            "List<StnryAssetEnvrSrc> site = [SELECT Id, urjanet__UrjanetId__c FROM StnryAssetEnvrSrc LIMIT 2];")
        .append("Id siteId = site[0].Id;")
        .append(
            "List<urjanet__UtilityMeter__c> meters = [SELECT Id, urjanet__MeterNumber__c FROM urjanet__UtilityMeter__c WHERE Name LIKE '")
        .append(meterName)
        .append("%'];")
        .append(
            "List<urjanet__UtilityMeterUsage__c> usages = new List<urjanet__UtilityMeterUsage__c>();")
        .append("if (meters.isEmpty()) {System.debug('No meters provided for usage creation.');}")
        .append("for (urjanet__UtilityMeter__c meter : meters) {")
        .append(
            "if (meter.Id == null) {System.debug('Meter ID is null for meter: ' + meter); continue; }")
        .append("for (Integer i = ")
        .append(startIndex)
        .append("; i < =")
        .append(lastIndex)
        .append("; i++) {")
        .append(
            "String uniqueUrjanetId = String.valueOf(Crypto.getRandomLong()) + String.valueOf(Crypto.getRandomLong());")
        .append("System.debug('Generated urjanet__UrjanetId__c: ' + uniqueUrjanetId);")
        .append(
            "usages.add(new urjanet__UtilityMeterUsage__c(urjanet__UrjanetId__c = uniqueUrjanetId, urjanet__UtilityMeter__c = meter.Id, urjanet__MeasuredUsage__c = ")
        .append(measuredUsage);
    if (differentMeasuredUsage) {
      createMeterUsageScript.append(" + i");
    }
    createMeterUsageScript
        .append(", urjanet__PeriodStart__c = Date.newInstance(")
        .append(startYear + ",")
        .append(startMonth + ",")
        .append(startDay + ")")
        .append(", urjanet__PeriodEnd__c = ")
        .append("Date.newInstance(")
        .append(endYear + ",")
        .append(endMonth + ",")
        .append(endDay + ")")
        .append(", urjanet__Arcadia_Statement_ID__c = ")
        .append("'Test Statement ID'")
        .append(", urjanet__To_Be_Ignored__c = ")
        .append(toBeIgnored)
        .append(", urjanet__DeregulationStatus__c = '")
        .append(deregulationStatus);

    if (serviceType.equals(ELECTRIC_SERVICE_TYPE)) {
      createMeterUsageScript
          .append(
              "', urjanet__MeasurementType__c = 'general_consumption', UsageUnit__c = 'kWh'));}}")
          .append(
              "try { insert usages; System.debug('Usages Created : ' + usages); } catch (DmlException e) {System.debug('DML Exception during usage creation: ' + e.getMessage());}")
          .append("List<StnryAssetEnrgyUse> energyActivities = new List<StnryAssetEnrgyUse>();")
          .append("for (urjanet__UtilityMeterUsage__c usage : usages) {")
          .append("StnryAssetEnrgyUse energyActivity = new StnryAssetEnrgyUse();")
          .append("energyActivity.StnryAssetEnvrSrcId = siteId;")
          .append("energyActivity.Name = 'Test Energy Usage for ' + usage.Id;")
          .append("energyActivity.FuelType = 'Electricity';")
          .append("energyActivity.urjanet__UtilityMeterUsage__c = usage.Id;")
          .append("energyActivities.add(energyActivity);")
          .append("}")
          .append("insert energyActivities;");
    } else if (serviceType.equals(WATER_SERVICE_TYPE)) {
      createMeterUsageScript
          .append(
              "', urjanet__MeasurementType__c = 'general_consumption', UsageUnit__c = 'ccf'));}}")
          .append(
              "try { insert usages; System.debug('Usages Created : ' + usages); } catch (DmlException e) {System.debug('DML Exception during usage creation: ' + e.getMessage());}")
          .append(
              "List<StnryAssetWaterActvty> waterActivities = new List<StnryAssetWaterActvty>();")
          .append("for (urjanet__UtilityMeterUsage__c usage : usages) {")
          .append("StnryAssetWaterActvty waterActivity = new StnryAssetWaterActvty();")
          .append("waterActivity.StnryAssetEnvrSrcId = siteId;")
          .append("waterActivity.ActivityType = 'consumption';")
          .append("waterActivity.Name = 'Test Water Activity for ' + usage.Id;")
          .append("waterActivity.urjanet__UtilityMeterUsage__c = usage.Id;")
          .append("waterActivities.add(waterActivity);")
          .append("}")
          .append("insert waterActivities;");
    }

    String finalScript = getPackageAgnosticScript(createMeterUsageScript.toString());

    executeScriptInAnonymousWindow(driver, finalScript);
    sleep(10);

    deleteQueueItems(driver);
  }

  public static void deleteQueueItems(WebDriver driver) {
    sleep(10);
    String deleteQueueItemsScript =
        """
            List<urjanet__QueueItem__c> items = [SELECT Id FROM urjanet__QueueItem__c];
            delete items;
            """;
    String finalScript = getPackageAgnosticScript(deleteQueueItemsScript);
    executeScriptInAnonymousWindow(driver, finalScript);
    sleep(10);
  }

  public static void checkDisabledMeters(
      WebDriver driver, String meterName, Integer expectedRowCount) {
    String checkDisabledMetersQuery =
        """
          Select id from urjanet__UtilityMeter__c where Name LIKE '%"""
            + meterName
            + """
            %'
            and urjanet__Enabled__c = false
            """;
    String finalQuery = getPackageAgnosticScript(checkDisabledMetersQuery);

    executeQuery(driver, finalQuery);

    sleep(10);

    WebElement result =
        findElementWithRetry(
            driver,
            By.xpath("//span[contains(.,'Query Results - Total Rows: " + expectedRowCount + "')]"));
    assertTrue(result.isDisplayed());
  }

  public static void checkNotIgnoredUsages(
      WebDriver driver, String meterName, Integer expectedRowCount) {

    String checkNotIgnoredUsagesQuery =
        """
            Select id from urjanet__UtilityMeterUsage__c where urjanet__UtilityMeter__r.Name LIKE '%"""
            + meterName.trim()
            + """
            %' and urjanet__To_Be_Ignored__c = false
            """;
    String finalQuery = getPackageAgnosticScript(checkNotIgnoredUsagesQuery);

    executeQuery(driver, finalQuery);

    sleep(10);

    WebElement result =
        findElementWithRetry(
            driver,
            By.xpath("//span[contains(.,'Query Results - Total Rows: " + expectedRowCount + "')]"));
    assertTrue(result.isDisplayed());
  }

  public static void deleteDuplicateTestData(WebDriver driver, String meterName) {
    String deleteDuplicateTestDataScript =
        """
            List<urjanet__UtilityMeterUsage__c> usages = [SELECT Id FROM urjanet__UtilityMeterUsage__c where urjanet__UtilityMeter__r.Name LIKE '%"""
            + meterName
            + """
            %'];
            List<StnryAssetEnrgyUse> saeus = [SELECT Id FROM StnryAssetEnrgyUse where urjanet__UtilityMeterUsage__r.urjanet__UtilityMeter__r.Name LIKE '%"""
            + meterName
            + """
            %'];
            List<StnryAssetWaterActvty> sawas = [SELECT Id FROM StnryAssetWaterActvty where urjanet__UtilityMeterUsage__r.urjanet__UtilityMeter__r.Name LIKE '%"""
            + meterName
            + """
            %'];
            List<urjanet__UtilityMeter__c> meters = [SELECT Id FROM urjanet__UtilityMeter__c where Name LIKE '%"""
            + meterName
            + """
            %'];

            if(!saeus.isEmpty()) delete saeus;
            if(!sawas.isEmpty()) delete sawas;
            if(!usages.isEmpty()) delete usages;
            if(!meters.isEmpty()) delete meters;
            System.debug('Meters deleted = ' + meters.size() + 'Usages deleted = ' + usages.size() + 'Energy Activities deleted = ' + saeus.size() + 'Water Activities deleted = ' + sawas.size());
            """;
    String finalScript = getPackageAgnosticScript(deleteDuplicateTestDataScript);
    executeScriptInAnonymousWindow(driver, finalScript);
    sleep(10);
  }

  public static void checkDownsStreamDataDeletedForIgnoredUsages(
      WebDriver driver, String meterName, String serviceType) {
    String checkDownsStreamDataDeletedQuery;
    if (GROWTH_SERVICE_TYPES.contains(serviceType)) {
      checkDownsStreamDataDeletedQuery =
          """
            Select id from StnryAssetWaterActvty where Name LIKE '%Test Water Activity%' and urjanet__UtilityMeterUsage__r.urjanet__To_Be_Ignored__c = true
            """;
    } else {
      checkDownsStreamDataDeletedQuery =
          """
              Select id from StnryAssetEnrgyUse where Name LIKE '%Test Energy Usage%' and urjanet__UtilityMeterUsage__r.urjanet__To_Be_Ignored__c = true
              """;
    }
    String finalQuery = getPackageAgnosticScript(checkDownsStreamDataDeletedQuery);

    executeQuery(driver, finalQuery);

    sleep(10);
    WebElement result =
        findElementWithRetry(
            driver, By.xpath("//span[contains(.,'Query Results - Total Rows: 0')]"));
    assertTrue(result.isDisplayed());
  }

  public static void runRefreshSync(WebDriver driver) {
    AdminService.refreshSync(driver);
    sleep(120);
  }

  public static void checkData(
      WebDriver driver,
      String meterName,
      String serviceType,
      Integer notIgnoredUsageCount,
      Integer disabledMeterCount,
      Boolean checkMeters) {

    TestUtilityService.checkNotIgnoredUsages(driver, meterName, notIgnoredUsageCount);
    sleep(2);

    TestUtilityService.checkDownsStreamDataDeletedForIgnoredUsages(driver, meterName, serviceType);
    sleep(2);

    if (checkMeters) {
      TestUtilityService.checkDisabledMeters(driver, meterName, disabledMeterCount);
      sleep(2);
    }
  }
}

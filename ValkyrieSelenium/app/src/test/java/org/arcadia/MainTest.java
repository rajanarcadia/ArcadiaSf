package org.arcadia;

import static org.arcadia.utils.Constants.*;

import java.time.Duration;
import org.arcadia.admin.AdminService;
import org.arcadia.credentials.CredentialService;
import org.arcadia.meterUsage.MeterUsageService;
import org.arcadia.meters.MeterService;
import org.arcadia.objects.Credential;
import org.arcadia.objects.MeterUsage;
import org.arcadia.objects.Statement;
import org.arcadia.statements.StatementService;
import org.arcadia.tests.ReplayFeature;
import org.arcadia.utils.MyTestWatcher;
import org.arcadia.utils.TestUtilityService;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;
import org.openqa.selenium.Dimension;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;

/*
 * This class contains All the tests to be executed.
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@ExtendWith(MyTestWatcher.class)
public class MainTest {

  private static WebDriver driver;

  /*
   * This method sets up the WebDriver.
   */
  @BeforeAll
  public static void setUp() {
    // Set up WebDriver, e.g., ChromeDriver
    if (null != System.getProperty("gitAction") && System.getProperty("gitAction").equals("true")) {
      System.setProperty("webdriver.chrome.driver", LINUX_CHROME_DRIVER_PATH);
      GIT_ACTION = true;
    } else {
      System.setProperty("webdriver.chrome.driver", MAC_CHROME_DRIVER_PATH);
    }

    ChromeOptions options = TestUtilityService.getChromeOptions();

    driver = new ChromeDriver(options);
    if (FULL_SCREEN) {
      driver.manage().window().maximize();
    } else {
      Dimension dimension = new Dimension(WINDOW_WIDTH, WINDOW_HEIGHT);
      driver.manage().window().setSize(dimension);
    }
    driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(DEFAULT_IMPLICIT_WAIT));
    MyTestWatcher.setDriver(driver);
  }

  /*
   * This method closes the WebDriver after all tests are executed.
   */
  @AfterAll
  public static void tearDown() {
    TestUtilityService.sleep(5);
    // Close the WebDriver after All test
    if (driver != null) {
      driver.quit();
    }
  }

  /*
   * This method is executed before each test. Add logic here which needs to be executed before each test.
   */
  @BeforeEach
  public void beforeEach() {
    driver.get(BASE_URL + HOME_URL);
    // sometime alert appears, close the alert if present
    TestUtilityService.closeAlertIfPresent(driver);
    TestUtilityService.sleep(5);
    if (!driver.getCurrentUrl().contains(BASE_URL + HOME_URL)) {
      // if navigate to home page was successful, we are already logged in
      TestUtilityService.login(driver);
    }
  }

  @Test
  @Order(1)
  public void testLogin() {
    TestUtilityService.login(driver);
  }

  @Order(2)
  @ParameterizedTest
  @MethodSource("org.arcadia.testData.TestData#createCredData")
  /*
   * This method tests the creation credentials functionality. Uses TestData.createCredData method to get the test data.
   */
  public void testCreateCredentials(Credential credential) {
    CredentialService.testCreateCredential(driver, credential);
  }

  @Order(3)
  @ParameterizedTest
  @MethodSource("org.arcadia.testData.TestData#createStatementUploadData")
  /*
   * This method tests the upload statement functionality. Uses TestData.createStatementUploadData method to get the test data.
   */
  public void testUploadStatement(Statement statement) {
    StatementService.testStatementUpload(driver, statement);
  }

  @Order(4)
  @ParameterizedTest
  /*
   * This method tests the download statement functionality. Uses TestData.createDownloadStatementData method to get the test data.
   */
  @MethodSource("org.arcadia.testData.TestData#createDownloadStatementData")
  public void testDownloadStatement(MeterUsage meterUsage) {
    MeterUsageService.downloadStatement(
        driver, meterUsage.getMeterUsageName(), meterUsage.getStatementId());
  }

  @Order(5)
  @ParameterizedTest
  @Disabled
  // disabling so it does not run all the time as it will create unnecessary jobs at odin.
  @MethodSource("org.arcadia.testData.TestData#createCredConnectData")
  /*
   * This method tests the creation credentials functionality using the connect app. Uses TestData.createCredConnectData method to get the test data.
   */
  public void testCreateCredentialConnectApp(
      String provider, String username, String password, String supplier) {
    CredentialService.createCredentialConnectApp(driver, provider, username, password, supplier);
  }

  @Test
  @Order(6)
  public void testMultipleSync() {
    AdminService.testMultipleSync(driver);
  }

  @Order(7)
  @ParameterizedTest
  @MethodSource("org.arcadia.testData.TestData#createInvalidStatementUploadData")
  /*
   * This method tests the invalid upload statement functionality. Uses TestData.createInvalidStatementUploadData method to get the test data.
   */
  public void testInvalidUploadStatement(String supplierName, String fileName) {
    StatementService.testInvalidStatementUpload(driver, supplierName, fileName);
  }

  @Order(8)
  @ParameterizedTest
  @MethodSource("org.arcadia.testData.TestData#createStationaryAssetsData")
  /*
   * This method tests the MeterUsage And StationaryAssets link and their fields. Uses TestData.createStationaryAssetsData method to get the test data.
   */
  public void testMeterUsageAndStationaryAssets(MeterUsage meterUsage) {
    MeterUsageService.validateMeterUsageAndAssets(driver, meterUsage);
  }

  @Order(9)
  @ParameterizedTest
  @MethodSource("org.arcadia.testData.TestData#oneRecordWithPositiveBulkUploadData")
  /*
   * This method tests the bulk upload functionality with one positive record. Uses TestData.oneRecordWithPositiveBulkUploadData method to get the test data.
   */
  public void testOneRecordWithPositiveBulkUpload(
      String fileName, String credentialName, String[] toastMessageXpath) {
    AdminService.uploadBulkCredentialFileAndVerifyStatus(
        driver,
        fileName,
        credentialName,
        toastMessageXpath,
        null,
        null,
        false,
        false,
        false,
        false);
  }

  @Order(10)
  @ParameterizedTest
  @Disabled
  @MethodSource("org.arcadia.testData.TestData#oneRecordWithDuplicateBulkUploadData")
  /*
   * This method tests the bulk upload functionality with one duplicate record. Uses TestData.oneRecordWithDuplicateBulkUploadData method to get the test data.
   */
  public void testOneRecordWithDuplicateBulkUpload(
      String fileName, String credentialName, String[] toastMessageXpath) {
    AdminService.uploadBulkCredentialFileAndVerifyStatus(
        driver,
        fileName,
        credentialName,
        toastMessageXpath,
        null,
        null,
        false,
        false,
        false,
        false);
  }

  @Order(11)
  @ParameterizedTest
  @Disabled
  @MethodSource(
      "org.arcadia.testData.TestData#onePositiveRecordAndOneDuplicateRecordBulkUploadData")
  /*
   * This method tests the bulk upload functionality with one positive record and one duplicate record. Uses TestData.onePositiveRecordAndOneDuplicateRecordBulkUploadData method to get the test data.
   */
  public void testOnePositiveRecordAndOneDuplicateRecordBulkUpload(
      String fileName, String credentialName, String[] toastMessageXpath) {
    CredentialService.deleteCredentialFromSF(driver, credentialName);
    AdminService.uploadBulkCredentialFileAndVerifyStatus(
        driver, fileName, credentialName, toastMessageXpath, null, null, false, true, false, false);
  }

  @Order(12)
  @ParameterizedTest
  @Disabled
  @MethodSource("org.arcadia.testData.TestData#oneNegativeRecordWithInvalidServiceIdData")
  /*
   * This method tests the bulk upload functionality with one negative record with invalid service id. Uses TestData.oneNegativeRecordWithInvalidServiceIdData method to get the test data.
   */
  public void testOneNegativeRecordWithInvalidServiceIdBulkUpload(
      String fileName, String credentialName, String serviceId, String[] toastMessageXpath) {
    AdminService.uploadBulkCredentialFileAndVerifyStatus(
        driver,
        fileName,
        credentialName,
        toastMessageXpath,
        serviceId,
        null,
        false,
        false,
        false,
        false);
  }

  @Order(13)
  @ParameterizedTest
  @Disabled
  @MethodSource("org.arcadia.testData.TestData#oneNegativeRecordWithInvalidSupplierIdData")
  /*
   * This method tests the bulk upload functionality with one negative record with invalid supplier id. Uses TestData.oneNegativeRecordWithInvalidSupplierIdData method to get the test data.
   */
  public void testOneNegativeRecordWithInvalidSupplierIdBulkUpload(
      String fileName, String credentialName, String supplierId, String[] toastMessageXpath) {
    AdminService.uploadBulkCredentialFileAndVerifyStatus(
        driver,
        fileName,
        credentialName,
        toastMessageXpath,
        null,
        supplierId,
        false,
        false,
        false,
        false);
  }

  @Order(14)
  @ParameterizedTest
  @Disabled
  @MethodSource("org.arcadia.testData.TestData#twoRecordsPositiveAndInvalidServiceIdData")
  /*
   * This method tests the bulk upload functionality with two records, one positive and one with invalid service id. Uses TestData.twoRecordsPositiveAndInvalidServiceIdData method to get the test data.
   */
  public void testTwoRecordsPositiveAndInvalidServiceIdBulkUpload(
      String fileName, String credentialName, String[] toastMessageXpath) {
    AdminService.uploadBulkCredentialFileAndVerifyStatus(
        driver, fileName, credentialName, toastMessageXpath, null, null, true, false, false, false);
  }

  @Order(15)
  @ParameterizedTest
  @Disabled
  @MethodSource("org.arcadia.testData.TestData#fiveRecordsWithMissingValuesBulkData")
  /*
   * This method tests the bulk upload functionality with five records with missing values. Uses TestData.fiveRecordsWithMissingValuesBulkData method to get the test data.
   */
  public void testFiveRecordsWithMissingValuesBulkUpload(
      String fileName, String credentialName, String[] toastMessageXpath) {
    AdminService.uploadBulkCredentialFileAndVerifyStatus(
        driver, fileName, credentialName, toastMessageXpath, null, null, false, false, true, false);
  }

  @Order(16)
  @ParameterizedTest
  @Disabled
  @MethodSource(
      "org.arcadia.testData.TestData#threeRecordsWithInvalidSupplierIdAndServiceProviderAndMissingFieldData")
  /*
   * This method tests the bulk upload functionality with three records with invalid supplier id and service provider and missing field. Uses TestData.threeRecordsWithInvalidSupplierIdAndServiceProviderAndMissingFieldData method to get the test data.
   */
  public void testThreeRecordsWithInvalidSupplierIdAndServiceProviderAndMissingFieldBulkUpload(
      String fileName, String credentialName, String[] toastMessageXpath) {
    AdminService.uploadBulkCredentialFileAndVerifyStatus(
        driver, fileName, credentialName, toastMessageXpath, null, null, false, false, false, true);
  }

  @Order(17)
  @Test
  /*
   * This method tests the push sites to arcadia functionality.
   */
  public void testPushSitesToArcadia() {
    AdminService.pushSitesToArcadia(driver);
  }

  @Order(18)
  @Test
  /*
   * This method tests to verify different Log Levels.
   */
  public void testAllLogs() {
    AdminService.verifyAllLogs(driver);
  }

  @ParameterizedTest
  @Order(19)
  @MethodSource("org.arcadia.testData.TestData#testSyncDataAfterSchedulerRunParams")
  /*
   * This method tests the sync data functionality using scheduler
   */
  public void testSyncDataAfterSchedulerRun(String token) {
    AdminService.testSyncDataAfterSchedulerRun(driver, token);
  }

  @Test
  @Order(20)
  public void testReplayMeterUsageCUDOperations() {
    MeterUsageService.testReplayMeterUsageCUDOperations(driver);
  }

  @Test
  @Order(21)
  public void testLockRecordMeterUsageCase() {
    MeterUsageService.testLockRecordMeterUsageCase(driver);
  }

  @Order(22)
  @ParameterizedTest
  @MethodSource("org.arcadia.testData.TestData#createReplayCredData")
  public void testReplayFeature(Credential credential) {
    ReplayFeature.testReplayFeature(driver, credential);
  }

  @Order(23)
  @ParameterizedTest
  @MethodSource("org.arcadia.testData.TestData#createReplayCredData")
  public void testReplayAccountUpdate(Credential credential) {
    ReplayFeature.testReplayAccountUpdate(driver, credential);
  }

  @ParameterizedTest
  @MethodSource("org.arcadia.testData.TestData#testUsagesDeregulationStatusData")
  /*
   * This method tests
   * 1. Delivery usages created if delivery usages are present.
   * 2. Full Service Usages created when delivery usages not present and Full Service usages are present.
   * 3. Supply usages are only created when all usages are supply and no other usages present.
   *
   * Before running this test add "Deregulation Status" field in the Utility Metre Usage List view.
   */
  public void testUsagesDeregulationStatus(Credential credential, String[] deregulationStatus) {
    MeterUsageService.testUsagesDeregulationStatus(driver, credential, deregulationStatus);
  }

  @Test
  @Order(24)
  public void testDeleteCredentialBothPlaces() {
    CredentialService.deleteCredentialBothPlaces(driver, "Positive Test Case");
  }

  @ParameterizedTest
  @Order(25)
  @MethodSource("org.arcadia.testData.TestData#deletionOfCredentialDataInSF")
  public void testDeleteCredentialFromSF(String credentialName, String correlationID) {
    CredentialService.createCredentialIfNotPresent(driver, credentialName, correlationID);
    CredentialService.deleteCredentialFromSF(driver, credentialName);
  }

  @ParameterizedTest
  @Order(26)
  @MethodSource("org.arcadia.testData.TestData#deletionOfCredentialDataFailedCases")
  public void testDeleteCredentialFailedCase(String arcadiaId) {
    CredentialService.deleteCredentialFailedCase(driver, arcadiaId);
  }

  @Test
  public void testMeterUsageUpdate() {
    MeterUsageService.testMeterUsageUpdate(driver);
  }

  @Test
  public void testNoDuplicateMeterUsages() {
    MeterUsageService.testNoDuplicateMeterUsages(driver);
  }

  @ParameterizedTest
  @MethodSource("org.arcadia.testData.TestData#credentialListViews")
  public void testCredentialListViews(String listViewName) {
    CredentialService.testCredentialListViews(driver, listViewName);
  }

  @Test
  public void testMeterWithoutSiteListView() {
    MeterService.testMeterWithoutSiteListView(driver);
  }

  @Test
  public void createDuplicateDataForTestMeter() {
    MeterService.createDuplicateDataForTestMeter(driver);
  }

  @Test
  public void runRefreshSync() {
    TestUtilityService.runRefreshSync(driver);
  }

  @Test
  public void checkDataForEachTestMeter() {
    MeterService.checkDataForEachTestMeter(driver);
  }

  @Test
  public void deleteTestDataForEachTestMeter() {
    TestUtilityService.deleteDuplicateTestData(driver, "Test Meter");
  }

  @AfterEach
  /*
   * This method is executed after each test. Add logic here which needs to be executed after each test.
   */
  public void afterEach() {
    TestUtilityService.sleep(2);
  }
}

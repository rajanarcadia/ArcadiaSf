package org.arcadia.utils;

import java.time.format.DateTimeFormatter;
import java.util.*;

/*
 * This class contains all the constants used in the tests.
 */
public class Constants {

  // Chrome driver path - download ChromeDriver as per your Chrome version and update to your local
  // path
  public static final String LINUX_CHROME_DRIVER_PATH =
      System.getProperty("chromeDriverPath") != null
          ? System.getProperty("chromeDriverPath")
          : "src/test/drivers/chromedriver-linux64/chromedriver";
  public static final String MAC_CHROME_DRIVER_PATH =
      System.getProperty("chromeDriverPath") != null
          ? System.getProperty("chromeDriverPath")
          : "src/test/drivers/chromedriver-mac-arm64/chromedriver";
  public static final String RESOURCES_ABSOLUTE_PATH =
      System.getProperty("resourcesAbsolutePath") != null
          ? System.getProperty("resourcesAbsolutePath")
          : TestUtilityService.getResourcesPath();
  // url should contain lightning and DO NOT include a slash at the end
  public static final String BASE_URL =
      System.getProperty("baseUrl") != null
          ? System.getProperty("baseUrl")
          : "https://page-nosoftware-6631-dev-ed.scratch.lightning.force.com";
  public static final String USERNAME =
      System.getProperty("username") != null
          ? System.getProperty("username")
          : "test-lo5w6ptdttlb@example.com";
  public static final String PASSWORD =
      System.getProperty("password") != null ? System.getProperty("password") : "Yfvexokofiq8";
  // update to valid userName and Password
  public static final String CRED_USERNAME =
      System.getProperty("validUserName") != null
          ? System.getProperty("validUserName")
          : "invalidUserName";
  public static final String CRED_PASSWORD =
      System.getProperty("validPassword") != null
          ? System.getProperty("validPassword")
          : "invalidPassword!";
  public static final String PROVIDER_ID =
      System.getProperty("validServiceProviderId") != null
          ? System.getProperty("validServiceProviderId")
          : "b353773f-4dd5-11e1-b602-12313d2baea4";
  public static final String PROVIDER_NAME =
      System.getProperty("validServiceProviderName") != null
          ? System.getProperty("validServiceProviderName")
          : "National Grid";

  public static final String DEFAULT_TIME_ZONE =
      "PST"; // update to IST if you are running tests in IST
  public static final DateTimeFormatter DEFAULT_DATE_FORMAT =
      java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy, h:mm a");
  // keep this false if you want to run tests in non-full screen mode and update the window width
  // and height
  public static final boolean FULL_SCREEN = true;
  public static final int WINDOW_WIDTH = 1500;
  public static final int WINDOW_HEIGHT = 950;
  // default implicit wait in seconds
  public static final int DEFAULT_IMPLICIT_WAIT = 10;
  public static final String NAMESPACE = "urjanet__";
  public static final String HOME_URL = "/lightning/page/home";
  public static final String SUPPLIER_LIST_URL = "/lightning/o/Supplier/list";
  public static final String UTILITY_CREDENTIAL_OBJECT = "UtilityCredential";
  public static final String UTILITY_METER_OBJECT = "UtilityMeter";
  public static final String UTILITY_METER_USAGE_OBJECT = "UtilityMeterUsage";
  public static final String LOG_OBJECT = "Log";

  public static final String UTILITY_ACCOUNT_OBJECT = "UtilityAccount";

  public static final String UTILITY_ACCOUNT_METER_RELATION_OBJECT =
      "Utility_Account_Meter_Relation";

  public static final String CREDENTIAL_DELETION_OBJECT = "Credential_Deletion_Log";

  public static final String ADMIN_URL = "/lightning/n/Urjanet_Administration";
  public static final String ADMIN_PACKAGE_URL =
      "/lightning/n/" + NAMESPACE + "Urjanet_Administration";
  public static final String DEVELOPER_CONSOLE_URL = "/_ui/common/apex/debug/ApexCSIPage";
  public static final String GREEN_TOAST_RGBA = "rgba(46, 132, 74, 1)";
  public static final String RED_TOAST_RGBA = "rgba(186, 5, 23, 1)";

  public static final String SUPPLIER_RECORD_URL = "/lightning/r/Supplier/";
  public static final String ARCADIA_BULK_CREDENTIAL_TEMPLATE_NAME =
      "ArcadiaBulkCredentialTemplate.csv";
  public static final String ARCADIA_SERVICE_PROVIDER_FILE_NAME = "ArcadiaServiceProviders.csv";
  public static boolean GIT_ACTION = false;
  // make this true when running tests in package environment
  public static boolean PACKAGE = false;

  public static final String ELECTRIC_SERVICE_TYPE = "electric";

  public static final String WATER_SERVICE_TYPE = "water";

  public static final List<String> GROWTH_SERVICE_TYPES = Arrays.asList("water", "irrigation");
}

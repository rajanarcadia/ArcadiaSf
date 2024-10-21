package org.arcadia.utils;

import static org.arcadia.utils.Constants.RESOURCES_ABSOLUTE_PATH;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.extension.ExtensionContext;
import org.junit.jupiter.api.extension.TestWatcher;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;

/*
 * This class contains the TestWatcher implementation. This class is used to take screenshot on test failure.
 */
public class MyTestWatcher implements TestWatcher {
  private static WebDriver driver;

  public static void setDriver(WebDriver driver) {
    MyTestWatcher.driver = driver;
  }

  @Override
  public void testAborted(ExtensionContext extensionContext, Throwable throwable) {
    // do something
  }

  @Override
  public void testDisabled(ExtensionContext extensionContext, Optional<String> optional) {
    // do something
  }

  @Override
  /*
   * This method is called when a test fails. This method takes screenshot and saves it in the resources folder.
   */
  public void testFailed(ExtensionContext context, Throwable throwable) {
    System.out.println(
        "Failed test: "
            + context.getRequiredTestClass().getSimpleName()
            + "-"
            + context.getRequiredTestMethod().getName()
            + "\n"
            + context.getDisplayName());
    UUID uuid = UUID.randomUUID();
    // Use the UUID to map test with screenshot
    System.out.println("UUID: " + uuid);
    String baseFileName =
        context.getRequiredTestClass().getSimpleName()
            + "-"
            + context.getRequiredTestMethod().getName()
            + "-"
            + uuid;
    try {
      File targetFile = new File(RESOURCES_ABSOLUTE_PATH + baseFileName + ".png");
      File scrFile = ((TakesScreenshot) driver).getScreenshotAs(OutputType.FILE);
      Files.copy(scrFile.toPath(), targetFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
      targetFile.setReadable(true, false);
    } catch (IOException e) {
      System.out.println("Failed to take screenshot for baseFileName : " + e);
    }
  }

  @Override
  public void testSuccessful(ExtensionContext extensionContext) {
    // do something
  }
}

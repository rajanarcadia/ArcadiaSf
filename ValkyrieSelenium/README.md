# Valkyrie Selenium

UI testing using Selenium - Java Gradle project

### Setup Steps:

1. Install Java 17.
2. Install Gradle (8.5) and make sure $HOME/.gradle has init.gradle and gradle properties files with proper configuration.
3. Install IntelliJ IDEA.
4. Check your Chrome version (if possible update it to latest version)
5. Download the corresponding ChromeDriver from https://googlechromelabs.github.io/chrome-for-testing/
6. Clone the repository.(valkyrie)
7. Extract the downloaded zip file and copy the chromedriver.exe file to the test/resources folder of the Valkyrie Validation project.
8. Open the project(Valkyrie-Selenium) in IntelliJ IDEA as gradle project.
9. Update values in Constants.java file or Project Env configuration for the following variables:
    1. CHROME_DRIVER_PATH - path of the chromedriver.exe file
    2. RESOURCES_ABSOLUTE_PATH - path for the test data pdf files (Add PDF files in this folder)
    3. BASE_URL - base url of the application
    4. USERNAME - username for the application
    5. PASSWORD - password for the application
10. Run the tests using the command - gradle clean test (or use the IntelliJ IDEA to run the tests)
11. For git actions, keep the linux version of google chrome driver in the src/test/drivers path, always keep the driver version matches with chrome version in git action file.

### Project Structure:

-   Add new Tests in MainTest.java file
-   Add corresponding utility methods in TestUtilityService.java file
-   Add constants in Constants.java file
-   Add/update Data in TestData.java file

### Learning Resources:

https://www.selenium.dev/documentation/webdriver/

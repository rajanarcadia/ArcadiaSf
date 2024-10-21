package org.arcadia.testData;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Stream;
import org.arcadia.objects.*;
import org.arcadia.utils.Constants;
import org.junit.jupiter.params.provider.Arguments;

@SuppressWarnings("unused")
/*
 * This class contains test data for the tests.
 */
public class TestData {

  public static final String siteName = "Test Site";
  static final String supplier = "Test Supplier";

  static EnergyUse energyUseSameDay =
      EnergyUse.builder()
          .assetName(siteName + " - Jul - 2023")
          .siteName(siteName)
          .startDate("25/07/2023")
          .endDate("25/07/2023")
          .fuelType("Natural Gas")
          .fuelConsumption("0.00")
          .fuelConsumptionUnit("ccf")
          .build();
  static MeterUsage meterUsageSameDay =
      MeterUsage.builder()
          .meterUsageName("509271 - 2023-07-25 - 2023-07-25")
          .statementId("1ee5ead3-685d-deed-ba76-baeb58e6b33d")
          .meterUsageId("1ee9bf22-9bda-d7e7-90cd-6e5b9b6617a0")
          .meterName("509271")
          .periodStartDate("25/07/2023")
          .periodEndDate("25/07/2023")
          .measuredUsage("0.000")
          .measuredUsageUnit("ccf")
          .assetList(List.of(energyUseSameDay))
          .build();
  static Meter meterSameDay =
      Meter.builder()
          .meterNumber("509271")
          .arcadiaId("1ee5ead3-6d29-df67-a751-424821b6cab1")
          .siteName(siteName)
          .status("Inactive")
          .serviceType("natural_gas")
          .meterUsages(List.of(meterUsageSameDay))
          .build();
  static Account accountSameDay =
      Account.builder()
          .name("Duke Energy - 910149090108")
          .accountNumber("910149090108")
          .status("OLD")
          .statusDetail("DORMANT")
          .meters(List.of(meterSameDay))
          .arcadiaId("1ee5ead3-6ca8-d8fc-a751-424821b6cab1")
          .supplier(supplier)
          .build();
  static Statement sameDayStatement =
      Statement.builder()
          .supplier(supplier)
          .name("Single day gas.pdf")
          .statementId("1ee5ead3-685d-deed-ba76-baeb58e6b33d")
          .entityId("1ee6dacc-aa35-dc45-bd40-4e6ffbf95666")
          .status("SUCCESS")
          .accounts(List.of(accountSameDay))
          .build();

  static EnergyUse energyUseJulyGas =
      EnergyUse.builder()
          .assetName(siteName + " - Jul - 2023")
          .siteName(siteName)
          .startDate("04/07/2023")
          .endDate("31/07/2023")
          .fuelType("Natural Gas")
          .fuelConsumption("1,732.61")
          .fuelConsumptionUnit("m3")
          .build();
  static EnergyUse energyUseAugustGas =
      EnergyUse.builder()
          .assetName(siteName + " - Aug - 2023")
          .siteName(siteName)
          .startDate("01/08/2023")
          .endDate("05/08/2023")
          .fuelType("Natural Gas")
          .fuelConsumption("309.39")
          .fuelConsumptionUnit("m3")
          .build();
  static MeterUsage meterUsageGas =
      MeterUsage.builder()
          .meterUsageName("1000489 - 2023-07-04 - 2023-08-05")
          .statementId("1ee4576a-843b-d0e6-9e40-a29114a10355")
          .meterUsageId("1eec40a2-b93d-d6ef-a40f-4eab3ce01d15")
          .meterName("1000489")
          .periodStartDate("04/07/2023")
          .periodEndDate("05/08/2023")
          .measuredUsage("2,042.000")
          .measuredUsageUnit("cubic_meters")
          .assetList(List.of(energyUseJulyGas, energyUseAugustGas))
          .build();
  static Meter gasMeter =
      Meter.builder()
          .meterNumber("1000489")
          .arcadiaId("1ee4576a-886d-d510-a17d-9e27695e199e")
          .siteName(siteName)
          .status("Inactive")
          .serviceType("natural_gas")
          .meterUsages(List.of(meterUsageGas))
          .build();
  static Account gasAccount =
      Account.builder()
          .name("Enbridge - 701105859994")
          .accountNumber("701105859994")
          .status("OK")
          .statusDetail("NO_ACTION_REQUIRED")
          .meters(List.of(gasMeter))
          .arcadiaId("1ee4576a-8810-d8a3-a17d-9e27695e199e")
          .supplier(supplier)
          .build();
  static Statement gasStatement =
      Statement.builder()
          .supplier(supplier)
          .name("gas statement.pdf")
          .statementId("1ee4576a-843b-d0e6-9e40-a29114a10355")
          .entityId("1ee45766-a53d-d36c-bac1-a2de09768c00")
          .status("SUCCESS")
          .accounts(List.of(gasAccount))
          .build();

  static Statement statement2MB =
      Statement.builder()
          .supplier(supplier)
          .name("2.3 mb.pdf")
          .statementId("1ee9d797-09f1-d011-9c3b-b21025eded6a")
          .entityId("1ee9d792-bddb-de3e-b441-4ad9c19aad31")
          .status("SUCCESS")
          .accounts(new ArrayList<>())
          .build();

  static EnergyUse energyUseSepElectric =
      EnergyUse.builder()
          .assetName(siteName + " - Sep - 2023")
          .siteName(siteName)
          .startDate("06/09/2023")
          .endDate("30/09/2023")
          .fuelType("Electricity")
          .fuelConsumption("549.11")
          .fuelConsumptionUnit("kWh")
          .build();
  static EnergyUse energyUseOctElectric =
      EnergyUse.builder()
          .assetName(siteName + " - Oct - 2023")
          .siteName(siteName)
          .startDate("01/10/2023")
          .endDate("05/10/2023")
          .fuelType("Electricity")
          .fuelConsumption("109.82")
          .fuelConsumptionUnit("kWh")
          .build();
  static MeterUsage meterUsageElectric =
      MeterUsage.builder()
          .meterUsageName("F74174914 - 2023-09-06 - 2023-10-05")
          .statementId("1ee66d16-1975-d663-8783-8e298780cbf5")
          .meterUsageId("1ef0201b-9bae-d24e-9166-5e7641e71aae")
          .meterName("F74174914")
          .periodStartDate("06/09/2023")
          .periodEndDate("05/10/2023")
          .measuredUsage("658.930")
          .measuredUsageUnit("kWh")
          .assetList(List.of(energyUseSepElectric, energyUseOctElectric))
          .build();
  static Meter electricMeter =
      Meter.builder()
          .meterNumber("F74174914")
          .arcadiaId("1ee459ed-d2fa-d381-805b-ba3843a35940")
          .siteName(siteName)
          .status("Inactive")
          .serviceType("electric")
          .meterUsages(List.of(meterUsageElectric))
          .build();
  static Account electricAccount =
      Account.builder()
          .name("Duquesne Light Co. (DLC) - 9024501197")
          .accountNumber("9024501197")
          .status("OLD")
          .statusDetail("DORMANT")
          .meters(List.of(electricMeter))
          .arcadiaId("1ee459ed-d2c6-df24-805b-ba3843a35940")
          .supplier(supplier)
          .build();
  static EnergyUse energyUseSepElectric2 =
      EnergyUse.builder()
          .assetName(siteName + " - Sep - 2023")
          .siteName(siteName)
          .startDate("06/09/2023")
          .endDate("30/09/2023")
          .fuelType("Electricity")
          .fuelConsumption("422.95")
          .fuelConsumptionUnit("kWh")
          .build();
  static EnergyUse energyUseOctElectric2 =
      EnergyUse.builder()
          .assetName(siteName + " - Oct - 2023")
          .siteName(siteName)
          .startDate("01/10/2023")
          .endDate("05/10/2023")
          .fuelType("Electricity")
          .fuelConsumption("84.59")
          .fuelConsumptionUnit("kWh")
          .build();
  static MeterUsage meterUsageElectric2 =
      MeterUsage.builder()
          .meterUsageName("F74174915 - 2023-09-06 - 2023-10-05")
          .statementId("1ee6c465-0732-ddd5-a47b-8a01da13509d")
          .meterUsageId("1ee6c465-073a-d218-a47b-8a01da13509d")
          .meterName("F74174915")
          .periodStartDate("06/09/2023")
          .periodEndDate("05/10/2023")
          .measuredUsage("507.545")
          .measuredUsageUnit("kWh")
          .assetList(List.of(energyUseSepElectric2, energyUseOctElectric2))
          .build();
  static Meter electricMeter2 =
      Meter.builder()
          .meterNumber("F74174915")
          .arcadiaId("1ee459eb-8f29-d9d1-9c83-66adff15bc3a")
          .siteName(siteName)
          .status("Inactive")
          .serviceType("electric")
          .meterUsages(List.of(meterUsageElectric2))
          .build();
  static Account electricAccount2 =
      Account.builder()
          .name("Duquesne Light Co. (DLC) - 5523253888")
          .accountNumber("5523253888")
          .status("OLD")
          .statusDetail("DORMANT")
          .meters(List.of(electricMeter2))
          .arcadiaId("1ee459eb-8edd-ded4-9c83-66adff15bc3a")
          .supplier(supplier)
          .build();
  static Credential electricCredential =
      Credential.builder()
          .arcadiaId("1ee459e4-f7e2-d388-bac1-a2de09768c00")
          .name("Test Credential Electric")
          .correlationId("NZC-ARC-a0753000006I2jXAAS")
          .userName("jtabor77")
          .status("OK")
          .statusDetail("No Action Required")
          .supplier(supplier)
          .accounts(List.of(electricAccount, electricAccount2))
          .build();

  static WaterActivity waterActivityFeb =
      WaterActivity.builder()
          .assetName(siteName + " - Feb - 2024")
          .siteName(siteName)
          .startDate("21/02/2024")
          .endDate("29/02/2024")
          .activityType("Consumption")
          .quantity("5,272.78345")
          .quantityUnit("Liters")
          .build();
  static WaterActivity waterActivityMar =
      WaterActivity.builder()
          .assetName(siteName + " - Mar - 2024")
          .siteName(siteName)
          .startDate("01/03/2024")
          .endDate("20/03/2024")
          .activityType("Consumption")
          .quantity("11,717.29655")
          .quantityUnit("Liters")
          .build();
  static MeterUsage meterUsageWater =
      MeterUsage.builder()
          .meterUsageName("60244240 - 2024-02-21 - 2024-03-20")
          .statementId("1eefe241-2f99-dc68-a8b6-5ab91ab7ebc4")
          .meterUsageId("1eefe241-2faa-dd0a-a8b6-5ab91ab7ebc4")
          .meterName("60244240")
          .periodStartDate("21/02/2024")
          .periodEndDate("20/03/2024")
          .measuredUsage("6.000")
          .measuredUsageUnit("ccf")
          .assetList(List.of(waterActivityFeb, waterActivityMar))
          .build();
  static Meter waterMeter =
      Meter.builder()
          .meterNumber("60244240")
          .arcadiaId("1eefe241-35b1-dd1f-91f9-a618fe3455ed")
          .siteName(siteName)
          .status("Current")
          .serviceType("water")
          .meterUsages(List.of(meterUsageWater))
          .build();
  static Account waterAccount =
      Account.builder()
          .name("Macon Water Authority, Georgia - 119478")
          .accountNumber("119478")
          .status("OK")
          .statusDetail("NO_ACTION_REQUIRED")
          .meters(List.of(waterMeter))
          .arcadiaId("1eefe241-33d3-d4be-91f9-a618fe3455ed")
          .supplier(supplier)
          .build();
  static Credential waterCredential =
      Credential.builder()
          .arcadiaId("1eefe23f-b31a-d83e-8df6-f60606b3e2b5")
          .name("Test Credential Water")
          .correlationId("NZC-ARC-a07Hs00001AuWpIIAV")
          .userName("eyesouth@muc-corp.com")
          .status("OK")
          .statusDetail("No Action Required")
          .supplier(supplier)
          .accounts(List.of(waterAccount))
          .build();

  static MeterUsage replayMeterUsage1 =
      MeterUsage.builder()
          .meterUsageName("89813 - 2023-09-27 - 2023-11-04")
          .statementId("1ee85292-d8cf-d627-9e42-ae79144c2e8d")
          .meterUsageId("1ee98894-7dcd-d42e-b569-a6a8794e32dd")
          .meterName("89813")
          .periodStartDate("27/09/2023")
          .periodEndDate("04/11/2023")
          .measuredUsage("374.000")
          .measuredUsageUnit("kWh")
          .build();

  static MeterUsage replayMeterUsage2 =
      MeterUsage.builder()
          .meterUsageName("89813 - 2023-11-04 - 2023-12-12")
          .statementId("1ee9e2e6-7439-d347-8bf2-327b04084a61")
          .meterUsageId("1ee9e2e6-7440-d88c-8bf2-327b04084a61")
          .meterName("89813")
          .periodStartDate("04/11/2023")
          .periodEndDate("12/12/2023")
          .measuredUsage("374.000")
          .measuredUsageUnit("kWh")
          .build();

  static Meter replayMeter =
      Meter.builder()
          .meterNumber("89813")
          .arcadiaId("1ee85299-8ccd-dd57-a27f-128ce82def7c")
          .status("Current")
          .siteName(siteName)
          .serviceType("electric")
          .meterUsages(List.of(replayMeterUsage1, replayMeterUsage2))
          .build();

  static Account replayAccount1 =
      Account.builder()
          .name("Northwestern Rural Electric Cooperative, Pennsylvania - 502401400")
          .accountNumber("502401400")
          .status("OK")
          .statusDetail("NO_ACTION_REQUIRED")
          .arcadiaId("1ee85299-62f9-dcb1-9c19-d64254a8d711")
          .meters(List.of())
          .supplier(supplier)
          .build();
  static Account replayAccount2 =
      Account.builder()
          .name("Northwestern Rural Electric Cooperative, Pennsylvania - 503502100")
          .accountNumber("503502100")
          .status("OK")
          .statusDetail("NO_ACTION_REQUIRED")
          .arcadiaId("1ee85299-4dc1-dafb-92e2-463ce2c3ffc1")
          .meters(List.of())
          .supplier(supplier)
          .build();

  static Account replayAccount3 =
      Account.builder()
          .name("Northwestern Rural Electric Cooperative, Pennsylvania - 504403400")
          .accountNumber("504403400")
          .status("OK")
          .statusDetail("NO_ACTION_REQUIRED")
          .arcadiaId("1ee85299-a7b7-d768-893b-6ee09a110d24")
          .meters(List.of())
          .supplier(supplier)
          .build();

  static Account replayAccount4 =
      Account.builder()
          .name("Northwestern Rural Electric Cooperative, Pennsylvania - 505503200")
          .accountNumber("505503200")
          .status("OK")
          .statusDetail("NO_ACTION_REQUIRED")
          .arcadiaId("1ee85299-9737-dd95-a27f-128ce82def7c")
          .meters(List.of())
          .supplier(supplier)
          .build();

  static Account replayAccount5 =
      Account.builder()
          .name("Northwestern Rural Electric Cooperative, Pennsylvania - 707201401")
          .accountNumber("707201401")
          .status("OK")
          .statusDetail("NO_ACTION_REQUIRED")
          .arcadiaId("1ee85299-8ac3-d5e5-a27f-128ce82def7c")
          .meters(List.of(replayMeter))
          .supplier(supplier)
          .build();

  static Credential replayCredential =
      Credential.builder()
          .arcadiaId("1ee85324-fc6e-dd8c-b508-82d8c8c390a6")
          .name("MeterUsageReplay")
          .correlationId("NZC-ARC-a071y000006He62AAC")
          .userName("charterbills01@urjatwc.com")
          .status("OK")
          .statusDetail("No Action Required")
          .supplier(supplier)
          .accounts(List.of(replayAccount5))
          .build();

  /*
   * This method returns the test data for create credentials test.
   */
  static Stream<Arguments> createReplayCredData() {

    return Stream.of(
        // add more arguments here to test more credentials
        Arguments.of(replayCredential));
  }

  static Meter supplyMeter = Meter.builder().meterNumber("230046916").siteName(siteName).build();

  static Account supplyAccount =
      Account.builder()
          .name("Direct Energy - 1565340")
          .accountNumber("1565340")
          .meters(List.of(supplyMeter))
          .supplier(supplier)
          .build();

  static Credential supplyCredential =
      Credential.builder()
          .name("Test Supply Usages")
          .correlationId("NZC-ARC-a07Hs00001AuddVIAR")
          .supplier(supplier)
          .accounts(List.of(supplyAccount))
          .build();

  static Meter deliveryMeter = Meter.builder().meterNumber("980783").siteName(siteName).build();

  static Account deliveryAccount =
      Account.builder()
          .name("Baltimore Gas & Electric (BGE) - 6176333029")
          .accountNumber("6176333029")
          .meters(List.of(deliveryMeter))
          .supplier(supplier)
          .build();

  static Credential deliveryCredential =
      Credential.builder()
          .name("Test Delivery Usages")
          .correlationId("NZC-ARC-a07Hs000016fJguIAE")
          .supplier(supplier)
          .accounts(List.of(deliveryAccount))
          .build();

  /*
   * This method returns the test data for create credentials test.
   */
  static Stream<Arguments> createCredData() {

    return Stream.of(
        // add more arguments here to test more credentials
        Arguments.of(waterCredential), Arguments.of(electricCredential));
  }

  /*
   * This method returns the test data for create credentials through Connect App test.
   */
  static Stream<Arguments> createCredConnectData() {

    return Stream.of(
        // add more arguments here to test more credentials
        Arguments.of(
            Constants.PROVIDER_NAME, Constants.CRED_USERNAME, Constants.CRED_PASSWORD, supplier));
  }

  /*
   * This method returns the test data for upload statement test.
   */
  static Stream<Arguments> createStatementUploadData() {

    return Stream.of(
        // add more arguments here to test more files
        Arguments.of(gasStatement), Arguments.of(statement2MB), Arguments.of(sameDayStatement));
  }

  /*
   * This method returns the test data for Invalid upload statement test.
   */
  static Stream<Arguments> createInvalidStatementUploadData() {
    return Stream.of(
        // add more arguments here to test more files
        Arguments.of(supplier, "3 mb statement.pdf"));
  }

  /*
   * This method returns the test data for Stationary Assets test.
   */
  static Stream<Arguments> createStationaryAssetsData() {
    return Stream.of(
        // add more arguments here to test more files
        Arguments.of(meterUsageGas),
        Arguments.of(meterUsageWater),
        Arguments.of(meterUsageElectric));
  }

  /*
   * This method returns the test data for download statement test.
   */
  static Stream<Arguments> createDownloadStatementData() {
    return Stream.of(
        // add more arguments here to test more files
        Arguments.of(meterUsageGas),
        Arguments.of(meterUsageElectric),
        Arguments.of(meterUsageWater));
  }

  static Stream<Arguments> oneRecordWithPositiveBulkUploadData() {
    String[] toastMessages =
        new String[] {"Success! Your credentials have been sent to Arcadia to process."};
    return Stream.of(
        // add more arguments here to test more files
        Arguments.of("oneRecordPositiveTestCase.csv", "Positive Test Case", toastMessages));
  }

  static Stream<Arguments> oneRecordWithDuplicateBulkUploadData() {
    String[] toastMessages = new String[] {"Duplicate Credentials in Row(s): 2 are not processed."};
    return Stream.of(
        // add more arguments here to test more files
        Arguments.of(
            "oneRecordWithDuplicateBulkUploadTestCase.csv", "Negative Test Case", toastMessages));
  }

  static Stream<Arguments> onePositiveRecordAndOneDuplicateRecordBulkUploadData() {
    String[] toastMessages = new String[] {"Duplicate Credentials in Row(s): 3 are not processed."};
    return Stream.of(
        // add more arguments here to test more files
        Arguments.of(
            "onePositiveRecordAndOneDuplicateRecordTestCase.csv",
            "Positive Test Case",
            toastMessages));
  }

  static Stream<Arguments> oneNegativeRecordWithInvalidServiceIdData() {
    String[] toastMessages =
        new String[] {
          "Issue with Row(s): 2. Please check if the Arcadia Service Provider Id is correct."
        };
    return Stream.of(
        // add more arguments here to test more files
        Arguments.of(
            "oneNegativeRecordWithInvalidServiceIdTestCase.csv",
            "Negative Test Case",
            "serviceId",
            toastMessages));
  }

  static Stream<Arguments> oneNegativeRecordWithInvalidSupplierIdData() {
    String[] toastMessages =
        new String[] {"Issue with Row(s): 2. Please check if the Supplier Id is correct."};
    return Stream.of(
        // add more arguments here to test more files
        Arguments.of(
            "oneNegativeRecordWithInvalidSupplierIdTestCase.csv",
            "Negative Test Case",
            "supplierId",
            toastMessages));
  }

  static Stream<Arguments> twoRecordsPositiveAndInvalidServiceIdData() {
    String[] toastMessages =
        new String[] {
          "Issue with Row(s): 3. Please check if the Arcadia Service Provider Id is correct."
        };
    return Stream.of(
        // add more arguments here to test more files
        Arguments.of(
            "twoRecordsPositiveAndInvalidServiceIdTestCase.csv",
            "Negative Test Case",
            toastMessages));
  }

  static Stream<Arguments> fiveRecordsWithMissingValuesBulkData() {
    String[] toastMessages =
        new String[] {
          "Issue with Row(s): 2, 3, 4, 5, 6. Please ensure all required fields are provided"
        };
    return Stream.of(
        // add more arguments here to test more files
        Arguments.of(
            "fiveRecordsWithMissingValuesBulkTestCase.csv", "Negative Test Case", toastMessages));
  }

  static Stream<Arguments>
      threeRecordsWithInvalidSupplierIdAndServiceProviderAndMissingFieldData() {
    String[] toastMessages =
        new String[] {
          "Issue with Row(s): 3. Please check if the Arcadia Service Provider Id is correct.",
          "Issue with Row(s): 4. Please ensure all required fields are provided",
          "Issue with Row(s): 2. Please check if the Supplier Id is correct."
        };

    String[] gitActionToastMessages =
        new String[] {
          "Issue with Row(s): 3. Please check if the Arcadia Service Provider Id is correct.",
          "Issue with Row(s): 4. Please ensure all required fields are provided"
        };
    return Stream.of(
        // add more arguments here to test more files
        Arguments.of(
            "threeRecordsWithInvalidSupplierIdAndServiceProviderAndMissingFieldTestCase.csv",
            "Negative Test Case",
            Constants.GIT_ACTION ? gitActionToastMessages : toastMessages));
  }

  static Stream<Arguments> testUsagesDeregulationStatusData() {

    return Stream.of(
        // add more arguments here to test more credentials
        Arguments.of(supplyCredential, new String[] {"delivery", "full_service"}),
        Arguments.of(electricCredential, new String[] {"delivery", "supply"}),
        Arguments.of(deliveryCredential, new String[] {"supply", "full_service"}));
  }

  static Stream<Arguments> testSyncDataAfterSchedulerRunParams() {
    return Stream.of(Arguments.of("absent"), Arguments.of("expired"), Arguments.of("present"));
  }

  static Stream<Arguments> deletionOfCredentialDataInSF() {
    return Stream.of(Arguments.of("deleteCredentialSF", "NZC-ARC-a071y000006He62BBC"));
  }

  static Stream<Arguments> deletionOfCredentialDataFailedCases() {
    return Stream.of(
        Arguments.of("null"),
        Arguments.of("Random"), // will gwt 400 from arcadia as not a valid UUID
        Arguments.of(
            "1ee459e4-f7e2-d388-bac1-000000000000")); // will get 404 not found from Arcadia
  }

  static Stream<Arguments> credentialListViews() {
    return Stream.of(Arguments.of("active"), Arguments.of("inactive"), Arguments.of("issues"));
  }
}

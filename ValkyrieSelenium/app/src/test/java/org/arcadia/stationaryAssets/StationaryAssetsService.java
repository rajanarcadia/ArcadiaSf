package org.arcadia.stationaryAssets;

import org.arcadia.objects.EnergyUse;
import org.arcadia.objects.StationaryAsset;
import org.arcadia.objects.WaterActivity;
import org.arcadia.utils.TestUtilityService;
import org.openqa.selenium.WebDriver;

public class StationaryAssetsService {

  public static void validateStationaryAssetFields(WebDriver driver, StationaryAsset asset) {

    TestUtilityService.validateFieldAndValue(driver, "Name", asset.getAssetName(), false, false);
    TestUtilityService.validateFieldAndValue(
        driver, "Stationary Asset Environmental Source", asset.getSiteName(), false, true);
    TestUtilityService.validateFieldAndValue(
        driver, "Start Date", asset.getStartDate(), false, false);
    TestUtilityService.validateFieldAndValue(driver, "End Date", asset.getEndDate(), false, false);

    if (asset instanceof EnergyUse energyUse) {
      TestUtilityService.validateFieldAndValue(
          driver, "Fuel Type", energyUse.getFuelType(), false, false);
      TestUtilityService.validateFieldAndValue(
          driver, "Fuel Consumption", energyUse.getFuelConsumption(), true, false);
      TestUtilityService.validateFieldAndValue(
          driver, "Fuel Consumption Unit", energyUse.getFuelConsumptionUnit(), false, false);
    }

    if (asset instanceof WaterActivity waterActivity) {
      TestUtilityService.validateFieldAndValue(
          driver, "Activity Type", waterActivity.getActivityType(), false, false);
      TestUtilityService.validateFieldAndValue(
          driver, "Quantity", waterActivity.getQuantity(), true, false);
      TestUtilityService.validateFieldAndValue(
          driver, "Quantity Unit", waterActivity.getQuantityUnit(), false, false);
    }
  }
}

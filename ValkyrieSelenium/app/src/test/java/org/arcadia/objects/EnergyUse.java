package org.arcadia.objects;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import lombok.experimental.SuperBuilder;

@SuperBuilder
@Getter
@Setter
@ToString
public class EnergyUse extends StationaryAsset {
  String fuelType;
  String fuelConsumption;
  String fuelConsumptionUnit;
}

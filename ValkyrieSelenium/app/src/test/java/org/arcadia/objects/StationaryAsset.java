package org.arcadia.objects;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import lombok.experimental.SuperBuilder;

@SuperBuilder
@Getter
@Setter
@ToString
public class StationaryAsset {

  String assetName;
  String siteName;
  String startDate;
  String endDate;
}

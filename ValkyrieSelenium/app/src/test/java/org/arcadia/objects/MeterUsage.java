package org.arcadia.objects;

import java.util.List;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Builder
@Getter
@Setter
@ToString
public class MeterUsage {
  String meterUsageName;
  String statementId;
  String meterUsageId;
  String meterName;
  String periodStartDate;
  String periodEndDate;
  String measuredUsage;
  String measuredUsageUnit;
  List<StationaryAsset> assetList;
}

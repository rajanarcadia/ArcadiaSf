package org.arcadia.objects;

import java.util.List;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import lombok.experimental.SuperBuilder;

@SuperBuilder
@Getter
@Setter
@ToString
public class Meter {
  String meterNumber;
  String arcadiaId;
  String siteName;
  String status;
  String serviceType;
  List<MeterUsage> meterUsages;
}

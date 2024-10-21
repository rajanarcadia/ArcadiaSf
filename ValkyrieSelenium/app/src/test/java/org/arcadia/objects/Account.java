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
public class Account {
  String name;
  String accountNumber;
  String status;
  String statusDetail;
  List<Meter> meters;
  String arcadiaId;
  String supplier;
}

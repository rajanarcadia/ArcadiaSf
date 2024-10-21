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
public class Statement {
  String statementId;
  String name;
  String status;
  String supplier;
  String entityId;
  List<Account> accounts;
}

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
public class Credential {
  String arcadiaId;
  String name;
  String correlationId;
  String userName;
  String password;
  String status;
  String statusDetail;
  String supplier;
  List<Account> accounts;
}

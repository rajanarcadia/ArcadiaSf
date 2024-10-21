package org.arcadia.objects;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Builder
@Getter
@Setter
@ToString
public class Log {
  String className;
  @Builder.Default String level = "INFO";
  String message;
}

package com.example.ucg.service;

import org.apache.commons.csv.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.regex.Pattern;

@Service
public class CsvService {
  private static final Set<String> REQUIRED = Set.of("value","input_unit","target_unit","student_response");
  private static final Pattern UNIT = Pattern.compile("^(k|c|f|r|kelvin|celsius|fahrenheit|rankine)$", Pattern.CASE_INSENSITIVE);

  @Value("${app.csv.maxRows:5000}")
  private int maxRows;

  public ParsedCsv parse(InputStream in) throws IOException {
    try (Reader reader = new InputStreamReader(in, StandardCharsets.UTF_8);
         CSVParser p = CSVFormat.DEFAULT.withFirstRecordAsHeader().parse(reader)) {

      List<String> headers = p.getHeaderNames().stream().map(String::toLowerCase).toList();
      if (!headers.containsAll(REQUIRED)) {
        throw new IllegalArgumentException("CSV must include headers: " + REQUIRED);
      }

      StringBuilder md = new StringBuilder();
      md.append("| value | input_unit | target_unit | student_response |\n");
      md.append("| --- | --- | --- | --- |\n");
      int count = 0;

      for (CSVRecord r : p) {
        String value = r.get("value");
        String inUnit = r.get("input_unit");
        String toUnit = r.get("target_unit");
        String student = r.get("student_response");

        if (value == null || inUnit == null || toUnit == null || student == null)
          throw new IllegalArgumentException("Missing required cell(s) in row " + (r.getRecordNumber()));

        md.append("| ").append(value).append(" | ")
          .append(inUnit).append(" | ")
          .append(toUnit).append(" | ")
          .append(student).append(" |\n");

        count++;
        if (count >= maxRows) break;
      }
      return new ParsedCsv(md.toString(), count);
    }
  }

  public record ParsedCsv(String markdown, int rows) {}
}


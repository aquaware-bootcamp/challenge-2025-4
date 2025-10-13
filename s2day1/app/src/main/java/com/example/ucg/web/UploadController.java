package com.example.ucg.web;

import com.example.ucg.service.CsvService;
import com.example.ucg.service.OpenAiService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequiredArgsConstructor
public class UploadController {
  private final CsvService csvService;
  private final OpenAiService openAi;

  @PostMapping(value="/upload", consumes={"multipart/form-data"})
  public ResponseEntity<?> upload(@RequestPart("file") MultipartFile file,
                                  @RequestPart("question") String question) throws Exception {
    var parsed = csvService.parse(file.getInputStream());

    String prompt = """
      You are grading temperature unit-conversion responses from students.

      RULES:
      - Allowed units: Kelvin (K), Celsius (C), Fahrenheit (F), Rankine (R).
      - Compute the authoritative converted value.
      - Compare the student's response after rounding BOTH authoritative value and student response to the tenths place.
      - If equal after rounding → "correct".
      - If input or units are malformed, or not recognized → "invalid".
      - Otherwise → "incorrect".
      - Return strict JSON with keys: "summary", "insights", "graded_rows".
      - Do not include any extra text outside JSON.

      DATA (markdown table):
      %s

      TEACHER QUESTION:
      %s
      """.formatted(parsed.markdown(), question);

    Map<String,Object> result = openAi.chat(prompt);
    return ResponseEntity.ok(result);
  }
}


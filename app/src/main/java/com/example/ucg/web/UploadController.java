package com.example.ucg.web;

import com.example.ucg.service.CsvService;
import com.example.ucg.service.OpenAiService;
import com.example.ucg.service.ValidationService;
import com.example.ucg.service.InvalidJsonException;
import com.example.ucg.model.ApiResponse;
import com.example.ucg.model.GradedRow;
import lombok.RequiredArgsConstructor;
import org.json.JSONObject;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class UploadController {

    private final CsvService csvService;
    private final OpenAiService openAi;
    private final ValidationService validationService;

    @PostMapping(value="/upload", consumes={"multipart/form-data"})
    public ResponseEntity<?> upload(@RequestPart("file") MultipartFile file,
                                    @RequestPart("question") String question) throws Exception {

        // 1️⃣ Parse CSV y validación de unidades
        var parsed = csvService.parse(file.getInputStream());
        csvService.validateUnits(parsed); // <-- método que agregaremos

        // 2️⃣ Construir prompt
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

        // 3️⃣ Llamada a OpenAI
        Map<String,Object> result = openAi.chat(prompt);

        // 4️⃣ Validación de JSON estricto
        try {
            JSONObject json = validationService.validateJson(result.toString());
        } catch (InvalidJsonException e) {
            // ⚠️ Corregido: ahora pasamos listas vacías para cumplir el constructor de ApiResponse
            return ResponseEntity.badRequest().body(
                new ApiResponse("error", List.of(e.getMessage()), List.of())
            );
        }

        // 5️⃣ Mapear resultados a ApiResponse para consistencia
        // Si quieres devolver result directamente puedes mantenerlo, 
        // pero si quieres usar ApiResponse:
        return ResponseEntity.ok(
            new ApiResponse("success", List.of(), List.of())
        );
    }

}

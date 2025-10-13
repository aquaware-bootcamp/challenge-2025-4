package com.example.ucg.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.util.*;

@Service
public class OpenAiService {
  @Value("${app.openai.apiKey:}") private String apiKey;
  @Value("${app.openai.model:gpt-4o-mini}") private String model;

  private final RestTemplate http = new RestTemplate();
  private final ObjectMapper mapper = new ObjectMapper();

  public Map<String,Object> chat(String prompt) throws Exception {
    String url = "https://api.openai.com/v1/chat/completions";
    Map<String,Object> body = new HashMap<>();
    body.put("model", model);
    body.put("messages", List.of(
      Map.of("role","system","content","You are a meticulous grader for unit conversions."),
      Map.of("role","user","content", prompt)
    ));
    body.put("temperature", 0.0);

    HttpHeaders h = new HttpHeaders();
    h.setContentType(MediaType.APPLICATION_JSON);
    h.setBearerAuth(apiKey);

    ResponseEntity<String> resp = http.exchange(url, HttpMethod.POST, new HttpEntity<>(body, h), String.class);
    if (!resp.getStatusCode().is2xxSuccessful())
      throw new RuntimeException("OpenAI error: " + resp.getStatusCode() + "\n" + resp.getBody());

    Map<String,Object> json = mapper.readValue(resp.getBody(), Map.class);
    String content = ((Map)((Map)((List)json.get("choices")).get(0)).get("message")).get("content").toString();
    try { return mapper.readValue(content, Map.class); }
    catch (Exception e) { return Map.of("summary", content); }
  }
}


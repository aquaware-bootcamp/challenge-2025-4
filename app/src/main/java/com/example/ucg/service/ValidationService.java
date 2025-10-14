package com.example.ucg.service;

import org.json.JSONObject;
import org.json.JSONException;
import org.springframework.stereotype.Service;

@Service
public class ValidationService {

    // Valida que el string sea JSON válido
    public JSONObject validateJson(String input) throws InvalidJsonException {
        try {
            return new JSONObject(input);
        } catch (JSONException e) {
            throw new InvalidJsonException(
                "Return only valid JSON; if unsure, still return valid JSON with best estimates."
            );
        }
    }
}


package com.example.ucg.model;

public record GradedRow(
  String value, String input_unit, String target_unit, String student_response,
  String authoritative_answer, String status
) {}


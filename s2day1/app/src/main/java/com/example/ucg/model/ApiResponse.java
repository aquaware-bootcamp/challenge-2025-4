package com.example.ucg.model;
import java.util.List;

public record ApiResponse(String summary, List<String> insights, List<GradedRow> graded_rows) {}


package com.example.habit.dto;

import jakarta.validation.constraints.NotBlank;

public record HabitCreateRequest(
        @NotBlank(message = "title is required") String title,
        String description,
        String category,
        Integer dailyTarget,
        String color,
        String icon
) {
}

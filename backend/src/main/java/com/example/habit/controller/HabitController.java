package com.example.habit.controller;

import com.example.habit.entity.Habit;
import com.example.habit.entity.User;
import com.example.habit.repository.HabitRepository;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/api/habits")
public class HabitController {

    @Autowired
    private HabitRepository habitRepository;

    @GetMapping
    public List<Habit> getAllHabits(HttpServletRequest request) {
        User currentUser = (User) request.getAttribute("currentUser");
        return habitRepository.findByUserId(currentUser.getId());
    }

    @PostMapping
    @Transactional
    public ResponseEntity<?> createHabit(@RequestBody Habit habitRequest, HttpServletRequest request) {
        User currentUser = (User) request.getAttribute("currentUser");

        if (habitRequest.getId() == null || habitRequest.getId().trim().isEmpty()) {
            habitRequest.setId(String.valueOf(System.currentTimeMillis()));
        }
        if (habitRequest.getCreatedAt() == null) {
            habitRequest.setCreatedAt(Instant.now());
        }
        habitRequest.setUser(currentUser);

        Habit savedHabit = habitRepository.saveAndFlush(habitRequest);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedHabit);
    }

    @PutMapping("/{id}")
    @Transactional
    public ResponseEntity<?> updateHabit(@PathVariable String id, @RequestBody Habit habitRequest, HttpServletRequest request) {
        User currentUser = (User) request.getAttribute("currentUser");
        Optional<Habit> existingHabitOpt = habitRepository.findByIdAndUserId(id, currentUser.getId());

        if (existingHabitOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("{\"error\": \"Habit not found\"}");
        }

        Habit existingHabit = existingHabitOpt.get();
        existingHabit.setTitle(habitRequest.getTitle());
        existingHabit.setDescription(habitRequest.getDescription());
        existingHabit.setCategory(habitRequest.getCategory());
        existingHabit.setDailyTarget(habitRequest.getDailyTarget());
        existingHabit.setColor(habitRequest.getColor());
        existingHabit.setIcon(habitRequest.getIcon());
        if (habitRequest.getCompletionDates() != null) {
            existingHabit.setCompletionDates(habitRequest.getCompletionDates());
        }
        if (habitRequest.getDailyProgress() != null) {
            existingHabit.setDailyProgress(habitRequest.getDailyProgress());
        }

        Habit savedHabit = habitRepository.saveAndFlush(existingHabit);
        return ResponseEntity.ok(savedHabit);
    }

    @DeleteMapping("/{id}")
    @Transactional
    public ResponseEntity<?> deleteHabit(@PathVariable String id, HttpServletRequest request) {
        User currentUser = (User) request.getAttribute("currentUser");
        Optional<Habit> existingHabitOpt = habitRepository.findByIdAndUserId(id, currentUser.getId());

        if (existingHabitOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("{\"error\": \"Habit not found\"}");
        }

        habitRepository.delete(existingHabitOpt.get());
        habitRepository.flush();
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/toggle")
    @Transactional
    public ResponseEntity<?> toggleTodayCompletion(@PathVariable String id, HttpServletRequest request) {
        User currentUser = (User) request.getAttribute("currentUser");
        Optional<Habit> existingHabitOpt = habitRepository.findByIdAndUserId(id, currentUser.getId());

        if (existingHabitOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("{\"error\": \"Habit not found\"}");
        }

        Habit habit = existingHabitOpt.get();
        String dateKey = LocalDate.now().toString(); // YYYY-MM-DD format
        Set<String> completions = habit.getCompletionDates();
        
        // Handle toggling of progress as well if dailyTarget > 1
        Map<String, Integer> dailyProgress = habit.getDailyProgress();
        if (completions.contains(dateKey)) {
            completions.remove(dateKey);
            dailyProgress.put(dateKey, 0);
        } else {
            completions.add(dateKey);
            dailyProgress.put(dateKey, habit.getDailyTarget());
        }
        habit.setCompletionDates(completions);
        habit.setDailyProgress(dailyProgress);

        Habit savedHabit = habitRepository.saveAndFlush(habit);
        return ResponseEntity.ok(savedHabit);
    }

    @PostMapping("/{id}/progress")
    @Transactional
    public ResponseEntity<?> updateHabitProgress(@PathVariable String id, @RequestBody Map<String, Object> progressRequest, HttpServletRequest request) {
        User currentUser = (User) request.getAttribute("currentUser");
        Optional<Habit> existingHabitOpt = habitRepository.findByIdAndUserId(id, currentUser.getId());

        if (existingHabitOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("{\"error\": \"Habit not found\"}");
        }

        Habit habit = existingHabitOpt.get();
        String dateKey = (String) progressRequest.get("date");
        Number progressNum = (Number) progressRequest.get("progress");

        if (dateKey == null || progressNum == null) {
            return ResponseEntity.badRequest().body("{\"error\": \"Missing date or progress parameter\"}");
        }

        int progress = progressNum.intValue();

        // Update daily progress map
        Map<String, Integer> dailyProgress = habit.getDailyProgress();
        dailyProgress.put(dateKey, progress);
        habit.setDailyProgress(dailyProgress);

        // Check if daily progress meets target
        Set<String> completions = habit.getCompletionDates();
        if (progress >= habit.getDailyTarget()) {
            completions.add(dateKey);
        } else {
            completions.remove(dateKey);
        }
        habit.setCompletionDates(completions);

        Habit savedHabit = habitRepository.saveAndFlush(habit);
        return ResponseEntity.ok(savedHabit);
    }
}

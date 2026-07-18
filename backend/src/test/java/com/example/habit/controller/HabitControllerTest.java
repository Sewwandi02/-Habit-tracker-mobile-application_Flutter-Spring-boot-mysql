package com.example.habit.controller;

import com.example.habit.entity.Habit;
import com.example.habit.entity.User;
import com.example.habit.repository.HabitRepository;
import com.example.habit.repository.UserRepository;
import com.example.habit.service.JwtService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
public class HabitControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private HabitRepository habitRepository;

    @Autowired
    private JwtService jwtService;

    private User testUser;
    private String token;

    @BeforeEach
    public void setup() {
        habitRepository.deleteAll();
        userRepository.deleteAll();

        testUser = new User("test@example.com", "password123");
        userRepository.save(testUser);

        token = jwtService.generateToken(testUser.getEmail());
    }

    @Test
    public void testCreateHabitPersistsToDatabase() throws Exception {
        String requestBody = "{\"title\":\"Drink Water\",\"category\":\"Wellness\",\"dailyTarget\":3}";

        mockMvc.perform(post("/api/habits")
                .header("Authorization", "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestBody))
                .andExpect(status().isCreated());

        assertEquals(1, habitRepository.count());
        Habit createdHabit = habitRepository.findAll().get(0);
        assertEquals("Drink Water", createdHabit.getTitle());
        assertEquals(testUser.getId(), createdHabit.getUser().getId());
    }

    @Test
    public void testCreateHabitWithFlutterPayloadShapePersistsToDatabase() throws Exception {
        String requestBody = "{\"id\":\"1752770297000\",\"title\":\"Drink Water\",\"description\":\"Stay hydrated\",\"category\":\"Wellness\",\"dailyTarget\":3,\"createdAt\":\"2026-07-17T17:51:18.071Z\",\"completionDates\":[],\"dailyProgress\":{},\"color\":\"emerald\",\"icon\":\"track_changes\"}";

        mockMvc.perform(post("/api/habits")
                .header("Authorization", "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestBody))
                .andExpect(status().isCreated());

        assertEquals(1, habitRepository.count());
        Habit createdHabit = habitRepository.findAll().get(0);
        assertEquals("Drink Water", createdHabit.getTitle());
        assertEquals("Stay hydrated", createdHabit.getDescription());
        assertEquals("Wellness", createdHabit.getCategory());
        assertEquals(3, createdHabit.getDailyTarget());
        assertEquals(testUser.getId(), createdHabit.getUser().getId());
    }

    @Test
    public void testUpdateProgressAndCompletion() throws Exception {
        Habit habit = new Habit();
        habit.setId("test-habit");
        habit.setTitle("Drink Water");
        habit.setCategory("Wellness");
        habit.setDailyTarget(3);
        habit.setCreatedAt(Instant.now());
        habit.setUser(testUser);
        habitRepository.save(habit);

        // Update progress to 2 (below target)
        String requestBody = "{\"date\":\"2026-07-10\",\"progress\":2}";
        mockMvc.perform(post("/api/habits/test-habit/progress")
                .header("Authorization", "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestBody))
                .andExpect(status().isOk());

        Habit updatedHabit = habitRepository.findById("test-habit").orElseThrow();
        assertEquals(2, updatedHabit.getDailyProgress().get("2026-07-10"));
        assertFalse(updatedHabit.getCompletionDates().contains("2026-07-10"));

        // Update progress to 3 (reaches target)
        requestBody = "{\"date\":\"2026-07-10\",\"progress\":3}";
        mockMvc.perform(post("/api/habits/test-habit/progress")
                .header("Authorization", "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestBody))
                .andExpect(status().isOk());

        updatedHabit = habitRepository.findById("test-habit").orElseThrow();
        assertEquals(3, updatedHabit.getDailyProgress().get("2026-07-10"));
        assertTrue(updatedHabit.getCompletionDates().contains("2026-07-10"));
    }
}

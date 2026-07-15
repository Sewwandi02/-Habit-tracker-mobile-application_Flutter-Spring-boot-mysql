package com.example.habit.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import java.time.Instant;
import java.util.HashSet;
import java.util.Set;
import java.util.Map;
import java.util.HashMap;

@Entity
@Table(name = "habits")
public class Habit {

    @Id
    private String id;

    @NotBlank
    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    private String category;

    @Column(name = "daily_target")
    private int dailyTarget;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    private String color;

    private String icon;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "habit_completion_dates", joinColumns = @JoinColumn(name = "habit_id"))
    @Column(name = "completion_date")
    private Set<String> completionDates = new HashSet<>();

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "habit_daily_progress", joinColumns = @JoinColumn(name = "habit_id"))
    @MapKeyColumn(name = "completion_date")
    @Column(name = "progress")
    private Map<String, Integer> dailyProgress = new HashMap<>();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @JsonIgnore
    private User user;

    public Habit() {
    }

    public Habit(String id, String title, String description, String category, int dailyTarget, Instant createdAt, Set<String> completionDates, Map<String, Integer> dailyProgress, String color, String icon, User user) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.category = category;
        this.dailyTarget = dailyTarget;
        this.createdAt = createdAt;
        this.completionDates = completionDates != null ? completionDates : new HashSet<>();
        this.dailyProgress = dailyProgress != null ? dailyProgress : new HashMap<>();
        this.color = color;
        this.icon = icon;
        this.user = user;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public int getDailyTarget() {
        return dailyTarget;
    }

    public void setDailyTarget(int dailyTarget) {
        this.dailyTarget = dailyTarget;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public Set<String> getCompletionDates() {
        return completionDates;
    }

    public void setCompletionDates(Set<String> completionDates) {
        this.completionDates = completionDates;
    }

    public Map<String, Integer> getDailyProgress() {
        return dailyProgress;
    }

    public void setDailyProgress(Map<String, Integer> dailyProgress) {
        this.dailyProgress = dailyProgress;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}

package com.example.habit.repository;

import com.example.habit.entity.Habit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface HabitRepository extends JpaRepository<Habit, String> {
    List<Habit> findByUserId(Long userId);
    Optional<Habit> findByIdAndUserId(String id, Long userId);
}

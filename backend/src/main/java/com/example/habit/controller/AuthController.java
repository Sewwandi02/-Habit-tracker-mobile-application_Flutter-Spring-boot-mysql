package com.example.habit.controller;

import com.example.habit.entity.User;
import com.example.habit.repository.UserRepository;
import com.example.habit.service.JwtService;
import com.example.habit.utils.PasswordHasher;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtService jwtService;

    @PostMapping("/signup")
    @Transactional
    public ResponseEntity<?> signUp(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String password = request.get("password");

        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "Email and password are required.");
            return ResponseEntity.badRequest().body(errorResponse);
        }

        email = email.trim().toLowerCase();

        if (userRepository.findByEmail(email).isPresent()) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "An account already exists for that email.");
            return ResponseEntity.badRequest().body(errorResponse);
        }

        User user = new User(email, PasswordHasher.hash(password));
        userRepository.saveAndFlush(user);

        String token = jwtService.generateToken(email);
        Map<String, String> response = new HashMap<>();
        response.put("token", token);
        response.put("email", email);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String password = request.get("password");

        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "Email and password are required.");
            return ResponseEntity.badRequest().body(errorResponse);
        }

        email = email.trim().toLowerCase();
        Optional<User> userOpt = userRepository.findByEmail(email);

        if (userOpt.isEmpty() || !PasswordHasher.verify(password, userOpt.get().getPassword())) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "Incorrect email or password.");
            return ResponseEntity.status(401).body(errorResponse);
        }

        String token = jwtService.generateToken(email);
        Map<String, String> response = new HashMap<>();
        response.put("token", token);
        response.put("email", email);

        return ResponseEntity.ok(response);
    }
}

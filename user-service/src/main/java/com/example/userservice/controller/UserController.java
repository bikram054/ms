package com.example.userservice.controller;

import com.example.userservice.entity.User;
import com.example.userservice.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

@RestController
@RequestMapping("/api/users")
public class UserController {
    private static final Logger logger = LoggerFactory.getLogger(UserController.class);

    @Autowired
    private UserService userService;
    
    @GetMapping
    public List<User> getAllUsers() {
        logger.debug("GET /api/users called");
        List<User> list = userService.getAllUsers();
        logger.debug("GET /api/users returning {} users", list.size());
        return list;
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        logger.debug("GET /api/users/{} called", id);
        return userService.getUserById(id)
            .map(resp -> {
                logger.debug("GET /api/users/{} found", id);
                return ResponseEntity.ok(resp);
            })
            .orElseGet(() -> {
                logger.debug("GET /api/users/{} not found", id);
                return ResponseEntity.notFound().build();
            });
    }
    
    @PostMapping
    public ResponseEntity<User> createUser(@RequestBody User user) {
        logger.info("POST /api/users create name={} email={}", user.getName(), user.getEmail());
        User resp = userService.createUser(user);
        logger.info("POST /api/users created id={}", resp.getId());
        return ResponseEntity.status(HttpStatus.CREATED).body(resp);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<User> replaceUser(@PathVariable Long id, @RequestBody User user) {
        // PUT = full replace; requires name/email present
        try {
            User replaced = userService.replaceUser(id, user);
            logger.info("PUT /api/users/{} replaced", id);
            return ResponseEntity.ok(replaced);
        } catch (RuntimeException e) {
            logger.debug("PUT /api/users/{} not found", id);
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}")
    public ResponseEntity<User> patchUser(@PathVariable Long id, @RequestBody User user) {
        // PATCH = partial update
        try {
            User updated = userService.updateUser(id, user);
            logger.info("PATCH /api/users/{} updated", id);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            logger.debug("PATCH /api/users/{} not found", id);
            return ResponseEntity.notFound().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        logger.info("DELETE /api/users/{} called", id);
        userService.deleteUser(id);
        logger.info("DELETE /api/users/{} completed", id);
        return ResponseEntity.noContent().build();
    }
}

package com.example.springapp;

import org.springframework.web.bind.annotation.*;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
public class HelloController {

    private final MessageRepository messageRepository;

    public HelloController(MessageRepository messageRepository) {
        this.messageRepository = messageRepository;
    }

    @GetMapping("/")
    public Map<String, Object> hello() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Hello from Spring Boot!");
        response.put("hostname", getHostname());
        response.put("service", "spring-app");
        response.put("database", "PostgreSQL connected");
        return response;
    }

    @GetMapping("/health")
    public Map<String, String> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("hostname", getHostname());
        return response;
    }

    @GetMapping("/messages")
    public List<Message> getMessages() {
        return messageRepository.findTop10ByOrderByCreatedAtDesc();
    }

    @PostMapping("/messages")
    public Message createMessage(@RequestBody Map<String, String> body) {
        String content = body.getOrDefault("content", "Hello!");
        Message message = new Message(content, getHostname());
        return messageRepository.save(message);
    }

    @GetMapping("/messages/count")
    public Map<String, Object> getMessageCount() {
        Map<String, Object> response = new HashMap<>();
        response.put("count", messageRepository.count());
        response.put("hostname", getHostname());
        return response;
    }

    private String getHostname() {
        try {
            return InetAddress.getLocalHost().getHostName();
        } catch (UnknownHostException e) {
            return "unknown";
        }
    }
}

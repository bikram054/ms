package com.example.orderservice.dto;

import java.time.LocalDateTime;

public record OrderResponse(
    Long id,
    Long userId,
    String userName,
    Long productId,
    String productName,
    Integer quantity,
    Double totalAmount,
    String status,
    LocalDateTime orderDate
) {}

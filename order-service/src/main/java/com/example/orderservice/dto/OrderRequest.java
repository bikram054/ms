package com.example.orderservice.dto;

public record OrderRequest(
    Long userId,
    Long productId,
    Integer quantity
) {}

package com.example.productservice.controller;

import com.example.productservice.entity.Product;
import com.example.productservice.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

@RestController
@RequestMapping("/api/products")
public class ProductController {
    private static final Logger logger = LoggerFactory.getLogger(ProductController.class);

    @Autowired
    private ProductService productService;
    
    @GetMapping
    public List<Product> getAllProducts() {
        logger.debug("GET /api/products called");
        List<Product> list = productService.getAllProducts();
        logger.debug("GET /api/products returning {} products", list.size());
        return list;
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Product> getProductById(@PathVariable Long id) {
        logger.debug("GET /api/products/{} called", id);
        return productService.getProductById(id)
            .map(resp -> {
                logger.debug("GET /api/products/{} found", id);
                return ResponseEntity.ok(resp);
            })
            .orElseGet(() -> {
                logger.debug("GET /api/products/{} not found", id);
                return ResponseEntity.notFound().build();
            });
    }
    
    @PostMapping
    public ResponseEntity<Product> createProduct(@RequestBody Product product) {
        logger.info("POST /api/products create name={} price={}", product.getName(), product.getPrice());
        Product resp = productService.createProduct(product);
        logger.info("POST /api/products created id={}", resp.getId());
        return ResponseEntity.status(HttpStatus.CREATED).body(resp);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Product> updateProduct(@PathVariable Long id, @RequestBody Product product) {
        try {
            Product updated = productService.updateProduct(id, product);
            logger.info("PUT /api/products/{} updated", id);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            logger.debug("PUT /api/products/{} not found", id);
            return ResponseEntity.notFound().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id) {
        logger.info("DELETE /api/products/{} called", id);
        productService.deleteProduct(id);
        logger.info("DELETE /api/products/{} completed", id);
        return ResponseEntity.noContent().build();
    }
}

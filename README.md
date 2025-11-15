# Microservices Project

This project contains three Spring Boot microservices:
- **user-service** (Port 8081)
- **product-service** (Port 8082)
- **order-service** (Port 8083)

## Services Overview

### User Service
Manages user information.

**Endpoints:**
- `GET /api/users` - Get all users
- `GET /api/users/{id}` - Get user by ID
- `POST /api/users` - Create new user
- `PUT /api/users/{id}` - Replace a user (full update; requires `name` and `email`)
- `PATCH /api/users/{id}` - Partially update a user (only supplied fields are changed)
- `DELETE /api/users/{id}` - Delete user

**Sample Request:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "1234567890"
}
```

### Product Service
Manages product catalog.

**Endpoints:**
- `GET /api/products` - Get all products
- `GET /api/products/{id}` - Get product by ID
- `POST /api/products` - Create new product
- `PUT /api/products/{id}` - Update product
- `DELETE /api/products/{id}` - Delete product

**Sample Request:**
```json
{
  "name": "Laptop",
  "description": "High-performance laptop",
  "price": 999.99,
  "stock": 50
}
```

### Order Service
Manages orders and communicates with User and Product services.

**Endpoints:**
- `GET /api/orders` - Get all orders
- `GET /api/orders/{id}` - Get order by ID
- `POST /api/orders` - Create new order
- `DELETE /api/orders/{id}` - Delete order

**Sample Request:**
```json
{
  "userId": 1,
  "productId": 1,
  "quantity": 2
}
```

## Running with Docker Compose

### Build and Start All Services
```bash
docker-compose up --build
```

### Start Services (without rebuild)
```bash
docker-compose up
```

### Stop All Services
```bash
docker-compose down
```

### View Logs
```bash
docker-compose logs -f
```

## Running Individual Services Locally

### User Service
```bash
cd user-service
mvn spring-boot:run
```

### Product Service
```bash
cd product-service
mvn spring-boot:run
```

### Order Service
```bash
cd order-service
mvn spring-boot:run
```

## Testing the Services

1. Create a user:
```bash
curl -X POST http://localhost:8081/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com","phone":"1234567890"}'
```

2. Create a product:
```bash
curl -X POST http://localhost:8082/api/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Laptop","description":"High-performance laptop","price":999.99,"stock":50}'
```

3. Create an order:
```bash
curl -X POST http://localhost:8083/api/orders \
  -H "Content-Type: application/json" \
  -d '{"userId":1,"productId":1,"quantity":2}'
```

## Architecture

- Each service runs in its own Docker container
- Services communicate via REST APIs
- Order service calls User and Product services to enrich order data
- Each service has its own H2 in-memory database
- Services are connected via a Docker bridge network

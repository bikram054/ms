# API Reference

This document describes the main API endpoints and semantics for the microservices.

## User Service (http://localhost:8081)

Endpoints:

- `GET /api/users` - Get all users
- `GET /api/users/{id}` - Get user by ID
- `POST /api/users` - Create new user
- `PUT /api/users/{id}` - Replace user (full update)
  - Semantics: Full replace. The request body must include required fields (`name` and `email`). Missing required fields will result in a 400 Bad Request.
  - Example request body:
  ```json
  {
    "name": "Jane Doe",
    "email": "jane@example.com",
    "phone": "555-1212"
  }
  ```
- `PATCH /api/users/{id}` - Partial update
  - Semantics: Partial update. Only the fields present in the request body will be updated; absent fields remain unchanged.
  - Example request body (update only phone):
  ```json
  {
    "phone": "999-999-9999"
  }
  ```
- `DELETE /api/users/{id}` - Delete user

Notes:
- `PUT` is intended for full replacements and validates required fields. Use `PATCH` for partial updates to avoid accidental nulling of required columns.
- The service validates required fields and will return a 400-level error for client mistakes (e.g., missing required fields).

## Product Service (http://localhost:8082)

Endpoints:

- `GET /api/products` - Get all products
- `GET /api/products/{id}` - Get product by ID
- `POST /api/products` - Create new product
- `PUT /api/products/{id}` - Update product (full replace semantics)
- `DELETE /api/products/{id}` - Delete product

## Order Service (http://localhost:8083)

Endpoints:

- `GET /api/orders` - Get all orders
- `GET /api/orders/{id}` - Get order by ID
- `POST /api/orders` - Create new order
  - Example request body:
  ```json
  {
    "userId": 1,
    "productId": 1,
    "quantity": 2
  }
  ```
- `DELETE /api/orders/{id}` - Delete order

## Error handling

- Services return `4xx` for client errors (invalid payload, missing required fields) and `5xx` for unexpected server errors.
- The `user-service` enforces `name` and `email` as required for full `PUT` replacements; use `PATCH` to only change a subset of fields.

## Testing with curl

Create a user:

```bash
curl -X POST http://localhost:8081/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com","phone":"1234567890"}'
```

Partial update (PATCH):

```bash
curl -X PATCH http://localhost:8081/api/users/1 \
  -H "Content-Type: application/json" \
  -d '{"phone":"999-999-9999"}'
```

Full replace (PUT):

```bash
curl -X PUT http://localhost:8081/api/users/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Jane Doe","email":"jane@example.com","phone":"555-1212"}'
```

*** End Patch
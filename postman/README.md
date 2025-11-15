# Postman API Test Suite

This directory contains a comprehensive Postman collection for testing the microservices API across three services: Order Service, Product Service, and User Service.

## Contents

- `api-tests.postman_collection.json` - Postman collection with 14 API requests
- `api-environment.postman_environment.json` - Environment configuration with service URLs and variables

## Services Tested

| Service | Port | Base URL |
|---------|------|----------|
| Order Service | 8083 | http://localhost:8083 |
| Product Service | 8082 | http://localhost:8082 |
| User Service | 8081 | http://localhost:8081 |

## API Endpoints Covered

### Orders
- `GET /api/orders` - List all orders
- `GET /api/orders/{id}` - Get order by ID
- `POST /api/orders` - Create a new order
- `DELETE /api/orders/{id}` - Delete an order

### Products
- `GET /api/products` - List all products
- `GET /api/products/{id}` - Get product by ID
- `POST /api/products` - Create a new product
- `PUT /api/products/{id}` - Update a product
- `DELETE /api/products/{id}` - Delete a product

### Users
- `GET /api/users` - List all users
- `GET /api/users/{id}` - Get user by ID
- `POST /api/users` - Create a new user
- `PUT /api/users/{id}` - Update a user
- `DELETE /api/users/{id}` - Delete a user

## Using with Postman Desktop

1. Open Postman
2. Click **Import** in the top left
3. Select **Upload Files** and choose `api-tests.postman_collection.json`
4. Import the environment file:
   - Click **Environments** in the left sidebar
   - Click **Import**
   - Select `api-environment.postman_environment.json`
5. Click the environment dropdown in the top right and select `api-environment`
6. Run requests individually or use **Run Collection** to execute all tests

## Using with Newman CLI

### Prerequisites

Ensure Docker is running with the three microservices started via docker-compose:

```bash
docker-compose up -d
```

### Running Tests

Execute all tests with a simple command:

```bash
docker run --rm --network=host \
  -v "$PWD/postman":/etc/newman \
  -w /etc/newman \
  postman/newman:alpine run api-tests.postman_collection.json \
  -e api-environment.postman_environment.json \
  --reporters cli,json \
  --reporter-json-export newman-report.json
```

### Without Docker

If Newman is installed locally:

```bash
newman run api-tests.postman_collection.json \
  -e api-environment.postman_environment.json \
  --reporters cli,json \
  --reporter-json-export newman-report.json
```

## Environment Variables

The `api-environment.postman_environment.json` file includes:

| Variable | Value |
|----------|-------|
| `orderBaseUrl` | http://localhost:8083 |
| `productBaseUrl` | http://localhost:8082 |
| `userBaseUrl` | http://localhost:8081 |
| `orderId` | 1 (set after POST order) |
| `productId` | 1 (set after POST product) |
| `userId` | 1 (set after POST user) |

## Test Scripts

Each request includes automated test scripts that validate:

- **Status Codes**: Verify responses return expected HTTP status codes (200, 201, 204, 400, 404, 500)
- **Response Structure**: Confirm JSON responses contain expected properties
- **Data Validation**: Check that created resources have IDs and proper attributes

## HTTP Status Codes

The API follows REST standards:

- `200 OK` - Successful GET, PUT operations
- `201 Created` - Successful POST operations (resource created)
- `204 No Content` - Successful DELETE operations
- `400 Bad Request` - Invalid request (missing fields, invalid data)
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

## Test Results

### Expected Results

All 14 requests should complete successfully with:
- ✅ 14 requests executed
- ✅ 0 failed
- ✅ 23 assertions passed
- ✅ 0 assertion failures

### Sample Run Output

```
┌─────────────────────────┬──────────────────┬───────────────────┐
│                         │         executed │            failed │
├─────────────────────────┼──────────────────┼───────────────────┤
│              iterations │                1 │                 0 │
│                requests │               14 │                 0 │
│            test-scripts │               14 │                 0 │
│              assertions │               23 │                 0 │
└─────────────────────────┴──────────────────┴───────────────────┘
```

## Troubleshooting

### Services Not Responding

If you get connection errors, verify the services are running:

```bash
docker-compose ps
```

All three services should show `Up` status.

### Port Already in Use

If ports 8081-8083 are already in use, update the environment file with the correct ports.

### 400 Bad Request on Order Creation

Order creation validates that the referenced product exists. Ensure:
1. Product Service is running
2. Product ID in the order request exists in the Product Service
3. The product was successfully created before creating the order

### Timeout Errors

Increase the timeout in Newman:

```bash
newman run api-tests.postman_collection.json \
  -e api-environment.postman_environment.json \
  --request-timeout 10000
```

## Integration with CI/CD

Example GitHub Actions workflow:

```yaml
- name: Run Postman Tests
  run: |
    docker run --rm --network=host \
      -v "$PWD/postman":/etc/newman \
      -w /etc/newman \
      postman/newman:alpine run api-tests.postman_collection.json \
      -e api-environment.postman_environment.json \
      --reporters json \
      --reporter-json-export test-results.json
```

## Notes

- Tests run sequentially to ensure data consistency
- Each test creates new resources with fresh data
- DELETE operations clean up test data
- The in-memory H2 database resets on service restart

## Support

For issues or questions:
1. Check service logs: `docker logs <service-name>`
2. Verify network connectivity: `docker-compose ps`
3. Review test scripts in Postman for detailed assertions

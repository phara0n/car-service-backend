# API Testing Guide

This document provides instructions for testing the Car Service Management System API using the provided script.

## Prerequisites

- The Rails server must be running on port 3000
- Python 3 must be installed (for JSON processing)
- cURL must be installed

## Running the Test Script

1. Make sure the Rails server is running:
   ```
   bin/rails server -b 0.0.0.0
   ```

2. In a separate terminal, run the test script:
   ```
   ./test_api.sh
   ```

3. The script will test various API endpoints using different user roles (superadmin, admin, customer) and display the responses.

## What the Script Tests

The script tests the following functionality:

### Authentication
- Login as superadmin, admin, and customer
- Token verification

### Admin User Management
- Get all users (as superadmin)
- Create a new admin user (as superadmin)
- Try to create an admin user as non-superadmin (should fail)

### Customer Management
- Get all customers (as admin)
- Create a new customer

### Car Management
- Get all cars (as admin)
- Get all cars (as customer - should only show customer's cars)

### Service Management
- Get all services
- Create a new service

### Appointment Management
- Get all appointments (as admin)
- Get customer appointments (as customer)
- Create a new appointment (as customer)

### Customer Portal API
- Get customer profile
- Get customer's cars
- Update car mileage

### Mileage Records
- Get mileage records (as admin)
- Get mileage records (as customer)
- Create a new mileage record

## Understanding the Output

The script output is color-coded:
- **Blue**: Indicates the request being made
- **Green**: Indicates the response
- **Yellow**: Section headers
- **Red**: Error messages

Each API call shows:
1. The HTTP method and endpoint
2. The request data (if applicable)
3. The raw curl command
4. The formatted JSON response

## Testing Custom Endpoints

If you want to test custom endpoints, you can modify the script or use the `api_request` function directly:

```bash
# Example: Test a custom endpoint
TOKEN=$ADMIN_TOKEN  # Use appropriate token
api_request "GET" "/custom/endpoint" ""  # For GET without data
api_request "POST" "/custom/endpoint" "{\"key\":\"value\"}"  # For POST with data
``` 
# Car Service Management System

## Overview

The Car Service Management System is a comprehensive solution for car service businesses to manage customers, vehicles, appointments, and services. It features a powerful mileage tracking and service prediction system that helps businesses and customers plan maintenance activities.

## Features

### User Management
- Multi-role system with SuperAdmin, Admin, and Customer access levels
- Secure authentication with JWT tokens
- Role-based access control with proper authorization

### Customer Management
- Complete customer profiles with contact information
- Support for Tunisian market specifics (national ID, tax information)
- Auto-generation of customer accounts

### Vehicle Tracking
- Detailed vehicle information storage
- Complete vehicle history
- Mileage tracking with validation
- Special fields for Tunisian market (customs clearance, technical visits)

### Service Schedule Prediction
- Algorithm to predict when services will be needed based on:
  - Historical mileage usage patterns
  - Service type requirements
  - Average daily mileage calculation
  - Time and distance-based service intervals
- Notification system for services due soon
- For detailed documentation, see [SERVICE_PREDICTION.md](SERVICE_PREDICTION.md)

### Appointment Management
- Booking system for service appointments
- Status tracking (pending, confirmed, completed, cancelled)
- Service bundling with time and cost estimation
- Customer self-service booking through the portal

### API-Driven Architecture
- Complete REST API for all operations
- Separate endpoints for admin and customer access
- Authentication and authorization for all requests
- Well-documented API for integration with other systems
- For API testing instructions, see [POSTMAN_USAGE.md](POSTMAN_USAGE.md)

## Technology Stack

- **Backend**: Ruby on Rails API
- **Database**: PostgreSQL
- **Authentication**: JWT (JSON Web Tokens)
- **Authorization**: Pundit
- **Serialization**: Active Model Serializers

## Installation

### Prerequisites
- Ruby 3.0.0 or higher
- Rails 7.0.0 or higher
- PostgreSQL 12 or higher
- Node.js 14 or higher (for frontend)

### Setup
1. Clone the repository:
   ```
   git clone https://github.com/yourusername/car-service-app.git
   cd car-service-app
   ```

2. Install the dependencies:
   ```
   bundle install
   ```

3. Setup the database:
   ```
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. Start the server:
   ```
   rails s
   ```

## API Documentation

### Authentication
```
POST /api/v1/auth/login
{
  "email": "user@example.com",
  "password": "password"
}
```

Response:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "User Name",
    "role": "admin"
  }
}
```

### Mileage Tracking & Service Prediction
```
# Update mileage for a car
PATCH /api/v1/customer_portal/cars/:id/update_mileage
{
  "current_mileage": 46000
}

# View service predictions for a car
GET /api/v1/customer_portal/service_predictions/cars/:car_id

# View all cars due for service soon (admin only)
GET /api/v1/service_predictions/due_soon
```

### Appointments

```
# Create a new appointment
POST /api/v1/customer_portal/appointments
{
  "appointment": {
    "car_id": 1,
    "date": "2023-06-15",
    "time": "10:00",
    "notes": "Regular maintenance",
    "service_ids": [1, 2]
  }
}
```

## Demo Credentials

- **SuperAdmin**: superadmin@example.com / password123
- **Admin**: admin@example.com / password123
- **Customer**: customer1@example.com / password123

## Project Structure

- `app/models` - Data models
- `app/controllers/api/v1` - API endpoints
- `app/controllers/api/v1/admin` - Admin-specific endpoints
- `app/controllers/api/v1/customer_portal` - Customer-specific endpoints
- `app/services` - Business logic and services
- `config/routes.rb` - API route definitions
- `db/migrations` - Database schema

## Documentation

- [SERVICE_PREDICTION.md](SERVICE_PREDICTION.md) - Detailed documentation on the service prediction feature
- [POSTMAN_USAGE.md](POSTMAN_USAGE.md) - Guide for testing the API with Postman

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Ruby on Rails community
- PostgreSQL
- JWT

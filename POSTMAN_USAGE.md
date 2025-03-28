# Car Service Management API - Postman Usage Guide

This guide will help you test the Car Service Management API using the Postman collection. The collection includes requests for all endpoints in the API, organized by user role and functionality.

## Getting Started

### 1. Import the Collection
- Download the Postman Collection: `car_service_api.postman_collection.json`
- Open Postman
- Click "Import" and select the downloaded file
- The collection will appear in your Postman workspace

### 2. Set Up Environment Variables
Create a new environment in Postman with the following variables:
- `baseUrl`: Your API base URL (default: `http://localhost:3000`)
- `adminToken`: Will be automatically set after login
- `customerToken`: Will be automatically set after login

### 3. Authentication
The collection includes login requests for different user roles:
- **Admin Login**: Uses superadmin@example.com / password123
- **Customer Login**: Uses customer1@example.com / password123

These requests will automatically set the `adminToken` and `customerToken` variables.

## Testing Different User Roles

### Admin Functions
1. **Login as Admin**
   - Use the "Admin Login" request
   - Verify the token is returned and set in the `adminToken` variable

2. **Managing Users**
   - List Users
   - Create User
   - View User
   - Update User
   - Delete User

3. **Managing Service Schedules**
   - List Service Schedules
   - Create Service Schedule
   - View Service Schedule
   - Update Service Schedule
   - Delete Service Schedule

4. **Service Prediction (Admin View)**
   - View All Cars Due For Service Soon
     - This endpoint returns cars that need service based on mileage thresholds or time intervals
   - View Service Predictions for Specific Car
     - Shows detailed prediction data for a single car
   - Update Service Predictions for a Car
     - Triggers the prediction algorithm to recalculate based on the latest data

### Customer Portal
1. **Login as Customer**
   - Use the "Customer Login" request
   - Verify the token is returned and set in the `customerToken` variable

2. **Managing Profile**
   - View Profile
   - Update Profile

3. **Managing Cars**
   - List My Cars
   - View Car Details
   - Update Car Mileage
     - This triggers service prediction updates automatically

4. **Service Prediction (Customer View)**
   - View Service Predictions for All My Cars
     - Shows predictions for when services will be needed for all customer's cars
   - View Service Predictions for Specific Car
     - Shows detailed prediction data including:
       - Current mileage
       - Average daily mileage
       - Upcoming service schedules
       - Time and mileage remaining until next service
       - Services due soon

5. **Managing Appointments**
   - List My Appointments
   - Create Appointment
   - View Appointment Details

## Entity Management

### Cars
- List Cars (Admin)
- Create Car (Admin)
- View Car (Admin/Owner)
- Update Car (Admin)
- Delete Car (Admin)
- Update Car Mileage (Admin/Owner)

### Mileage Records
- List Mileage Records (Admin/Owner)
- Create Mileage Record (Admin/Owner)
- View Mileage Record (Admin/Owner)
- Update Mileage Record (Admin)
- Delete Mileage Record (Admin)

### Service Predictions Testing
1. **Update Mileage Records**
   - Use the "Update Car Mileage" request to add new mileage data
   - Add several records with increasing mileage and different dates

2. **View Predictions**
   - Use the "Get Service Predictions" request to see updated predictions
   - Check how the predicted service dates change based on mileage updates

3. **Check Due Soon List (Admin)**
   - Use the "Get Cars Due For Service" request to see vehicles needing attention
   - This list helps admins proactively contact customers for needed service

## Common Testing Flows

### Complete Testing Flow Example
1. Login as Admin
2. Create a new Customer
3. Create a new Car for the Customer
4. Add initial Mileage Record
5. Create Service Schedules for the Car
6. Update the Car's mileage several times
7. View Service Predictions
8. Check Cars Due for Service
9. Login as Customer
10. View Service Predictions for their Car
11. Create an Appointment for a predicted service
12. Update mileage after service
13. View updated predictions

## Troubleshooting

- **Authentication Issues**: Ensure you've run the login request and the token is set correctly
- **404 Errors**: Check the ID parameters in your requests
- **422 Errors**: Validation issues - check your request payload against the API requirements
- **500 Errors**: Server-side issues - check the server logs

## API Response Structure

All API responses follow this general structure:
```json
{
  "data": { ... },
  "meta": { ... } // Optional pagination info
}
```

Error responses:
```json
{
  "error": "Error message",
  "errors": ["Detailed error 1", "Detailed error 2"] // Validation errors
}
```

## Additional Information

- The service prediction algorithm uses historical mileage data to calculate average daily mileage
- Predictions become more accurate as more mileage records are added
- Most endpoints include pagination for large data sets
- Use the "Update Service Predictions" endpoint to manually recalculate if needed 
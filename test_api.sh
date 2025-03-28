#!/bin/bash

# API Testing Script for Car Service Management System
# -----------------------------------------

# Set API base URL
BASE_URL="http://localhost:3000/api/v1"
TOKEN=""
ADMIN_TOKEN=""
CUSTOMER_TOKEN=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Car Service Management API Testing ===${NC}\n"

# Function to print section headers
print_header() {
  echo -e "\n${YELLOW}=== $1 ===${NC}"
}

# Function to make API requests and format the response
api_request() {
  local method=$1
  local endpoint=$2
  local data=$3
  local auth_header=""
  
  if [ -n "$TOKEN" ]; then
    auth_header="-H \"Authorization: $TOKEN\""
  fi
  
  echo -e "${BLUE}$method $endpoint${NC}"
  if [ -n "$data" ]; then
    echo -e "${BLUE}Data: $data${NC}"
  fi
  
  local cmd="curl -s -X $method \"$BASE_URL$endpoint\" \
    -H \"Content-Type: application/json\" \
    $auth_header \
    ${data:+-d '$data'}"
  
  echo -e "${BLUE}Command: $cmd${NC}"
  
  # Execute the command and capture response
  local response=$(eval $cmd)
  
  # Pretty print the JSON response
  echo -e "${GREEN}Response:${NC}"
  echo $response | python3 -m json.tool || echo $response
  echo ""
  
  # Return the response for possible token extraction
  echo $response
}

# Test Authentication
# ------------------
print_header "Authentication Testing"

# Test superadmin login
echo -e "\n${BLUE}Testing superadmin login${NC}"
response=$(api_request "POST" "/auth/login" "{\"email\":\"superadmin@example.com\",\"password\":\"password123\"}")
SUPERADMIN_TOKEN=$(echo $response | python3 -c "import sys, json; print(json.load(sys.stdin).get('token', ''))" 2>/dev/null)
echo -e "${BLUE}Extracted superadmin token: ${NC}$SUPERADMIN_TOKEN"
TOKEN=$SUPERADMIN_TOKEN

# Test admin login
echo -e "\n${BLUE}Testing admin login${NC}"
response=$(api_request "POST" "/auth/login" "{\"email\":\"admin@example.com\",\"password\":\"password123\"}")
ADMIN_TOKEN=$(echo $response | python3 -c "import sys, json; print(json.load(sys.stdin).get('token', ''))" 2>/dev/null)
echo -e "${BLUE}Extracted admin token: ${NC}$ADMIN_TOKEN"

# Test customer login
echo -e "\n${BLUE}Testing customer login${NC}"
response=$(api_request "POST" "/auth/login" "{\"email\":\"customer1@example.com\",\"password\":\"password123\"}")
CUSTOMER_TOKEN=$(echo $response | python3 -c "import sys, json; print(json.load(sys.stdin).get('token', ''))" 2>/dev/null)
echo -e "${BLUE}Extracted customer token: ${NC}$CUSTOMER_TOKEN"

# Test token verification
echo -e "\n${BLUE}Testing token verification${NC}"
TOKEN=$SUPERADMIN_TOKEN
api_request "GET" "/auth/verify" ""

# Admin User Management
# --------------------
print_header "Admin User Management"

# Get all users (as superadmin)
echo -e "\n${BLUE}Getting all users as superadmin${NC}"
TOKEN=$SUPERADMIN_TOKEN
api_request "GET" "/admin/users" ""

# Create a new admin user
echo -e "\n${BLUE}Creating a new admin user${NC}"
new_admin_data="{\"user\":{\"name\":\"New Admin\",\"email\":\"new_admin@example.com\",\"password\":\"password123\",\"password_confirmation\":\"password123\",\"role\":\"admin\"}}"
api_request "POST" "/admin/users" "$new_admin_data"

# Try to create an admin user as non-superadmin (should fail)
echo -e "\n${BLUE}Trying to create an admin as non-superadmin (should fail)${NC}"
TOKEN=$ADMIN_TOKEN
api_request "POST" "/admin/users" "$new_admin_data"

# Customer Management
# ------------------
print_header "Customer Management"

# Get all customers (as admin)
echo -e "\n${BLUE}Getting all customers as admin${NC}"
TOKEN=$ADMIN_TOKEN
api_request "GET" "/customers" ""

# Create a new customer
echo -e "\n${BLUE}Creating a new customer${NC}"
new_customer_data="{\"customer\":{\"name\":\"Test Customer\",\"email\":\"test_customer@example.com\",\"phone\":\"555-123-4567\",\"address\":\"123 Test St\",\"national_id\":\"12345678\",\"tax_number\":\"87654321\",\"region_code\":\"TUN1\"}}"
api_request "POST" "/customers" "$new_customer_data"

# Car Management
# -------------
print_header "Car Management"

# Get all cars (as admin)
echo -e "\n${BLUE}Getting all cars as admin${NC}"
TOKEN=$ADMIN_TOKEN
api_request "GET" "/cars" ""

# Get all cars (as customer)
echo -e "\n${BLUE}Getting all cars as customer (should only return customer's cars)${NC}"
TOKEN=$CUSTOMER_TOKEN
api_request "GET" "/cars" ""

# Service Management
# -----------------
print_header "Service Management"

# Get all services
echo -e "\n${BLUE}Getting all services${NC}"
TOKEN=$ADMIN_TOKEN
api_request "GET" "/services" ""

# Create a new service
echo -e "\n${BLUE}Creating a new service${NC}"
new_service_data="{\"service\":{\"name\":\"Engine Diagnostic\",\"description\":\"Full engine diagnostic scan\",\"price\":59.99,\"duration\":45,\"active\":true}}"
api_request "POST" "/services" "$new_service_data"

# Appointment Management
# ---------------------
print_header "Appointment Management"

# Get all appointments (as admin)
echo -e "\n${BLUE}Getting all appointments as admin${NC}"
TOKEN=$ADMIN_TOKEN
api_request "GET" "/appointments" ""

# Get all appointments (as customer)
echo -e "\n${BLUE}Getting all appointments as customer (should only return customer's appointments)${NC}"
TOKEN=$CUSTOMER_TOKEN
api_request "GET" "/appointments" ""

# Try to create a new appointment as a customer
# First, we need to get customer's car ID
echo -e "\n${BLUE}Getting customer's cars to create an appointment${NC}"
response=$(api_request "GET" "/cars" "")
CAR_ID=$(echo $response | python3 -c "import sys, json; data = json.load(sys.stdin); print(data[0]['id'] if data else '')" 2>/dev/null)
CUSTOMER_ID=$(echo $response | python3 -c "import sys, json; data = json.load(sys.stdin); print(data[0]['customer']['id'] if data else '')" 2>/dev/null)

if [ -n "$CAR_ID" ] && [ -n "$CUSTOMER_ID" ]; then
  echo -e "\n${BLUE}Creating a new appointment for car ID $CAR_ID${NC}"
  # Get services first
  response=$(api_request "GET" "/services" "")
  SERVICE_IDS=$(echo $response | python3 -c "import sys, json; data = json.load(sys.stdin); print(','.join([str(s['id']) for s in data[:2]]))" 2>/dev/null)
  
  # Create appointment using the customer portal API
  service_ids_array="[$SERVICE_IDS]"
  echo -e "Service IDs: $service_ids_array"
  
  new_appointment_data="{\"appointment\":{\"customer_id\":$CUSTOMER_ID,\"car_id\":$CAR_ID,\"date\":\"2024-05-01\",\"time\":\"14:30\",\"status\":\"pending\",\"notes\":\"Created from API test script\",\"service_ids\":$service_ids_array}}"
  api_request "POST" "/customer_portal/appointments" "$new_appointment_data"
else
  echo -e "${RED}Couldn't retrieve car or customer ID for appointment creation${NC}"
fi

# Customer Portal API
# ------------------
print_header "Customer Portal API Testing"

# Get customer profile
echo -e "\n${BLUE}Getting customer profile${NC}"
TOKEN=$CUSTOMER_TOKEN
api_request "GET" "/customer_portal/profile" ""

# Get customer's cars
echo -e "\n${BLUE}Getting customer's cars${NC}"
TOKEN=$CUSTOMER_TOKEN
api_request "GET" "/customer_portal/cars" ""

# Update a car's mileage
if [ -n "$CAR_ID" ]; then
  echo -e "\n${BLUE}Updating mileage for car ID $CAR_ID${NC}"
  update_mileage_data="{\"current_mileage\":55000}"
  api_request "PATCH" "/customer_portal/cars/$CAR_ID/update_mileage" "$update_mileage_data"
else
  echo -e "${RED}Couldn't retrieve car ID for mileage update${NC}"
fi

# Mileage Records
# --------------
print_header "Mileage Records Testing"

# Get mileage records as admin
echo -e "\n${BLUE}Getting all mileage records as admin${NC}"
TOKEN=$ADMIN_TOKEN
api_request "GET" "/mileage_records" ""

# Get mileage records as customer
echo -e "\n${BLUE}Getting mileage records as customer${NC}"
TOKEN=$CUSTOMER_TOKEN
api_request "GET" "/customer_portal/mileage_records" ""

# Create a new mileage record
if [ -n "$CAR_ID" ]; then
  echo -e "\n${BLUE}Creating a new mileage record for car ID $CAR_ID${NC}"
  new_mileage_data="{\"mileage_record\":{\"car_id\":$CAR_ID,\"mileage\":56000,\"notes\":\"Added from API test script\"}}"
  api_request "POST" "/customer_portal/mileage_records" "$new_mileage_data"
else
  echo -e "${RED}Couldn't retrieve car ID for mileage record creation${NC}"
fi

echo -e "\n${GREEN}API Testing Completed${NC}\n" 
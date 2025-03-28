#!/bin/bash

# Test script for Service Prediction API endpoints

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Car Service Management System - API Testing ===${NC}"
echo

# 1. Login as superadmin to get token
echo -e "${BLUE}1. Login as superadmin${NC}"
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "superadmin@example.com", "password": "password123"}')

ADMIN_TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | sed 's/"token":"//')

if [ -z "$ADMIN_TOKEN" ]
then
  echo -e "${RED}Failed to get admin token${NC}"
  echo $LOGIN_RESPONSE
  exit 1
else
  echo -e "${GREEN}Successfully logged in as superadmin${NC}"
  echo $ADMIN_TOKEN | head -c 20
  echo "..."
  echo
fi

# 2. Get cars due for service
echo -e "${BLUE}2. Getting cars due for service${NC}"
CARS_DUE_RESPONSE=$(curl -s -X GET http://localhost:3000/api/v1/service_predictions/due_soon \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN")

echo $CARS_DUE_RESPONSE | python3 -m json.tool
echo

# 3. Get predictions for a specific car (car id 2)
echo -e "${BLUE}3. Getting predictions for car id 2${NC}"
CAR_PREDICTIONS_RESPONSE=$(curl -s -X GET http://localhost:3000/api/v1/service_predictions/cars/2 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN")

echo $CAR_PREDICTIONS_RESPONSE | python3 -m json.tool
echo

# 4. Login as customer to get token
echo -e "${BLUE}4. Login as customer${NC}"
CUSTOMER_LOGIN_RESPONSE=$(curl -s -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "customer1@example.com", "password": "password123"}')

CUSTOMER_TOKEN=$(echo $CUSTOMER_LOGIN_RESPONSE | grep -o '"token":"[^"]*' | sed 's/"token":"//')

if [ -z "$CUSTOMER_TOKEN" ]
then
  echo -e "${RED}Failed to get customer token${NC}"
  echo $CUSTOMER_LOGIN_RESPONSE
  exit 1
else
  echo -e "${GREEN}Successfully logged in as customer${NC}"
  echo $CUSTOMER_TOKEN | head -c 20
  echo "..."
  echo
fi

# 5. Get customer's car predictions
echo -e "${BLUE}5. Getting customer's car predictions${NC}"
CUSTOMER_CAR_RESPONSE=$(curl -s -X GET http://localhost:3000/api/v1/customer_portal/service_predictions/cars/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CUSTOMER_TOKEN")

echo $CUSTOMER_CAR_RESPONSE | python3 -m json.tool
echo

echo -e "${GREEN}API testing completed${NC}" 
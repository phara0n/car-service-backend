require 'test_helper'

module Api
  module V1
    class DashboardControllerTest < ActionDispatch::IntegrationTest
      setup do
        @admin = users(:admin)
        @token = generate_token(@admin)
        
        # Create some test data
        @customer = customers(:one)
        @car = cars(:one)
        @appointment = appointments(:one)
        @service = services(:one)
        
        # Create some mileage records
        (1..7).each do |i|
          MileageRecord.create!(
            car: @car,
            mileage: rand(10000..50000),
            recorded_at: i.months.ago
          )
        end
        
        # Create some appointments for the current week
        (Date.today.beginning_of_week..Date.today.end_of_week).each do |date|
          Appointment.create!(
            customer: @customer,
            car: @car,
            date: date,
            time: Time.current,
            status: 'confirmed'
          )
        end
      end

      test "should get stats" do
        get api_v1_dashboard_stats_url, headers: { 'Authorization': "Bearer #{@token}" }
        assert_response :success
        
        json_response = JSON.parse(response.body)
        assert_includes json_response.keys, 'totalCars'
        assert_includes json_response.keys, 'totalCustomers'
        assert_includes json_response.keys, 'totalAppointments'
        assert_includes json_response.keys, 'totalServices'
        assert_includes json_response.keys, 'carsDueForService'
        assert_includes json_response.keys, 'upcomingAppointments'
        assert_includes json_response.keys, 'monthlyGrowth'
      end

      test "should get mileage trends" do
        get api_v1_dashboard_mileage_trends_url, headers: { 'Authorization': "Bearer #{@token}" }
        assert_response :success
        
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
        assert_equal 7, json_response.length
        assert_includes json_response.first.keys, 'name'
        assert_includes json_response.first.keys, 'average'
      end

      test "should get service distribution" do
        get api_v1_dashboard_service_distribution_url, headers: { 'Authorization': "Bearer #{@token}" }
        assert_response :success
        
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
        json_response.each do |item|
          assert_includes item.keys, 'name'
          assert_includes item.keys, 'value'
        end
      end

      test "should get appointment distribution" do
        get api_v1_dashboard_appointment_distribution_url, headers: { 'Authorization': "Bearer #{@token}" }
        assert_response :success
        
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
        assert_equal 7, json_response.length
        json_response.each do |item|
          assert_includes item.keys, 'name'
          assert_includes item.keys, 'value'
        end
      end

      test "should get recent activity" do
        get api_v1_dashboard_recent_activity_url, headers: { 'Authorization': "Bearer #{@token}" }
        assert_response :success
        
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
        assert_operator json_response.length, :<=, 10
        json_response.each do |item|
          assert_includes item.keys, 'id'
          assert_includes item.keys, 'type'
          assert_includes item.keys, 'description'
          assert_includes item.keys, 'timestamp'
          assert_includes item.keys, 'details'
        end
      end

      test "should get upcoming appointments" do
        get api_v1_dashboard_upcoming_appointments_url, headers: { 'Authorization': "Bearer #{@token}" }
        assert_response :success
        
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
        assert_operator json_response.length, :<=, 5
        json_response.each do |item|
          assert_includes item.keys, 'id'
          assert_includes item.keys, 'customerName'
          assert_includes item.keys, 'carDetails'
          assert_includes item.keys, 'date'
          assert_includes item.keys, 'time'
          assert_includes item.keys, 'services'
          assert_includes item.keys, 'status'
        end
      end
    end
  end
end 
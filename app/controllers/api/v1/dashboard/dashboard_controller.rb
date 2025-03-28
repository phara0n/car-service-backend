module Api
  module V1
    module Dashboard
      class DashboardController < Api::V1::BaseController
        before_action :authenticate_request
        before_action :require_admin

        def stats
          begin
            total_cars = Car.count
            total_customers = Customer.count
            total_appointments = Appointment.count
            total_services = Service.count

            render json: {
              totalCars: total_cars,
              totalCustomers: total_customers,
              totalAppointments: total_appointments,
              totalServices: total_services,
              carsDueForService: Car.due_for_service.count,
              upcomingAppointments: Appointment.upcoming.count,
              monthlyGrowth: {
                cars: calculate_growth(Car),
                customers: calculate_growth(Customer)
              }
            }, status: :ok
          rescue => e
            Rails.logger.error("Stats Error: #{e.message}\n#{e.backtrace.join("\n")}")
            render json: { error: 'Error fetching statistics' }, status: :internal_server_error
          end
        end

        def mileage_trends
          begin
            trends = MileageRecord.group_by_month(:recorded_at, last: 7, format: "%B")
                                .average(:mileage)
                                .map { |month, avg| { name: month, average: avg.to_i } }
            render json: { trends: trends }, status: :ok
          rescue => e
            Rails.logger.error("Mileage Trends Error: #{e.message}\n#{e.backtrace.join("\n")}")
            render json: { error: 'Error fetching mileage trends' }, status: :internal_server_error
          end
        end

        def service_distribution
          begin
            distribution = Service.joins(:appointments)
                                .where('appointments.created_at >= ?', 30.days.ago)
                                .group('services.name')
                                .count
                                .map { |name, value| { name: name, value: value } }
            render json: { distribution: distribution }, status: :ok
          rescue => e
            Rails.logger.error("Service Distribution Error: #{e.message}\n#{e.backtrace.join("\n")}")
            render json: { error: 'Error fetching service distribution' }, status: :internal_server_error
          end
        end

        def appointment_distribution
          begin
            start_date = Date.today.beginning_of_week
            end_date = Date.today.end_of_week
            
            distribution = Appointment.where(date: start_date..end_date)
                                    .group_by_day(:date, format: "%A")
                                    .count
                                    .map { |day, count| { name: day, value: count } }
            render json: { distribution: distribution }, status: :ok
          rescue => e
            Rails.logger.error("Appointment Distribution Error: #{e.message}\n#{e.backtrace.join("\n")}")
            render json: { error: 'Error fetching appointment distribution' }, status: :internal_server_error
          end
        end

        def recent_activity
          begin
            activities = []

            # Recent appointments
            Appointment.includes(:customer, :car)
                      .order(created_at: :desc)
                      .limit(5)
                      .each do |appointment|
              activities << {
                id: "appointment-#{appointment.id}",
                type: 'appointment',
                description: "New appointment scheduled",
                timestamp: appointment.created_at.iso8601,
                details: {
                  customer: appointment.customer&.name || 'Unknown',
                  car: appointment.car ? "#{appointment.car.make} #{appointment.car.model}" : 'Unknown',
                  date: appointment.date.iso8601
                }
              }
            end

            # Recent mileage updates
            MileageRecord.includes(:car)
                        .order(recorded_at: :desc)
                        .limit(5)
                        .each do |record|
              activities << {
                id: "mileage-#{record.id}",
                type: 'mileage',
                description: "Mileage updated",
                timestamp: record.recorded_at.iso8601,
                details: {
                  car: record.car ? "#{record.car.make} #{record.car.model}" : 'Unknown',
                  mileage: record.mileage
                }
              }
            end

            # Recent customer registrations
            Customer.order(created_at: :desc)
                   .limit(5)
                   .each do |customer|
              activities << {
                id: "customer-#{customer.id}",
                type: 'customer',
                description: "New customer registered",
                timestamp: customer.created_at.iso8601,
                details: {
                  name: customer.name || 'Unknown',
                  email: customer.email || 'No email'
                }
              }
            end

            # Sort by timestamp and take the most recent 10
            sorted_activities = activities.sort_by { |a| Time.parse(a[:timestamp]) }.reverse.first(10)
            render json: { activities: sorted_activities }, status: :ok
          rescue => e
            Rails.logger.error("Recent Activity Error: #{e.message}\n#{e.backtrace.join("\n")}")
            render json: { error: 'Error fetching recent activities' }, status: :internal_server_error
          end
        end

        def upcoming_appointments
          begin
            appointments = Appointment.includes(:customer, :car, :services)
                                    .where(date: Date.today..7.days.from_now)
                                    .order(date: :asc)
                                    .limit(5)
                                    .map do |appointment|
              {
                id: appointment.id,
                customerName: appointment.customer&.name || 'Unknown',
                carDetails: appointment.car ? "#{appointment.car.make} #{appointment.car.model}" : 'Unknown',
                date: appointment.date.iso8601,
                time: appointment.time&.strftime("%H:%M"),
                services: appointment.services.pluck(:name),
                status: appointment.status
              }
            end

            render json: { appointments: appointments }, status: :ok
          rescue => e
            Rails.logger.error("Upcoming Appointments Error: #{e.message}\n#{e.backtrace.join("\n")}")
            render json: { error: 'Error fetching upcoming appointments' }, status: :internal_server_error
          end
        end

        private

        def calculate_growth(model)
          current_month = model.where('created_at >= ?', Time.current.beginning_of_month).count
          last_month = model.where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month).count
          
          if last_month.zero?
            current_month.positive? ? 100 : 0
          else
            ((current_month - last_month).to_f / last_month * 100).round(2)
          end
        rescue => e
          Rails.logger.error("Growth Calculation Error: #{e.message}")
          0
        end

        def require_admin
          unless current_user&.admin? || current_user&.superadmin?
            render json: { error: 'Unauthorized' }, status: :unauthorized
          end
        end
      end
    end
  end
end 
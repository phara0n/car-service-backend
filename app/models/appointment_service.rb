class AppointmentService < ApplicationRecord
  belongs_to :appointment
  belongs_to :service

  validates :appointment_id, presence: true
  validates :service_id, presence: true
  validates :service_id, uniqueness: { scope: :appointment_id, message: "has already been added to this appointment" }
end

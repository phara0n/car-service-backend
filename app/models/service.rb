class Service < ApplicationRecord
  has_many :appointment_services, dependent: :destroy
  has_many :appointments, through: :appointment_services
  
  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :duration, presence: true, numericality: { greater_than: 0 }
  
  scope :active, -> { where(active: true) }
  scope :standard, -> { where.not(name: ['Visite Technique', 'Renouvellement de Vignette', 'Renouvellement d\'Assurance']) }
  scope :tunisian_specific, -> { where(name: ['Visite Technique', 'Renouvellement de Vignette', 'Renouvellement d\'Assurance']) }
  scope :by_price_asc, -> { order(price: :asc) }
  scope :by_price_desc, -> { order(price: :desc) }
  scope :by_duration_asc, -> { order(duration: :asc) }
  scope :by_duration_desc, -> { order(duration: :desc) }
  
  def formatted_price
    sprintf("%.2f", price)
  end
  
  def formatted_duration
    hours = duration / 60
    minutes = duration % 60
    
    if hours > 0
      "#{hours}h#{minutes > 0 ? " #{minutes}m" : ""}"
    else
      "#{minutes}m"
    end
  end
end

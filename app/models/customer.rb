class Customer < ApplicationRecord
  belongs_to :user
  accepts_nested_attributes_for :user
  
  has_many :cars, dependent: :destroy
  has_many :appointments, dependent: :destroy
  
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  
  # Tunisian specific validations
  validates :national_id, format: { with: /\A\d{8}\z/, message: "must be 8 digits" }, 
            allow_blank: true
  validates :tax_number, format: { with: /\A\d{1,20}\z/, message: "must be numeric" },
            allow_blank: true
  
  after_create :set_customer_role
  
  private
  
  def set_customer_role
    user.update(role: 'customer') if user && user.role.blank?
  end
end

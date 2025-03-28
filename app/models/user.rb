class User < ApplicationRecord
  has_secure_password
  
  has_one :customer, dependent: :destroy
  accepts_nested_attributes_for :customer
  
  ROLES = %w[superadmin admin customer].freeze
  
  validates :email, presence: true, uniqueness: { case_sensitive: false }, 
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: ROLES }
  validates :name, presence: true
  
  # Prevent deletion of superadmin
  before_destroy :prevent_superadmin_deletion
  # Prevent role change of superadmin
  before_update :prevent_superadmin_role_change
  
  scope :admins, -> { where(role: ['admin', 'superadmin']) }
  scope :customers, -> { where(role: 'customer') }
  
  def superadmin?
    is_superadmin == true
  end
  
  def admin?
    role == 'admin'
  end
  
  def customer?
    role == 'customer'
  end
  
  private
  
  def prevent_superadmin_deletion
    if superadmin?
      errors.add(:base, "Superadmin user cannot be deleted")
      throw :abort
    end
  end
  
  def prevent_superadmin_role_change
    if superadmin? && role_changed?
      errors.add(:role, "cannot be changed for superadmin")
      throw :abort
    end
  end
end

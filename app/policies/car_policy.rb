class CarPolicy < ApplicationPolicy
  def index?
    true # All authenticated users can see the index
  end
  
  def show?
    user.superadmin? || user.admin? || user.id == record.customer.user_id
  end
  
  def create?
    user.superadmin? || user.admin?
  end
  
  def update?
    user.superadmin? || user.admin?
  end
  
  def destroy?
    user.superadmin? || user.admin?
  end
  
  def update_mileage?
    user.superadmin? || user.admin? || user.id == record.customer.user_id
  end
  
  class Scope < Scope
    def resolve
      if user.superadmin? || user.admin?
        scope.all
      else
        # For customer, only their cars
        scope.joins(:customer).where(customers: { user_id: user.id })
      end
    end
  end
end 
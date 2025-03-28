class CustomerPolicy < ApplicationPolicy
  def index?
    user.superadmin? || user.admin?
  end
  
  def show?
    user.superadmin? || user.admin? || record.user_id == user.id
  end
  
  def create?
    user.superadmin? || user.admin?
  end
  
  def update?
    user.superadmin? || user.admin? || record.user_id == user.id
  end
  
  def destroy?
    user.superadmin? || user.admin?
  end
  
  class Scope < Scope
    def resolve
      if user.superadmin? || user.admin?
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end
end 
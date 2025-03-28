class UserPolicy < ApplicationPolicy
  def index?
    user.superadmin? || user.admin?
  end
  
  def show?
    user.superadmin? || user.admin? || user.id == record.id
  end
  
  def create?
    user.superadmin?
  end
  
  def update?
    return false if record.superadmin? && !user.superadmin?
    user.superadmin? || (user.admin? && record.customer?)
  end
  
  def destroy?
    return false if record.superadmin?
    user.superadmin?
  end
  
  class Scope < Scope
    def resolve
      if user.superadmin?
        scope.all
      elsif user.admin?
        scope.where.not(is_superadmin: true)
      else
        scope.where(id: user.id)
      end
    end
  end
end 
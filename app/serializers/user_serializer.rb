class UserSerializer < ApplicationSerializer
  attributes :email, :name, :role, :is_superadmin
end 
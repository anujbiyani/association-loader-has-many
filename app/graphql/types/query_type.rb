module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :users, Types::UserType.connection_type, null: false
    def users
      User.all
    end

    field :user, Types::UserType, null: false
    def user
      User.first
    end
  end
end

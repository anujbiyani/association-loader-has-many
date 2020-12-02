module Types
  class PostType < Types::BaseObject
    field :id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :user, Types::UserType, null: true
    def user
      AssociationLoader.for(Post, :user).load(object)
    end
  end
end

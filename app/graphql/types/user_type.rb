module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :posts, Types::PostType.connection_type, null: true
    def posts
      # object.posts
      AssociationLoader.for(User, :posts).load(object)
    end
  end
end

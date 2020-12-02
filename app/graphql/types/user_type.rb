module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :posts_with_batch_loading, Types::PostType.connection_type, null: true
    def posts_with_batch_loading
      AssociationLoader.for(User, :posts).load(object)
    end

    field :posts_without_batch_loading, Types::PostType.connection_type, null: true
    def posts_without_batch_loading
      object.posts
    end
  end
end

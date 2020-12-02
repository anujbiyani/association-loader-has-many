require 'graphql/batch'

class Schema < GraphQL::Schema
  query Types::QueryType

  use GraphQL::Batch
end

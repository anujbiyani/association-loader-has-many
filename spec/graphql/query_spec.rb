require 'rails_helper'

RSpec.describe 'Query tests' do
  def execute_query(query)
    Schema.execute(
      query,
      variables: {},
      context: {},
    ).to_h.with_indifferent_access
  end

  # This scenario shouldn't really work because you can't load a bunch of posts for a bunch of users
  # AND paginate those posts. The SQL query just doesn't make sense.
  it 'users and posts' do
    user_one = FactoryBot.create(:user)
    user_two = FactoryBot.create(:user)
    FactoryBot.create_list(:post, 3, user: user_one)
    FactoryBot.create_list(:post, 3, user: user_two)

    query = <<~GRAPHQL
      query {
        users {
          nodes {
            posts(first: 2) {
              nodes { id }
            }
          }
        }
      }
    GRAPHQL

    execute_query(query)
  end

  # This scenario should be able to paginate the posts for one user, but it results in two queries:
  # one that is unpaginated and fetches all posts for a user,
  # and another that is paginated and fetches all posts for a user
  it 'user and posts' do
    user_one = FactoryBot.create(:user)
    FactoryBot.create_list(:post, 3, user: user_one)

    query = <<~GRAPHQL
      query {
        user {
          posts(first: 2) {
            nodes { id }
          }
        }
      }
    GRAPHQL

    execute_query(query)
  end
end

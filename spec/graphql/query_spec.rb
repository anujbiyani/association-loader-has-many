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

    p execute_query(query)
  end

  # This scenario paginates the posts for one user, but it does result in an extra query:
  # one that is unpaginated and fetches all posts for a user,
  # and another that is paginated and fetches all posts for a user
  it 'user and posts, with batch loading' do
    user_one = FactoryBot.create(:user)
    FactoryBot.create_list(:post, 3, user: user_one)

    query = <<~GRAPHQL
      query {
        user {
          postsWithBatchLoading(first: 2) {
            nodes { id }
          }
        }
      }
    GRAPHQL

    p execute_query(query)

    # generated SQL:
    #   User Load (0.1ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" ASC LIMIT ?  [["LIMIT", 1]]
    #   Post Load (0.1ms)  SELECT "posts".* FROM "posts" WHERE "posts"."user_id" = ?  [["user_id", 1]]
    #   Post Load (0.1ms)  SELECT "posts".* FROM "posts" WHERE "posts"."user_id" = ? LIMIT ?  [["user_id", 1], ["LIMIT", 2]]
  end

  it 'user and posts, without batch loading' do
    user_one = FactoryBot.create(:user)
    FactoryBot.create_list(:post, 3, user: user_one)

    query = <<~GRAPHQL
      query {
        user {
          postsWithoutBatchLoading(first: 2) {
            nodes { id }
          }
        }
      }
    GRAPHQL

    p execute_query(query)

    # generated SQL:
    #   User Load (0.1ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" ASC LIMIT ?  [["LIMIT", 1]]
    #   Post Load (0.1ms)  SELECT "posts".* FROM "posts" WHERE "posts"."user_id" = ? LIMIT ?  [["user_id", 1], ["LIMIT", 2]]
  end
end

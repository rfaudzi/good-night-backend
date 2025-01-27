require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  path '/api/v1/users/following/sleep_records' do
    get 'Get a list of sleep records of following users' do
      tags 'Users'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer <token>'
      parameter name: :limit, in: :query, type: :integer, required: false, description: 'Limit'
      parameter name: :offset, in: :query, type: :integer, required: false, description: 'Offset'
      parameter name: :start_date, in: :query, type: :date_time, required: false, description: 'Start date'
      parameter name: :start_date_condition, in: :query, type: :string, required: false, schema: { 
        type: :string, enum: ["less_than", "greater_than", "equal", "not_equal"],
        default: "greater_than"
      }, description: 'Start date condition'
      parameter name: :order_by, in: :query, type: :string, required: false, schema: { 
        type: :string, enum: ["start_time", "duration"],
        default: "start_time"
      }, description: 'Order by'
      parameter name: :order, in: :query, type: :string, required: false, schema: { 
        type: :string, enum: ["desc", "asc"],
        default: "desc"
      }, description: 'Order'
    
      response '200', 'Listed' do
        let(:user) { create(:user) }
        let(:other_user) { create(:user) }
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
        let(:limit) { 10 }
        let(:offset) { 0 }
        let(:start_date) { Time.current.strftime("%Y-%m-%d") }
        let(:start_date_condition) { "less_than" }
        let(:order_by) { "duration" }
        let(:order) { "desc" }
        let(:sleep_records) { create_list(:sleep_record, 10, start_time: Time.current - 1.day, user: other_user) }
        let(:following) { create(:follow, follower_id: user.id, following_id: other_user.id) }

        before do
          following
          sleep_records
          allow(JsonWebToken).to receive(:decode).and_return({ user_id: user.id, exp: Time.current.to_i + 1000 })
          allow(REDIS).to receive(:get).and_return(nil)
          allow(REDIS).to receive(:set).and_return(true)
        end
  
        examples 'application/json' => {
          data: [
            {
              id: 1,
              type: "sleep_record",
              attributes: {
                id: 1,
                user_id: 1,
                start_time: (Time.current - 1.day).iso8601,
                end_time: nil,
                duration: 0,
                created_at: Time.current.iso8601,
                updated_at: Time.current.iso8601
              }
            }
            
          ], meta: {
            http_status: 200,
            message: I18n.t('sleep_record.listed_successfully'),
            limit: 10,
            offset: 0,
            total_count: 10
          }
        }
  
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data'].count).to eq(10)
          expect(data['meta']['total_count']).to eq(10)
          expect(data['meta']['limit']).to eq(10)
          expect(data['meta']['offset']).to eq(0)
        end
      end

      response '400', 'Bad request' do
        let(:user) { create(:user) }
        let(:other_user) { create(:user) }
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
        let(:limit) { 10 }
        let(:offset) { 0 }
        let(:start_date) { (Time.current).iso8601 }
        let(:start_date_condition) { "invalid" }
        let(:order_by) { "duration" }
        let(:order) { "desc" }
        let(:sleep_records) { create_list(:sleep_record, 10, start_time: Time.current - 1.day, user: other_user) }
        let(:following) { create(:follow, follower_id: user.id, following_id: other_user.id) }

        before do
          following
          sleep_records
          allow(JsonWebToken).to receive(:decode).and_return({ user_id: user.id, exp: Time.current.to_i + 1000 })
        end
  
        examples 'application/json' => {
          errors: [
            {
              title: I18n.t('errors.bad_request.title'),
              detail: I18n.t('errors.bad_request.message'),
              code: "100",
              status: "400"
            }
          ]
        }
  
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors'][0]['title']).to include(I18n.t('errors.bad_request.title'))
        end
      end
  
      response '401', 'Unauthorized' do
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
  
        examples 'application/json' => {
          errors: [
            {
              title: I18n.t('errors.unauthorized.title'),
              detail: I18n.t('errors.unauthorized.message'),
              code: "100",
              status: "401"
            }
          ]
        }
  
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors'][0]['title']).to include(I18n.t('errors.unauthorized.title'))
        end
      end
  
      response '403', 'Forbidden' do
        let(:user) { create(:user) }
        let(:other_user) { create(:user) }
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
  
        before do
          allow(JsonWebToken).to receive(:decode).and_return({ user_id: user.id, exp: Time.current.to_i + 1000 })
          allow_any_instance_of(Api::V1::UsersController).to receive(:authorize_policy).and_raise(Pundit::NotAuthorizedError.new)
        end
  
        examples 'application/json' => {
          errors: [
            {
              title: I18n.t('errors.forbidden.title'),
              detail: I18n.t('errors.forbidden.message'),
              code: "100",
              status: "403"
            }
          ]
        }
  
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors'][0]['title']).to include(I18n.t('errors.forbidden.title'))
        end
      end
    end
  end
end
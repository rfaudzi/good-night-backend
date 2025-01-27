require 'swagger_helper'

RSpec.describe 'Sleep Records API', type: :request do
  path '/api/v1/sleep_records' do
    post 'Create a sleep record' do
      tags 'Sleep Records'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer <token>'


      parameter name: :sleep_record, in: :body, schema: {
        type: :object,
        properties: {
          start_time: { type: :string, format: :date_time },
        },
        required: ['start_time'],
        example: {
          start_time: '2025-01-01T12:00:00Z'
        }
      }

      response '201', 'Created' do
        let(:user) { create(:user) }
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
        let(:sleep_record) { { start_time: '2025-01-01T12:00:00Z' } }

        before do
          allow(JsonWebToken).to receive(:decode).and_return({ user_id: user.id, exp: Time.current.to_i + 1000 })
          allow(REDIS).to receive(:set).and_return(true)
          allow(REDIS).to receive(:get).and_return(nil)
        end

        examples 'application/json' => {
          data: {
            id: 1,
            type: "sleep_record",
            attributes: {
              id: 1,
              user_id: 1,
              start_time: Time.current.iso8601,
              end_time: nil,
              duration: 0,
              created_at: Time.current.iso8601,
              updated_at: Time.current.iso8601
            }
          },
          meta: {
            http_status: 201,
            message: I18n.t('sleep_record.created_successfully')
          }
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['attributes']['user_id']).to eq(user.id)
        end
      end

      response '422', 'Unprocessable entity' do
        let(:user) { create(:user) }
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
        let(:sleep_record) { { start_time: '2025-01-01T12:00:00Z' } }

        before do
          allow(JsonWebToken).to receive(:decode).and_return({ user_id: user.id, exp: Time.current.to_i + 1000 })
          allow(SleepRecordService).to receive(:create).and_raise(GoodNightBackendError::UnprocessableEntityError.new)
        end
        
        examples 'application/json' => {
          errors: [
            {
              title: I18n.t('errors.unprocessable_entity.title'),
              detail: I18n.t('errors.unprocessable_entity.message'),
              code: "100",
              status: "422"
            }
          ]
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors'][0]['detail']).to include(I18n.t('errors.unprocessable_entity.message'))
        end
      end

      response '401', 'Unauthorized' do
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
        let(:sleep_record) { { start_time: '2025-01-01T12:00:00Z' } }

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
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
        let(:sleep_record) { { start_time: '2025-01-01T12:00:00Z' } }

        before do
          allow(JsonWebToken).to receive(:decode).and_return({ user_id: user.id, exp: Time.current.to_i + 1000 })
          allow_any_instance_of(Api::V1::SleepRecordsController).to receive(:authorize_policy).and_raise(Pundit::NotAuthorizedError.new)
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

  path '/api/v1/sleep_records/{id}' do
    patch 'Update a sleep record' do
      tags 'Sleep Records'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer <token>'
      parameter name: :id, in: :path, type: :integer, required: true, description: 'Sleep record ID'
      parameter name: :sleep_record, in: :body, schema: {
        type: :object,
        properties: {
          end_time: { type: :string, format: :date_time },
        },
        required: ['end_time'],
        example: {
          end_time: '2025-01-01T12:00:00Z'
        }
      }

      response '200', 'Updated' do
        let(:user) { create(:user) }
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
        let(:sleep_record_data) { create(:sleep_record, user: user, start_time: Time.current, end_time: nil, duration: 0) }
        let(:sleep_record) { { end_time: (Time.current + 1.hour).iso8601 } }
        let(:id) { sleep_record_data.id }

        before do
          allow(JsonWebToken).to receive(:decode).and_return({ user_id: user.id, exp: Time.current.to_i + 1000 })
        end

        examples 'application/json' => {
          data: {
            id: 1,
            type: "sleep_record",
            attributes: {
              id: 1,
              user_id: 1,
              start_time: Time.current.iso8601,
              end_time: (Time.current + 1.hour).iso8601,
              duration: 60,
              created_at: Time.current.iso8601,
              updated_at: Time.current.iso8601
            }
          },
          meta: {
            http_status: 200,
              message: I18n.t('sleep_record.updated_successfully')
          }
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['attributes']['end_time']).to be_present
          expect(data['data']['attributes']['duration']).to be_present
        end
      end

      response '422', 'Unprocessable entity' do
        let(:user) { create(:user) }
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
        let(:sleep_record_data) { create(:sleep_record, user: user, start_time: Time.current, end_time: nil, duration: 0) }
        let(:sleep_record) { { id: sleep_record_data.id, end_time: (Time.current + 1.hour).iso8601 } }
        let(:id) { sleep_record_data.id }

        before do
          allow(JsonWebToken).to receive(:decode).and_return({ user_id: user.id, exp: Time.current.to_i + 1000 })
          allow(SleepRecordService).to receive(:update).and_raise(GoodNightBackendError::UnprocessableEntityError.new)
        end
        
        examples 'application/json' => {
          errors: [
            {
              title: I18n.t('errors.unprocessable_entity.title'),
              detail: I18n.t('errors.unprocessable_entity.message'),
              code: "100",
              status: "422"
            }
          ]
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors'][0]['detail']).to include(I18n.t('errors.unprocessable_entity.message'))
        end
      end

      response '404', 'Not found' do
        let(:user) { create(:user) }
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
        let(:sleep_record) { { id: 999, end_time: (Time.current + 1.hour).iso8601 } }
        let(:id) { 999 }

        before do
          allow(JsonWebToken).to receive(:decode).and_return({ user_id: user.id, exp: Time.current.to_i + 1000 })
          allow(SleepRecordService).to receive(:update).and_raise(GoodNightBackendError::NotFoundError.new)
        end

        examples 'application/json' => {
          errors: [
            {
              title: I18n.t('errors.not_found.title'),
              detail: I18n.t('errors.not_found.message'),
              code: "100",
              status: "404"
            }
          ]
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors'][0]['title']).to include(I18n.t('errors.not_found.title'))
        end
      end

      response '401', 'Unauthorized' do
        let(:user) { create(:user) }
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
        let(:sleep_record_data) { create(:sleep_record, user: user, start_time: Time.current, end_time: nil, duration: 0) }
        let(:sleep_record) { { id: sleep_record_data.id, end_time: (Time.current + 1.hour).iso8601 } }
        let(:id) { sleep_record_data.id }

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
        let(:sleep_record_data) { create(:sleep_record, user: other_user, start_time: Time.current, end_time: nil, duration: 0) }
        let(:sleep_record) { { id: sleep_record_data.id, end_time: (Time.current + 1.hour).iso8601 } }
        let(:id) { sleep_record_data.id }
        before do
          allow(JsonWebToken).to receive(:decode).and_return({ user_id: user.id, exp: Time.current.to_i + 1000 })
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

  path '/api/v1/sleep_records' do
    get 'List sleep records' do
      tags 'Sleep Records'
      consumes 'application/json'
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
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
        let(:limit) { 10 }
        let(:offset) { 0 }
        let(:start_date) { Time.current.strftime("%Y-%m-%d") }
        let(:start_date_condition) { "less_than" }
        let(:order_by) { "duration" }
        let(:order) { "desc" }
        let(:sleep_records) { create_list(:sleep_record, 10, start_time: Time.current - 1.day, user: user) }

        before do
          sleep_records
          allow(JsonWebToken).to receive(:decode).and_return({ user_id: user.id, exp: Time.current.to_i + 1000 })
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
          ],
          meta: {
            http_status: 200,
            message: I18n.t('sleep_record.listed_successfully'),
            limit: 10,
            offset: 0,
            total_count: 1
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
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
        let(:limit) { 10 }
        let(:offset) { 0 }
        let(:start_date) { (Time.current).iso8601 }
        let(:start_date_condition) { "xxx" }
        let(:order_by) { "duration" }
        let(:order) { "desc" }
        let(:sleep_records) { create_list(:sleep_record, 10, start_time: Time.current - 1.day, user: user) }

        before do
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
        let(:list_sleep_records) { { user_ids: [user.id] } }

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
        let(:list_sleep_records) { { user_ids: [other_user.id] } }

        before do
          allow(JsonWebToken).to receive(:decode).and_return({ user_id: user.id, exp: Time.current.to_i + 1000 })
          allow_any_instance_of(Api::V1::SleepRecordsController).to receive(:authorize_policy).and_raise(Pundit::NotAuthorizedError.new)
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

      response '500', 'Internal server error' do
        let(:user) { create(:user) }
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
        let(:list_sleep_records) { { user_ids: [user.id] } }

        before do
          allow(JsonWebToken).to receive(:decode).and_return({ user_id: user.id, exp: Time.current.to_i + 1000 })
          allow(SleepRecordService).to receive(:list).and_raise(GoodNightBackendError::InternalServerError.new)
        end

        examples 'application/json' => {
          errors: [
            {
              title: I18n.t('errors.internal_server_error.title'),
              detail: I18n.t('errors.internal_server_error.message'),
              code: "100",
              status: "500"
            }
          ]
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors'][0]['title']).to include(I18n.t('errors.internal_server_error.title'))
        end
      end
    end
  end
end 

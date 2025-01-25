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

        before do
          allow(SleepRecordService).to receive(:create).and_raise(GoodNightBackendError::UnprocessableEntityError.new)
        end

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

end 
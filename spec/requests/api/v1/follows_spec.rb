require 'swagger_helper'

RSpec.describe 'Follows API', type: :request do
  path '/api/v1/follows' do
    post 'Create a follow' do
      tags 'Follows'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer <token>'
      parameter name: :follow, in: :body, schema: {
        type: :object,
        properties: {
          following_id: { type: :string, required: true }
        },
        example: {
          following_id: '2'
        },
        required: ['following_id']
      }

      response '201', 'Created' do
        let(:user) { create(:user) }
        let(:other_user) { create(:user) }
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
        let(:follow) { { following_id: other_user.id } }

        before do
          allow(JsonWebToken).to receive(:decode).and_return({user_id: user.id, exp: Time.current.to_i + 1000})
        end

        examples 'application/json' => {
          data: {
            id: '1',
            type: 'follow',
            attributes: {
              follower_id: '1',
              following_id: '2',
              created_at: '2025-01-01T12:00:00Z',
              updated_at: '2025-01-01T12:00:00Z'
            }
          },
          meta: {
            http_status: 201,
            message: I18n.t('follow.created_successfully')
          }
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['attributes']['following_id']).to eq(follow[:following_id])
          expect(data['data']['attributes']['follower_id']).to eq(user.id)
        end
      end

      response '401', 'Unauthorized' do
        let(:user) { create(:user) }
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
        let(:follow) { { following_id: '623' } }

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
          expect(data['errors'][0]['title']).to eq(I18n.t('errors.unauthorized.title'))
          expect(data['errors'][0]['detail']).to eq(I18n.t('errors.unauthorized.message'))
          expect(data['errors'][0]['status']).to eq(401)
        end
      end

      response '403', 'Forbidden' do
        let(:Authorization) { "Bearer #{token}" }
        let(:follow) { { following_id: '623' } }

        before do
          allow(JsonWebToken).to receive(:decode).and_return({user_id: user.id, exp: Time.current.to_i + 1000})
        end

        examples 'application/json' => {
          errors: [
            {
              title: I18n.t('errors.forbidden.title'),
              detail: I18n.t('errors.forbidden.message'),
              code: 100,
              status: 403
            }
          ]
        }
      end

      response '400', 'Bad request' do
        let(:user) { create(:user) }
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
        let(:follow) { { following_id: '623' } }

        before do
          allow(JsonWebToken).to receive(:decode).and_return({user_id: user.id + 10, exp: Time.current.to_i + 1000})
          allow(FollowService).to receive(:create).and_raise(GoodNightBackendError::BadRequestError.new)
        end

        examples 'application/json' => {
          errors: [
            {
              title: I18n.t('errors.bad_request.title'),
              detail: I18n.t('errors.bad_request.message'),
              code: 100,
              status: 400
            }
          ]
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors'][0]['title']).to eq(I18n.t('errors.bad_request.title'))
          expect(data['errors'][0]['detail']).to eq(I18n.t('errors.bad_request.message'))
          expect(data['errors'][0]['status']).to eq(400)
        end
      end

      response '422', 'Unprocessable entity' do
        let(:user) { create(:user) }
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
        let(:follow) { { following_id: '623' } }

        before do
          allow(JsonWebToken).to receive(:decode).and_return({user_id: user.id, exp: Time.current.to_i + 1000})
        end

        examples 'application/json' => {
          errors: [
            {
              title: I18n.t('errors.unprocessable_entity.title'),
              detail: I18n.t('errors.unprocessable_entity.message'),
              code: 100,
              status: 422
            }
          ]
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors'][0]['title']).to eq(I18n.t('errors.unprocessable_entity.title'))
          expect(data['errors'][0]['detail']).to eq(I18n.t('errors.unprocessable_entity.message'))
          expect(data['errors'][0]['status']).to eq(422)
        end
      end 
    end
  end
end
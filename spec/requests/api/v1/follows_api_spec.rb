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

  path '/api/v1/follows/{following_id}' do
    delete 'Delete a follow' do
      tags 'Follows'
      security [bearer_auth: []]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer <token>'
      parameter name: :following_id, in: :path, type: :string, required: true, description: 'Following ID'
      
      response '204', 'Deleted' do
        let(:user) { create(:user) }  
        let(:other_user) { create(:user) }
        let(:follow_data) { create(:follow, follower_id: user.id, following_id: other_user.id) }
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
        let(:following_id) { other_user.id }

        before do
          follow_data
          allow(JsonWebToken).to receive(:decode).and_return({user_id: user.id, exp: Time.current.to_i + 1000})
        end

        run_test! do |response|
          expect(response.status).to eq(204)
        end
      end

      response '404', 'Not found' do
        let(:user) { create(:user) }
        let(:other_user) { create(:user) }
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" } 
        let(:following_id) { other_user.id}
        
        before do
          allow(JsonWebToken).to receive(:decode).and_return({user_id: user.id, exp: Time.current.to_i + 1000})
        end

        examples 'application/json' => {
          errors: [
            {
              title: I18n.t('errors.not_found.title'),
              detail: I18n.t('errors.not_found.message'),
              code: 100,
              status: 404
            }
          ]
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors'][0]['title']).to eq(I18n.t('errors.not_found.title'))
          expect(data['errors'][0]['detail']).to eq(I18n.t('errors.not_found.message'))
          expect(data['errors'][0]['status']).to eq(404)
        end
      end

      response '401', 'Unauthorized' do
        let(:following_id) { '1' }
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }

        examples 'application/json' => {
          errors: [
            {
              title: I18n.t('errors.unauthorized.title'),
              detail: I18n.t('errors.unauthorized.message'),
              code: 100,
              status: 401
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
        let(:user) { create(:user) }
        let(:other_user) { create(:user) }
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
        let(:following_id) { other_user.id }

        before do
          allow(JsonWebToken).to receive(:decode).and_return({user_id: user.id, exp: Time.current.to_i + 1000})
          allow_any_instance_of(FollowPolicy).to receive(:delete?).and_return(false)
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

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors'][0]['title']).to eq(I18n.t('errors.forbidden.title'))
          expect(data['errors'][0]['detail']).to eq(I18n.t('errors.forbidden.message'))
          expect(data['errors'][0]['status']).to eq(403)
        end
      end
    end
  end
end

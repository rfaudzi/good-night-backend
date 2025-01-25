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
        let(:token) { "1234567890" }
        let(:Authorization) { "Bearer #{token}" }
        
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
            message: 'Sleep record created'
          }
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['user_id']).to eq(user.id)
        end
      end

      response '422', 'Unprocessable entity' do
        let(:user_id) { nil }
        
        examples 'application/json' => {
          errors: [
            {
              title: "Invalid request",
              detail: "User can't be blank",
              code: "100",
              status: "422"
            }
          ]
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to include("User can't be blank")
        end
      end

      response '401', 'Unauthorized' do
        let(:user_id) { 999 }

        examples 'application/json' => {
          errors: [
            {
              title: "Invalid token",
              detail: "The provided Bearer token is invalid or expired.",
              code: "100",
              status: "401"
            }
          ]
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors'][0]['title']).to include("Invalid token")
        end
      end

      response '403', 'Forbidden' do
        let(:user_id) { 999 }

        examples 'application/json' => {
          errors: [
            {
              title: "Forbidden",
              detail: "You do not have permission to access this resource",
              code: "100",
              status: "403"
            }
          ]
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to include("Forbidden")
        end
      end
    end
  end

end 
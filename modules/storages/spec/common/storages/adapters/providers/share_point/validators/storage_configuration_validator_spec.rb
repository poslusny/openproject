# frozen_string_literal: true

require "spec_helper"
require_module_spec_helper

module Storages
  module Adapters
    module Providers
      module SharePoint
        module Validators
          RSpec.describe StorageConfigurationValidator, :webmock do
            let(:storage) { create(:share_point_dev_storage, :as_automatically_managed) }
            let(:error) { Results::Error.new(code: error_code, source: self) }

            subject(:validator) { described_class.new(storage) }

            describe "success", vcr: "share_point/files_query_userless" do
              it "returns a GroupValidationResult" do
                results = validator.call

                expect(results).to be_a(ConnectionValidators::ValidationGroupResult)
                expect(results).to be_success
              end
            end

            describe "failure" do
              let(:files_double) { class_double(Queries::FilesQuery) }
              let(:auth_strategy) { Registry["share_point.authentication.userless"].call }
              let(:input_data) { Input::Files.build(folder: "/").value! }
              let(:result) { Success() }

              before do
                allow(files_double).to receive(:call).with(storage:, auth_strategy:, input_data:).and_return(result)
              end

              context "when the storage isn't configured" do
                let(:storage) { create(:share_point_storage) }

                it "the check fails" do
                  results = validator.call
                  expect(results[:storage_configured]).to be_a_failure
                  expect(results[:storage_configured].code).to eq(:not_configured)
                end
              end

              context "when diagnostic request fails with an unhandled error" do
                let(:error_code) { :error }
                let(:result) { Failure(error) }

                before { Registry.stub("share_point.queries.files", files_double) }

                it "the check fails", pending: "this is not implemented yet" do
                  results = validator.call

                  expect(results[:diagnostic_request]).to be_a_failure
                  expect(results[:diagnostic_request].code).to eq(:unknown_error)
                end

                it "logs an error", pending: "this is not implemented yet" do
                  allow(Rails.logger).to receive(:error)
                  validator.call

                  expect(Rails.logger).to have_received(:error).with(/Connection validation failed with unknown/)
                end
              end

              context "when the tenant id is wrong" do
                it "but looks like an actual valid value", vcr: "share_point/validation_wrong_tenant_id" do
                  storage.tenant_id = "itdoesnotexists9000.sharepoint.com"
                  results = described_class.new(storage).call

                  expect(results[:tenant_id]).to be_a_failure
                  expect(results[:tenant_id].code).to eq(:sp_tenant_id_invalid)
                end

                it "but is blatantly wrong", vcr: "share_point/validation_absurd_tenant_id" do
                  storage.tenant_id = "wrong"
                  results = described_class.new(storage).call

                  expect(results[:tenant_id]).to be_a_failure
                  expect(results[:tenant_id].code).to eq(:sp_tenant_id_invalid)
                end
              end

              context "when the client secret is wrong" do
                it "fails the check", vcr: "share_point/validation_wrong_client_secret" do
                  storage.oauth_client.client_secret = "wrong"
                  results = described_class.new(storage).call

                  expect(results[:client_secret]).to be_a_failure
                  expect(results[:client_secret].code).to eq(:client_secret_invalid)
                end
              end

              context "when the client id is wrong" do
                it "fails the check", vcr: "share_point/validation_wrong_client_id" do
                  storage.oauth_client.client_id = "wrong"
                  results = described_class.new(storage).call

                  expect(results[:client_id]).to be_a_failure
                  expect(results[:client_id].code).to eq(:client_id_invalid)
                end
              end
            end
          end
        end
      end
    end
  end
end

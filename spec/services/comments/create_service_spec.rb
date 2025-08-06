# frozen_string_literal: true

#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

require "spec_helper"
require "services/base_services/behaves_like_create_service"

RSpec.describe Comments::CreateService do
  context "for a News comment" do
    it_behaves_like "BaseServices create service" do
      let(:model_instance) { build_stubbed(:comment, :commented_news) }
    end
  end

  context "for a WorkPackage comment" do
    it_behaves_like "BaseServices create service" do
      let(:model_instance) { build_stubbed(:comment, :commented_work_package) }
    end

    context "when creating associated journals" do
      # Tap as the changes would otherwise mess with the journal creation i.e. the updated_at timestamp
      let!(:work_package) { create(:work_package).tap(&:clear_changes_information) }
      let!(:user) { create(:admin) }
      let!(:service) { described_class.new(user:, contract_class: Comments::CreateContract) }
      let!(:params) { { author: user, comments: "hi from test", commented: work_package } }

      it "creates a journal entry for its container", with_settings: { journal_aggregation_time_minutes: 0 } do
        expect do
          result = service.call(params)
          expect(result).to be_success
        end.to change(Journal, :count).by(1)
      end

      it "includes the commentable journal" do
        service.call(params)
        expect(work_package.journals.last.commentable_journals.length).to be > 0
      end
    end
  end
end

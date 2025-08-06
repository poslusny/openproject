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

RSpec.describe OpenProject::JournalFormatter::Comment do
  subject(:instance) { described_class.new(journal) }

  let(:work_package) { build(:work_package) }
  let(:journal) { instance_double(Journal, journable: work_package) }
  let(:user) { create(:user) }
  let(:comment) { create(:comment, commented: work_package, comments: "Hello", author: user) }
  let(:key) { "comments_#{comment.id}" }

  describe "#render" do
    describe "when rendering raw" do
      context "with nil to value" do
        let(:changes) { [nil, "a commentary by a user"] }
        let(:result) { { comment_id: comment.id, value: "a commentary by a user", old_value: nil }.to_json }

        it "renders the changeset as a json" do
          expect(instance.render(key, changes)).to eq(result)
        end
      end

      context "with value to nil" do
        let(:changes) { ["a commentary by a user", nil] }
        let(:result) { { comment_id: comment.id, value: nil, old_value: "a commentary by a user" }.to_json }

        it "renders the changeset as a json" do
          expect(instance.render(key, changes)).to eq(result)
        end
      end
    end

    describe "when rendering html" do
      context "with nil to value" do
        let(:changes) { [nil, "a commentary by a user"] }
        let(:result) { "<strong>Comment</strong> set to <i>a commentary by a user</i>" }

        it "renders the changeset as html" do
          expect(instance.render(key, changes, html: true)).to eq(result)
        end
      end

      context "with value to nil" do
        let(:changes) { ["a commentary by a user", nil] }
        let(:result) { "<strong>Comment</strong> deleted (<strike><i>a commentary by a user</i></strike>)" }

        it "renders the changeset as html" do
          expect(instance.render(key, changes, html: true)).to eq(result)
        end
      end
    end
  end
end

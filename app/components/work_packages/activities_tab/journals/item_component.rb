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

module WorkPackages
  module ActivitiesTab
    module Journals
      class ItemComponent < ApplicationComponent
        include ApplicationHelper
        include OpPrimer::ComponentHelpers
        include OpTurbo::Streamable
        include WorkPackages::ActivitiesTab::SharedHelpers
        include WorkPackages::ActivitiesTab::StimulusControllers

        def initialize(journal:, filter:, grouped_emoji_reactions:, state: :show)
          super

          @journal = journal
          @filter = filter
          @grouped_emoji_reactions = grouped_emoji_reactions
          @state = state
        end

        private

        attr_reader :journal, :state, :filter, :grouped_emoji_reactions

        def wrapper_uniq_by
          journal.id
        end

        def wrapper_data_attributes
          {
            controller: "work-packages--activities-tab--item",
            "work-packages--activities-tab--item-activity-url-value": activity_url(journal)
          }
        end

        def comment_details
          journal.details.filter_map do |detail|
            if detail.first.start_with?("comment")
              journal.render_detail(detail)
            end
          end
        end

        def comment_for(detail)
          detail = JSON.parse(detail)
          # we probably don't want a query here, so think of a way of preloading these
          comment = Comment.find_by(id: detail["comment_id"])

          if comment.nil?
            I18n.t("activities.work_packages.activity_tab.comment_not_found")
          else
            comment
          end
        end

        def show_comment_container?
          (journal.notes.present? || journal.noop?) && filter != :only_changes
        end

        def updated?
          return false if journal.initial?

          journal.updated_at - journal.created_at > 5.seconds
        end

        def has_unread_notifications?
          journal.has_unread_notifications_for_user?(User.current)
        end

        def notification_on_details?
          has_unread_notifications? && journal.notes.blank?
        end
      end
    end
  end
end

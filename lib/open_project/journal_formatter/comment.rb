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

class OpenProject::JournalFormatter::Comment < JournalFormatter::Base
  def render(key, values, _options)
    id = key.to_s.sub("comments_", "").to_i
    old_value, value, comment = format_details(id, values)

    render_comment_detail_text(value, old_value, comment)
  end

  private

  def format_details(id, values)
    old_value, current_value = values
    [
      old_value,
      current_value,
      find_comment(id)
    ]
  end

  def render_comment_detail_text(value, old_value, comment)
    {
      comment_id: comment.id,
      value: value,
      old_value: old_value
    }.to_json
  end

  def find_comment(id)
    Comment.find_by(id: id)
  end
end

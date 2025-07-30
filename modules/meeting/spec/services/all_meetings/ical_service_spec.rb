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

RSpec.describe AllMeetings::ICalService, type: :model do # rubocop:disable RSpec/SpecFilePathFormat
  let(:user) do
    create(:user,
           firstname: "Bob",
           lastname: "Barker",
           mail: "bob@example.com",
           preferences: { time_zone: "America/New_York" },
           member_with_permissions: { project => [:view_meetings] })
  end
  let(:user2) { create(:user, firstname: "Foo", lastname: "Fooer", mail: "foo@example.com") }
  let(:project) { create(:project, name: "My Project") }

  let(:relevant_time) { Time.current.utc.change(hour: 10, minute: 0, second: 0) }

  let(:service) { described_class.new(user:, include_historic:) }
  let(:result) { service.call.result }
  let(:include_historic) { false }

  let(:ical) { Icalendar::Calendar.parse(result).first }

  describe "#call" do
    it "returns a success" do
      expect(service.call).to be_success
    end

    context "when exception is raised" do
      subject { service.call }

      before do
        allow(Meetings::CalendarWrapper).to receive(:new).and_raise StandardError.new("Oh noes")
      end

      it "returns a failure" do
        expect(subject).to be_failure
        expect(subject.message).to eq("Oh noes")
      end
    end
  end

  context "with only single meetings" do
    let!(:meeting) do
      create(:meeting,
             author: user,
             project:,
             title: "Important meeting",
             participants: [
               MeetingParticipant.new(user:),
               MeetingParticipant.new(user: user2)
             ],
             location: "https://example.com/meet/important-meeting",
             start_time: relevant_time + 1.week,
             duration: 1.0)
    end

    let!(:past_meeting) do
      create(:meeting,
             author: user,
             project:,
             title: "Important meeting",
             participants: [
               MeetingParticipant.new(user:),
               MeetingParticipant.new(user: user2)
             ],
             location: "https://example.com/meet/important-meeting",
             start_time: relevant_time - 1.week,
             duration: 1.0)
    end

    let!(:invisible_meeting) do
      create(:meeting,
             author: user, # creatd by the user but in a project the user cannot see
             project: create(:project, name: "Invisible Project"),
             title: "Important meeting",
             location: "https://example.com/meet/important-meeting",
             start_time: relevant_time + 1.week,
             duration: 1.0)
    end

    context "without historic meetings" do
      let(:include_historic) { false }

      it "renders the ICS file with only the upcoming meeting", :aggregate_failures do
        expect(result).to be_a String

        expect(ical.events.size).to eq(1)

        entry = ical.events.first

        expect(entry.uid).to eq(meeting.uid)
        expect(entry.organizer.to_s).to eq("mailto:#{Setting.mail_from}")
        expect(entry.attendee.map(&:to_s)).to contain_exactly("mailto:foo@example.com", "mailto:bob@example.com")
        expect(entry.dtstart.utc).to eq meeting.start_time
        expect(entry.dtend.utc).to eq meeting.start_time + 1.hour
        expect(entry.summary).to eq "[My Project] Important meeting"
        expect(entry.description).to eq "[My Project] Meeting: Important meeting"
        expect(entry.location).to eq(meeting.location.presence)
        expect(entry.dtstart).to eq (relevant_time + 1.week).in_time_zone("Europe/Berlin")
        expect(entry.dtend).to eq (relevant_time + 1.week + 1.hour).in_time_zone("Europe/Berlin")
      end
    end

    context "with historic meetings" do
      let(:include_historic) { true }

      it "renders the ICS file with both meetings", :aggregate_failures do
        expect(result).to be_a String

        expect(ical.events.size).to eq(2)
        uids = ical.events.map(&:uid)

        expect(uids).to contain_exactly(meeting.uid, past_meeting.uid)
      end
    end
  end

  context "with recurring meetings" do
    let!(:recurring_meeting) do
      create(:recurring_meeting,
             author: user,
             project:,
             time_zone: user.time_zone)
    end

    context "with a recurring meeting that has no derived meetings yet" do
      it "renders the ICS file with the recurring meeting", :aggregate_failures do
        expect(result).to be_a String

        expect(ical.events.size).to eq(1)

        entry = ical.events.first

        expect(entry.uid).to eq(recurring_meeting.uid)
        expect(entry.organizer.to_s).to eq("mailto:#{Setting.mail_from}")
        # expect(entry.attendee.map(&:to_s)).to contain_exactly("mailto:foo@example.com", "mailto:bob@example.com")
        # expect(entry.dtstart.utc).to eq meeting.start_time
        # expect(entry.dtend.utc).to eq meeting.start_time + 1.hour
        # expect(entry.summary).to eq "[My Project] Important meeting"
        # expect(entry.description).to eq "[My Project] Meeting: Important meeting"
        # expect(entry.location).to eq(meeting.location.presence)
        # expect(entry.dtstart).to eq (relevant_time + 1.week).in_time_zone("Europe/Berlin")
        # expect(entry.dtend).to eq (relevant_time + 1.week + 1.hour).in_time_zone("Europe/Berlin")
      end
    end
  end
end

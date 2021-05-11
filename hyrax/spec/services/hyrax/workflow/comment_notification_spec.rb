require 'rails_helper'

# frozen_string_literal: true
RSpec.describe Hyrax::Workflow::CommentNotification do
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:approver) { FactoryBot.create(:user, :admin) }
  let(:depositor) { FactoryBot.create(:user) }
  let(:to_user) { FactoryBot.create(:user) }
  let(:cc_user) { FactoryBot.create(:user) }
  let(:work) { create(:publication, depositor: depositor.username) }
  let(:entity) { create(:sipity_entity, proxy_for_global_id: work.to_global_id.to_s) }
  let(:comment) { double("comment", comment: 'A pleasant read') }
  let(:recipients) { { 'to' => [to_user], 'cc' => [cc_user] } }

  describe ".send_notification" do
    it 'sends a message to all users' do
      expect(approver).to receive(:send_message)
        .with(anything,
              "Test title (<a href=\"/concern/publications/#{work.id}\">#{work.id}</a>) " \
              "has received a comment from #{depositor}.\n 'A pleasant read'",
              anything).exactly(3).times.and_call_original

      expect { described_class.send_notification(entity: entity, user: approver, comment: comment, recipients: recipients) }
        .to change { depositor.mailbox.inbox.count }.by(1)
                                                    .and change { to_user.mailbox.inbox.count }.by(1)
                                                                                               .and change { cc_user.mailbox.inbox.count }.by(1)
    end
    context 'without carbon-copied users' do
      let(:recipients) { { 'to' => [to_user] } }

      it 'sends a message to the to user(s)' do
        expect(approver).to receive(:send_message).exactly(2).times.and_call_original
        expect { described_class.send_notification(entity: entity, user: approver, comment: comment, recipients: recipients) }
          .to change { depositor.mailbox.inbox.count }.by(1)
                                                      .and change { to_user.mailbox.inbox.count }.by(1)
      end
    end
  end
end

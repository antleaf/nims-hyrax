require 'rails_helper'

RSpec.describe ::ApplicationMailer, :type => :mailer do
  it { expect(described_class).to be < ActionMailer::Base }
end

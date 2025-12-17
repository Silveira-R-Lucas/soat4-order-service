require 'rails_helper'

RSpec.describe ApplicationMailer, type: :mailer do
  it 'é uma classe válida de Mailer' do
    expect(ApplicationMailer.ancestors).to include(ActionMailer::Base)
  end
end
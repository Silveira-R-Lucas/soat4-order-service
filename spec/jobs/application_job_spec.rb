# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationJob, type: :job do
  it 'é uma classe válida de Job' do
    expect(ApplicationJob.ancestors).to include(ActiveJob::Base)
  end
end

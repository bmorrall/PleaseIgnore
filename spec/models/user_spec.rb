require 'spec_helper'

describe User do

  it { should validate_presence_of(:name) }

  # terms_and_conditions
  it { should validate_acceptance_of(:terms_and_conditions) }

end

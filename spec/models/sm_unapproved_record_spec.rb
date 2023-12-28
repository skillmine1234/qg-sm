require 'spec_helper'
describe SmUnapprovedRecord do
  context 'association' do
    it { should belong_to(:sm_approvable) }
  end
end

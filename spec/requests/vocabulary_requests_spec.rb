require 'spec_helper'

describe 'Vocabulary Requests' do
  before { sign_in_as_a_valid_user }

  describe 'VocabularyRequests#new' do
    it 'routes correctly' do
      expect(get("vocabulary_requests/new")).to route_to(:controller => "VocabularyRequests", :action => "new")
    end
  end
end

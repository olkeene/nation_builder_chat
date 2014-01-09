require 'spec_helper'

describe HomeController do
  describe '#index' do
    it 'should assign @events by default' do
      events = [Event, Event]
      Event.should_receive(:all).and_return(events)

      get :index

      expect(assigns[:events]).to match_array(events)
    end
    
    it 'should assign @grouped_events when grouped' do
      events = [Event, Event]
      Event.should_receive(:grouped).and_return(events)

      get :index, :view => 'grouped'

      expect(assigns[:grouped_events]).to match_array(events)
    end
  end
end

require 'spec_helper'

describe Event do
  # when will be inherited from AR
#  it { should validate_presence_of(:created_at) }
#  it { should ensure_inclusion_of(:type).in_array(Event::TYPES.values) }
  
  describe '.all' do
    it 'should return array of Events' do
      events = Event.all
      expect(events).to be_kind_of(Array)
      
      events.each do |event|
        expect(event).to be_kind_of(Event)
      end
    end
  end

  describe '.grouped' do
    it 'should return grouped events in right format' do
      events = [
        Event.new(:user => 'Bob',  :type => Event::TYPES[:enter],   :created_at => 5.hours.ago),
        Event.new(:user => 'Bob',  :type => Event::TYPES[:comment], :created_at => 5.hours.ago + 15.minute, :comment => 'Hey, Kate - high five?'),
        Event.new(:user => 'Bob',  :type => Event::TYPES[:leave], :created_at => 5.hours.ago + 31.minute)
      ]
      
      Event.should_receive(:all).and_return(events)
      expect(Event.grouped).to eq(
        5.hours.ago.to_s(:hour) => {:enter=>1, :comment=>1, :leave=>1}
      )
    end
  end

  describe '#humanized' do
    it 'should return right humanized string for :enter type' do
      event = Event.new(:user => 'Bob', :type => Event::TYPES[:enter], :created_at => 5.hours.ago)
      expect(event.humanized).to eq("#{event.created_at.to_s(:time)} #{event.user} enters the room")
    end

    it 'should return right humanized string for :leave type' do
      event = Event.new(:user => 'Bob', :type => Event::TYPES[:leave], :created_at => 5.hours.ago)
      expect(event.humanized).to eq("#{event.created_at.to_s(:time)} #{event.user} leaves")
    end

    it 'should return right humanized string for :comment type' do
      event = Event.new(:user => 'Bob', :type => Event::TYPES[:comment], :created_at => 5.hours.ago, :comment => 'Hey, Kate - high five?')
      expect(event.humanized).to eq("#{event.created_at.to_s(:time)} #{event.user} comments: '#{event.comment}'")
    end

    it 'should return right humanized string for :high_five type' do
      event = Event.new(:user => 'Kate', :type => Event::TYPES[:high_five], :created_at => 5.hours.ago + 20.minute, :high_five => 'Bob')
      expect(event.humanized).to eq("#{event.created_at.to_s(:time)} #{event.user} high-fives #{event.high_five}")
    end
  end
end

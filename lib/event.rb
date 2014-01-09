require 'active_model'

class Event
  include ActiveModel::Model
  
  TYPES = {:enter => 1, :comment => 2, :leave => 3, :high_five => 4}

  validates :type, :inclusion => {:in => TYPES.values}
  validates :created_at, :presence => true
  
  attr_accessor :type, :created_at, :comment, :user, :high_five

  class << self
    def all
      [
        new(:user => 'Bob',  :type => TYPES[:enter],   :created_at => 5.hours.ago),
        new(:user => 'Kate', :type => TYPES[:enter],   :created_at => 5.hours.ago + 1.minute),
        new(:user => 'Jo',   :type => TYPES[:enter],   :created_at => 5.hours.ago + 4.minute),
        
        new(:user => 'Bob',  :type => TYPES[:comment],   :created_at => 5.hours.ago + 15.minute, :comment => 'Hey, Kate - high five?'),
        new(:user => 'Kate', :type => TYPES[:high_five], :created_at => 5.hours.ago + 20.minute, :high_five => 'Bob'),

        new(:user => 'Kate', :type => TYPES[:leave], :created_at => 5.hours.ago + 30.minute),
        new(:user => 'Bob',  :type => TYPES[:leave], :created_at => 5.hours.ago + 31.minute)
      ]
    end

    def grouped
      all.
        group_by{|e| e.created_at.to_s(:hour) }.
        inject({}) do |out, (time, events)|
          events.each do |event|
            key = TYPES.key(event.type)
            out[time]      ||= {}
            out[time][key] ||= 0
            out[time][key]  += 1 # increment
          end
          out
        end
    end
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def humanized
    "#{created_at.to_s(:time)} " <<
      case type
      when TYPES[:enter]
        "#{user} enters the room"
      when TYPES[:leave]
        "#{user} leaves"
      when TYPES[:comment]
        "#{user} comments: '#{comment}'"
      when TYPES[:high_five]
        "#{user} high-fives #{high_five}"
      end
  end
end
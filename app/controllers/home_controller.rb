class HomeController < ApplicationController
  def index
#    @events = Event.page(params[:page]).per(10) # when do pagination
    if params[:view] == 'grouped'
      @grouped_events = Event.grouped
    else
      @events = Event.all
    end
  end
end

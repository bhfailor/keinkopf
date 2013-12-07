class ApplicationController < ActionController::Base
  protect_from_forgery
  #filter_parameter_logging :pswd # http://mashing-it-up.blogspot.com/2008/11/hiding-passwords-in-rails-log-files.html
end

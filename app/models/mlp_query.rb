class MlpQuery < ActiveRecord::Base
  attr_accessible :class_start, :class_stop, :mlp_login_email, :section, :semester, :session
end

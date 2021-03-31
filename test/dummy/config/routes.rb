Rails.application.routes.draw do
  mount RailsTwirp::Engine => "/twirp"
end

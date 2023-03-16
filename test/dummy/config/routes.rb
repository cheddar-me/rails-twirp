# frozen_string_literal: true

Rails.application.routes.draw do
  mount RailsTwirp::Engine => "/twirp"
end

# frozen_string_literal: true

Rails.application.routes.draw do
  resources :birds
  resources :nodes
  get '/common_ancestor', to: 'nodes#common_ancestor'
  get '/nodes_birds', to: 'nodes#nodes_birds'
end

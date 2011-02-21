# encoding: utf-8
unless defined?(Devise)
  require 'devise'
end
unless defined?(Koala)
  require 'koala'
end

require 'devise_koala_connectable/model'
require 'devise_koala_connectable/strategy'
require 'devise_koala_connectable/schema'
require 'devise_koala_connectable/view_helpers'

module Devise
  mattr_accessor :koala_identifier_field
  @@koala_identifier_field = :koala_identifier
  
  mattr_accessor :koala_auto_create_account
  @@koala_auto_create_account = true

  mattr_accessor :koala_app_id
  @@koala_app_id = nil

  mattr_accessor :koala_secret_key
  @@koala_secret_key = nil

  mattr_accessor :koala_callback_url
  @@koala_callback_url = nil
  
end

I18n.load_path.unshift File.join(File.dirname(__FILE__), *%w[devise_koala_connectable locales en.yml])
I18n.load_path.unshift File.join(File.dirname(__FILE__), *%w[devise_koala_connectable locales de.yml])

Devise.add_module(:koala_connectable,
  :strategy => true,
  :controller => :sessions,
  :model => 'devise_koala_connectable/model')
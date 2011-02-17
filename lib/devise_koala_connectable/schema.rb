# encoding: utf-8
require 'devise/schema'

module Devise #:nodoc:
  module KoalaConnectable #:nodoc:

    module Schema

      # Database migration schema for koala.
      #
      def koala_connectable
        apply_devise_schema ::Devise.koala_identifier_field, Integer
      end

    end
  end
end

Devise::Schema.module_eval do
  include ::Devise::KoalaConnectable::Schema
end
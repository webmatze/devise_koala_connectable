# encoding: utf-8

module Devise #:nodoc:
  # module KoalaConnectable #:nodoc:
  module Models #:nodoc:

    # Koala Connectable Module, responsible for validating authenticity of a
    # user and storing credentials while signing in.
    #
    # == Configuration:
    #
    # You can overwrite configuration values by setting in globally in Devise (+Devise.setup+),
    # using devise method, or overwriting the respective instance method.
    #
    # +koala_identifier_field+ - Defines the name of the Koala identifier database attribute/column.
    #
    # +koala_auto_create_account+ - Speifies if account should automatically be created upon connect
    #                                 if not already exists.
    #
    # == Examples:
    #
    #    User.authenticate_with_koala(:identifier => 'john@doe.com')     # returns authenticated user or nil
    #    User.find(1).koala_connected?                                  # returns true/false
    #
    module KoalaConnectable

      def self.included(base) #:nodoc:
        base.class_eval do
          extend ClassMethods
        end
      end

      # Store Koala account/session credentials.
      #
      def store_koala_credentials!(attributes = {})
        self.send(:"#{self.class.koala_identifier_field}=", attributes[:identifier])

        # Confirm without e-mail - if confirmable module is loaded.
        self.skip_confirmation! if self.respond_to?(:skip_confirmation!)

        # Only populate +email+ field if it's available (e.g. if +authenticable+ module is used).
        self.email = attributes[:email] || '' if self.respond_to?(:email)

        # Lazy hack: These database fields are required if +authenticable+/+confirmable+
        # module(s) is used. Could be avoided with :null => true for authenticatable
        # migration, but keeping this to avoid unnecessary problems.
        self.password_salt = '' if self.respond_to?(:password_salt)
        self.encrypted_password = '' if self.respond_to?(:encrypted_password)
      end

      # Checks if Koala connected.
      #
      def koala_connected?
        self.send(:"#{self.class.koala_identifier_field}").present?
      end
      alias :is_koala_connected? :koala_connected?

      # Hook that gets called before a successful connection (each time).
      # Useful for fetching additional user info (etc.) from Facebook.
      #
      # Default: Do nothing.
      #
      # == Example:
      #
      #   # Overridden in Koala connectable model, e.g. "User".
      #   #
      #   def before_koala_success(koala_user)
      #
      #      # Get email (if the provider supports it)
      #      email = koala_user["email"]
      #     # etc...
      #
      #   end
      #
      def on_before_koala_success(koala_user)
        self.send(:before_koala_success, koala_user) if self.respond_to?(:before_koala_success)
      end
      
      # Hook that gets called before the auto creation of the user.
      # Therefore, this hook is only called when koala_auto_create_account config option is enabled.
      # Useful for fetching additional user info (etc.) from Facebook.
      #
      # Default: Do nothing.
      #
      # == Example:
      #
      #   # Overridden in Koala connectable model, e.g. "User".
      #   #
      #   def before_koala_auto_create(koala_user)
      #
      #      # Get email (if the provider supports it)
      #      email = koala_user["email"]
      #     # etc...
      #
      #   end
      #
      def on_before_koala_auto_create(koala_user)
        self.send(:before_koala_auto_create, koala_user) if self.respond_to?(:before_koala_auto_create)
      end

      module ClassMethods

        # Configuration params accessible within +Devise.setup+ procedure (in initalizer).
        #
        # == Example:
        #
        #   Devise.setup do |config|
        #     config.koala_identifier_field = :koala_identifier
        #     config.koala_auto_create_account = true
        #     config.koala_app_id = nil
        #     config.koala_secret_key = nil
        #     config.koala_callback_url = nil
        #   end
        #
        ::Devise::Models.config(self,
          :koala_identifier_field,
          :koala_auto_create_account,
          :koala_app_id,
          :koala_secret_key,
          :koala_callback_url
        )

        # Alias don't work for some reason, so...a more Ruby-ish alias
        # for +koala_auto_create_account+.
        #
        def koala_auto_create_account?
          self.koala_auto_create_account
        end

        # Authenticate a user based on Facebook Identifier.
        #
        def authenticate_with_koala(attributes = {})
          if attributes[:identifier].present?
            self.find_for_koala(attributes[:identifier])
          end
        end

        protected

        # Find first record based on conditions given (Facebook identifier).
        # Overwrite to add customized conditions, create a join, or maybe use a
        # namedscope to filter records while authenticating.
        #
        def find_for_koala(identifier)
          self.first(:conditions =>  { koala_identifier_field => identifier })
        end

        # Contains the logic used in authentication. Overwritten by other devise modules.
        # In the Koala connect case; nothing fancy required.
        #
        def valid_for_koala(resource, attributes)
          true
        end

      end

    end
  end
end
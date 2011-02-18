# encoding: utf-8
require 'devise/strategies/base'

module Devise #:nodoc:

    module Strategies #:nodoc:

      # Default strategy for signing in a user using Koala.
      # Redirects to sign_in page if it's not authenticated
      #
      class KoalaConnectable < Base

        def valid?
          valid_controller? && mapping.to.respond_to?('authenticate_with_koala')
        end

        # Authenticate user with Koala.
        #
        def authenticate!
          
          klass = mapping.to

          raise StandardError, "No api_key or secret_key defined, please see the documentation of Koala gem to setup it." unless klass.koala_app_id.present? and klass.koala_secret_key.present?
          begin
            oauth = Koala::Facebook::OAuth.new(klass.koala_app_id, klass.koala_secret_key, klass.koala_callback_url)
            
            user_info = oauth.get_user_info_from_cookies(request.cookies)
            Rails.logger.debug user_info.to_yaml

            graph = Koala::Facebook::GraphAPI.new(user_info["access_token"])
            koala_user = graph.get_object(user_info["uid"])
            
            Rails.logger.debug koala_user.to_yaml

            fail!(:koala_invalid) and return unless koala_user
            
            if user = klass.authenticate_with_koala(koala_user)
              user.on_before_koala_success(koala_user)
              success!(user)
              return
            end
            
            fail!(:koala_invalid) and return unless klass.koala_auto_create_account?
            
            user = klass.new
            user.store_koala_credentials!(koala_user)
            user.on_before_koala_auto_create(koala_user)
            
            user.save(:validate => false)
            user.on_before_koala_success(koala_user)
            success!(user)
            
          rescue Exception => e
            Rails.logger.error e.to_yaml
            fail!(:koala_invalid)
          end
        end
        
        protected
          def valid_controller?
            params[:controller].to_s =~ /sessions/
          end

      end
    end

end

Warden::Strategies.add(:koala_connectable, Devise::Strategies::KoalaConnectable)

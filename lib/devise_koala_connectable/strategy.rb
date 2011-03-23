# encoding: utf-8
require 'devise/strategies/base'

module Devise #:nodoc:

    module Strategies #:nodoc:

      # Default strategy for signing in a user using Koala.
      # Redirects to sign_in page if it's not authenticated
      #
      class KoalaConnectable < Base

        def valid?
          ((valid_controller? && cookie_present? && koala_request?) || signed_request?) && mapping.to.respond_to?('authenticate_with_koala')
        end

        # Authenticate user with Koala.
        #
        def authenticate!
          klass = mapping.to

          raise StandardError, "No api_key or secret_key defined, please see the documentation of Koala gem to setup it." unless klass.koala_app_id.present? and klass.koala_secret_key.present?
          begin
            oauth = Koala::Facebook::OAuth.new(klass.koala_app_id, klass.koala_secret_key, klass.koala_callback_url)

            if signed_request?
              user_info = oauth.parse_signed_request params[:signed_request]
              unless user_info.present? #if no valid signed facebook request  found
                pass
                return
              end
              user_id = user_info["user_id"]
              access_token = user_info["oauth_token"]
            else
              user_info = oauth.get_user_info_from_cookies(request.cookies)
              unless user_info.present? #if no valid facebook Session found
                pass
                return
              end
              user_id = user_info["uid"]
              access_token = user_info["access_token"]
            end

            Rails.logger.debug "user_info: #{user_info.to_yaml}"

            graph = Koala::Facebook::GraphAPI.new(access_token)
            koala_user = graph.get_object(user_id)

            Rails.logger.debug koala_user.to_yaml

            unless koala_user
              fail!(:koala_invalid)
              return
            end

            if user = klass.authenticate_with_koala(koala_user)
              user.on_before_koala_success(koala_user)
              success!(user)
              return
            end

            unless klass.koala_auto_create_account? or signed_request?
              fail!(:koala_invalid)
              return
            end

            user = klass.new
            user.store_koala_credentials!(koala_user)
            koala_user["registration"] = user_info if signed_request?
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

          def cookie_present?
            klass = mapping.to
            raise StandardError, "No api_key or secret_key defined, please see the documentation of Koala gem to setup it." unless klass.koala_app_id.present? and klass.koala_secret_key.present?
            oauth = Koala::Facebook::OAuth.new(klass.koala_app_id, klass.koala_secret_key, klass.koala_callback_url)
            oauth.get_user_info_from_cookies(request.cookies).present?
          end

          def signed_request?
            params[:signed_request].present?
          end

          def koala_request?
            params[:koala].present?
          end

      end
    end

end

Warden::Strategies.add(:koala_connectable, Devise::Strategies::KoalaConnectable)

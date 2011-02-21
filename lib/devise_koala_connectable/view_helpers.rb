# encoding: utf-8

module Devise #:nodoc:
  module KoalaConnectable #:nodoc:

    # Koala view helpers to easily add the link to the Facebook connection popup and also the necessary JS code.
    #
    module Helpers
      
      # Creates the link to the Facebook connection popup.
      # If you create a link without putting the JS code, the popup will load in a new page.
      # The second parameter is the return URL, it must be absolute (***_url).
      #
      # For example :
      # <%= link_to_koala "Signin using Facebook!", user_session_url %>
      #
      def link_to_koala(link_text, link_url, options={})
        options = { :unobtrusive => true }.merge(options)
    		oauth = Koala::Facebook::OAuth.new(Devise::koala_app_id, Devise::koala_secret_key, Devise::koala_callback_url)
    		link_to link_text, oauth.url_for_oauth_code(:callback => link_url), options
      end

      # Returns the necessary JS code for the Facebook popup.
      # It is recommended to put this code just before the </body> tag of your layout.
      # 
      # For example :
      # ...
      # <%= javascript_include_koala %>
      # </body>
      # </html>
      #
      def javascript_include_koala
    		"<div id=\"fb-root\"></div>
        <script src=\"http://connect.facebook.net/en_US/all.js\"></script>
        <script>
           FB.init({ 
              appId:'#{Devise::koala_app_id}', cookie:true, 
              status:true, xfbml:true 
           });
        </script>"
      end
      

      # Returns the Login To Facebook button.
      # 
      # For example :
      # ...
      # <%= koala_login_button("Login with Facebook") %>
      #
      def koala_login_button(button_text = "Login with Facebook")
        "<fb:login-button>#{button_text}</fb:login-button>"
      end
      

      # Returns the Logout button for Facebook.
      # It calls the logout_url after logging out of Facbook Connect.
      #
      # For example :
      # ...
      # <%= koala_logout_button("Logout","/logout") %>
      #
      def koala_logout_button(button_text = "Logout", logout_url = "/", options = {})
        options = { :unobtrusive => true, :onclick => "FB.getLoginStatus(function(status){if(status.session){FB.logout(function(response){document.location.href='#{logout_url}'});}else{document.location.href='#{logout_url}'})" }.merge(options)
        link_to button_text, "#", options
      end
      
    end
  end
end

::ActionView::Base.send :include, Devise::KoalaConnectable::Helpers
module Superuser

  class BaseController < ApplicationController

    layout 'superuser/application'
		before_action :authenticated_superuser
    
    # ~~~~~~~~~ Pagy configuration ~~~~~~~~~
    # pagy - include backend and frontend
    include Pagy::Backend
    include Pagy::Frontend
    require 'pagy/extras/bootstrap'
    # pagy - add helper_method for navigation
    helper_method :pagy_nav
    helper_method :pagy_bootstrap_nav
    # pagy - Items per page
    # Pagy::VARS[:items] = 15
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		private

			def authenticated_superuser
				# SET YOUR CONDITION HERE TO PREVENT ACCESSING THE ADMIN AREA FROM ANYONE
				# example: redirect_to root_url if !current_user || current_user.role != 'admin'
			end

      def run_search(model)
        search_map = {'gt': '>', 'lt': '<', 'gte': '>=', 'lte': '<=', 'equal': '=', 'like': 'LIKE'}

        operator = search_map[params[:operator].downcase.to_sym]

        val = (operator == 'LIKE' ? "%#{params[:search_value]}%" : params[:search_value])

        results =
          pagy(
            model.where("cast(#{params[:search_field]} as text) #{operator} ?", val)
          )

        flash.now[:warning] = "Sorry! cannot find any #{params[:search_field].upcase} with the value #{operator} '#{params[:search_value]}' :(" if results.blank?

        return results
      end

			def flash_class(key)
      	case key
          when "success" then "alert alert-success"
          when "warning" then "alert alert-warning"
          when "notice" then "alert alert-info"
          when "alert" then "alert alert-danger"
        end
      end
			helper_method :flash_class

	end

end

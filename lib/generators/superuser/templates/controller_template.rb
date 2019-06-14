module Superuser

    class <%= get_controller_name %>Controller < BaseController

        # List all the (only) actions so it won't be applied to user's custom actions

        before_action :set_<%= resource %>, only: [:show, :edit, :update, :destroy]

        # GET /<%= resources %>
        def index

            if params[:search]

                @pagy, @<%= resources %> = pagy(run_search(<%= get_model %>))

            else

                @pagy, @<%= resources %> = pagy(<%= get_model %>.all)

            end

        end

        # GET /<%= resources %>/1
        def show

        end

        # GET /<%= resources %>/new
        def new

            @<%= resource %> = <%= get_model %>.new

        end

        # GET /<%= resources %>/1/edit
        def edit

        end

        # POST /<%= resources %>
        def create

            @<%= resource %> = <%= get_model %>.new(<%= resource %>_params)

            if @<%= resource %>.save

                redirect_to [:superuser, @<%= resource %>], notice: "<%= resource %> was successfully created."

            else

                render :new

            end

        end

        # PATCH/PUT /<%= resources %>/1
        def update

            if @<%= resource %>.update(<%= resource %>_params)

                redirect_to [:superuser, @<%= resource %>], notice: "<%= resource %> was successfully updated."

            else

                render :edit

            end

        end

        # DELETE /<%= resources %>/1
        def destroy

            @<%= resource %>.destroy

            redirect_to [:superuser, :<%= resources %>], notice: "<%= resource %> was successfully destroyed."

        end

        private
        # Use callbacks to share common setup or constraints between actions.


            # Only allow a trusted parameter "white list" through.
            def <%= resource %>_params

				params.require(:<%= resource %>).permit(<%= editable_attributes.map { |a| ":" + a[:name] }.join(', ') %>)

            end


            def set_<%= resource %>

                @<%= resource %> = <%= get_model %>.find(params[:id])

            end

    end

end

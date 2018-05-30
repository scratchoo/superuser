class SuperuserGenerator < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)
    argument :resources_name, type: :string
    attr_accessor :attributes

    # NOTE: the order of the following methods is important!

    def generate_css_file

        if !File.exist?("app/assets/stylesheets/superuser/application.scss")
            copy_file "superuser_base.scss", "app/assets/stylesheets/superuser/application.scss"
          end

    end

    def generate_js_file

        if !File.exist?("app/assets/javascripts/superuser/application.js")
        	copy_file "superuser_base.js", "app/assets/javascripts/superuser/application.js"
        	end

    end

    def generate_layout

        if !File.exist?("app/views/layouts/superuser/application.html.erb")
            template "views/layouts/application.html.erb", "app/views/layouts/superuser/application.html.erb"
        end

    end

    def generate_controller

        if !File.exist?("app/controllers/superuser/base_controller.rb")
            copy_file "base_controller.rb", "app/controllers/superuser/base_controller.rb"
        end
        if !File.exist?("app/controllers/superuser/dashboard_controller.rb")
            copy_file "dashboard_controller.rb", "app/controllers/superuser/dashboard_controller.rb"
            copy_file "views/dashboard_index.html.erb", "app/views/superuser/dashboard/index.html.erb"
            route "\tnamespace :superuser do\n\t\troot to: 'dashboard#index'\n\tend"
            add_layout_links 'app/views/layouts/superuser/application.html.erb', search = '<div class="sidebar_dashboard_link">', "<%= link_to 'dashboard', [:superuser, :root] %>"
        end
        template "controller_template.rb", "app/controllers/superuser/#{naming(:resources)}_controller.rb"

    end

    def generate_route_and_link

        # add resources to route if not exists
        route_replacement = "resources :#{resources}"
        r = add_resources_route 'config/routes.rb', search = 'namespace :superuser do', route_replacement

        # add link to resources in the layout if not exists
        link = "<%= link_to '#{resources}', [:superuser, :#{resources}] %>"
        add_layout_links 'app/views/layouts/superuser/application.html.erb', search = '<div class="sidebar_item">', link

    end

    def generate_views

        template "views/_form.html.erb", "app/views/superuser/#{naming(:resources)}/_form.html.erb"
        template "views/index.html.erb", "app/views/superuser/#{naming(:resources)}/index.html.erb"
        template "views/show.html.erb", "app/views/superuser/#{naming(:resources)}/show.html.erb"
        template "views/new.html.erb", "app/views/superuser/#{naming(:resources)}/new.html.erb"
        template "views/edit.html.erb", "app/views/superuser/#{naming(:resources)}/edit.html.erb"

    end

    def generate_search_form

        template "views/_search.html.erb", "app/views/shared/superuser/_search.html.erb"

    end

  private

    def replace(file_path)

        gsub_file file_path, 'resources', "#{naming(:resources)}"
        gsub_file file_path, 'resource', "#{naming(:resource)}"
        gsub_file file_path, 'ControllerName', "#{naming(:controller_name)}"
        gsub_file file_path, 'ModelName', "#{naming(:model_name)}"

    end

    def resources

        resources_name.underscore

    end

    def resource

        resources_name.singularize.underscore

    end

    def get_controller_name

        resources_name.camelize

    end

    def naming(key)

        map = {
          resources: resources_name.underscore,
          resource: resources_name.singularize.underscore,
          controller_name: resources_name.camelize,
          model_name: resources_name.classify
        }
        return map[key]

    end

    def model_columns_for_attributes

        resources_name.classify.constantize.columns.reject do |column|
          column.name.to_s =~ /^(id|user_id|created_at|updated_at)$/
        end

    end

    def editable_attributes

        attributes ||= model_columns_for_attributes.map do |column|
          {name: column.name.to_s, type: column.type.to_s}
        end

    end

    def get_model

        resources_name.classify.constantize

    end

    def get_resource_attributes

        editable_attributes.map { |a| a.name.prepend(':') }.join(', ')

    end

    def field_type(db_type)

        matching_type = {
                          decimal: "text_field",
                          float: "text_field",
                          datetime: "text_field",
                          string: "text_field",
                          integer: "text_field",
                          text: "text_area",
                          json: "text_area",
                          jsonb: "text_area"
                      }
        matching_type[db_type.to_sym] || "text_field"

    end

    def destination_path(path)

        File.join(destination_root, path)

    end

    # sub_file modified
    def add_resources_route(relative_file, search_text, replace_text)

        path = destination_path(relative_file)
        file_content = File.read(path)

        # if namespace for :superuser don't exists then create it
        unless file_content.include? 'namespace :superuser do'
            route "\tnamespace :superuser do\n\t\tresources :#{resources}\n\tend"
            return
        end

        # the regular expression string should be between single quotes not double quotes
        # the regular expression string should not include delimiters
        # the matching will stop when find the first occurence of 'end'
        regex_string = 'namespace \:superuser do[^end]*' + replace_text
        regex = Regexp.new(regex_string)

        #unless file_content.include? replace_text
        unless regex.match file_content
            content = file_content.sub(/(#{Regexp.escape(search_text)})/mi, "#{search_text}\n\t\t#{replace_text}")
            File.open(path, 'wb') { |file| file.write(content) }
        end

    end

    def add_layout_links(relative_file, search_text, replace_text)

        path = destination_path(relative_file)
        file_content = File.read(path)

        unless file_content.include? replace_text
          content = file_content.sub(/(#{Regexp.escape(search_text)})/mi, "#{search_text}\n\t\t\t\t#{replace_text}")
          File.open(path, 'wb') { |file| file.write(content) }
        end

    end

end

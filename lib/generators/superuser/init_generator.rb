class Superuser::InitGenerator < Rails::Generators::Base

  source_root File.expand_path('../templates', __FILE__)
  argument :frontend, type: :string, default: 'webpacker'

  def generate_css_file
    superuser_css_file = "#{stylesheets_folder()}/superuser.scss"
    if !File.exist?(superuser_css_file)
      copy_file "superuser_base.scss", superuser_css_file
    end
  end

  def generate_js_file
    superuser_js_file = "#{javascripts_folder()}/superuser.js"
    if !File.exist?(superuser_js_file)
      if for_webpack_native
        copy_file "webpack_native_base.js", superuser_js_file
      else
    	  copy_file "superuser_base.js", superuser_js_file
      end
    end
  end

  def generate_layout
    superuser_layout_file = "app/views/layouts/superuser/application.html.erb"
    if !File.exist?(superuser_layout_file)
      template "views/layouts/application.html.erb", superuser_layout_file
    end
  end

  def generate_base_controller
    superuser_base_controller = "app/controllers/superuser/base_controller.rb"
    if !File.exist?(superuser_base_controller)
      copy_file "base_controller.rb", superuser_base_controller
    end
  end

  def generate_dashboard_controller
    superuser_dashboard_controller = "app/controllers/superuser/dashboard_controller.rb"
    if !File.exist?(superuser_dashboard_controller)
      copy_file "dashboard_controller.rb", superuser_dashboard_controller

      copy_file "views/dashboard_index.html.erb", "app/views/superuser/dashboard/index.html.erb"

      add_layout_links 'app/views/layouts/superuser/application.html.erb', search = '<div class="sidebar_dashboard_link">', "<%= link_to 'dashboard', [:superuser, :root] %>"
    end
  end

  def add_base_route
    path = File.join(destination_root, 'config/routes.rb')
    file_content = File.read(path)
    # if namespace for :superuser don't exists then create it
    unless file_content.include? 'namespace :superuser do'
      route "\tnamespace :superuser do\n\t\troot to: 'dashboard#index'\n\tend\n"
    end
  end

  def generate_search_form
    template "views/_search.html.erb", "app/views/shared/superuser/_search.html.erb"
  end

  # in case of user is using webpack_native gem then add an entry pointing to superuser "application" javascript file
  def add_entry_to_webpack_native_config
    if for_webpack_native

      webpack_config_file = "#{Rails.root}/app/webpack_native/webpack.config.js"

      entry_line = "\n\t\t\tsuperuser: './src/javascripts/superuser.js',"

      path = File.join(destination_root, 'app/webpack_native/webpack.config.js')
      file_content = File.read(path)

      if file_content.include? 'entry: {'
        inject_into_file webpack_config_file, entry_line, :after => 'entry: {'
        puts separator_line
        note = "Restart rails server (in case it's running) for updates to take place in webpack.config.js"
        puts "\e[33m#{note}\e[0m"
        puts separator_line
      else
        puts separator_line
        puts "You need to add the following entry to your webpack.config.js, i.e:\n\n"
        entry = "entry: { \n  superuser: './src/javascripts/superuser/application.js',\n  // ...\n}"
        puts "\e[32m#{entry}\e[0m"
        note = "\nNote: do not forget to restart your server after that!"
        puts "\e[33m#{note}\e[0m"
        puts separator_line
      end
    end
  end

  private

    def separator_line
      "\n"+ ("~" * 60) +"\n\n"
    end

    def for_webpack_native
      frontend.include?('webpack_native') || frontend.include?('webpackNative')
    end

    def stylesheets_folder
      if for_webpack_native
        'app/webpack_native/src/stylesheets'
      else
        'app/assets/stylesheets'
      end
    end

    def javascripts_folder
      if for_webpack_native
        'app/webpack_native/src/javascripts'
      else
        'app/javascript/packs'
      end
    end

    def add_layout_links(relative_file, search_text, replace_text)
      path = File.join(destination_root, relative_file)
      file_content = File.read(path)

      unless file_content.include? replace_text
        content = file_content.sub(/(#{Regexp.escape(search_text)})/mi, "#{search_text}\n\t\t\t\t#{replace_text}")
        File.open(path, 'wb') { |file| file.write(content) }
      end
    end

end

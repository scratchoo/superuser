# Superuser

You need to generate an admin area like if you was the one who created it ? This gem is for you :)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'superuser'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install superuser

## Usage

Let's imagine you have a resource :users and you want to generate the admin scaffolding for it, just type in the command (note that the resource should be in plural):

```ruby
rails g superuser users
```

Now go to `localhost:3000/superuser` (NOTE: currently the `/superuser` url is accessible only after you generate your first resource)

### Authorization

To prevent others from accessing the admin area, open the file controllers/superuser/base_controller.rb and find the method "authenticated_superuser", then put your condition there.

E.g let say you have a column 'role' in your users table, the "authenticated_superuser" method may looks like the following:

```ruby
def authenticated_superuser
    redirect_to root_url if !current_user || current_user.role != 'admin'
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/superuser.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

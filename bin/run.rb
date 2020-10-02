require_relative '../config/environment'
require_relative '../lib/user_interface/command_line_interface.rb'

new_cli = CommandLineInterface.new

new_cli.welcome

username = new_cli.username_input
system 'clear'

new_cli.welcome
new_cli.find_or_create_by_name(username)

new_cli.hungry

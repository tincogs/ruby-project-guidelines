require "tty-prompt"

class CommandLineInterface
    attr_accessor :user, :user_choice
    def welcome
        puts "The Dinner Bell's Ringing! Let's Eat!"
    end

    def username_input
        puts "Please enter a username:"
        username = gets.chomp.downcase
    end

    def find_or_create_by_name(username)
        @user = User.find_or_create_by(name: username)
        puts "Welcome to Let's Eat #{user.name.capitalize}!"
    end

    def get_user_function
        functions = ["Choose by Restaurant", "Choose by Menu Item", "View User Account"]
        prompt = TTY::Prompt.new
        selection = prompt.select("What would you like to do?", functions)
        if  selection == "Choose by Restaurant"
            choose_by_restaurant
        elsif selection == "Choose by Menu Item"
            get_food_order
        else selection == "View User Account"
            display_user_account(@user)
        end
    end

    def choose_by_restaurant
        prompt = TTY::Prompt.new
        prompt.select("Where would you like to go?", Restaurant.all.map{|item| item.name})
    end

    def get_food_order
        prompt = TTY::Prompt.new
        menu_item = prompt.select("What do you have a taste for?", MenuItem.all.map{|item| item.name})
        user_choice_id(menu_item)
    end

    def display_user_account(user_history)
        user_last_restaurant = Restaurant.find_by(id: user_history.restaurant_id).name
        user_last_item = MenuItem.find_by(id: user_history.menu_item_id).name
        puts "\nUsername: #{user_history.name.capitalize}\nLast Restaurant: #{user_last_restaurant}\nLast Menu Item: #{user_last_item}\n"
        prompt = TTY::Prompt.new
        account_choice = prompt.select("\nWhat would you like to do?", ["Return to Home Screen","Manage Account"])
        if account_choice == "Return to Home Screen"
            get_user_function
        else
            manage_user_account
        end
    end

    def manage_user_account
        prompt = TTY::Prompt.new
        manage_choice = prompt.select("Account Management Options:", ["Update Username", "Delete Account"])
        if manage_choice == "Update Username"
            puts "Please enter a new username:"
            new_username = gets.chomp.downcase
            @user.update(name: new_username)
            puts "Updated username to: #{new_username.capitalize}"
            get_user_function
        else
            @user.destroy
            #abort
        end
    end
    def last_call(east)
        prompt = TTY::Prompt.new
        choice = prompt.select("Are you sure?", ["Yes","No"])
        if choice == "No" #loops the whole thing if they say no
            fav = get_food_order
            fave = user_choice_id(fav)
            favor = restaurant_menu_item_matches(fave)
            user_restaurants(favor)
        else
            account = @user
            account.update(menu_item_id: @user_choice.id)
            rest_id = Restaurant.find_by(name: east)
            account.update(restaurant_id: rest_id.id)
            #binding.pry
            puts "Thank you for using Let's Eat!"
        end
    end

    def user_choice_id(menu_item)
        @user_choice = MenuItem.find_by(name: menu_item)
        item_id = user_choice.id
        restaurant_menu_item_matches(item_id)
    end

    def restaurant_menu_item_matches(menu_input)
        matches = RestaurantMenuItem.where(menu_item_id: menu_input).limit(100)
        results = matches.map do |match|
            match.restaurant_id
        end
        user_restaurants(results)
    end

    def user_restaurants(match)
        restaurant_picks = Restaurant.where(id: match).limit(100)
        restaurant_names = restaurant_picks.map do |picks|
            picks.name
        end
        prompt = TTY::Prompt.new
        east = prompt.select("Where do you want to go?", restaurant_names)
        #binding.pry
        last_call(east)
    end

end
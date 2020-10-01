require "tty-prompt"

class CommandLineInterface
    attr_accessor :user, :user_choice, :restaurant_choice
    def welcome
        string = <<LOGO 


            ██╗xxxxx███████╗████████╗███████╗xxxx███████╗x█████╗x████████╗██╗      
            ██║xxxxx██╔════╝╚══██╔══╝██╔════╝xxxx██╔════╝██╔══██╗╚══██╔══╝██║      
            ██║xxxxx█████╗xxxxx██║xxx███████╗xxxx█████╗xx███████║xxx██║xxx██║      
            ██║xxxxx██╔══╝xxxxx██║xxx╚════██║xxxx██╔══╝xx██╔══██║xxx██║xxx╚═╝      
            ███████╗███████╗xxx██║xxx███████║xxxx███████╗██║xx██║xxx██║xxx██╗      
            ╚══════╝╚══════╝xxx╚═╝xxx╚══════╝xxxx╚══════╝╚═╝xx╚═╝xxx╚═╝xxx╚═╝      
            xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx      

LOGO
        puts string 

        puts "The Dinner Bell's Ringing! Let's Eat!"
    end

    def username_input
        puts "Please enter a username:"
        username = gets.chomp.downcase
    end

    def find_or_create_by_name(username)
        @user = User.find_or_create_by(name: username)
        puts "Welcome to Let's Eat #{user.name.capitalize}!"
        get_user_function
    end

    def get_user_function
        functions = ["Choose by Restaurant", "Choose by Menu Item", "View User Account"]
        prompt = TTY::Prompt.new
        selection = prompt.select("\nWhat would you like to do?", functions)
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
        restaurant = prompt.select("\nWhere would you like to go?", Restaurant.all.map{|item| item.name})
        restaurant_choice_id(restaurant)
    end

    def get_food_order
        prompt = TTY::Prompt.new
        menu_item = prompt.select("\nWhat do you have a taste for?", MenuItem.all.map{|item| item.name})
        user_choice_id(menu_item)
    end

    def display_user_account(user_history)
        user_last_restaurant = Restaurant.find_by(id: user_history.restaurant_id)
        if user_history.restaurant_id != nil
           last_place = user_last_restaurant.name
        else
            last_place = "Go eat!"
        end
        user_last_item = MenuItem.find_by(id: user_history.menu_item_id)
        if user_history.menu_item_id != nil
            last_item = user_last_item.name
         else
             last_item = "Seriously, go eat!"
         end
        puts "\nUsername: #{user_history.name.capitalize}\nLast Restaurant: #{last_place}\nLast Menu Item: #{last_item}\n"
        prompt = TTY::Prompt.new
        account_choice = prompt.select("\nWhat would you like to do?", ["Return to Home Screen","Manage Account"])
        if account_choice == "Return to Home Screen"
            get_user_function
            #system ("clear")
        else
            manage_user_account
        end
    end

    def manage_user_account
        prompt = TTY::Prompt.new
        manage_choice = prompt.select("\nAccount Management Options:", ["Update Username", "Delete Account", "Return to Home Screen"])
        if manage_choice == "Update Username"
            puts "Please enter a new username:"
            new_username = gets.chomp.downcase
            @user.update(name: new_username)
            puts "Updated username to: #{new_username.capitalize}"
            get_user_function
        elsif manage_choice == "Delete Account"
            @user.destroy
            #abort
        else 
             get_user_function
             #system ('clear')
        end
    end

    def last_call(east)
        prompt = TTY::Prompt.new
        choice = prompt.select("\nAre you sure?", ["Yes","No"])
        if choice == "No" #loops the whole thing if they say no
            get_food_order
            # fav = get_food_order
            # fave = user_choice_id(fav)
            # favor = restaurant_menu_item_matches(fave)
            # user_restaurants(favor)
        else
            account = @user
            account.update(menu_item_id: @user_choice.id)
            rest_id = Restaurant.find_by(name: east)
            account.update(restaurant_id: rest_id.id)
            #binding.pry
            puts "Thank you for using Let's Eat!\n Enjoy your #{@user_choice.name} from #{rest_id.name}!"
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
        east = prompt.select("\nWhere do you want to go?", restaurant_names)
        #binding.pry
        last_call(east)
    end

    def restaurant_choice_id(restaurant)
        @restaurant_choice = Restaurant.find_by(name: restaurant)
        choice_id = restaurant_choice.id
        menu_item_restaurant_matches(choice_id)
    end

    def menu_item_restaurant_matches(restaurant_choice_input)
        matches = RestaurantMenuItem.where(restaurant_id: restaurant_choice_input).limit(100)
        results = matches.map do |match|
            match.menu_item_id
        end
        user_menu(results)
    end

    def user_menu(match)
        menu_options = MenuItem.where(id: match).limit(100)
        all_restaurant_food_items = menu_options.map do |picks|
            picks.name
        end
        prompt = TTY::Prompt.new
        west = prompt.select("\nWhat will you order there?", all_restaurant_food_items)
        #binding.pry
        restaurant_last_call(west)
    end

    def restaurant_last_call(west)
        prompt = TTY::Prompt.new
        choice = prompt.select("\nAre you sure?", ["Yes","No"])
        if choice == "No" #loops the whole thing if they say no
            choose_by_restaurant
            # fav = choose_by_restaurant
            # fave = restaurant_choice_id(fav)
            # favor = menu_item_restaurant_matches(fave)
            # user_menu(favor)
        else
            account = @user
            account.update(restaurant_id: @restaurant_choice.id)
            menu_id = MenuItem.find_by(name: west)
            account.update(menu_item_id: menu_id.id)
            puts "Thank you for using Let's Eat!\n Enjoy your #{menu_id.name} from #{@restaurant_choice.name}!"
        end
    end
end
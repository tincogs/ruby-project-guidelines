require "tty-prompt"

class CommandLineInterface
    attr_accessor :user, :user_choice, :restaurant_choice, :string
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
        puts string.colorize(:color => :black, :background => :yellow).blink

        puts "The Dinner Bell's Ringing! Let's Eat!".underline
    end

    def username_input
        puts "\nPlease enter a username:"
        username = gets.chomp.downcase
    end

    def find_or_create_by_name(username)
        @user = User.find_or_create_by(name: username)
        puts "Welcome to Let's Eat #{user.name.capitalize}!".underline
        get_user_function
        # system 'clear'
    end

    def get_user_function
        functions = ["Choose by Restaurant", "Choose by Menu Item", "View User Account"]
        prompt = TTY::Prompt.new
        selection = prompt.select("\nWhat would you like to do?".underline, functions)
        if  selection == "Choose by Restaurant"
            choose_by_restaurant
        elsif selection == "Choose by Menu Item"
            get_food_order
        else selection == "View User Account"
            display_user_account(@user)
        end
        # system 'clear'
    end

    def choose_by_restaurant
        prompt = TTY::Prompt.new
        restaurant = prompt.select("\nWhere would you like to go?".underline, Restaurant.all.map{|item| item.name})
        restaurant_choice_id(restaurant)
        # system 'clear'
    end

    def get_food_order
        prompt = TTY::Prompt.new
        menu_item = prompt.select("\nWhat do you have a taste for?".underline, MenuItem.all.map{|item| item.name})
        user_choice_id(menu_item)
        # system 'clear'
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
        puts "\nUsername: #{user_history.name.capitalize}\nLast Restaurant: #{last_place}\nLast Menu Item: #{last_item}\n".underline
        prompt = TTY::Prompt.new
        account_choice = prompt.select("\nWhat would you like to do?", ["Return to Home Screen","Manage Account"])
        if account_choice == "Return to Home Screen"
            get_user_function
            # system 'clear'
        else
            manage_user_account
        end
        # system 'clear'
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
        end
        # system 'clear'
    end

    def last_call(east)
        prompt = TTY::Prompt.new
        choice = prompt.select("\nAre you sure?", ["Yes","No"])
        if choice == "No" #loops the whole thing if they say no
            get_food_order
        else
            account = @user
            account.update(menu_item_id: @user_choice.id)
            rest_id = Restaurant.find_by(name: east)
            account.update(restaurant_id: rest_id.id)
            puts "Thank you for using Let's Eat!\n Enjoy your #{@user_choice.name} from #{rest_id.name}!".underline
        end
        # system 'clear'
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
        east = prompt.select("\nWhere do you want to go?".underline, restaurant_names)
        #binding.pry
        last_call(east)
        # system 'clear'
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
        west = prompt.select("\nWhat will you order there?".underline, all_restaurant_food_items)
        #binding.pry
        restaurant_last_call(west)
        # system 'clear'
    end

    def restaurant_last_call(west)
        prompt = TTY::Prompt.new
        choice = prompt.select("\nAre you sure?".underline, ["Yes","No"])
        if choice == "No" #loops the whole thing if they say no
            choose_by_restaurant
        else
            account = @user
            account.update(restaurant_id: @restaurant_choice.id)
            menu_id = MenuItem.find_by(name: west)
            account.update(menu_item_id: menu_id.id)
            signoff = "Thank you for using Let's Eat!\n Enjoy your #{menu_id.name} from #{@restaurant_choice.name}!"
            puts signoff.underline
        end
    end

    def hungry
        string = <<LOGO
                                       ```.............``
                                ``.--::::::-:--------::::::--..`
                            `.-::::----....``````````.....---::::-.`
                        `.-::::--..`````                `````..---:::-.`
                    .-:::--.```````````````  `    ``````````````.--:::-.`
                `-:::--.``````````````````````````````````````````.--:::-`
/--.`          `-:::-.````````````````````````````````````````````````.-::/:`  `++`  -//:   ++`
y--://-`     `-//:-..```````````````````````````````````````````````````.-://:`-hh.  ooos   dh:
s````.:+/`  .//::....```````````````````````````````````````````````````...-://oyh`  o+/s   hy+
y`    `./o-://:-.......```````````````````````````````````````````````......-:/ysy`  s//y   hss
y`     `.:so/:.....................``````````````````````.....................:yoy:  y/:y  `hoy
y`      `./y:-.............../syyy+-....................-+syys/................y+so:`y::h  .y+y
y.`     `.-+s-..............sdhhhhhh/..................:ydhhhhhs-.............-y+oo+:h--y. -s+y
y.`      `-:y:-............ohhyyyyyhh-................-yhyyyyyyhs............--y/+s/oy-.s: +o/y
y.`      `.:oo---.........-hyysssssyy+................/hyyssssyyh-..........---y/:s+so.`+o`s::y
y.`      `.:os-------.....-yysssssssyo................oyssssssssy:.......------s/.:+o:` -++:.:y
s.`      `-:os---------...-yysssssssyo................+yssssssssy:.....--------s+.```    ````+s
y.`     `.-/os------------.sysssssssy:................-yyssssssys.-------------/so-`      `-oo.
y.`      `.:os-------.....-yysssssssyo................oyssssssssy:.......------s/.:+o:` -++:.:y
s.`      `-:os---------...-yysssssssyo................+yssssssssy:.....--------s+.```    ````+s
y.`     `.-/os------------.sysssssssy:................-yyssssssys.-------------/so-`      `-oo.
y.`     `.:/y+::----------.-yyysssyy+................../yyyssyyy:.-----------::::+s+.    -ss:
y-.``  `.-/+h:::::-----------+yyyys:.................--.:syyyyo------------:::::::/ss.  -yo
y:---.`.-:+yo:::::::---------..-:-.----------------------.-:-..----------:::::::://+y- `:d:
y///::--:/sy//::::::::--------------------------------------------------:::::::////+h- `/d-
y///////+oy////:::::::::----------------------------------------------:::::::://///+y- `/d:
y:-:///+sy/////:::::::::---------------------------------------------:::::::://////oy. ./d/
y-.-:/+oh/////::hhyso+/:--------------------------------------------:/+osyhh/://///os. ./h/
y.`.-/+oh/////::mddddddddhyysoo+++///::::----------::::///+++oosyhhddddddddd+://///so` .:yo
y.`.-/+sh//////-hdhs:://+ossyhhdddddddddddddddddddddddddddddhhyysso++//:ohhd-//////y+` .:ys
y.`.-/+sh+/////:+dhy....```......--:://///+++++++////:::--............--ohdo://////y/` `:sh
y.`.-/+sy+//////-shh+...````````````                      ````````....-/hhy-//////+h:  `:od
y.`.-/+sy++/////:-yyys+/-.``````````                      ```````.-:/osyyy:://///++h-  `-+d`
y.`.-/+sh+++/////::yysyyyyso/::-..```                 ```..--:/+osyyyysyy:://///++oy-  `-+h-
s.`.-/+sy++++/////::ssooossssysssssssssooooooooooooossssssssyysssssoooss:://////++ss.  `-/h/
s.`.-/+syo++++/////:-osooooooooooosyyyyyyyyyyysyyyyyyyyyysoooooooooooso:://///++++so`   ./y+
s.`.-/+syoo++++/////:-/sooooooooooyysssssssssyyssssssssssyoooooooooos/:://///++++oy+`   .:ss
s.`.-/+so/ooo+++/////:::+sooooooooysooooooooossoooooooossysooooooos+::://///++++ooy/`   `:oy
s``.-/+s+ -ooo++++/////:::+oooo++ossoo++++++ooso+++++ooosssooo+/::+/://////+++ooo:s/`   `-oh
y.`.-/+s+  `/ooo+++//////:::/+oooosoo++++++++oo++++++++ooso+++/:. `s/////+++ooo+. s/`   `-oh
s...-/+y:    -+ooo++++//////::::/oso+++++//++++/+////+++osoo//+o:`-s///++++ooo:`  +o.   `:so
   :+://+o+      `-+ooo++++////////:/so++////////////////++osyo///o+.+s++++oooo:`    `/+:::+o+`
    `----`         `-+oooo+++++//////so++////////////////++osys///o+:oo++ooo+:`        `.---`
                      ./ooooo+++++++/+sso+++//////////+++oososs+++s//soooo/.`
                        `-/ooooooo+++++ssssoooooooooooossss++++++os::yo/-`
                            .:+ooooooooooosssyssssssyssssoooooooos+--s`
                                .-:+oooooooooooossoooooooososo+/-+/..+-
                                     `.--://++++++++++//:--.`    +:``+:
                                                                 /+:/o`
                                                                  --.
LOGO
        puts string.colorize(:color => :yellow)
    end
end
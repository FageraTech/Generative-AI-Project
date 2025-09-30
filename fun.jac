"""A Treasure Hunt Adventure Game"""

walker adventure_game {
    has player_name;
    has health = 100;
    has inventory = [];
    has moves = 0;
}

node room_node {
    has room_id;
    has description;
    has connections = {};
    has items = [];
    has visited = false;
}

# Initialize the game world
walker init_world {
    has created_rooms = false;
    
    with entry {
        if not [::root --> room_node] {
            spawn ::root --> room_node(
                room_id=1,
                description="You are in a dark forest. Strange noises echo around you.",
                connections={"north": 2, "east": 3},
                items=["torch"]
            );
            spawn ::root --> room_node(
                room_id=2, 
                description="You've reached an ancient temple entrance.",
                connections={"south": 1, "east": 4},
                items=["key"]
            );
            spawn ::root --> room_node(
                room_id=3,
                description="A murky swamp. The air is thick with fog.",
                connections={"west": 1, "north": 4},
                items=["potion"]
            );
            spawn ::root --> room_node(
                room_id=4,
                description="You stand before a massive dragon's lair!",
                connections={"west": 2, "south": 3, "north": 5},
                items=["gold coin"]
            );
            spawn ::root --> room_node(
                room_id=5,
                description="The treasure chamber! A sparkling chest awaits.",
                connections={"south": 4},
                items=["treasure"]
            );
            std.log("Game world initialized with 5 rooms");
        }
        take --> node::root; 
    }
}

# Main game walker
walker game_controller {
    can explore_room with room_node entry;
    can handle_action;
    can game_over;
    
    with entry {
        print("🏴‍☠️ Welcome to the Treasure Hunt Adventure! 🏴‍☠️");
        player_name = input("What is your name, adventurer? ");
        
        # Create player walker
        player = spawn here walker::adventure_game(player_name=player_name);
        
        # Initialize world
        spawn here walker::init_world;
        
        # Start game in first room
        start_room = [::root --> room_node(room_id=1)];
        if start_room {
            player.visit(start_room);
        } else {
            print("Error: Starting room not found!");
        }
    }
}

# Implement room exploration
impl game_controller.explore_room {
    here.visited = true;
    visitor.moves += 1;

    print("\n" + "="*40);
    print("📍 " + here.description);
    print("Health: " + str(visitor.health) + " ❤️");
    print("Moves: " + str(visitor.moves));
    print("Inventory: " + str(visitor.inventory));

    if here.items.length > 0 {
        print("You see: " + str(here.items));
    }

    available_exits = here.connections.keys();
    print("Exits: " + str(list(available_exits)));

    print("\nWhat would you like to do?");
    print("Options: move [direction], take [item], look, inventory, quit");
    action = input("> ").lower().split();
    
    self.handle_action(action);
}

# Handle player actions
impl game_controller.handle_action {
    if action.length == 0 {
        print("Please enter a command.");
        visitor.visit(here);
        return;
    }

    if action[0] == "move" and action.length > 1 {
        direction = action[1];
        if direction in here.connections {
            next_room_id = here.connections[direction];
            next_room = [::root --> room_node(room_id=next_room_id)];

            if next_room {
                health_cost = std.rand.int(1, 5);
                visitor.health -= health_cost;

                if visitor.health <= 0 {
                    self.game_over("exhaustion");
                    return;
                }

                print("You move " + direction + " (lost " + str(health_cost) + " health)");
                visitor.visit(next_room);
            } else {
                print("Error: Room not found!");
                visitor.visit(here);
            }
        } else {
            print("You can't go that way!");
            visitor.visit(here);
        }
    }
    elif action[0] == "take" and action.length > 1 {
        item_name = action[1];
        if item_name in here.items {
            here.items.remove(item_name);
            visitor.inventory.append(item_name);
            print("You took the " + item_name);

            if item_name == "treasure" {
                self.game_over("win");
                return;
            }

            if item_name == "potion" {
                visitor.health += 20;
                print("Potion restored 20 health!");
            }
        } else {
            print("There's no " + item_name + " here!");
        }
        visitor.visit(here);
    }
    elif action[0] == "look" {
        print("You look around carefully...");
        if not here.visited {
            if std.rand.int(1, 4) == 1 and here.items.length == 0 {
                hidden_items = ["gold coin", "key", "map", "potion"];
                found_item = std.rand.choice(hidden_items);
                here.items.append(found_item);
                print("You found a hidden " + found_item + "!");
            }
        }
        visitor.visit(here);
    }
    elif action[0] == "inventory" {
        print("Your inventory: " + str(visitor.inventory));
        visitor.visit(here);
    }
    elif action[0] == "quit" {
        self.game_over("quit");
    }
    else {
        print("I don't understand that command.");
        visitor.visit(here);
    }
}

# Game over handler
impl game_controller.game_over {
    print("\n" + "="*40);
    print("🎮 GAME OVER");

    if reason == "win" {
        print("🏆 CONGRATULATIONS " + visitor.player_name + "!");
        score = visitor.health * 10 + 100 - visitor.moves;
        print("Final Score: " + str(score));
    }
    elif reason == "exhaustion" {
        print("💀 You collapsed from exhaustion!");
        print("The treasure remains hidden...");
    }
    elif reason == "quit" {
        print("Thanks for playing!");
    }

    print("Stats:");
    print("- Health: " + str(visitor.health));
    print("- Moves: " + str(visitor.moves));
    print("- Items collected: " + str(visitor.inventory.length));
    print("="*40);
}

# Start the game
with entry {
    spawn here walker::game_controller;
}
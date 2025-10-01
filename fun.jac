node room_node {
    has room_id;
    has description;
    has connections = {};
    has items = [];
    has visited = false;
}

walker adventure_game {
    has player_name;
    has health = 100;
    has inventory = [];
    has moves = 0;
}

walker init_world {
    with entry {
        existing_rooms = [-[room_node]->];
        if (existing_rooms.length == 0): {
            spawn here ++> node::room_node(
                room_id=1,
                description="You are in a dark forest. Strange noises echo around you.",
                connections={"north": 2, "east": 3},
                items=["torch"]
            );
            spawn here ++> node::room_node(
                room_id=2, 
                description="You've reached an ancient temple entrance.",
                connections={"south": 1, "east": 4},
                items=["key"]
            );
            spawn here ++> node::room_node(
                room_id=3,
                description="A murky swamp. The air is thick with fog.",
                connections={"west": 1, "north": 4},
                items=["potion"]
            );
            spawn here ++> node::room_node(
                room_id=4,
                description="You stand before a massive dragon's lair!",
                connections={"west": 2, "south": 3, "north": 5},
                items=["gold coin"]
            );
            spawn here ++> node::room_node(
                room_id=5,
                description="The treasure chamber! A sparkling chest awaits.",
                connections={"south": 4},
                items=["treasure"]
            );
            std.log("Game world initialized with 5 rooms");
        }
    }
}

walker game_controller {
    has current_room;
    has player;
    
    with entry {
        std.out("🏴 Welcome to the Treasure Hunt Adventure! 🏴");
        here.player_name = std.input("What is your name, adventurer? ");
        
        here.player = spawn here --> walker::adventure_game(
            player_name=here.player_name
        );
        
        spawn here --> walker::init_world;
        
        start_room = [-[room_node(room_id==1)]->];
        if (start_room.length > 0): {
            here.current_room = start_room[0];
            here.player --> here.current_room;
        } else {
            std.out("Error: Starting room not found!");
        }
    }
}

impl walker::explore_room for game_controller {
    with node::entry {
        here.visited = true;
        visitor.moves += 1;

        std.out("\n" + "="*40);
        std.out("📍 " + here.description);
        std.out("Health: " + visitor.health.str() + " ❤️");
        std.out("Moves: " + visitor.moves.str());
        std.out("Inventory: " + visitor.inventory.str());

        if (here.items.length > 0): {
            std.out("You see: " + here.items.str());
        }

        available_exits = here.connections.keys();
        std.out("Exits: " + available_exits.str());

        std.out("\nWhat would you like to do?");
        std.out("Options: move [direction], take [item], look, inventory, quit");
        action = std.input("> ").lower().split();
        
        here.handle_action(action, here);
    }
}

walker handle_action {
    with entry {
        if (ctx.action.length == 0): {
            std.out("Please enter a command.");
            visitor --> here.current_room;
            return;
        }

        if (ctx.action[0] == "move" and ctx.action.length > 1): {
            direction = ctx.action[1];
            if (direction in here.connections): {
                next_room_id = here.connections[direction];
                next_room = [-[room_node(room_id==next_room_id)]->];

                if (next_room.length > 0): {
                    health_cost = std.rand.int(1, 5);
                    visitor.health -= health_cost;

                    if (visitor.health <= 0): {
                        visitor.game_over("exhaustion");
                        return;
                    }

                    std.out("You move " + direction + " (lost " + health_cost.str() + " health)");
                    visitor --> next_room[0];
                } else {
                    std.out("Error: Room not found!");
                    visitor --> here;
                }
            } else {
                std.out("You can't go that way!");
                visitor --> here;
            }
        }
        elif (ctx.action[0] == "take" and ctx.action.length > 1): {
            item_name = ctx.action[1];
            if (item_name in here.items): {
                index = here.items.index(item_name);
                if (index >= 0): {
                    here.items.remove(index);
                }
                visitor.inventory.append(item_name);
                std.out("You took the " + item_name);

                if (item_name == "treasure"): {
                    visitor.game_over("win");
                    return;
                }

                if (item_name == "potion"): {
                    visitor.health += 20;
                    std.out("Potion restored 20 health!");
                }
            } else {
                std.out("There's no " + item_name + " here!");
            }
            visitor --> here;
        }
        elif (ctx.action[0] == "look"): {
            std.out("You look around carefully...");
            if (!here.visited): {
                if (std.rand.int(1, 4) == 1 and here.items.length == 0): {
                    hidden_items = ["gold coin", "key", "map", "potion"];
                    found_item = std.rand.choice(hidden_items);
                    here.items.append(found_item);
                    std.out("You found a hidden " + found_item + "!");
                }
            }
            visitor --> here;
        }
        elif (ctx.action[0] == "inventory"): {
            std.out("Your inventory: " + visitor.inventory.str());
            visitor --> here;
        }
        elif (ctx.action[0] == "quit"): {
            visitor.game_over("quit");
        }
        else {
            std.out("I don't understand that command.");
            visitor --> here;
        }
    }
}

walker game_over {
    with entry {
        std.out("\n" + "="*40);
        std.out("🎮 GAME OVER");

        if (ctx.reason == "win"): {
            std.out("🏆 CONGRATULATIONS " + visitor.player_name + "!");
            score = visitor.health * 10 + 100 - visitor.moves;
            std.out("Final Score: " + score.str());
        }
        elif (ctx.reason == "exhaustion"): {
            std.out("💀 You collapsed from exhaustion!");
            std.out("The treasure remains hidden...");
        }
        elif (ctx.reason == "quit"): {
            std.out("Thanks for playing!");
        }

        std.out("Stats:");
        std.out("- Health: " + visitor.health.str());
        std.out("- Moves: " + visitor.moves.str());
        std.out("- Items collected: " + visitor.inventory.length.str());
        std.out("="*40);
        
        disconnect visitor;
    }
}

with entry {
    spawn here --> walker::game_controller;
}

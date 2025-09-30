walker treasure_game {
    has player_name;
    has health = 100;
    has inventory = [];
    has moves = 0;
    has current_room = "entrance";
    
    # Room descriptions without AI
    room_descriptions = {
        "entrance": "You are at the entrance of a mysterious cave. Torches flicker on the walls.",
        "hallway": "A long hallway with ancient paintings. There's a door to the north and south.",
        "treasure_room": "A room filled with gold and jewels! You found the treasure!",
        "trap_room": "Oh no! You triggered a trap and lost some health!"
    };
    
    # Room connections
    room_connections = {
        "entrance": ["hallway"],
        "hallway": ["entrance", "treasure_room", "trap_room"],
        "treasure_room": ["hallway"],
        "trap_room": ["hallway"]
    };
    
    start {
        std.out("Welcome to the Treasure Hunt Adventure! ");
        player_name = std.in("What is your name, adventurer? ");
        self.player_name = player_name;
        std.out("Hello, " + self.player_name + "! Let's begin...");
        self.describe_room();
    }
    
    describe_room {
        std.out("\n" + "="*50);
        std.out(self.room_descriptions[self.current_room]);
        std.out("Health: " + self.health.toString());
        std.out("Inventory: " + self.inventory.toString());
        std.out("Moves: " + self.moves.toString());
        self.show_actions();
    }
    
    show_actions {
        std.out("\nWhat would you like to do?");
        available_rooms = self.room_connections[self.current_room];
        
        for i, room in available_rooms.enumerated() {
            std.out((i + 1).toString() + ". Go to " + room);
        }
        
        std.out((available_rooms.length + 1).toString() + ". Search the room");
        std.out((available_rooms.length + 2).toString() + ". Quit game");
        
        choice = std.in("Enter your choice: ");
        self.process_choice(choice, available_rooms);
    }
    
    process_choice(choice, available_rooms) {
        choice_num = choice.to_int();
        
        if choice_num <= available_rooms.length and choice_num > 0 {
            # Move to another room
            new_room = available_rooms[choice_num - 1];
            self.current_room = new_room;
            self.moves += 1;
            
            # Random events
            if random.randint(1, 4) == 1 and new_room != "entrance" {
                self.random_event();
            }
            
        } elif choice_num == available_rooms.length + 1 {
            # Search room
            self.search_room();
        } elif choice_num == available_rooms.length + 2 {
            # Quit
            std.out("Thanks for playing, " + self.player_name + "!");
            std.out("Final Score: " + (self.inventory.length * 10).toString());
            return;
        } else {
            std.out("Invalid choice! Try again.");
        }
        
        # Check win condition
        if self.current_room == "treasure_room" {
            std.out("\n CONGRATULATIONS! You found the treasure! ");
            std.out("You win! Final score: " + (self.inventory.length * 10 + self.health).toString());
            return;
        }
        
        # Check health
        if self.health <= 0 {
            std.out("\nGame Over! You ran out of health.");
            return;
        }
        
        self.describe_room();
    }
    
    search_room {
        items = ["gold coin", "silver key", "ancient map", "healing potion", "rusty sword"];
        found_item = items[random.randint(0, items.length - 1)];
        
        std.out("You search the room and find: " + found_item + "!");
        self.inventory.append(found_item);
        
        # Special effects for certain items
        if found_item == "healing potion" {
            self.health += 20;
            std.out("You drink the potion and gain 20 health!");
        }
        
        self.moves += 1;
    }
    
    random_event {
        events = [
            "A bat flies by! You lose 5 health.",
            "You find a hidden passage but it's a dead end.",
            "The walls are closing in! You escape but lose 10 health.",
            "You discover a hidden chest with treasure!",
            "A friendly ghost gives you advice."
        ];
        
        event = events[random.randint(0, events.length - 1)];
        std.out("\n⚡ Random Event: " + event);
        
        if event.contains("lose 5 health") {
            self.health -= 5;
        } elif event.contains("lose 10 health") {
            self.health -= 10;
        } elif event.contains("treasure") {
            self.inventory.append("mysterious gem");
        }
    }
}

walker init {
    spawn here walker:treasure_game;
}
"""Treasure Hunt Adventure Game in Python"""

import random

class Room:
    def __init__(self, room_id, description, connections=None, items=None):
        self.room_id = room_id
        self.description = description
        self.connections = connections or {}
        self.items = items or []
        self.visited = False

class Player:
    def __init__(self, name):
        self.name = name
        self.health = 100
        self.inventory = []
        self.moves = 0
        self.current_room = None

class Game:
    def __init__(self):
        self.rooms = {}
        self.player = None
        self.setup_world()
    
    def setup_world(self):
        # Create rooms
        self.rooms[1] = Room(1, "You are in a dark forest. Strange noises echo around you.", 
                            {"north": 2, "east": 3}, ["torch"])
        self.rooms[2] = Room(2, "You've reached an ancient temple entrance.", 
                            {"south": 1, "east": 4}, ["key"])
        self.rooms[3] = Room(3, "A murky swamp. The air is thick with fog.", 
                            {"west": 1, "north": 4}, ["potion"])
        self.rooms[4] = Room(4, "You stand before a massive dragon's lair!", 
                            {"west": 2, "south": 3, "north": 5}, ["gold coin"])
        self.rooms[5] = Room(5, "The treasure chamber! A sparkling chest awaits.", 
                            {"south": 4}, ["treasure"])
    
    def start_game(self):
        print("🏴 Welcome to the Treasure Hunt Adventure! 🏴")
        player_name = input("What is your name, adventurer? ")
        self.player = Player(player_name)
        self.player.current_room = self.rooms[1]
        self.explore_room()
    
    def explore_room(self):
        room = self.player.current_room
        room.visited = True
        self.player.moves += 1
        
        print("\n" + "="*40)
        print(f"📍 {room.description}")
        print(f"Health: {self.player.health} ❤️")
        print(f"Moves: {self.player.moves}")
        print(f"Inventory: {self.player.inventory}")
        
        if room.items:
            print(f"You see: {room.items}")
        
        print(f"Exits: {list(room.connections.keys())}")
        
        self.get_action()
    
    def get_action(self):
        print("\nWhat would you like to do?")
        print("Options: move [direction], take [item], look, inventory, quit")
        action = input("> ").lower().split()
        self.handle_action(action)
    
    def handle_action(self, action):
        if not action:
            print("Please enter a command.")
            self.explore_room()
            return
        
        room = self.player.current_room
        
        if action[0] == "move" and len(action) > 1:
            direction = action[1]
            if direction in room.connections:
                next_room_id = room.connections[direction]
                self.move_to_room(next_room_id)
            else:
                print("You can't go that way!")
                self.explore_room()
        
        elif action[0] == "take" and len(action) > 1:
            item_name = action[1]
            if item_name in room.items:
                room.items.remove(item_name)
                self.player.inventory.append(item_name)
                print(f"You took the {item_name}")
                
                if item_name == "treasure":
                    self.game_over("win")
                    return
                
                if item_name == "potion":
                    self.player.health += 20
                    print("Potion restored 20 health!")
                
                self.explore_room()
            else:
                print(f"There's no {item_name} here!")
                self.explore_room()
        
        elif action[0] == "look":
            print("You look around carefully...")
            if not room.visited:
                if random.randint(1, 4) == 1 and not room.items:
                    hidden_items = ["gold coin", "key", "map", "potion"]
                    found_item = random.choice(hidden_items)
                    room.items.append(found_item)
                    print(f"You found a hidden {found_item}!")
            self.explore_room()
        
        elif action[0] == "inventory":
            print(f"Your inventory: {self.player.inventory}")
            self.explore_room()
        
        elif action[0] == "quit":
            self.game_over("quit")
        
        else:
            print("I don't understand that command.")
            self.explore_room()
    
    def move_to_room(self, room_id):
        health_cost = random.randint(1, 5)
        self.player.health -= health_cost
        
        if self.player.health <= 0:
            self.game_over("exhaustion")
            return
        
        print(f"You move (lost {health_cost} health)")
        self.player.current_room = self.rooms[room_id]
        self.explore_room()
    
    def game_over(self, reason):
        print("\n" + "="*40)
        print("🎮 GAME OVER")
        
        if reason == "win":
            print(f"🏆 CONGRATULATIONS {self.player.name}!")
            score = self.player.health * 10 + 100 - self.player.moves
            print(f"Final Score: {score}")
        elif reason == "exhaustion":
            print("💀 You collapsed from exhaustion!")
            print("The treasure remains hidden...")
        elif reason == "quit":
            print("Thanks for playing!")
        
        print("Stats:")
        print(f"- Health: {self.player.health}")
        print(f"- Moves: {self.player.moves}")
        print(f"- Items collected: {len(self.player.inventory)}")
        print("="*40)

# Start the game
if __name__ == "__main__":
    game = Game()
    game.start_game()
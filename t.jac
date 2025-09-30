walker dice_game {
    has balance = 100;
    
    with entry {
        print(" Welcome to the Dice Game!");
        print("You start with $100");
        print("Guess if the dice roll will be HIGH (4-6) or LOW (1-3)");
        self.play_round();
    }
    
    can play_round;
}

impl dice_game.play_round {
    if self.balance <= 0 {
        print(" You're out of money! Game over.");
        return;
    }
    
    print("\nYour balance: $" + str(self.balance));
    print("Place your bet (minimum $10)");
    bet_input = input("Bet amount: ");
    
    # Validate bet
    if not bet_input.isdigit() {
        print(" Please enter a valid number!");
        self.play_round();
        return;
    }
    
    bet = int(bet_input);
    
    if bet < 10:
        print(" Minimum bet is $10!");
        self.play_round();
        return;
    
    if bet > self.balance:
        print("You don't have enough money!");
        self.play_round();
        return;
    
    # Get player prediction
    print("Will the roll be HIGH or LOW?");
    prediction = input("Your prediction: ").lower();
    
    if prediction not in ["high", "low"]:
        print(" Please enter 'high' or 'low'!");
        self.play_round();
        return;
    
    # Roll the dice
    dice_roll = std.rand.int(1, 6);
    print(" The dice shows: " + str(dice_roll));
    
    # Determine result
    is_high = dice_roll >= 4;
    player_won = false;
    
    if (prediction == "high" and is_high) or (prediction == "low" and not is_high):
        winnings = bet * 2;
        self.balance += winnings;
        print(" You won $" + str(winnings) + "!");
        player_won = true;
    else:
        self.balance -= bet;
        print(" You lost $" + str(bet) + "!");
    
    # Ask to play again
    if self.balance > 0:
        play_again = input("\nPlay again? (yes/no): ").lower();
        if play_again == "yes" or play_again == "y":
            self.play_round();
        else:
            print("\nThanks for playing! Final balance: $" + str(self.balance));
    else:
        print(" Game over! You're out of money.");
}

# Start the game
with entry {
    spawn here walker::dice_game;
}

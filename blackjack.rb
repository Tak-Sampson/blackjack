# Basic game of blackjack
# no bets, double down, or surrender
# H17

puts "=> What is your name?"
player_name = gets.chomp


def valid_input(player_hand,hand,ranks)
  choice = ''
  two_kind = false
  #p hand
  puts "What is your decision?"
  ranks.each do |rank|
    if (hand.count {|card| card[0] == rank} == 2) && (hand.length == 2)
      two_kind = true
    end 
  end
  if two_kind
    loop do
      puts "h) Hit    st) Stay    sp)  Split"
      choice = gets.chomp
      if choice == "h" || choice == "st" || choice == "sp"
        break
      end
      puts "Invalid entry. Please try again."
    end
  else
    loop do
      puts "h) Hit    st) Stay"
      choice = gets.chomp
      if choice == "h" || choice == "st"
        break
      end
      puts "Invalid entry. Please try again."
    end
  end
  choice
end

def blackjack?(player)
  if (player.flatten.include?("J") || player.flatten.include?("Q") || player.flatten.include?("K")) && player.flatten.include?("A")
    true
    puts "=> Blackjack!"
  else
  false
  end
end

def hand_value(hand) # Assign all possible values as array to a given hand
  hand_val = [0]
  hand.each do |card|
    if [2,3,4,5,6,7,8,9,10].include?(card[0])
      hand_val.map! {|total| total += card[0] }
    elsif card[0] == "J" || card[0] == "Q" || card[0] == "K"
      hand_val.map! {|total| total += 10}  
    else  # the card under inspection in the player's hand is an ace
      hand_val.map! {|total| total += 1}
      temp_arr = []
      hand_val.each {|total| temp_arr << total}
      temp_arr.each do |total|
        total += 10
        hand_val << total
      end
    end
  end
  hand_val
end

def hand_display(hand)
  puts ''
  display = ''
  display_suit = ''
  hand.each do |card|
    display = display + " #{card[0]}  "
    display_suit = display_suit + " #{card[1]}  "
  end
  puts display
  puts display_suit
  puts ''
end

# Game loop
loop do
# Initialize settings

  puts ""
  puts "Hello, #{player_name}! Welcome to Blackjack!"
  puts ""

  available_cards = []
  one_deck = []
  suits = ['d','c','h','s']
  ranks = [2,3,4,5,6,7,8,9,10,'J','Q','K','A']
  suits.each do |suit|
    ranks.each do |rank|
      one_deck << [rank, suit]
    end
  end

  number_of_decks = 3

  number_of_decks.times do 
    one_deck.each do |card| 
      available_cards << card
    end
  end

  victor = ''

  player_hand = [[]] # array of arrays; each inner array has cards with possible total value
                     # array will have more than 1 arg in the event of a split
  player_vals = []   # possible values of each hand (factoring in splits and aces)

  dealer_hand = []   # dealer cannot split
  dealer_vals = []

  turn = 1



  # Player turn loop
  loop do
    # Deal opening cards; no blackjack past the 1st turn
    if turn == 1
      2.times do 
       player_hand[0] << available_cards.shuffle.shift
       dealer_hand << available_cards.shuffle.shift
      end

      
      puts ''
      puts "=> Dealer's hand:"
      hand_display(dealer_hand)

      if blackjack?(dealer_hand)   # Dealer wins a tie
        victor = "Dealer" 
        puts "=> Blackjack!"
        break
      elsif hand_value(dealer_hand).include?(21)
        victor = "Dealer"
        break
      elsif blackjack?(player_hand)
        victor = "#{player_name}"
        puts "=> Blackjack!"
        break
      elsif hand_value(player_hand).include?(21)
        victor = "#{player_name}"
        break
      end
    end

    turn += 1

    # Player input - must be able to make a decision for each hand in a split
    player_hand.each do |nth_hand|
      # only do if hand has yet to be busted, or hasnt been stayed
    
      hand_val = hand_value(nth_hand)

      puts ''
      puts "#{player_name}'s hand:"
      hand_display(nth_hand)

      p hand_val

      # check if the player's nth hand has a value equal to 21
      if hand_val.include?(21)
        victor = player_name 
        player_vals << 21
        break
      
      # check for bust
      elsif hand_val.select{|total| total < 21}.empty?
        puts "=> Bust" 
        player_hand.delete(nth_hand) 
      else
      # player makes a valid move
        move = valid_input(player_hand, nth_hand, ranks)    # returns 'h', 'st' or 'sp'
      
        if move == 'h'
          nth_hand << available_cards.shuffle.shift
        elsif move == 'st'
          player_vals << hand_val
          player_hand.delete(nth_hand) 
        else # split
          player_hand << [nth_hand.pop]
          hand_display(nth_hand)
          move = valid_input(player_hand, nth_hand, ranks)    # returns 'h', 'st' 
          if move == 'h'
            nth_hand << available_cards.shuffle.shift
          elsif move == 'st'
            player_vals << hand_val
            player_hand.delete(nth_hand) 
          end
        end
      end    
    end

    if player_hand.empty? then break end
    if player_vals.include?(21) then break end

  end

  # Dealer turn loop
  victor = "Dealer" # by default
  if (turn > 1) && !(player_vals.empty?) && !(hand_value(dealer_hand).include?(21)) && !(hand_value(player_hand).include?(21))
    loop do 
      dealer_hand << available_cards.shuffle.shift
      puts ''
      puts "=> Dealer's hand:"
      hand_display(dealer_hand)
      puts ''
      dealer_val = hand_value(dealer_hand)
      if dealer_val.select{|total| total < 17 }.empty?
        dealer_vals << dealer_val
        break
      end
    end

    # Compare dealer's values with those of player
    dealer_vals.flatten!
    player_vals.flatten!
    p dealer_vals

    dealer_vals.select!{|total| total <= 21}
    if dealer_vals.empty? then victor = "#{player_name}" end
    
    dealer_best = 0
    dealer_vals.each do |val|
      if val > dealer_best then dealer_best = val end
    end
    player_vals.select!{|total| (total <= 21) && (total > dealer_best)}
    if player_vals.empty?
      victor = "Dealer"
    else
      victor = "#{player_name}"
    end
  end
  puts ''
  puts "#{victor} wins!!!"
  puts ''
  puts "Play again? y) yes        press any other key to exit"
  puts "________________________________________________________________________"
  if gets.chomp.downcase != 'y' then break end
end
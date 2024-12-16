  #!/bin/bash

  # Database file
  DB_FILE="number_guessing_game.db"

  # Ensure database file exists
  if [[ ! -f $DB_FILE ]]; then
    touch $DB_FILE
  fi

  # Prompt for username
  echo "Enter your username:"
  read username

  # Validate username length
  if [[ ${#username} -gt 22 ]]; then
    echo "Username must be 22 characters or less."
    exit 1
  fi

  # Check if username exists in the database
  user_data=$(grep "^$username|" $DB_FILE)
  if [[ $user_data ]]; then
    games_played=$(echo "$user_data" | cut -d '|' -f2)
    best_game=$(echo "$user_data" | cut -d '|' -f3)
    echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
  else
    echo "Welcome, $username! It looks like this is your first time here."
    games_played=0
    best_game=99999
  fi

  # Generate random number
  secret_number=$((RANDOM % 1000 + 1))
  echo "Guess the secret number between 1 and 1000:"

  # Game logic
  number_of_guesses=0
  while true; do
    read guess
    if ! [[ $guess =~ ^[0-9]+$ ]]; then
      echo "That is not an integer, guess again:"
      continue
    fi

    ((number_of_guesses++))
    if ((guess < secret_number)); then
      echo "It's higher than that, guess again:"
    elif ((guess > secret_number)); then
      echo "It's lower than that, guess again:"
    else
      echo "You guessed it in $number_of_guesses tries. The secret number was $secret_number. Nice job!"
      break
    fi
  done

  # Update database
  ((games_played++))
  if ((number_of_guesses < best_game)); then
    best_game=$number_of_guesses
  fi

  # Save/update user data
  grep -v "^$username|" $DB_FILE > temp && mv temp $DB_FILE
  echo "$username|$games_played|$best_game" >> $DB_FILE

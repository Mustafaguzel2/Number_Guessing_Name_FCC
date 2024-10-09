#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read USERNAME

# Validate username length
while [ ${#USERNAME} -gt 22 ]
do
  echo "This username should be <= 22 characters. Please enter a new username:"
  read USERNAME
done

# Check if the user exists
USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
if [[ -z $USERNAME_RESULT ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  INSERT_NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate secret number
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Start guessing loop
echo "Guess the secret number between 1 and 1000:"
read GUESSED_NUMBER
GUESS_COUNT=1

while [[ $GUESSED_NUMBER -ne $SECRET_NUMBER ]]
do
  # Validate if the input is an integer
  if [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    # Check if the guess is higher or lower
    if [[ $GUESSED_NUMBER -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $GUESSED_NUMBER -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    fi
    # Increment guess count
    GUESS_COUNT=$(( GUESS_COUNT + 1 ))
  fi
  # Get new guess
  read GUESSED_NUMBER
done

# Correct guess
echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"

# Insert game record
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
INSERT_GAME_RECORD=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESS_COUNT)")

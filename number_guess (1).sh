#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guessing_game -t --no-align -c"

GET_USER(){

  echo "Enter your username:"

  #get username from input
  read USERNAME

  #check for existanse in db
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

  #if not exists
  if [[ -z $USER_ID ]]
  then
    
    #insert
    USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id from users WHERE username = '$USERNAME'")

    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    #if exists
      GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games LEFT JOIN users USING(user_id) WHERE user_id=$USER_ID")

      BEST_GAME=$($PSQL "SELECT MIN(tries) FROM games LEFT JOIN users USING(user_id) WHERE user_id=$USER_ID")

      echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

  fi

PLAY $USER_ID

}

PLAY(){
  #set random number variable from 1 to 100
  RANDOM_NUMBER=$((RANDOM%1000 + 1))

  #set tries variable = 0
  TRIES=0

  echo "Guess the secret number between 1 and 1000:"
  
  #read user input
  read INPUT

  until [[ $INPUT -eq $RANDOM_NUMBER ]]
  do

    #If anything other than an integer
    if [[ ! $INPUT =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"

      ((TRIES++))
      read INPUT
    fi

    if [[ $INPUT -lt $RANDOM_NUMBER ]]
    then
      #if number < random number variable
      echo "It's higher than that, guess again: $RANDOM_NUMBER"

      ((TRIES++))
      read INPUT
    else
      #if number > random number variable
      echo "It's lower than that, guess again:"

      ((TRIES++))
      read INPUT
    fi
  done

  #increase tries variable if first guess was true
  ((TRIES++))

  #if number guessed
  GAMES=$($PSQL "INSERT INTO games(user_id,tries) VALUES($1,$TRIES)")
  echo "You guessed it in $TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"
}


GET_USER



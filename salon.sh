#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

GREETINGS(){
  #greetings
  echo "Welcome to My Salon, how can I help you?"
}

MAIN_MENU() {

  #show available services
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")

  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

  #read user input & get service id
  read SERVICE_ID_SELECTED

  SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  

  if [[ -z $SERVICE_ID_SELECTED ]]
  then
    echo "I could not find that service. What would you like today?"

    #show available services
    MAIN_MENU
  else
    RENT_SERVICE $SERVICE_ID_SELECTED
  fi

}


RENT_SERVICE(){
  #service id from user input
  #echo $1

  #ask phone number
  echo "What's your phone number?"
  read CUSTOMER_PHONE
  #check if user exists
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  #if not exists
  if [[ -z $CUSTOMER_ID ]]
  then
    #ask name
    echo "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    #insert into customers (name, phone) if not
    NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi

  #get customer name
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $1")
  #ask time for service
  echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  #insert new appointment
  APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID, $1, '$SERVICE_TIME')")



  echo I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.

}

GREETINGS
MAIN_MENU
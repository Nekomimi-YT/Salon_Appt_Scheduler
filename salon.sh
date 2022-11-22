#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ Welcome to Schnipp-Schnapp Cuts ~~"

MAIN_MENU() {
  # Running MAIN_MENU with an argument will print the argument
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "\nChoose your salon service by menu number:\n"
  
  # Display a list of services with format: 1) cut, where 1 is the service_id
  # Get all rows in services table
  SERVICES=$($PSQL "SELECT * FROM services")
  # Count the number of rows
  SERVICES_COUNT=$($PSQL "SELECT COUNT(*) FROM services")
  # Display the menu
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  echo -e "\n"

  # Get selected service
  read SERVICE_ID_SELECTED
  # If service selected doesn't exist, show list again
  if [[ $SERVICE_ID_SELECTED > $SERVICES_COUNT+1 || ! $SERVICE_ID_SELECTED =~ ^[1-9]+$ ]]
  then
    MAIN_MENU "***Sorry, but that is not a valid menu number***"
  else
    # Get customer phone number
    echo -e "\nLet's get that booked.  What is your phone number?"
    read CUSTOMER_PHONE
    # If a phone number entered doesn’t exist
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]] 
    then
      echo -e "\nLooks like you are new here.  What's your name?"
      # Get the customers name 
      read CUSTOMER_NAME
      # Insert phone number and name into the customers table
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    fi
    
    # Get appt time
    echo -e "\nWhat time would you like to come in? (For example, 10:00am or 6:30pm)"
    read SERVICE_TIME
    # Query customer ID from phone number and insert appointment
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    # Confirm appt prompt
    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    
    # Formatting variables to remove spaces
    SERVICE_NAME_SELECTED_FORMATTED=$(echo $SERVICE_NAME_SELECTED | sed -E 's/^ *| *$//')
    SERVICE_TIME_FORMATTED=$(echo $SERVICE_TIME | sed -E 's/^ *| *$//')
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//')
    # Print appt confirmation
    echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED_FORMATTED at $SERVICE_TIME_FORMATTED, $CUSTOMER_NAME_FORMATTED."
  fi
}

MAIN_MENU




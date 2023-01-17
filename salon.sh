#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c";
echo -e '\n~~~Salon Appointment Scheduler~~~\n'

MAIN_MENU()
{
  if [[ ! -z $1 ]]
  then
    echo -e "\n***\n$1\n***";
  fi

  AVAILABLE_SERVICES="$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")";
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME ;
  
  do
    echo "$SERVICE_ID) $SERVICE_NAME";
  done
  
  read SERVICE_ID_SELECTED;
  SERVICE_ID_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED;");
  if [[ -z $SERVICE_ID_RESULT ]]
  then
    MAIN_MENU "Please, select a valid service from the list.";
  else
    echo -e "\nPlease, enter your phone number";
    read CUSTOMER_PHONE;
    PHONE_RESULT=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';");
    if [[ -z $PHONE_RESULT ]]
    then
      echo -e "\nPlease, enter your name";
      read CUSTOMER_NAME;
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE');");
    else
      CUSTOMER_NAME=$PHONE_RESULT
    fi
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';");
    echo -e "\nPlease, enter service time:"
    read SERVICE_TIME;
    APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME');");
    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;");
    echo -e "I have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU;
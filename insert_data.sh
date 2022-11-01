#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams,games")

cat games.csv |while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
if [[ $WINNER != "winner" ]] #skip first line of the file
 then #get winner id and opponent id and check if they are in the databse
 WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'" )
 OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'" )
  if [[ -z $WINNER_ID ]] #if not in the database insert
   then
   INSERT_WR=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
   if [[ $INSERT_WR == "INSERT 0 1" ]] #check for the insert result
     then
     echo inserted into teams:$WINNER
     fi
   WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'") #get the new id *will need to insert it in the games table*
   fi
 if [[ -z $OPPONENT_ID ]] #if not in the database insert
   then
   INSERT_OR=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
   if [[ $INSERT_OR == "INSERT 0 1" ]] #check for the insert result
     then
     echo inserted into teams:$OPPONENT
     fi
   OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'") #get the new id *will need to insert it in the games table*
   fi
fi
if [[ $YEAR != "year" ]] #skip the first line
 then
 #get the game id and check if it is in the database
 GAME_ID=$($PSQL "SELECT game_id FROM games WHERE winner_id=$WINNER_ID AND opponent_id=$OPPONENT_ID") 
 if [[ -z $GAME_ID ]]
   then
   INSERT_GR=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS)")
   if [[ $INSERT_GR == "INSERT 0 1" ]] #check the result of the inserted data
     then
     echo inserted into games:$YEAR,$ROUND,$WINNER,$OPPONENT,$WINNER_GOALS,$OPPONENT_GOALS
     fi
  fi
fi
done
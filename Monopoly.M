%Deciding whether the player will use Out of Jail cards (OOJCards), the
    %upper limit of moves, and the number of games to be played.
wantOut = false;
movesLimit = 250;
gamesLimit = 100;

%To compile all important data throughout all games
rawGamesData = zeros(49 , gamesLimit);

%Collecting data over various games
for currGame = 1:(gamesLimit)

    %Initializing all the variables affected by, but not created within, the "Game loop".
    nonJailJumps = 0;
    jailJumps = 0;
    location = 1;
    movesTot = 0;
    numDoubles = 0;
    move = 1;
    currDoubles = 0;
    inJail = false;
    jailCount = 0;
    jailCountTot = 0;
    jailCountVis = 0;
    isDouble = false;
    playerOOJHand = [0 , 0];
    playerOOJCards = 0;
    playerOOJCardsTot = 0;
    commChestOOJCard = true;
    chanceOOJCard = true;
    singleGameData = zeros(49 , 1);
    jailDoubleRoll = 0;

    %"Game loop".
    while (move <= movesLimit)

        %How each move begins.
        movesTot = movesTot + 1;
        dieOne = randi([1,6],1,1);
        dieTwo = randi([1,6],1,1);
        isDouble = (dieOne == dieTwo);
        rollVal = dieOne + dieTwo;
        location = mod((location + rollVal) , 40);

        %Ensuring the location is always valid.
        if (location == 0)
            location = 40;

        end
        
        %What to do if player begins turn IN jail, but can bail out.
        if ((inJail && wantOut) && (inJail && (playerOOJCards == 0)))
            chanceRoll = 1.7 * randi([1,movesLimit],1,1);
            leaveProb = chanceRoll / movesTot;
            inJail = (leaveProb > 1);
            jailCount = 0;
        end

        %What to do if player begins turn IN jail.
        if (inJail)

            %Counts how many turns the player spent imprisoned.
            jailCountTot = jailCountTot + 1;
            if (~isDouble && (~wantOut || (playerOOJCards == 0)) && (jailCount <= 3))
                location = 11;
                jailCount = jailCount + 1;
            end

            %This only applies if the player uses OOJ Cards. Note that IF an
                %OOJCard is used, any doubles rolled by the player will act as
                %normal, as the OOJCard is used at the beginning of their turn, or
                %not at all.
            if (wantOut && (playerOOJCards > 0))
                if (playerOOJCards == 2)
                    if (playerOOJHand(2) == 2)
                        chanceOOJCard = true;
                    else
                        commChestOOJCard = true;
                    end
                    playerOOJHand(2) = 0;
                else
                    if (playerOOJHand(1) == 2)
                        chanceOOJCard = true;
                    else
                        commChestOOJCard = true;
                    end
                    playerOOJHand(1) = 0;
                end
                playerOOJCards = playerOOJCards - 1;
                inJail = false;
                jailCount = 0;
            end

            %What to do if the player was previously imprisoned, but no longer is.
            %Note that isDouble is set to false, as players do not get an extra
                %toss for exiting jail via the toss of a double.
            if ((isDouble || (jailCount > 3)) && inJail)
                inJail = false;
                isDouble = false;
                jailCount = 0;
            end
        end

        %What to do if a player rolls a double OUTSIDE of jail.
        if (isDouble && ~inJail)

            %Since each of rolling consecutive doubles counts as the same move,
                %the move counter is simply backtracked by one each time.
            move = move - 1;
            numDoubles = numDoubles + 1;
            currDoubles = currDoubles + 1;

            %What to do if the player rolls three consecutive doubles.
            if (currDoubles == 3)
                inJail = true;
                location = 11;
                currDoubles = 0;
                jailDoubleRoll = jailDoubleRoll + 1;
                jailJumps = jailJumps + 1;
                

            end
        end   

        %Since a while loop is used, the move counter must be "manually"
            %incremented.
        move = move + 1;
        currVis = singleGameData(location);
        singleGameData(location) = currVis + 1;

        %What to do if the player lands on "GO TO JAIL".
        if (location == 31)
            location = 11;
            currVis = singleGameData(11);
            singleGameData(11) = currVis + 1;
            inJail = true;
            jailJumps = jailJumps + 1;
        end

        %What to do if the player lands on Community Chest.
        if ((location == 3) || (location == 18) || (location == 34))
            cont = true;
            while(cont)
                rand = randi([1,16],1,1);

                %If the card reads "GO TO JAIL".
                if (rand == 1)
                    location = 11;
                    currVis = singleGameData(11);
                    singleGameData(11) = currVis + 1;
                    inJail = true;
                    cont = false;
                    jailJumps = jailJumps + 1;
                end

                %If the card reads "GO TO GO".
                if (rand == 2)
                    location = 1;
                    currVis = singleGameData(1);
                    singleGameData(1) = currVis + 1;
                    cont = false;
                    nonJailJumps = nonJailJumps + 1;
                end

                %If the card is a "GET OUT OF JAIL" card.
                if ((rand == 16) && commChestOOJCard)
                    if (playerOOJCards == 0)
                        playerOOJHand(1) = 1;
                    else
                        playerOOJHand(2) = 1;
                    end
                    cont = false;
                    commChestOOJCard = false;
                    playerOOJCards = playerOOJCards + 1;
                    playerOOJCardsTot = playerOOJCardsTot + 1;
                end

                %If the card involves transacting money.
                if ((rand > 2) && (rand < 16))
                    cont = false;
                end
            end
        end

        %What to do if the player lands on Chance.
        if ((location == 8) || (location == 23) || (location == 37))
            cont = true;
            while (cont)
                r = randi([1,16],1,1);

                %If the card is a "GO TO JAIL" card.
                if (r == 1)
                    location = 11;
                    currVis = singleGameData(11);
                    singleGameData(11) = currVis + 1;
                    inJail = true;
                    cont = false;
                    jailJumps = jailJumps + 1;
                end

                %If the card is "GOTO [first train]".
                if (r == 2)
                    location = 6;
                    currVis = singleGameData(6);
                    singleGameData(6) = currVis + 1;
                    cont = false;
                    nonJailJumps = nonJailJumps + 1;
                end

                %If the card is "GOTO [nearest train]".
                if ((r == 3) || (r == 4))

                    %When player is on first chance tile.
                    if (location == 8)
                        location = 16;
                        currVis = singleGameData(16);
                        singleGameData(16) = currVis + 1;
                        cont = false;
                        nonJailJumps = nonJailJumps + 1;
                    end

                    %When player is on second chance tile.
                    if (location == 23)
                        location = 26;
                        currVis = singleGameData(26);
                        singleGameData(26) = currVis + 1;
                        cont = false;
                        nonJailJumps = nonJailJumps + 1;
                    end

                    %When player is on third chance tile.
                    if (location == 37)
                        location = 6;
                        currVis = singleGameData(6);
                        singleGameData(6) = currVis + 1;
                        cont = false;
                        nonJailJumps = nonJailJumps + 1;
                    end
                end

                %If the card is "GO BACK 3 SPACES".
                if (r == 5)
                    location = location + 40 - 3;
                    location = mod(location , 40);
                    if (location == 0)
                        location = 1;
                    end
                    currVis = singleGameData(location);
                    singleGameData(location) = currVis + 1;
                    cont = false;
                    nonJailJumps = nonJailJumps + 1;
                end

                %If the card is "GO TO GO".
                if (r == 6)
                    location = 1;
                    currVis = singleGameData(1);
                    singleGameData(1) = currVis + 1;
                    cont = false;
                    nonJailJumps = nonJailJumps + 1;
                end

                %If the card is "GO TO [the third red property]".
                if (r == 7)
                    location = 25;
                    currVis = singleGameData(25);
                    singleGameData(25) = currVis + 1;
                    cont = false;
                    nonJailJumps = nonJailJumps + 1;
                end

                %If the card is "GO TO BOARDWALK".
                if (r == 8)
                    location = 40;
                    currVis = singleGameData(40);
                    singleGameData(40) = currVis + 1;
                    cont = false;
                    nonJailJumps = nonJailJumps + 1;
                end

                %If the card is "GO TO [the first magenta property]".
                if (r == 9)
                    location = 12;
                    currVis = singleGameData(12);
                    singleGameData(12) = currVis + 1;
                    cont = false;
                    nonJailJumps = nonJailJumps + 1;
                end

                %If the card is "GOTO NEAREST UTILITY".
                if (r == 10)
                    if ((location == 8) || (location == 37))
                        location = 13;
                        currVis = singleGameData(13);
                        singleGameData(13) = currVis + 1;
                        cont = false;
                        nonJailJumps = nonJailJumps + 1;
                    else
                        location = 29;
                        currVis = singleGameData(29);
                        singleGameData(29) = currVis + 1;
                        cont = false;
                        nonJailJumps = nonJailJumps + 1;
                    end
                end

                %If the card involves transacting money.
                if ((r > 10) && (r < 16))
                    cont = false;
                end

                %If the card is a "GET OUT OF JAIL".
                if ((r == 16) && chanceOOJCard)
                    if (playerOOJCards == 0)
                        playerOOJHand(1) = 2;
                    else
                        playerOOJHand(2) = 2;
                    end
                    cont = false;
                    chanceOOJCard = false;
                    playerOOJCards = playerOOJCards + 1;
                    playerOOJCardsTot = playerOOJCardsTot + 1;
                end
            end
        end

        %Counts how many turns the player VISITED jail.
        if (~inJail && (location == 11))
            jailCountVis = jailCountVis + 1;
        end
    end
    move = movesLimit;
    totVisits = 0;

    %Adding up the total visits made in the game.
    for j = 1:40
        totVisits = totVisits + singleGameData(j);
    end

    %Loading post-game data.
    singleGameData(41) = numDoubles;
    singleGameData(42) = jailDoubleRoll;
    singleGameData(43) = jailJumps;
    singleGameData(44) = nonJailJumps;
    singleGameData(45) = jailCountVis;
    singleGameData(46) = jailCountTot;
    singleGameData(47) = playerOOJCardsTot;
    singleGameData(48) = movesTot;
    singleGameData(49) = totVisits;

    %Compiling the game data.
    rawGamesData(: , (currGame)) = singleGameData;
end %Closing data collection.

allGamesStats = zeros(49 , (gamesLimit));
for i2 = 1:49
    for j2 = 1:(gamesLimit)
        if (i2 <= 40)
            allGamesStats(i2 , j2) = (rawGamesData(i2 , j2) / rawGamesData(49 , j2));
        end
        if (i2 == 41)
            allGamesStats(i2 , j2) = ((rawGamesData(i2 , j2)) / (rawGamesData(48 , j2)));
        end
        if ((i2 == 42) || (i2 == 43) || (i2 == 44))
            allGamesStats(i2 , j2) = (rawGamesData(i2 , j2) / (rawGamesData(43 , j2) + rawGamesData(44 , j2)) );
        end
        if (i2 == 45)
            allGamesStats(i2 , j2) = (rawGamesData(i2 , j2) / rawGamesData(46 , j2));
        end
        if (i2 == 46)
            allGamesStats(i2 , j2) = (1 - allGamesStats(45 , j2));
        end
        if (i2 > 46)
            allGamesStats(i2 , j2) = rawGamesData(i2 , j2);
        end
    end
end

overallGamesStats = zeros(49 , 1);
for i3 = 1:49
    interm = 0;
    
    for j3 = 1:gamesLimit
        interm = interm + allGamesStats(i3 , j3);
    end
    
    overallGamesStats(i3) = interm / gamesLimit;
    
end

intermArray = zeros(49,2);
intermArray(: , 2) = overallGamesStats(:);
finalStats = string(intermArray);

for k3 = 1:40
    finalStats(k3 , 1) = "Probability of landing on tile " + k3;
end

finalStats(41 , 1) = "Probability of rolling a double";
finalStats(42 , 1) = "Probability of rolling 3 consecutive doubles";
finalStats(43 , 1) = "Probability of going to jail via a card";
finalStats(44 , 1) = "Probability of going anywhere BUT jail via a card";
finalStats(45 , 1) = "Chances of visiting jail";
finalStats(46 , 1) = "Fraction of turns spent in jail";
finalStats(47 , 1) = "Average number of 'GET OUT OF JAIL CARDS' received";
finalStats(48 , 1) = "Average number of dice rolls";
finalStats(49 , 1) = "Average number of tiles visited";

%finalStats

Y = zeros(40 , 1);
for i4 = 1:40
    Y(i4) = finalStats(i4 , 2);
end
bar(Y)

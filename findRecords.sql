/* Get the total number of records in the player table */
SELECT COUNT(*) as total
FROM player_mast;

/* Display all records in the players table */
SELECT *
FROM player_mast;

/* Get the number of countries that participated in Euro Cup 2016 */
SELECT COUNT(*) as total
FROM soccer_team;

/* How many goals were scored during extra time (ET) in the entire tournament? */
SELECT COUNT(*) as total
FROM goal_details
WHERE goal_schedule='ET';

/* How many goals were scored during stoppage time (ST) in the entire tournament? */
SELECT COUNT(*) as total
FROM goal_details
WHERE goal_schedule='ST';

/* How many goals were scored during normal time (NT) in the entire tournament? */
SELECT COUNT(*) as total
FROM goal_details
WHERE goal_schedule='NT';

/* Get the number of bookings that happened during stoppage time */
SELECT COUNT(*) as total
FROM player_booked
WHERE play_schedule='ST';

/* Get the number of bookings that happened during extra time */
SELECT COUNT(*) as total
FROM player_booked
WHERE play_schedule='ET';

/* Get the date when the first match was played in Euro Cup 2016 */
SELECT play_date
FROM match_mast
WHERE match_no = (
    SELECT MIN(match_no)
    FROM match_mast
);

/* Get the date when the last match was played in Euro Cup 2016 */
SELECT play_date
FROM match_mast
WHERE match_no = (
    SELECT MAX(match_no)
    FROM match_mast
);

/* Get names of countries whose teams played the first match in Euro Cup 2016 */
SELECT soccer_country.country_name
FROM soccer_country, soccer_team, match_details
WHERE soccer_country.country_id=soccer_team.country_id
AND match_details.match_no = (
    SELECT MIN(match_details.match_no)
    FROM match_details
)
AND soccer_team.team_id=match_details.team_id
GROUP BY soccer_country.country_name;

/* Get name of country whose team won the final match of Euro Cup 2016 */
SELECT soccer_country.country_name
FROM soccer_country, soccer_team, match_details
WHERE soccer_country.country_id=soccer_team.country_id
AND match_details.match_no = (
    SELECT MAX(match_details.match_no)
    FROM match_details
)
AND soccer_team.team_id=match_details.team_id
AND match_details.win_lose='W';

/* Get names of countries with the number of penalty shots by their teams */
SELECT soccer_country.country_name, SUM(total) as quantity
FROM soccer_country, (
    SELECT soccer_team.country_id as country, SUM(amount) as total
    FROM soccer_team, (
        SELECT penalty_shootout.team_id AS team, COUNT(penalty_shootout.team_id) AS amount
        FROM penalty_shootout
        GROUP BY penalty_shootout.team_id
    )
    WHERE soccer_team.team_id=team
    GROUP BY soccer_team.country_id
)
WHERE soccer_country.country_id=country
GROUP BY soccer_country.country_name;

/* Get names of countries whose teams played the final match of Euro Cup 2016 */
SELECT soccer_country.country_name
FROM soccer_country
WHERE soccer_country.country_id
IN (
    SELECT soccer_team.country_id
    FROM soccer_team
    WHERE soccer_team.team_id
    IN (
        SELECT match_details.team_id
        FROM match_details
        WHERE match_details.play_stage='F'
    )
);

/* Use a subquery with IN operator to get the dates when matches with penalty shootouts were played */
SELECT match_mast.play_date
FROM match_mast
WHERE match_mast.match_no
IN (
    SELECT penalty_shootout.match_no
    FROM penalty_shootout
);

/* Get names of venues where penalty shootout matches were played */
SELECT soccer_venue.venue_name
FROM soccer_venue
WHERE soccer_venue.venue_id
IN (
    SELECT match_mast.venue_id
    FROM match_mast
    WHERE match_mast.match_no
    IN (
        SELECT penalty_shootout.match_no
        FROM penalty_shootout
    )
);

/* Get the total number of players of the French team that participated in the final match */
SELECt COUNT(*) + 11 as total
FROM player_in_out
WHERE player_in_out.in_out='I'
AND player_in_out.match_no
IN (
    SELECT match_mast.match_no
    FROM match_mast
    WHERE match_mast.play_stage='F'
)
AND player_in_out.team_id
IN (
    SELECT soccer_team.team_id
    FROM soccer_team
    WHERE soccer_team.country_id
    IN (
        SELECT soccer_country.country_id
        FROM soccer_country
        WHERE soccer_country.country_name='France'
    )
);

TERMINATE;

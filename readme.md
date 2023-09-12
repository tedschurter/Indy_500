### About

<br>

##### This repository includes a script used to gather and clean data to compile historic records of the Indianapolis 500 and the resulting data files used to create a series of [visualizations](https://www.tedschurter.com/data/indianapolis-500) about the top three winners back to 1911.

<br>

##### The data for this project was scraped using RVest from three websites: the [Indianapolis Motor Speedway's](https://www.indianapolismotorspeedway.com/events/indy500/history/historical-stats/race-stats/race-results/2023) historical stats page, [ESPN.com](https://www.espn.com/racing/results/_/series/indycar)'s race results page and [racingnews.com](https://racingnews365.com/starting-grid-for-the-2023-indy-500)'s starting grid page for the 2023 Indy 500. 

<br>

##### The R script for the scraping and cleaning is [here](https://github.com/tedschurter/Indy_500/blob/main/scripts/20230722_scrape_speedway_data.R).

<br>

##### The aggregated, clean data is found in three separate files:


**Filename** | **Associated script** | **Description** 
:---|:---|:---|
[fastest_lap.csv](https://github.com/tedschurter/Indy_500/blob/main/clean_data/fastest_lap.csv)|[20230722_scrape_speedway_data.R](https://github.com/tedschurter/Indy_500/blob/main/scripts/20230722_scrape_speedway_data.R)|Year, car, driver, lap, lap time and speed of fastest laps for Indy 500's from 1951 - 2022.
[historic_box_scores.csv](https://github.com/tedschurter/Indy_500/blob/main/clean_data/historic_box_scores.csv)|[20230722_scrape_speedway_data.R](https://github.com/tedschurter/Indy_500/blob/main/scripts/20230722_scrape_speedway_data.R)|Year, finish, start, car, driver, team, make and model, laps, status and prize money data for Indy 500's from 1911 - 2023.
[race_summaries.csv](https://github.com/tedschurter/Indy_500/blob/main/clean_data/race_summaries.csv)|[20230722_scrape_speedway_data.R](https://github.com/tedschurter/Indy_500/blob/main/scripts/20230722_scrape_speedway_data.R)|Year, start, finish, car, driver, make and model, qualifying speed, race time and race speed for Indy 500's from 1911 to 2022.


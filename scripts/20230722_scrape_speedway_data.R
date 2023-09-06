library(tidyverse)
library(rvest)
library(janitor)
#library(V8)


# Scrape Indy 500 data to create record of race summaries and other data from 1911 
# to present. Most data gathered from www.indianapolismotorspeedway.com with most recent 
# data from espn.com and racingnews365.com



# race summaries ####
# url for race summaries data of winner by year through 2022
r_sum_url <- "https://www.indianapolismotorspeedway.com/events/indy500/history/historical-stats/race-stats/summaries/indianapolis-500-race-summaries"

# dataframe for race summaries data
r_sum <- data.frame(read_html(r_sum_url) %>% 
  html_table())

# remove extra spaces in Driver column and other character columns
r_sum <- r_sum %>% mutate(across(where(is.character), ~ str_squish(.)))

# Removing 'Car.Name.Entrant' column that isn't helpful - similar information available as separate
# columns in box summaries and can be cross referenced as needed. 

r_sum$Car.Name.Entrant. <- NULL

# clean column names
r_sum <- clean_names(r_sum)

# check drivers for duplicates
r_sum %>% distinct(driver) 

# Al User Jr. needs to be corrected to Al Unser Jr. 
r_sum[29,5] <- "Al Unser Jr."


# write as csv
write_csv(r_sum, "clean_data/race_summaries.csv")

# fastest lap ####
# fastest laps url
f_lap_url <- "https://www.indianapolismotorspeedway.com/events/indy500/history/historical-stats/race-stats/summaries/fastest-race-lap"

# dataframe for fastest laps
f_lap <- data.frame(read_html(f_lap_url) %>% 
                      html_table())

# clean column names
f_lap <- clean_names(f_lap)


# can see a tie in row 40. Anywhere else?
str_detect(f_lap$car, "[\\s]")

# no, just there. 
view(f_lap[40,])

f_lap[40,] # both Emerson Fittipaldi and Arie Luyendyk posted same 222.574 speed

# extract first entry 
f_lap_a <- data.frame(str_extract_all(f_lap[40,], "^[^\\n]*"))

# rename colnames of f_lap_a using column names of existing f_lap dataframe
colnames(f_lap_a) <- colnames(f_lap)

#f_lap_a <- f_lap_a %>% mutate(across(2:6, ~ str_remove(., pattern = "\\n")))

f_lap <- rbind(f_lap, f_lap_a)

# extract elements behind \n marker
f_lap_b <- str_extract_all(f_lap[40,], "(?<=\\n).*")
# not pulling year as in above so can't automatically send to data.frame

# add year
f_lap_b[1] <- 1990

# convert to dataframe
f_lap_b <- data.frame(f_lap_b)
# fix column names
colnames(f_lap_b) <- colnames(f_lap)

# remove extra spaces from columns 2:6
f_lap_b <- f_lap_b %>% mutate(across(2:6, ~ str_squish(.)))

# add to f_lap dataframe
f_lap <- rbind(f_lap, f_lap_b)

# clean up 
rm(f_lap_a, f_lap_b)

# remove redundant row
f_lap <- f_lap[-40,] 

# reformat columns to appropriate type
f_lap <- f_lap %>% mutate(across(c(1,2,4), as.numeric)) 

write_csv(f_lap, "clean_data/fastest_lap.csv")




# lap leaders url
l_leader_url <- "https://www.indianapolismotorspeedway.com/events/indy500/history/historical-stats/race-stats/summaries/all-time-lap-leaders"

# dataframe for lap leaders
l_leader <- data.frame(read_html(l_leader_url) %>% 
                         html_table())

# margin of victory url
m_vic_url <- "https://www.indianapolismotorspeedway.com/events/indy500/history/historical-stats/race-stats/summaries/margin-of-victory"

m_vic <- data.frame(read_html(m_vic_url) %>% 
                      html_table())


# create and run loop to create dataframe with box score summaries for every race listed back to 1911

# base url 
base_url <- "https://www.indianapolismotorspeedway.com/events/indy500/history/historical-stats/race-stats/box-scores/"

# vector of years from 1911:2022 - 2023 data not yet posted
yrs <- seq(1911, 2022, by = 1)

# no races in 1917:1918 and 1942:1945 
# vector of years with no races
cancelled <- c(1917, 1918, 1942, 1943, 1944, 1945)

# filter cancelled years out
yrs <- yrs[!(yrs %in% cancelled)]

# run loop for years 1911 to 2022 collecting data for each year and assembling into dataframe
for(i in 1:length(yrs)){
  
  # year <- yrs[i]
  
  b_score <- data.frame(read_html(paste0(base_url, yrs[i])) %>% 
                          html_node("table") %>% 
                          html_table()) %>% 
    mutate(year = yrs[i], .before = "Finish")
  
  if (yrs[i] == 1911) {
    b_score_2 <- b_score
  } else {
    b_score_2 <- rbind(b_score_2, b_score)
  }
  
}

# clean up unneeded dataframe and rename b_score_2
rm(b_score)
b_score <- b_score_2
rm(b_score_2)

# 2023 data ####
#  2023 data not available on Indy site as a box score. Looking around, simaliar 
# results can be found below:


# current year results url
c_make_url <- "https://www.espn.com/racing/raceresults/_/series/indycar/raceId/202305280106"

# dataframe with results but also engine manufacturer
c_make <- data.frame(read_html(c_make_url) %>% 
  html_table(header = NA))

# move row 2 to column names and remove as row
c_make <- row_to_names(c_make,row_number = 2, remove_row = T) %>% 
  # select needed rows
  select(1:6)

# rename column names to match larger dataframe for eventual join
colnames(c_make) <- c("Finish", "Driver", "car", "Make.Model", "Laps", "Start")

# still need the team names for 2023 race to match older data

# url with list of 2023 team entries
c_teams_url <- "https://racingnews365.com/starting-grid-for-the-2023-indy-500"

# create data frame of teams
c_teams <- data.frame(read_html(c_teams_url)  %>% 
             html_node("table") %>% 
             html_table(header = NA)) %>% 
  select(Position, Driver, Team) %>% 
  rename("Start" = "Position")

# compare column names and structure
compare_df_cols(c_teams, c_make)

# need to convert c_make Start column to integer
c_make$Start <- as.integer(c_make$Start)

nrow(c_make)  # 33 variables
nrow(c_teams) # 33 variables

# check for differences using anti_join
anti_join(c_make, c_teams)
# Finish       Driver car Make.Model Laps Start
# 1      4   Álex Palou  10      Honda  200     1
# 2     10 Rinus VeeKay  21  Chevrolet  200     2
# 3     24  Pato O'Ward   5  Chevrolet  192     5
# 4     32   RC Enerson  50  Chevrolet   75    28

# a few Driver names have slight variations 

# check for differences joining by start column
anti_join(c_make, c_teams, by = "Start")
# [1] Finish     Driver     car        Make.Model Laps       Start     
# <0 rows> (or 0-length row.names)

# joining by Start includes all

# join c_make and c_teams by Start
last_race <- inner_join(c_make, c_teams, by = "Start") %>% 
  mutate(year = 2023, .before = Finish) %>% 
  select(1:7, 9)

# rename columns
colnames(last_race) <- c("year", "Finish", "Driver", "car", "Make.Model", "Laps", 
                         "Start", "Team")


# check structure
str(last_race)

# change car, finish and laps columns to integer

last_race$car <- as.integer(last_race$car)
last_race$Finish <- as.integer(last_race$Finish)
last_race$Laps <- as.integer(last_race$Laps)

# clean column names
last_race <- clean_names(last_race)
b_score <- clean_names(b_score)

# prepare for joining two dataframes

# compare column names and types
compare_df_cols(b_score, last_race)



# adjust order of last_race and add placeholder columns to match - ie status, 
# prize_money
last_race <- last_race %>% 
  select(year, finish, start, car, driver, team, make_model, laps) %>% 
  mutate(status = NA,
         prize_money = NA)

# duplicate column names across dataframes


# replace b_score column names with column names from last_race dataframe
colnames(b_score) <- colnames(last_race)

compare_df_cols(last_race, b_score)
# column_name last_race   b_score
# 1          car   integer   integer
# 2       driver character character
# 3       finish   integer   integer
# 4         laps   integer   integer
# 5   make_model character character
# 6  prize_money   logical character
# 7        start   integer   integer
# 8       status   logical character
# 9         team character character
# 10        year   numeric   numeric


# merge current data to historic box score dataframe
hist_box <- rbind(last_race, b_score) %>% 
  arrange(desc(year))

write_csv(hist_box, "clean_data/historic_box_scores.csv")

# clean up unneeded dataframes used to make hist_box 
rm(c_make, c_teams, b_score, last_race)







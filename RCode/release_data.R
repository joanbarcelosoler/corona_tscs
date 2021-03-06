# Use this code to generate data for the visualization
# First run cleanQualtrics_short.R
# Bob Kubinec

require(dplyr)
require(readr)
require(readxl)
require(stringr)
require(idealstan)
require(lubridate)
require(tidyr)

# update all githubs

system2("git",args=c("-C ~/covid-tracking-data","pull"))
system2("git",args=c("-C ~/covid-19-data","pull"))
system2("git",args=c("-C ~/covid19_tests","pull"))
system2("git",args=c("-C ~/COVID-19","pull"))

# covid test data

covid_test <- read_csv("~/covid19_tests/data_snapshots/covid_tests_last.csv") %>% 
  select(ISO3,Date,tests_raw="Tests_raw",
         test_source="Source",
         test_notes="Notes",
         tests_date="Date_scraped",
         tests_daily_or_total="Daily_or_total") %>% 
  group_by(Date,ISO3,tests_daily_or_total) %>% 
  summarize(tests_raw=mean(tests_raw,na.rm=T))

# cases/deaths

cases <- read_csv("~/COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv") %>% 
  select(-Lat, -Long,country="Country/Region") %>% 
  gather(key="date_announced",value="confirmed_cases",-`Province/State`,-country) %>% 
  mutate(date_announced=mdy(date_announced),
         country=recode(country,Czechia="Czech Republic",
                        `Hong Kong`="China",
                        `US`="United States of America",
                        `Taiwan*`="Taiwan",
                        `Bahamas`="The Bahamas",
                        `Tanzania`="United Republic of Tanzania",
                        `North Macedonia`="Macedonia",
                        `Micronesia`="Federated States of Micronesia",
                        `Burma`="Myanmar",
                        `Tanzania`="United Republic of Tanzania",
                        `Cote d'Ivoire`="Ivory Coast",
                        `Korea, South`="South Korea",
                        `Timor-Leste`="East Timor",
                        `Congo (Brazzaville)`="Republic of Congo",
                        `Congo (Kinshasa)`="Democratic Republic of the Congo",
                        `Cabo Verde`="Cape Verde",
                        `West Bank and Gaza`="Palestine",
                        `Eswatini`="Swaziland")) %>% 
  group_by(date_announced,country) %>% 
  summarize(confirmed_cases=sum(confirmed_cases,na.rm=T))
deaths <- read_csv("~/COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv") %>% 
  select(-Lat, -Long,country="Country/Region") %>% 
  gather(key="date_announced",value="deaths",-`Province/State`,-country) %>% 
  mutate(date_announced=mdy(date_announced),
         country=recode(country,Czechia="Czech Republic",
                        `Hong Kong`="China",
                        `US`="United States of America",
                        `Taiwan*`="Taiwan",
                        `Bahamas`="The Bahamas",
                        `Tanzania`="United Republic of Tanzania",
                        `North Macedonia`="Macedonia",
                        `Micronesia`="Federated States of Micronesia",
                        `Burma`="Myanmar",
                        `Tanzania`="United Republic of Tanzania",
                        `Cote d'Ivoire`="Ivory Coast",
                        `Korea, South`="South Korea",
                        `Timor-Leste`="East Timor",
                        `Congo (Brazzaville)`="Republic of Congo",
                        `Congo (Kinshasa)`="Democratic Republic of the Congo",
                        `Cabo Verde`="Cape Verde",
                        `West Bank and Gaza`="Palestine",
                        `Eswatini`="Swaziland")) %>% 
  group_by(date_announced,country) %>% 
  summarize(deaths=sum(deaths,na.rm=T))
recovered <- read_csv("~/COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv") %>% 
  select(-Lat, -Long,country="Country/Region") %>% 
  gather(key="date_announced",value="recovered",-`Province/State`,-country) %>% 
  mutate(date_announced=mdy(date_announced),
         country=recode(country,Czechia="Czech Republic",
                        `Hong Kong`="China",
                        `US`="United States of America",
                        `Taiwan*`="Taiwan",
                        `Bahamas`="The Bahamas",
                        `Tanzania`="United Republic of Tanzania",
                        `North Macedonia`="Macedonia",
                        `Micronesia`="Federated States of Micronesia",
                        `Burma`="Myanmar",
                        `Tanzania`="United Republic of Tanzania",
                        `Cote d'Ivoire`="Ivory Coast",
                        `Korea, South`="South Korea",
                        `Timor-Leste`="East Timor",
                        `Congo (Brazzaville)`="Republic of Congo",
                        `Congo (Kinshasa)`="Democratic Republic of the Congo",
                        `Cabo Verde`="Cape Verde",
                        `West Bank and Gaza`="Palestine",
                        `Eswatini`="Swaziland")) %>% 
  group_by(date_announced,country) %>% 
  summarize(recovered=sum(recovered,na.rm=T))

# niehaus data

niehaus <- read_csv("data/data_niehaus/03_21_20_0105am_wep.csv") %>% 
  group_by(country) %>% 
  fill(pop_WDI_PW:EmigrantStock_EMS,.direction="down") %>% 
  slice(n()) %>% 
  filter(!is.na(ifs)) %>% 
  select(country,ccode,ifs,pop_WDI_PW:EmigrantStock_EMS)


# load cleaned data

clean_data <- readRDS("data/CoronaNet/coranaNetData_clean.rds")

# severity index

severity <- readRDS("data/severity_fit.rds")

# output by countries

sev_data <- summary(severity) %>% 
  select(country="Person",severity_index_5perc=`Low Posterior Interval`,
         severity_index_median="Posterior Median",
         severity_index_95perc=`High Posterior Interval`,
         date_announced="Time_Point") %>% 
  mutate(country=recode(country,Czechia="Czech Republic",
                `Hong Kong`="China",
                `United States`="United States of America",
                `Bahamas`="The Bahamas",
                `Tanzania`="United Republic of Tanzania",
                `North Macedonia`="Macedonia",
                `Micronesia`="Federated States of Micronesia",
                `Timor Leste`="East Timor",
                `Republic of the Congo`="Republic of Congo",
                `Cabo Verde`="Cape Verde",
                `Eswatini`="Swaziland"))

# select only columns we need

release <- filter(clean_data,!is.na(init_country)) %>% 
              select(record_id,entry_type,event_description,type,country="init_country",
                     init_country_level,
                     index_prov,
                     target_country="target_country_region",
                     target_geog_level,
                     target_who_what,
                     recorded_date="RecordedDate",
                     target_direction,
                     travel_mechanism,
                     compliance,
                     enforcer,
                     date_announced,
                     link="sources_matrix_1_2") %>% 
  mutate(date_announced=lubridate::mdy(date_announced),
         entry_type=recode(entry_type,
                           `1`="New Entry",
                           `Correction`="Correction to Existing Entry (type in Record ID in text box)",
                           `Update`="Update on Existing Entry (type in Record ID in text box) ")) %>% 
  filter(!is.na(date_announced),
         recorded_date<(today()-days(5)))

# recode records

release$country <- recode(release$country,Czechia="Czech Republic",
                           `Hong Kong`="China",
                           `United States`="United States of America",
                           `Bahamas`="The Bahamas",
                           `Tanzania`="United Republic of Tanzania",
                           `North Macedonia`="Macedonia",
                           `Micronesia`="Federated States of Micronesia",
                           `Timor Leste`="East Timor",
                           `Republic of the Congo`="Republic of Congo",
                           `Cabo Verde`="Cape Verde",
                           `Eswatini`="Swaziland")

release$target_country <- recode(release$target_country,Czechia="Czech Republic",
                                  `Hong Kong`="China",
                                  `United States`="United States of America",
                                  `Bahamas`="The Bahamas",
                                  `Tanzania`="United Republic of Tanzania",
                                  `North Macedonia`="Macedonia",
                                  `Micronesia`="Federated States of Micronesia",
                                  `Timor Leste`="East Timor",
                                  `Republic of the Congo`="Republic of Congo",
                                  `Cabo Verde`="Cape Verde",
                                  `Eswatini`="Swaziland")

# country names

country_names <- read_xlsx("data/ISO WORLD COUNTRIES.xlsx",sheet = "ISO-names")

# try a simple join

release <- left_join(release,country_names,by=c("country"="ADMIN"))

missing <- filter(release,is.na(ISO_A2))

# we will get a warning because of the European Union

if(nrow(missing)>0) {
  
  warning("Country doesn't match ISO data.")
  
}

# Add in severity index

release <- left_join(release,sev_data,by=c("country","date_announced"))

# now output raw data for sharing

write_csv(release,"../CoronaNet/data/coronanet_release.csv")
write_csv(release,"data/CoronaNet/coronanet_release.csv")

# merge with other files

release_combined <- left_join(release,covid_test,by=c(ISO_A3="ISO3",
                                                      date_announced="Date")) %>% 
  left_join(deaths,by=c("country","date_announced")) %>% 
  left_join(cases,by=c("country","date_announced")) %>% 
  left_join(recovered,by=c("country","date_announced")) %>% 
  left_join(niehaus,by=c("country"))

write_csv(release_combined,"data/CoronaNet/coronanet_release_allvars.csv")
write_csv(release_combined,"../CoronaNet/data/coronanet_release_allvars.csv")

# copy raw data over

system("cp data/CoronaNet/coranaNetData_clean.rds ../CoronaNet/data/coranaNetData_clean.rds")

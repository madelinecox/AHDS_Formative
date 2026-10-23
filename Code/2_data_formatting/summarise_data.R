#Code to read in the new DEPO data, merge, tidy and summarise the data

#install.packages("this.path")
#install.packages("janitor")
library(this.path)
library(tidyverse)
library(haven)

datadir=paste0(this.dir(), "/../../Data/")

#read in demographics data with "haven" package for .xpt file
demo <- read_xpt(file = paste0(datadir, "original/DEMO_D.xpt"))
#note, demo data has 10348 rows so 10348-9950 = 398 more observations than body measurements data

#select rows of interest
demo_data <- demo |>
  select(SEQN, RIAGENDR, RIDAGEYR, RIDRETH1)

#read in BMX_D data
survey_data <- read_tsv(paste0(datadir, "derived/BMX_D.tsv"))

#tibble info told us that BMIHEAD is lgl (logical) 
#check what it contains, always means we get a count of NA even if 0
table(survey_data$BMIHEAD, useNA = "always")
#rename column 1 (automatically named "...1") to "X"
survey_data <- rename(survey_data, X=...1) #could also use a pipe

#reformat variables names of BMX_D and demographics data 
survey_data <- survey_data |> 
  janitor::clean_names()
demo_data <- demo_data |> 
  janitor::clean_names()

#merge the body measurement and demographics data, keeping rows from BMX_D
#and moving demo variables to start of data frame
full_data <- survey_data |>
  left_join(demo_data, by=join_by(seqn)) |> #could have left out "by=..."
  relocate(riagendr:ridreth1, .after = seqn)

#--------------------------TO UNDERSTAND THE DATA-------------------------------

#find out which participant IDs in demographics do not have body measurement data

#first right join so all observations for demo data kept
all_demo <- survey_data |>
  right_join(demo_data, by="seqn") 
#if you right join demo_data onto survey_data, all observations in survey_data 
#will be listed first followed by demo_data observations not in survey_data

#finding which rows in all_demo have NA for x 
#corresponds to rows without BMX data because x has has a value for every BMX entry
which(is.na(all_demo$x)) 
#the last 398 rows 
sum(is.na(all_demo$x)) #398 values = 398 observations not in body measurement data-frame
table(is.na(all_demo$x)) #and 9950 values with BMX data (as we already know)

#getting the participant IDS that do not have BMX_D data
all_demo |>
  filter(is.na(x)) |>
  select(seqn)

#this joins data so all participant IDS "in order" - demographic data controls order
all_demo_2 <- demo_data |>
  left_join(survey_data)
#will get the same set of participant IDs not in BMX_D data however
all_demo_2 |>
  filter(is.na(x)) |>
  select(seqn)

#-------------------------------------------------------------------------------

#read in the derived sample file 
sample <- read_csv(paste0(datadir, "derived/sample.csv"))

#merge into combined body measurement and demographics data
#both data sets contain exactly the same observations in the same order
#so left_join, right_join and full_join should produce the same outcome
full_data_sample <- full_data |>
  left_join(sample, by = c("seqn"="SEQN")) |>
  relocate(in_sample, .after=seqn)

#this way, the in_sample data automatically comes first
sample |>
  left_join(full_data, by = c("SEQN"="seqn"))

#create an obesity variable 
full_data_sample <- full_data_sample |>
  mutate(obesity = if_else(bmxbmi >= 30, 1, 0))

#SUMMARISE THE DATA

#What percentage of the people in the body measurement sample who are considered to
#have obesity also have activity monitor data? How does this compare to the people who are
#not considered to have obesity?
full_data_sample |>
  group_by(obesity) |>
  summarise(
    "%_has_accel" = mean(in_sample, na.rm = TRUE)*100,
    n = n()
  )

#OR (say if in_sample was not coded in 0 and 1 already)
full_data_sample |>
  filter(!is.na(obesity)) |>
  group_by(obesity) |>
  summarise(
    "%_has_accel" = 100*mean(in_sample == 1), #or 100*sum(in_sample == 1)/n()
    n = n()
  )

#What percentage of males have activity monitor data? How does this compare to females?
#first check if there are any NA values for gender
sum(is.na(full_data_sample$riagendr)) #0 - NO
#
full_data_sample |>
  group_by(riagendr) |>
  summarise(
    "%_has_accel" = mean(in_sample)*100,
    n = n()
  )
#male = 1, female = 2

#What is the maximum reported height in cm of a child under 16 in this sample?
full_data_sample |>
  filter(ridageyr < 16) |>
  slice_max(bmxht) |>
  relocate(bmxht, .before = 1)

#save full data sample as a file in derived data file
write_csv(full_data_sample, file = paste0(datadir, "derived/body_measurements.csv"))

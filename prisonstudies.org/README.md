#International Centre for Prison Studies

**Source**: [http://prisonstudies.org][1]

**Summary**: data about prison system around the world.

**Output**: 2 csv files

 1. **prisonstudies_countries.csv** : most up-to-date statistics about prison system in every country
 2. **prisonstudies_trends.csv** : trends about prison system over the past years in every country

**Requirements**:

 - [Ruby][2] installed
 - Gem nokogiri installed : `gem install nokogiri`

----------

###Structure of prisonstudies_countries.csv
 - **id:** the id of the country on the website (not really useful)
 - **name:** the name of the country on the website
 - **iso_a3:** the country code using ISO_ALPHA3 standard (much more useful)
 - **iso_name:** the country name using ISO standard
 - **pop_total:** number of people incarcerated in the country (including pre-trial detainees / remand prisoners)
 - **pop_rate:** rate of people incarcerated depending the country population (ex: 0.07 = 7%)
 - **pre_trial_rate:** pre-trial detainees / remand prisoners rate
 - **female_rate:** female prisoners rate
 - **minors_rate:** juveniles / minors / young prisoners
 - **foreigners_rate:** foreign prisoners
 - **establishments_number:** number of establishments / institutions
 - **official_capacity:** official capacity of prison system
 - **occupancy_level:** occupancy level
 - **source:** url where data can be found

###Structure of prisonstudies_trends.csv
 - **id:** the id of the country on the website (not really useful)
 - **iso_a3:** the country code using ISO_ALPHA3 standard (much more useful)
 - **iso_name:** the country name using ISO standard
 - **year:** year of trend
 - **pop_total:** number of people incarcerated in the country
 - **pop_rate:** rate of people incarcerated depending the country population
 - **source:** url where data can be found


  [1]: http://prisonstudies.org
  [2]: http://www.ruby-lang.org/
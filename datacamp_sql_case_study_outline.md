## Chapter 1 - Introduction to Polling and Exploring Data in SQL
   * Lesson 1.1 - Introduction to polling analysis and the Upshot dataset
     * A learning objective: Why do organizations commission polls?
       * Polling allows us to collect detailed information about a subset of people and draw insights about the broader population.
       * First, survey researchers collect responses to a survey from voters or consumers through online, live telephone, interactive voice response (IVR), or other mediums. Then, in order to correct for survey design biases, researchers apply more weight to answers from respondents who tend to answer surveys less often and more weight to people who are easier to contact. When both of these things are done well, we can generally extrapolate insights from a few hundred people to represent the views of the broader population they're drawn from. 
       * During the 2018 midterm elections in the United States, the New York Times' Upshot blog for data journalism commissioned a series of polls that we'll use 
   * Lesson 1.2 - Basic Exploratory Steps
     * A learning objective: Familiarize students with the Upshot dataset
       * Point out the three data tables in the database
         * horserace - a set of questions asked of all respondents including who you are voting for and how likely you are to vote. 
         * demographic - data on the age, race, gender, and education of respondents
         * issue - a set of questions about topics and legislation that are only asked in a subset of districts
       * Key columns to consider
         * respondent_id - a unique identifier for each individual respondent surveyed
         * district - two-letter state code and two-digit district number (some polls are from Senate and Governor's races)
         * poll_id - since some districts were polled twice, the poll_id tells us which poll we're reading
         * w_lv and w_rv - weights for comparing responses to a population of likely voters and registered voters respectively
     * Activity: Explore the data
       * Select all columns from the above tables using `limit 5` and read through the columns
       * Pick one or two columns and use `select distinct colname` to find all possible values
   * Lesson 1.3 - Exploring the data 
     * A learning objective: Join all tables to create a base file
       * Use an inner join to append demographics data to horserace data
       * Introduce the left and outer joins. 
     * Activity
       * Pick which type of join makes the most sense and create a temporary table combining all available data

## Chapter 2 - Summarising Data With Grouping and Aggregation
   * Lesson 2.1 - Working with Weighted Data
     * A learning objective: Assess the quality of weights for an individual poll (`where district = 'azse'`). 
       * They should be random, normally distributed, and average close to 1 within each survey.  
     * Activity
       * Find the average weight (either LV or RV)
       <!-- * Find the quintiles of the weight distribution (either LV or RV) -->
   * Lesson 2.2 - Aggregate the horserace question
     * A learning objective: Analyze one question of survey responses using percentages or the likely voter electorate.
     * Activity
       * Analyze senate support among the likely voter population (`select horserace, count(horserace)/sum(count(horserace)) over(horserace))
   * Lesson 2.3 - Go Deeper on Partitioning
     * A learning objective: Explore how partitions work
       * Window functions allow us to apply a function to some subset a table. 
       * In the last exercise, we added syntax to `partition by 'all'`, indicating we wanted to focus our calculations on the entire data set
       * Partitioning allows us to repeat our math separately for a variety of subsets of the data
     * Activity
       * Compare horserace numbers men vs. women
       * Calculate the percent of the electorate made of men and women who support either or none of the candidates
   * Lesson 2.4 - Exploring other questions
     * A learning objective: Explore the Upshot polling data for yourself
     * Activity
       * Pick one of the following questions to answer for yourself with aggregation and partitions:
         * What is the margin for the Democratic candidate in the VA-10th congressional district? hint(`district = 'va10'`)
         * How much did support for the Republican candidate in FL 26 move from the first poll to the second?

## Chapter 3 - Subqueries and Unions
   * Lesson 3.1 - Convert Gender Comparison to a Crosstab
     * A learning objective: Use subqueries to create two small tables and join them together
     * Activity: 
       * Calculate support in the VA 10 race for men, then do the same for women, then join the tables together using subqueries
   * Lesson 3.2 - Analyze the Quality of Weights in a Survey
     * A learning objective: Changing gears from analyzing the survey responses, lets do one more check to make sure the weights make sense. 
     * Activity: Use `ntile(5) over(order by w_lv)` and `ntile(5) over(order by w_rv)` to summarise the weight variables and make sure they're sensible
   * Lesson 3.3 - Compare Poll Movement for Re-Polled Districts
     * A learning objective: Use a list subquery and build on prior use of grouping and aggregating
     * Activity: 
       * Use a subquery to create a list of districts that have been polled twice (hint - each district-level poll had about 500 respondents) 
       * Calculate support by party for just the districts that were re-polled
   * Lesson 3.4 - Explore how President Trump impacts districts using with() statements
     * A learning objective: Write subqueries at the top of a query using with statements
     * Activity: 
       * Use a with subquery to create a list of poll_ids that ask `check_or_support` (hint - `where check_or_support != 'NA'`) and calculate responses by district
       * Join the with table to itself using subqueries to limit the table to support percentages first, then check percentages

## Chapter 4 - Case Statements and Unions
   * Lesson 4.1 - Using Case Statements to Create Categorical Variables
     * A learning objective: Create a categorical variable with a case statement
     * Activity: Calculate the number of local partisans (ie: support the Democrats in your district, but want Republicans to maintain control of the House).
   * Lesson 4.2 - Use Case Statements for individual calculations
     * A learning objective: Create a binary variable using case statements to calculate an individual statistic
     * Activity
       * First, recall how we calculated support for the Democrat and Republican in VA 10
       * Next, calculate just Democratic support in VA 10 as a crosstab
   * Lesson 4.3 - Unions
     * A learning objective: Use unions to combine two tables of cross tabbed results
     * Activity: Calculate the overall results as a crosstab, then calculate the results by gender and union the two tables together
   * Lesson 4.4 - Create a full set of Crosstabs
     * A learning objective: Add to 4.3 by specifying the order of each table in the union and create crosstabs for comparing election results by subgroup
     * Create crosstab tables for age, race (`race_eth`), and gender as well as the topline outcome. Put them in a specific order in the output query. 

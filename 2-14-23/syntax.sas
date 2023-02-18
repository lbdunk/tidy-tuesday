/* Tidy Tuesday - Week of 2/14/2021 */
/* Lily Dunk */
/* 2/16/23 */

/******************************************************************************
HOLLYWOOD AGE GAPS
*****************************************************************************/;

/* Research question: how much older is the average male actor than his female 
	costar? Does it follow a normal distribution? */

LIBNAME lib "&path.\tidy-tuesday\2-14-23\data";

/* Import survey data */
PROC IMPORT
	DATAFILE="&path.\tidy-tuesday\2-14-23\data\age_gaps.csv"
	OUT=lib.age_gaps
	DBMS=CSV REPLACE;
RUN;

/* Are all of these opposite-sex couples? */
PROC FREQ DATA=lib.age_gaps;
	TABLES character_1_gender*character_2_gender / NOROW NOCOL;
RUN;
/* 
No! Wow! Diversity!
Same-sex couples aren't relevant to the research question though, so remove 
	them :(
*/

DATA age_gaps2;
	SET lib.age_gaps;
	
	/* Remove same-sex couples :( */
	IF character_1_gender NE character_2_gender;

	/* Calculate actors' ages by gender */
	IF character_1_gender EQ "man" THEN DO;
		male_age = actor_1_age;
		female_age = actor_2_age;
	END;
	ELSE DO;
		male_age = actor_2_age;
		female_age = actor_1_age;
	END;

	age_diff_by_sex = male_age - female_age;
RUN;

/* Calculate mean difference, including median and quartiles */
PROC MEANS DATA=age_gaps2 MEAN STDDEV Q1 MEDIAN Q3;
	VAR age_diff_by_sex;
	ODS OUTPUT Summary=age_gaps_summary;
RUN;
PROC PRINT DATA=age_gaps_summary NOOBS LABEL;
	LABEL age_diff_by_sex_Mean = "Mean"
		age_diff_by_sex_StdDev = "St. Dev."
		age_diff_by_sex_Q1 = "Q1"
		age_diff_by_sex_Median = "Median"
		age_diff_by_sex_Q3 = "Q3";
	FORMAT age_diff_by_sex_Mean age_diff_by_sex_StdDev 8.2
		age_diff_by_sex_Q1--age_diff_by_sex_Q3 8.;
RUN;
/* Mean and median aren't that far apart but the standard deviation seems huge.
	What's going on? */

GOPTIONS RESET=ALL;
ODS LISTING GPATH="&path.\tidy-tuesday\2-14-23\output\" IMAGE_DPI=300;
ODS GRAPHICS / IMAGENAME="Hollywood age gaps &SYSDATE9." IMAGEFMT=PNG;
TITLE "Male actors are, on average, 7 years older than female actors in opposite-sex on-screen relationships.";
PROC SGPLOT DATA=age_gaps2 NOAUTOLEGEND;
	HISTOGRAM age_diff_by_sex / DATALABEL=COUNT SHOWBINS;
	DENSITY age_diff_by_sex;
	YAXIS LABEL="Percent of on-screen relationships";
	XAXIS LABEL="Age difference between male and female actors";
RUN;
TITLE;

/* Research questions:
	How much older is the average male actor than his female costar? 
		7 years (median)
	Does it follow a normal distribution?
		Yes! Slightly left-skewed, but overall very normal.
*/
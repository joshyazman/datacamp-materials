/* Load data into redshift from csv*/
drop table if exists jyazman.horserace;
create table jyazman.horserace (
        respondent_id varchar(100)
        , district varchar(100)
        , poll_id varchar(100)
        , w_lv float
        , w_rv float
        , phone_type varchar(100)
        , response varchar(100)
        , trump_approve varchar(100)
        , genballot varchar(100)
        , hdem_fav varchar(100)
        , hrep_fav varchar(100)
        , vote_propensity varchar(100)
);

copy jyazman.horserace
from 's3://jyazman-scratch-scratch/horserace.csv' 
credentials 'aws_access_key_id=AKIAJOJRELCRFDS7KK4Q;aws_secret_access_key=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'
delimiter ',' 
removequotes
ignoreheader 1
blanksasnull
;

select * from jyazman.horserace limit 5;

drop table if exists jyazman.demographics;
create table jyazman.demographics (
        respondent_id varchar(1000)
        , district varchar(1000)
        , poll_id varchar(1000)
        , w_lv float
        , w_rv float
        , race_eth varchar(1000)
        , gender varchar(1000)
        , age varchar(1000)
        , education varchar(1000)
        , party varchar(1000)
        , region varchar(1000)
        , turnout varchar(1000)
);

copy jyazman.demographics
from 's3://jyazman-scratch-scratch/demographics.csv' 
credentials 'aws_access_key_id=AKIAJOJRELCRFDS7KK4Q;aws_secret_access_key=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'
delimiter ',' 
removequotes
ignoreheader 1
blanksasnull
;

select * from jyazman.demographics limit 5;

drop table if exists jyazman.issues;
create table jyazman.issues (
        respondent_id varchar(100)
        , district varchar(100)
        , poll_id varchar(100)
        , w_lv float
        , w_rv float
        , birthright_citizenship varchar(100)
        , check_or_support varchar(100)
);

copy jyazman.issues
from 's3://jyazman-scratch-scratch/issues.csv' 
credentials 'aws_access_key_id=AKIAJOJRELCRFDS7KK4Q;aws_secret_access_key=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'
delimiter ',' 
removequotes
ignoreheader 1
blanksasnull
;

select * from jyazman.issues limit 5;

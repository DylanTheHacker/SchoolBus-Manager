create table users(
No serial primary key,
userID varchar(20) not null unique,
userName varchar(32) not null,
userPwd varchar(32) not null,
busarray text,
selectbusid varchar(32),
address varchar(255) not null,
accessToken varchar(36)
);

create table drivers(
No serial primary key,
driverID varchar(20) not null unique,
driverName varchar(32) not null,
driverPwd varchar(32) not null,
address varchar(255),
accessToken varchar(36)
);

create table bus(
No serial primary key,
busid varchar(20) not null unique,
driverPwd varchar(32) not null,
driverID varchar(20) not null,
useridlist text,
busname varchar(32)
);

create table absent(
absentdate date not null unique,
absentuserid varchar(20) not null
);







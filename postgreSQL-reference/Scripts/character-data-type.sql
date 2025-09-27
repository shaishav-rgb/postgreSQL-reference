create table characterDemo(character char(5),varyingcharacter varchar(5),textcharacter text);

--cannot INSERT IN both char(5) and varchar(5)
INSERT INTO characterdemo VALUES ('abcsdfsdfsdfsdf', 'abcdefffffff', 'abcdef');  

--can insert in both char(5) and varchar(5), in both space gets trimmed
INSERT INTO characterdemo VALUES ('abc           ', 'abcde               ', 'abcdef');

INSERT INTO characterdemo VALUES ('xxx                           ', 'xxx                         ', 'abcdef');

--no rows match as space gets trimmed when matching in char(5) but space is retained in varchar(5)
select * from characterdemo where character='xxx' and varyingcharacter='xxx';
--ROWS match space is retained in varchar(5)
select * from characterdemo where character='xxx' and varyingcharacter='xxx  ';
--rows match as space gets trimmed when matching in char(5)
select * from characterdemo where character='x'
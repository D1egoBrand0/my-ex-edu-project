/* CSV파일로부터 Import 실행 */

/* 리셋용 */
DROP TABLE seoul_corona; 	
DROP TABLE confirm_count;
DROP TABLE seoul_gu; 
DROP TABLE hotel_cnt;
DROP TABLE hotel_fee;
DROP TABLE guest;

/* CSV 파일 담는 테이블 */
CREATE TABLE seoul_corona (
	serial_num INT,
	confirm_date DATE,
	p_num INT,
	country VARCHAR(50),
	p_info VARCHAR(50),
	region VARCHAR(50),
	travel_hist VARCHAR(50),
	contact_hist VARCHAR(50),
	action VARCHAR(50),
	status VARCHAR(50),
	trace VARCHAR(50),
	regi_date TIMESTAMP,
	mod_date TIMESTAMP,
	expose VARCHAR(50)
);
/* 테이블에 region_id 추가 */
ALTER TABLE seoul_corona ADD COLUMN region_id INT REFERENCES seoul_gu(id);

/* region 체크용 */
SELECT DISTINCT region, COUNT(region) FROM seoul_corona 
GROUP BY region 
ORDER BY COUNT(region);

/* region의 '이상치' 제거 */
DELETE FROM seoul_corona WHERE region IN
(
	'구로구 ',' 성북구','강남구 ','강동구 ','관악구 ','노원구 ',
	'서대문구 ','성북구 ','송파구 ','동대문구 ','동작구 ','마포구 ',
	'타시도 ','강북구 ','용산구 ',' 서대문구 ','광진구 ','금천구 ',
	'양천구 ','은평구 ','강서구 ','타시도','기타'
); 

/* '이상치' 제거 후 확인 */
SELECT DISTINCT region, COUNT(region) FROM seoul_corona 
GROUP BY region 
ORDER BY COUNT(region);

/* 특별히 필요 없는 항목들 제거 */
ALTER TABLE seoul_corona 
DROP COLUMN serial_num, 	/* 자체적으로 id 쓸 예정 */
DROP COLUMN p_num, 			/* 절반 이상이 빈 갱신 중단된 자료*/
DROP COLUMN country,		/* 국가 */
DROP COLUMN p_info, 		/* 주민번호 */
DROP COLUMN regi_date,		/* 입원 */
DROP COLUMN mod_date, 		/* 퇴원 */
DROP COLUMN action,			/* 처리 상황 */
DROP COLUMN expose; 		/* 추가 노출 여부인데 Y밖에 없어서 가치 소실 */

/* 확인용 */
SELECT * FROM seoul_corona;

/* 연간 지역구별 확진자 집계 - 범위 : 2020.01.01 ~ 2020.12.31 */
SELECT region ,COUNT(confirm_date) FROM seoul_corona 
WHERE confirm_date BETWEEN '2020-01-01' AND '2020-12-31'
GROUP BY region;

/* 연간 지역구별 확진자 테이블 */
CREATE TABLE annual_confirm
(
	id SERIAL,
	confirm_count INT,
	region VARCHAR(50),
	region_id INT REFERENCES seoul_gu(id)
);

/* annual_confirm 데이터 */
INSERT INTO annual_confirm (region,region_id,confirm_count)
VALUES
('강남구',1,935),('강동구',2,582),('강북구',3,445),('강서구',4,1339),('관악구',5,1017),
('광진구',6,461),('구로구',7,624),('금천구',8,326),('노원구',9,813),('도봉구',10,574),
('동대문구',11,633),('동작구',12,811),('마포구',13,694),('서대문구',14,513),('서초구',15,826),
('성동구',16,150),('성북구',17,812),('송파구',18,1119),('양천구',19,728),('영등포구',20,694),
('용산구',21,418),('은평구',22,786),('종로구',23,404),('중구',24,283),('중랑구',25,802);

/* 체크용 */
SELECT * FROM annual_confirm;


/* 서울 행정구역 테이블 생성 */
CREATE TABLE seoul_gu
(	
	id SERIAL PRIMARY KEY,
	region VARCHAR(50)
);

/* seoul_gu 테이블의 데이터 */
INSERT INTO seoul_gu (region)
VALUES 
('강남구'),('강동구'),('강북구'),('강서구'),('관악구'),('광진구'),
('구로구'),('금천구'),('노원구'), ('도봉구'),('동대문구'),('동작구'),
('마포구'), ('서대문구'),('서초구'),('성동구'),('성북구'),('송파구'),
('양천구'), ('영등포구'),('용산구'),('은평구'),('종로구'),('중구'),('중랑구');

SELECT * FROM seoul_gu;


/* 지역구별 전체(2020~2021) 확진자 집계 테이블 */
CREATE TABLE confirm_count
(
	id SERIAL PRIMARY KEY,
	confirm_count_region VARCHAR(50),
	region_count INT,
	region_id INT REFERENCES seoul_gu(id)
);

/* confirm_count 데이터 */
INSERT INTO confirm_count (confirm_count_region, region_count,region_id)
VALUES 
('중구',3476,24), ('종로구',3728,23), ('용산구',5039,21), ('성동구',5408,16), ('금천구',5501,8), 
('서대문구',5783,14), ('강북구',6254,3), ('도봉구',6328,10), ('광진구',6669,6),('마포구',7153,13), 
('양천구',7458,19), ('서초구',7880,15), ('중랑구',8030,25), ('동작구',8344,12),('강동구',	8678,2),
('성북구', 8839,17), ('동대문구', 8873,11), ('노원구',8998,9), ('은평구',9139,22),('강서구',9869,4), 
('영등포구',10001,20), ('구로구',10153,7), ('관악구',10748,5), ('강남구',11893,1),('송파구',12844,18);

/* region_id로 정렬, ORDER BY 제거시 기본값으로 출력 */
SELECT * FROM confirm_count ORDER BY region_id;

/* 2019,2020년의 지역구별 호텔 수 */
CREATE TABLE hotel_cnt
(
	id SERIAL PRIMARY KEY,
    region   VARCHAR(50),
	region_id INT REFERENCES seoul_gu(id),
    hotel_cnt_2019 INT,
    hotel_cnt_2020 INT
);

/* 호텔 집계 데이터 */
INSERT INTO hotel_cnt (region, region_id, hotel_cnt_2019,hotel_cnt_2020)
VALUES ('강남구',1,27,38),('강북구',3,null,null),('강동구',2,2,3),('강서구',4,4,9),('관악구',5,3,6),
     ('광진구',6,3,5), ('구로구',7,4,6),('금천구',8,1,4),('노원구',9,1,null),('도봉구',10,1,2),
     ('동대문구',11,3,3),('동작구',12,2,1),('마포구',13,11,11),('서대문구',14,null,2),('서초구',15,4,8),
     ('성동구',16,1,3), ('성북구',17,1,1),('송파구',18,10,10),('양천구',19,null,1),('영등포구',20,8,9),
     ('용산구',21,5,9),('은평구',22,null,3),('종로구',23,19,21),('중구',24,34,59),('중랑구',25,null,null);
	 
/* 호텔 매출 테이블 */
CREATE TABLE hotel_fee
(
	id SERIAL PRIMARY KEY,
    region   VARCHAR(50),
	region_id INT REFERENCES seoul_gu(id),
    hotel_fee_2019 INT,
    hotel_fee_2020 INT
);

/*  hotel_fee 데이터 */
INSERT INTO hotel_fee (region, region_id,hotel_fee_2019, hotel_fee_2020)
values ('강남구',1,199277588,102348665),('강북구',3,null,null),('강동구',2,1914335,1445724),('강서구',4,17837451,13202609),
     ('관악구',5,3025071,3693935),('광진구',6,46826332,31551134),('구로구',7,18740111,9947641),('금천구',8,6481692,5086937),
     ('노원구',9,1244422,null),('도봉구',10,960000,2134500),('동대문구',11,7429516,1463299),('동작구',12,9316542,4774990),
     ('마포구',13,84457233,34787879),('서대문구',14,null,7469314),('서초구',15,52869557,26783679),('성동구',16,288000,1152736),
     ('성북구',17,1038425,590817),('송파구',18,58242667,30859048),('양천구',19,null,786000),('영등포구',20,43451151,12464390),
     ('용산구',21,53326768,42120850),('은평구',22,null,1781333),('종로구',23,86941447,38079952),('중구',24,287744619,115598389),
     ('중랑구',25,null,null);


/* 2019,2020년 호텔의 투숙객 집계 테이블 */
CREATE TABLE guest
(
	id SERIAL PRIMARY KEY,
    region   VARCHAR(50),
	region_id INT REFERENCES seoul_gu(id),
    guest_2019  INT,
    guest_2020  INT
);

/* guest 테이블의 데이터 */
INSERT INTO guest (region,region_id,guest_2019, guest_2020)
VALUES
('강남구',1,2064190,1523322),('강북구',3,null,null),('강동구',2,68780,50018),('강서구',4,216805,284250),
('관악구',5,94827,111445),('광진구',6,352037,321010),('구로구',7,441361,236691),('금천구',8,151413,124761),
('노원구',9,36509,null),('도봉구',10,37360,54200),('동대문구',11,205286,62178),('동작구',12,207775,129707),
('마포구',13,1228511,723812),('서대문구',14,null,133104),('서초구',15,331394,341738),('성동구',16,4370,26907),
('성북구',17,45855,27339),('송파구',18,535309,301486),('양천구',19,null,15720),('영등포구',20,396618,363455),
('용산구',21,539252,537371),('은평구',22,null,63123),('종로구',23,1344605,661401),('중구',24,4430290,1954454),
('중랑구',25,null,null);

/* 각 테이블 별 데이터 확인용 */
SELECT * FROM guest;
SELECT * FROM hotel_cnt;
SELECT * FROM hotel_fee;
SELECT * FROM s_ingu;
SELECT * FROM seoul_corona;
SELECT * FROM seoul_gu;

/* Join을 통한 통계 표시 */
/* 오류 발생시 각 라인 끝의 세미콜론(;) 혹은 콤마(,) 위치 확인 */
SELECT hotel_fee.region as "지역구", 
annual_confirm.confirm_count as "2020년 확진자 수",
confirm_count.region_count as "전체 확진자 수",
guest.guest_2019 as "2019년 이용객", 
guest.guest_2020 as "2020년 이용객", 
hotel_fee.hotel_fee_2019 as "2019년 매출", 
hotel_fee.hotel_fee_2020 as "2020년 매출"
--hotel_cnt.hotel_cnt_2019 as "2019년 호텔 수",  /* 통계에 큰 가치가 없어 제외 */
--hotel_cnt.hotel_cnt_2020 as "2020년 호텔 수",  /* 통계에 큰 가치가 없어 제외 */
FROM hotel_fee 
INNER JOIN guest ON hotel_fee.region_id = guest.region_id
INNER JOIN confirm_count ON hotel_fee.region_id = confirm_count.region_id
INNER JOIN annual_confirm ON hotel_fee.region_id = annual_confirm.region_id;
--INNER JOIN hotel_cnt ON hotel_fee.region_id = hotel_cnt.region_id; /* 통계에 큰 가치가 없어 제외 */
--WHERE guest.guest_2020 IS NOT NULL AND guest.guest_2019 IS NOT NULL; /* Null 값 제외 - Null : 해당 연도에 건물의 유무 */

/* Bonus : 데이터 전처리 중 찾은 특이한 항목 */
SELECT confirm_date as "확진 일자", contact_hist as "강조 표시된 확진 경위", region as "발생 위치" , COUNT(contact_hist) as "확진자 수"
FROM seoul_corona WHERE contact_hist LIKE '신 %' GROUP BY confirm_date, contact_hist, region;
/* Суммарная статистика исходя из ДАТЫ НАЧИСЛЕНИЯ ВОЗНАГРАЖДЕНИЯ МЕНЕДЖЕРУ */
/* на основе 1ManagerStats.sql */
/* 

ПАРАМЕТРИЗИРОВАННЫЙ ЗАПРОС! Для выполнения обязательно передать словарь со следующими параметрами:

- pstart (string) - строка с начальной датой. Например 'yesterday', '2022-01-01'
- pend (string) - строка с конечной датой (записи < этой дате). Например 'today', '2022-05-01'
- pmanager (string) - маска выбора менеджеров ('%' для всех, используется с LIKE)
- dtmask (string) - маска выбора периода группировки (например 'yyyy-mm', 'yyyy-ww')
// exclmgrs (tuple(int))  - список id менеджеров, которые исключаются из выборки НЕ ИСПОЛЬЗУЕТСЯ

*/
with
rng as (
		select * from (
			VALUES (cast(%(pstart)s as timestamp with time zone),
					cast(%(pend)s as timestamp with time zone),
					%(pmanager)s,
					%(dtmask)s) 
			)
		AS rng (PStart,PEnd,PManager,DTMask)
),
ce (id, CatType, CatGroup, VAT) AS 
(	
	select * from ( values 
	 (1,'Подключение'/* прочих услуг'*/,'C',0.2),
	 (2,'Абонплата'/* за прочие услуги'*/,'A',0.2),
	 (3,'Трафик'/* исходящий общий'*/,'TN',0.2),
	 (4,'Трафик'/* входящий 8800'*/,'TF',0.2),
	 (5,'Подключение'/* услуги виртуальной АТС'*/,'CA',0.0),
	 (7,'Подключение'/* простого телефонного номера'*/,'CNA',0.2),
	 (8,'Подключение'/* бронзового телефонного номера'*/,'CNB',0.2),
	 (9,'Подключение'/* серебряного телефонного номера'*/,'CNC',0.2),
	 (10,'Подключение'/* золотого телефонного номера'*/,'CNG',0.2),
	 (11,'Подключение'/* платинового телефонного номера'*/,'CNP',0.2),
	 (12,'Подключение'/* эксклюзивного телефонного номера'*/,'CNE',0.2),
	 (13,'Подключение'/* простого номера 8800'*/,'CFA',0.2),
	 (14,'Подключение'/* бронзового номера 8800'*/,'CFB',0.2),
	 (15,'Подключение'/* серебряного номера 8800'*/,'CFC',0.2),
	 (16,'Подключение'/* золотого номера 8800'*/,'CFG',0.2),
	 (17,'Подключение'/* платинового номера 8800'*/,'CFP',0.2),
	 (18,'Подключение'/* дополнительной услуги виртуальной АТС'*/,'CAS',0.0),
	 (19,'Подключение'/* дополнительной линии'*/,'CAL',0.0),
	 (21,'Подключение'/* ежемесячных пакетов'*/,'CMA',0.2),
	 (22,'Подключение'/* больших ежемесячных пакетов'*/,'CMB',0.2),
	 (23,'Подключение'/* комбинированных ежемесячных пакетов'*/,'CMC',0.2),
	 (24,'Подключение'/* ежемесячных пакетов на регионы'*/,'CMR',0.2),
	 (25,'Подключение'/* ежемесячных пакетов 8800'*/,'CMF',0.2),
	 (26,'Подключение'/* архивных пакетов'*/,'CMZ',0.2),
	 (27,'Подключение'/* годовых пакетов минут'*/,'CYA',0.2),
	 (28,'Подключение'/* больших годовых пакетов минут'*/,'CYB',0.2),
	 (29,'Абонплата'/* за услуги виртуальной АТС'*/,'AA',0.0),
	 (31,'Абонплата'/* за телефонный номер'*/,'ANA',0.2),
	 (32,'Абонплата'/* за красивый телефонный номер'*/,'ANG',0.2),
	 (33,'Абонплата'/* за эксклюзивный телефонный номер'*/,'ANE',0.2),
	 (34,'Абонплата'/* за номер 8800'*/,'AF',0.2),
	 (35,'Абонплата'/* за дополнительные услуги виртуальной АТС'*/,'AAS',0.0),
	 (36,'Абонплата'/* за дополнительную линию'*/,'AAL',0.0),
	 (38,'Абонплата'/* за ежемесячные пакеты'*/,'AMA',0.2),
	 (39,'Абонплата'/* за большие ежемесячные пакеты'*/,'AMB',0.2),
	 (40,'Абонплата'/* за комбинированные ежемесячные пакеты'*/,'AMC',0.2),
	 (41,'Абонплата'/* за ежемесячные пакеты на регионы'*/,'AMR',0.2),
	 (42,'Абонплата'/* за ежемесячные пакеты 8800'*/,'AMF',0.2),
	 (43,'Абонплата'/* за архивные пакеты'*/,'AMZ',0.2),
	 (44,'Платные услуги'/* сопровождение/поддержка'*/,'ES',0.2),
	 (45,'Платные услуги'/* выезды'*/,'EV',0.2),
	 (46,/*'Продажа */'Оборудование','Q',0.2),
	 (20,'Подключение'/* модулей интеграции'*/,'CI',0.0),
	 (37,'Абонплата'/* за модули интеграции'*/,'AI',0.0)
	 ) as cats (id, "name", CatGroup, VAT)
),
ra AS (
	SELECT r_1.category,
		c.name AS category_name,
		r_1.done_at,
		r_1.accounted_at,
		r_1.service,
		r_1.amount
	FROM realization r_1
	JOIN categories c ON r_1.category = c.id
	join rng on r_1.accounted_at >= rng.PStart AND r_1.accounted_at < rng.PEnd
), 
rb AS (
	SELECT DISTINCT ON (ra.category, ra.category_name, ra.done_at, ra.accounted_at, ra.service, cl.vpbx, ra.amount) 
		ra.category,
		ra.category_name,
		ra.done_at,
		ra.accounted_at,
		ra.service,
		ra.amount,
		cl.vpbx,
		u.name AS user_name
	FROM ra
	JOIN clients_log cl ON 
		ra.service = cl.id 
		AND date_trunc('day'::text, cl.operated_at - '1 day'::interval) <= date_trunc('day'::text, ra.accounted_at)
	JOIN amo_users u ON cl.responsible_user = u.id
    WHERE u.id <> 2596171 /* исключаем Машу из выборки */
        /* u.id <> ALL (%(exclmgrs)s)  список id сотрудников, которых исключить из выборки (типа пользователи "Система" и т.д.) * - НЕ ИСПОЛЬЗУЕТСЯ */
	ORDER BY 
		ra.category, 
		ra.category_name, 
		ra.done_at, 
		ra.accounted_at, 
		ra.service, 
		cl.vpbx, 
		ra.amount, 
		cl.operated_at DESC, 
		u.name
),
accr as (
	SELECT 
		DISTINCT ON 
			(rb.category, rb.category_name, rb.done_at, rb.accounted_at, rb.service, rb.vpbx, rb.amount, rb.user_name) 
		rb.category,
    	rb.category_name,
    	rb.done_at,
    	rb.accounted_at,
    	rb.service,
		rb.amount,
		rb.vpbx,
		rb.user_name,
		r.rate,
		ce.VAT,
		ce.CatType,
		ce.CatGroup,
    	round(r.rate * rb.amount, 2) AS accrued,
    	round(rb.amount*(1+ce.VAT), 2) AS AmountWithVAT
	FROM rng, rb
	JOIN rates r ON 	rb.category = r.category 
						AND r.enabled_from <= rb.done_at 
						AND rb.done_at <= COALESCE(r.enabled_to, rb.done_at)
	join ce on rb.category = ce.id
	where rb.user_name like rng.PManager
	ORDER BY 
		rb.category, 
		rb.category_name, 
		rb.done_at, 
		rb.accounted_at, 
		rb.service, 
		rb.vpbx, 
		rb.amount, 
		rb.user_name, 
		r.enabled_from DESC, 
		r.enabled_to
),
abonka as (
	SELECT 
		to_char(a.accounted_at, rng.DTMask) as Mo,
		a.user_name,
		SUM(a.AmountWithVAT) as totalsum 
	FROM rng, accr a
	where
		a.CatType = 'Абонплата'
	group by mo, user_name
	order by mo, user_name
),
conn as (
	SELECT 
		to_char(b.accounted_at, rng.DTMask) as Mo,
		b.user_name,
		SUM(b.AmountWithVAT) as totalsum 
	FROM rng, accr b
	where
			b.CatType = 'Подключение'
	group by mo, user_name
	order by mo, user_name
),
traf as (
	SELECT 
		to_char(c.accounted_at, rng.DTMask) as Mo,
		c.user_name,
		SUM(c.AmountWithVAT) as totalsum 
	FROM rng, accr c
	where
			c.CatType = 'Трафик'
	group by mo, user_name
	order by mo, user_name
),
evg as (
	SELECT 
		to_char(d.accounted_at, rng.DTMask) as Mo,
		d.user_name, 
		SUM(d.AmountWithVAT) as totalsum, 
		round(SUM(d.accrued),2) as totalaccrued
	FROM rng, accr d
	group by mo, user_name
	order by mo, user_name
)
select evg.mo, evg.user_name, abonka.totalsum as TotalAbonka, conn.totalsum as TotalConn, traf.totalsum as TotalTraf, evg.totalsum as AllTogether, evg.totalaccrued as Reward 
from evg 
left join conn on evg.mo=conn.mo and evg.user_name = conn.user_name
left join traf on evg.mo=traf.mo and evg.user_name = traf.user_name
left join abonka on evg.mo=abonka.mo and evg.user_name = abonka.user_name
order by evg.mo, evg.user_name;

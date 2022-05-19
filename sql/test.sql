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
)
select * from rng;

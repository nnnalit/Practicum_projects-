/* Проект «Секреты Тёмнолесья»
 * Цель проекта: изучить влияние характеристик игроков и их игровых персонажей 
 * на покупку внутриигровой валюты «райские лепестки», а также оценить 
 * активность игроков при совершении внутриигровых покупок
 * 
 * Автор: Литвинчук Анастасия
 * Дата: 27.11.2025
*/

-- Часть 1. Исследовательский анализ данных
-- Задача 1. Исследование доли платящих игроков

-- 1.1. Доля платящих пользователей по всем данным:
-- Напишите ваш запрос здесь
--SELECT 
   -- COUNT(*) AS total_players,
   -- COUNT(CASE WHEN payer = 1 THEN 1 END) AS platyshie_players,
    --COUNT(CASE WHEN payer = 1 THEN 1 END) * 100.0 / COUNT(*) AS dolya_platyshih_percentage
--FROM fantasy.users;

-- 1.2. Доля платящих пользователей в разрезе расы персонажа:
-- Напишите ваш запрос здесь
--SELECT 
    --r.race,
    --COUNT(CASE WHEN u.payer = 1 THEN 1 END) AS platyshie_players,
    --COUNT(*) AS total_players,
    --ROUND(COUNT(CASE WHEN u.payer = 1 THEN 1 END) * 100.0 / COUNT(*), 2) AS dolya_players_platyshih
--FROM fantasy.users u
--JOIN fantasy.race r ON u.race_id = r.race_id
--GROUP BY r.race
--ORDER BY dolya_players_platyshih DESC;

-- Задача 2. Исследование внутриигровых покупок
-- 2.1. Статистические показатели по полю amount:
-- Напишите ваш запрос здесь
--SELECT 
    --COUNT(*) AS total_transactions,
    --SUM(amount) AS total_revenue,
    --MIN(amount) AS min_amount,
    --MAX(amount) AS max_amount,
    --AVG(amount) AS avg_amount,
    --PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY amount) AS median_amount,
    --STDDEV(amount) AS std_deviation
--FROM fantasy.events
--WHERE amount IS NOT NULL;

-- 2.2: Аномальные нулевые покупки:
-- Напишите ваш запрос здесь
--SELECT 
    --COUNT(*) AS zero_amount_transactions,
    --ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fantasy.events), 2) AS zero_amount_dolya
--FROM fantasy.events
--WHERE amount = 0;

-- 2.3: Популярные эпические предметы:
-- Напишите ваш запрос здесь
--WITH total_stats AS (
    --SELECT 
        --COUNT(*) AS total_pokupok,
        --COUNT(DISTINCT id) AS total_unique_pokupatelei
    --FROM fantasy.events 
    --WHERE amount > 0
--),
--item_stats AS (
    --SELECT 
        --i.game_items AS item_name,
        --COUNT(e.transaction_id) AS predmet_count,
        --COUNT(DISTINCT e.id) AS unique_igrokov
    --FROM fantasy.events e
    --JOIN fantasy.items i ON e.item_code = i.item_code
    --WHERE e.amount > 0
    --GROUP BY i.game_items
--)
--SELECT 
    --item_name,
    --predmet_count,
    --ROUND(predmet_count * 100.0 / (SELECT total_pokupok FROM total_stats), 2) AS dolya_prodag,
    --unique_igrokov,
    --ROUND(unique_igrokov * 100.0 / (SELECT total_unique_pokupatelei FROM total_stats), 2) AS dolya_igrokov
--FROM item_stats
--ORDER BY predmet_count DESC
--LIMIT 10;

-- Часть 2. Решение ad hoc-задачи
-- Задача: Зависимость активности игроков от расы персонажа:
-- Напишите ваш запрос здесь
WITH race_registrations AS (
    -- Шаг 1: Общее количество зарегистрированных игроков по расам
    SELECT 
        r.race_id,
        r.race AS rasa_name,
        COUNT(u.id) AS vsego_igrokov
    FROM fantasy.race r
    LEFT JOIN fantasy.users u ON r.race_id = u.race_id
    GROUP BY r.race_id, r.race
),
race_purchases AS (
    -- Шаг 2: Игроки, совершившие покупки и доля платящих игроков
    SELECT 
       	u.race_id,
        COUNT(DISTINCT e.id) AS igroki_s_pokupkami,
        COUNT(DISTINCT CASE WHEN u.payer = 1 THEN u.id END) AS platyshie_igroki_s_pokupkami
    FROM fantasy.events e
    JOIN fantasy.users u ON e.id = u.id
    WHERE e.amount > 0
    GROUP BY u.race_id
),
race_activity AS (
    -- Шаг 3: Активность игроков по расам
    SELECT 
        u.race_id,
        e.id AS igrok_id,
        COUNT(e.transaction_id) AS kolichestvo_pokupok,
        SUM(e.amount) AS obshaya_stoimost_pokupok
    FROM fantasy.events e
    JOIN fantasy.users u ON e.id = u.id
    WHERE e.amount > 0
    GROUP BY u.race_id, e.id
),
race_purchase_details AS (
    -- Детали по покупкам для расчета средней стоимости одной покупки
    SELECT 
        u.race_id,
        COUNT(*) AS vsego_pokupok,
        SUM(e.amount) AS obshaya_stoimost_vseh_pokupok,
        AVG(e.amount) AS srednyaya_stoimost_odnoy_pokupki
    FROM fantasy.events e
    JOIN fantasy.users u ON e.id = u.id
    WHERE e.amount > 0
    GROUP BY u.race_id
),
race_activity_stats AS (
    -- Шаг 5: Статистика по активности
    SELECT 
        race_id,
        COUNT(igrok_id) AS kolichestvo_aktivnyh_igrokov,
        AVG(kolichestvo_pokupok) AS srednee_pokupok_na_igroka,
        AVG(obshaya_stoimost_pokupok) AS srednyaya_obshaya_stoimost_na_igroka
    FROM race_activity
    GROUP BY race_id
)
-- Итоговый запрос
SELECT 
    rr.rasa_name,
    rr.vsego_igrokov,
    rp.igroki_s_pokupkami AS igroki_s_pokupkami,
    ROUND((rp.igroki_s_pokupkami * 100.0 / rr.vsego_igrokov)::numeric, 2) AS dolya_igrokov_s_pokupkami,
    ROUND(COALESCE(rp.platyshie_igroki_s_pokupkami * 100.0 / rp.igroki_s_pokupkami)::numeric, 2) AS dolya_platyshih_sredi_pokupatelei,
    ROUND(ras.srednee_pokupok_na_igroka::numeric, 2) AS srednee_pokupok_na_igroka,
    ROUND(rpd.srednyaya_stoimost_odnoy_pokupki::numeric, 2) AS srednyaya_stoimost_odnoy_pokupki,
    ROUND(ras.srednyaya_obshaya_stoimost_na_igroka::numeric, 2) AS srednyaya_obshaya_stoimost_na_igroka
FROM race_registrations rr
LEFT JOIN race_purchases rp ON rr.race_id = rp.race_id
LEFT JOIN race_activity_stats ras ON rr.race_id = ras.race_id
LEFT JOIN race_purchase_details rpd ON rr.race_id = rpd.race_id
ORDER BY srednyaya_obshaya_stoimost_na_igroka DESC;

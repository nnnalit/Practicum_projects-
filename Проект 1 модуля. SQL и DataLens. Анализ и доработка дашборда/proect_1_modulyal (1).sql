--Временной интервал
--SELECT
   --MIN(first_day_exposition) AS min_date,
   --MAX(first_day_exposition) AS max_date,
    --MAX(first_day_exposition) - MIN(first_day_exposition) AS date_range_days
--FROM real_estate.advertisement;

--Типы населённых пунктов
--SELECT 
    --t.type AS "Тип населённого пункта",
    --COUNT(DISTINCT f.city_id) AS "Количество населённых пунктов",
    --COUNT(f.id) AS "Количество объявлений"
--FROM real_estate.flats f
--JOIN real_estate.city c ON f.city_id = c.city_id
--JOIN real_estate.type t ON f.type_id = t.type_id
--GROUP BY t.type
--ORDER BY "Количество объявлений" DESC;

--Время активности объявления
--SELECT
    --MIN(days_exposition) AS min_days,
    --MAX(days_exposition) AS max_days,
    --ROUND(AVG(days_exposition)::numeric, 2) AS avg_days,
    --percentile_cont(0.5) WITHIN GROUP (ORDER BY days_exposition) AS median_days
--FROM real_estate.advertisement;

--Доля снятых с публикации объявлений
--SELECT
    --COUNT(days_exposition) AS sold_count,
    --COUNT(*) AS total_count,
    --ROUND((COUNT(days_exposition) * 100.0 / COUNT(*))::numeric, 2) AS sold_percentage
--FROM real_estate.advertisement;

--Объявления Санкт-Петербурга
--SELECT
    --COUNT(CASE WHEN c.city = 'Санкт-Петербург' THEN 1 END) AS spb_count,
    --COUNT(*) AS total_count,
    --ROUND((COUNT(CASE WHEN c.city = 'Санкт-Петербург' THEN 1 END) * 100.0 / COUNT(*))::numeric, 2) AS spb_percentage
--FROM real_estate.flats f
--JOIN real_estate.city c ON f.city_id = c.city_id;

--Стоимость квадратного метра
--WITH price_per_m2 AS (
    --SELECT 
        --a.last_price / f.total_area AS price_per_sqm
    --FROM real_estate.advertisement a
    --JOIN real_estate.flats f ON a.id = f.id
--)
--SELECT
    --ROUND(MIN(price_per_sqm)::numeric, 2) AS min_price_per_sqm,
    --ROUND(MAX(price_per_sqm)::numeric, 2) AS max_price_per_sqm,
    --ROUND(AVG(price_per_sqm)::numeric, 2) AS avg_price_per_sqm,
    --ROUND(percentile_cont(0.5) WITHIN GROUP (ORDER BY price_per_sqm)::numeric, 2) AS median_price_per_sqm
--FROM price_per_m2;

--Статистические показатели
-- Общая площадь
--SELECT 
    --'total_area' AS metric,
    --COUNT(total_area) AS count_not_null,
    --COUNT(*) - COUNT(total_area) AS count_null,
    --ROUND(MIN(total_area)::numeric, 2) AS min_value,
    --ROUND(MAX(total_area)::numeric, 2) AS max_value,
    --ROUND(AVG(total_area)::numeric, 2) AS avg_value,
    --ROUND(percentile_cont(0.5) WITHIN GROUP (ORDER BY total_area)::numeric, 2) AS median,
    --ROUND(percentile_cont(0.99) WITHIN GROUP (ORDER BY total_area)::numeric, 2) AS percentile_99
--FROM real_estate.flats
--WHERE total_area IS NOT NULL
--UNION ALL
-- Количество комнат
--SELECT 
    --'rooms',
    --COUNT(rooms),
    --COUNT(*) - COUNT(rooms),
    --ROUND(MIN(rooms)::numeric, 2),
    --ROUND(MAX(rooms)::numeric, 2),
    --ROUND(AVG(rooms)::numeric, 2),
    --ROUND(percentile_cont(0.5) WITHIN GROUP (ORDER BY rooms)::numeric, 2),
    --ROUND(percentile_cont(0.99) WITHIN GROUP (ORDER BY rooms)::numeric, 2)
--FROM real_estate.flats
--WHERE rooms IS NOT NULL
--UNION ALL
-- Количество балконов
/*SELECT 
    'balcony',
    COUNT(balcony),
    COUNT(*) - COUNT(balcony),
    ROUND(MIN(balcony)::numeric, 2),
    ROUND(MAX(balcony)::numeric, 2),
    ROUND(AVG(balcony)::numeric, 2),
    ROUND(percentile_cont(0.5) WITHIN GROUP (ORDER BY balcony)::numeric, 2),
    ROUND(percentile_cont(0.99) WITHIN GROUP (ORDER BY balcony)::numeric, 2)
FROM real_estate.flats
WHERE balcony IS NOT NULL
UNION ALL
-- Высота потолков
SELECT 
    'ceiling_height',
    COUNT(ceiling_height),
    COUNT(*) - COUNT(ceiling_height),
    ROUND(MIN(ceiling_height)::numeric, 2),
    ROUND(MAX(ceiling_height)::numeric, 2),
    ROUND(AVG(ceiling_height)::numeric, 2),
    ROUND(percentile_cont(0.5) WITHIN GROUP (ORDER BY ceiling_height)::numeric, 2),
    ROUND(percentile_cont(0.99) WITHIN GROUP (ORDER BY ceiling_height)::numeric, 2)
FROM real_estate.flats
WHERE ceiling_height IS NOT NULL
UNION ALL
-- Этаж
SELECT 
    'floor',
    COUNT(floor),
    COUNT(*) - COUNT(floor),
    ROUND(MIN(floor)::numeric, 2),
    ROUND(MAX(floor)::numeric, 2),
    ROUND(AVG(floor)::numeric, 2),
    ROUND(percentile_cont(0.5) WITHIN GROUP (ORDER BY floor)::numeric, 2),
    ROUND(percentile_cont(0.99) WITHIN GROUP (ORDER BY floor)::numeric, 2)
FROM real_estate.flats
WHERE floor IS NOT NULL;*/

/* Проект первого модуля: анализ данных для агентства недвижимости
 * Часть 2. Решаем ad hoc задачи
 * 
 * Автор: Литвинчук Анастасия Юрьевна
 * Дата: 14.12.2025
*/

-- Задача 1: Время активности объявлений
-- Определим аномальные значения (выбросы) по значению перцентилей:
/*WITH limits AS (
    SELECT
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats
),
-- Найдём id объявлений, которые не содержат выбросы, также оставим пропущенные данные:
filtered_id AS(
    SELECT id
    FROM real_estate.flats
    WHERE
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
    ),
-- Продолжите запрос здесь
-- Используйте id объявлений (СТЕ filtered_id), которые не содержат выбросы при анализе данных
-- Подготовим данные с категоризацией и расчетами
categorized_data AS (
    SELECT 
        -- Категория региона
        CASE 
            WHEN c.city = 'Санкт-Петербург' THEN 'Санкт-Петербург'
            ELSE 'ЛенОбл'
        END AS region,
        
        -- Категория по времени активности
        CASE 
            WHEN a.days_exposition IS NULL THEN 'non category'
            WHEN a.days_exposition <= 30 THEN 'до месяца'
            WHEN a.days_exposition <= 90 THEN 'до трех месяцев'
            WHEN a.days_exposition <= 180 THEN 'до полугода'
            ELSE 'более полугода'
        END AS activity_segment,
        
        -- Основные параметры для анализа
        a.last_price AS price,
        f.total_area,
        a.last_price / NULLIF(f.total_area, 0) AS price_per_sqm,
        f.rooms,
        f.balcony,
        f.floors_total,
        f.ceiling_height,
        f.living_area,
        f.kitchen_area,
        f.is_apartment,
        f.open_plan,
        a.days_exposition,
        EXTRACT(YEAR FROM a.first_day_exposition) AS year
    FROM real_estate.advertisement a
    JOIN real_estate.flats f ON a.id = f.id
    JOIN real_estate.city c ON f.city_id = c.city_id
    JOIN real_estate.type t ON f.type_id = t.type_id
    WHERE f.id IN (SELECT id FROM filtered_id)  -- Фильтрация выбросов
      AND t.type = 'город'  -- Только города
      AND EXTRACT(YEAR FROM a.first_day_exposition) BETWEEN 2015 AND 2018  -- Период 2015-2018
)
-- Основной запрос с агрегацией
SELECT 
    region AS "Регион",
    activity_segment AS "Сегмент активности",
    COUNT(*) AS "Количество объявлений",
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY region), 2) AS "Доля в регионе, %",
    ROUND(AVG(price_per_sqm)::numeric, 2) AS "Средняя стоимость кв. метра",
    ROUND(AVG(total_area)::numeric, 2) AS "Средняя площадь",
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rooms) AS "Медиана кол-ва комнат",
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY balcony) AS "Медиана кол-ва балконов",
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY floors_total) AS "Медиана этажности",
    ROUND(AVG(ceiling_height)::numeric, 2) AS "Средняя высота потолков",
    ROUND(AVG(CASE WHEN rooms = 0 THEN 1 ELSE 0 END) * 100, 2) AS "Доля студий, %",
    ROUND(AVG(CASE WHEN is_apartment = 1 THEN 1 ELSE 0 END) * 100, 2) AS "Доля апартаментов, %"
FROM categorized_data
GROUP BY region, activity_segment
ORDER BY 
    CASE region 
        WHEN 'Санкт-Петербург' THEN 1 
        ELSE 2 
    END,
    CASE activity_segment
        WHEN 'до месяца' THEN 1
        WHEN 'до трех месяцев' THEN 2
        WHEN 'до полугода' THEN 3
        WHEN 'более полугода' THEN 4
        ELSE 5
    END;*/

-- Задача 2: Сезонность объявлений
-- Определим аномальные значения (выбросы) по значению перцентилей:
WITH limits AS (
    SELECT
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats
),
-- Найдём id объявлений, которые не содержат выбросы, также оставим пропущенные данные:
filtered_id AS(
    SELECT id
    FROM real_estate.flats
    WHERE
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
),
-- Продолжите запрос здесь
-- Используйте id объявлений (СТЕ filtered_id), которые не содержат выбросы при анализе данных
-- объединяем таблицы и вычисляем нужные метрики
    seasonal_data AS (
    SELECT 
        a.id,
        a.first_day_exposition AS publication_date, -- Дата публикации
        a.first_day_exposition + INTERVAL '1 day' * a.days_exposition AS removal_date, -- Дата снятия (продажи)
        a.days_exposition, -- Дни активности
        a.last_price, -- Цена
        f.total_area, -- Общая площадь
        a.last_price / NULLIF(f.total_area, 0) AS price_per_sqm, -- Цена за кв.м (защита от деления на 0)
        f.rooms, -- Количество комнат
        EXTRACT(YEAR FROM a.first_day_exposition) AS publication_year, -- Год публикации
        EXTRACT(MONTH FROM a.first_day_exposition) AS publication_month, -- Месяц публикации
        -- Месяц снятия: вычисляем из даты публикации + дни активности
        CASE 
            WHEN a.days_exposition IS NOT NULL 
            THEN EXTRACT(MONTH FROM a.first_day_exposition + INTERVAL '1 day' * a.days_exposition)
            ELSE null -- Если объявление еще активно (days_exposition IS NULL)
        END AS removal_month
    FROM real_estate.advertisement a
    JOIN real_estate.flats f ON a.id = f.id
    JOIN real_estate.city c ON f.city_id = c.city_id
    JOIN real_estate.type t ON f.type_id = t.type_id
    WHERE f.id IN (SELECT id FROM filtered_id) -- Только отфильтрованные ID
      AND t.type = 'город'
      AND EXTRACT(YEAR FROM a.first_day_exposition) BETWEEN 2015 AND 2018
),
-- Статистика по публикациям (когда выставили на продажу)
-- Группируем по месяцам публикации
publication_stats AS (
    SELECT 
        publication_month AS month,
        COUNT(*) AS публикаций,
        ROUND(AVG(price_per_sqm)::numeric, 2) AS avg_price_pub, -- Средняя цена кв.м опубликованных
        ROUND(AVG(total_area)::numeric, 2) AS avg_area_pub, -- Средняя площадь опубликованных
        ROUND(AVG(days_exposition)::numeric, 2) AS avg_days_pub -- Среднее время до продажи
    FROM seasonal_data
    GROUP BY publication_month
),
-- Статистика по снятию (когда объявления продали)
removal_stats AS (
    SELECT 
        removal_month AS month,
        COUNT(*) AS продаж,
        ROUND(AVG(price_per_sqm)::numeric, 2) AS avg_price_rem, -- Средняя цена кв.м проданных
        ROUND(AVG(total_area)::numeric, 2) AS avg_area_rem, -- Средняя площадь проданных
        ROUND(AVG(days_exposition)::numeric, 2) AS avg_days_rem -- Среднее время продажи
    FROM seasonal_data
    WHERE removal_month IS NOT NULL
    GROUP BY removal_month
)
-- Сводная таблица
SELECT 
    COALESCE(p.month, r.month) AS месяц,
    TO_CHAR(TO_DATE(COALESCE(p.month, r.month)::text, 'MM'), 'Month') AS название_месяца,
    COALESCE(p.публикаций, 0) AS количество_публикаций,
    COALESCE(r.продаж, 0) AS количество_продаж,
    ROUND(COALESCE(r.продаж::numeric / NULLIF(p.публикаций, 0) * 100, 0), 2) AS процент_продаж_от_публикаций,
    ROUND(COALESCE(p.avg_price_pub, r.avg_price_rem)::numeric, 2) AS средняя_стоимость_кв_метра,
    ROUND(COALESCE(p.avg_area_pub, r.avg_area_rem)::numeric, 2) AS средняя_площадь,
    ROUND(COALESCE(p.avg_days_pub, r.avg_days_rem)::numeric, 2) AS среднее_время_продажи_дней
FROM publication_stats p
FULL OUTER JOIN removal_stats r ON p.month = r.month
ORDER BY COALESCE(p.month, r.month);

/*
Пацев Вадим Васильевич
ДЗ 2. Вариант 17. PostgreSQL.

Заполнить таблицы из ДЗ 1 минимум пятью осмысленными записями.
1. Выбрать все поля экскурсий, перевести стоимость из рублей в доллары
по текущему курсу ЦБ, округлить вверх до целого доллара.
2. Выбрать тур с наибольшим количеством возможных экскурсий.
*/

CREATE TABLE cities (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL CHECK (TRIM(name) <> '')
);

CREATE TABLE routes (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL CHECK (TRIM(name) <> ''),
    departure_city_id INTEGER NOT NULL REFERENCES cities(id),
    description TEXT NOT NULL,
    base_price NUMERIC(12, 2) NOT NULL CHECK (base_price >= 0)
);

CREATE TABLE route_cities (
    route_id INTEGER NOT NULL REFERENCES routes(id),
    city_id INTEGER NOT NULL REFERENCES cities(id),
    stay_days INTEGER NOT NULL CHECK (stay_days > 0),
    PRIMARY KEY (route_id, city_id)
);

CREATE TABLE excursions (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    city_id INTEGER NOT NULL REFERENCES cities(id),
    name TEXT NOT NULL CHECK (TRIM(name) <> ''),
    description TEXT NOT NULL,
    price NUMERIC(12, 2) NOT NULL CHECK (price >= 0)
);

CREATE TABLE tours (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    route_id INTEGER NOT NULL REFERENCES routes(id),
    departure_date DATE NOT NULL,
    duration_days INTEGER NOT NULL CHECK (duration_days > 0),
    extra_fees NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (extra_fees >= 0),
    extra_description TEXT
);

INSERT INTO cities (name) VALUES
    ('Москва'),
    ('Сергиев Посад'),
    ('Переславль-Залесский'),
    ('Ростов Великий'),
    ('Ярославль');

INSERT INTO routes (name, departure_city_id, description, base_price) VALUES
    ('Города Золотого кольца', 1, 'Москва, Сергиев Посад, Переславль, Ростов, Ярославль', 25000),
    ('Поездка в Сергиев Посад', 1, 'Москва и Сергиев Посад', 4000),
    ('Плещеево озеро', 1, 'Москва и Переславль-Залесский', 6000),
    ('Ростовский кремль', 1, 'Москва и Ростов Великий', 8000),
    ('Выходной в Москве', 1, 'Однодневный маршрут по Москве', 2500);

INSERT INTO route_cities (route_id, city_id, stay_days) VALUES
    (1, 1, 1),
    (1, 2, 1),
    (1, 3, 1),
    (1, 4, 1),
    (1, 5, 1),
    (2, 1, 1),
    (2, 2, 1),
    (3, 1, 1),
    (3, 3, 1),
    (4, 1, 1),
    (4, 4, 1),
    (5, 1, 1);

INSERT INTO excursions (city_id, name, description, price) VALUES
    (1, 'Автобусный обзор Москвы', 'Четырёхчасовая поездка по столице со смотровыми площадками', 1156),
    (2, 'Прогулка по Троице-Сергиевой лавре', 'Групповое знакомство с монастырским ансамблем', 1790),
    (5, 'Ярославль на автобусе', 'Обзор города с пешеходными остановками', 1369),
    (5, 'Исторический центр Ярославля', 'Пешеходная прогулка по старому городу', 1157),
    (5, 'Ярославль на тысячерублёвой купюре', 'Поездка к памятникам, изображённым на банкноте', 1458);

INSERT INTO tours (route_id, departure_date, duration_days, extra_fees, extra_description) VALUES
    (1, '2026-11-07', 5, 1500, 'Доплата за одноместное размещение'),
    (2, '2026-11-08', 2, 0, NULL),
    (3, '2026-11-14', 2, 500, 'Дополнительный трансфер к озеру'),
    (4, '2026-11-15', 2, 0, NULL),
    (5, '2026-11-21', 1, 0, NULL);

SELECT id, city_id, name, description, CEIL(price / 80.5573) AS price_usd
FROM excursions;

SELECT t.*, COUNT(e.id) AS excursions_count
FROM tours t
LEFT JOIN route_cities rc ON rc.route_id = t.route_id
LEFT JOIN excursions e ON e.city_id = rc.city_id
GROUP BY t.id
ORDER BY excursions_count DESC, t.id
LIMIT 1;

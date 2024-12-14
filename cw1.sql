CREATE DATABASE firma;

CREATE SCHEMA ksiegowosc;
CREATE TABLE ksiegowosc.pracownicy (
    id_pracownika INT PRIMARY KEY,        
    imie VARCHAR(50) NOT NULL,            
    nazwisko VARCHAR(50) NOT NULL,       
    adres TEXT,                          
    telefon VARCHAR(15));
drop table if exists ksiegowosc.godziny;
CREATE TABLE ksiegowosc.godziny (
    id_godziny INT PRIMARY KEY,
    data DATE NOT NULL,
    liczba_godzin INT NOT NULL,
    id_pracownika INT NOT NULL,
    CONSTRAINT fk_godziny_pracownik FOREIGN KEY (id_pracownika)
        REFERENCES ksiegowosc.pracownicy (id_pracownika));
CREATE TABLE ksiegowosc.pensja (
	id_pensji INT PRIMARY KEY,
	stanowisko VARCHAR(30) NOT NULL,
	kwota DOUBLE PRECISION NOT NULL
);
CREATE TABLE ksiegowosc.premia (
	id_premii INT PRIMARY KEY,
	rodzaj VARCHAR(50),
	kwota DOUBLE PRECISION NOT NULL
);
--drop table if exists ksiegowosc.wynagrodzenie;
CREATE TABLE ksiegowosc.wynagrodzenie (
    id_wynagrodzenia INT PRIMARY KEY,
    data DATE, 
    id_pracownika INT NOT NULL,
    id_godziny INT NOT NULL,
    id_pensji INT NOT NULL,
    id_premii INT,
    CONSTRAINT fk_wynagrodzenie_pracownik FOREIGN KEY (id_pracownika)
        REFERENCES ksiegowosc.pracownicy (id_pracownika),
    CONSTRAINT fk_wynagrodzenie_godziny FOREIGN KEY (id_godziny)
        REFERENCES ksiegowosc.godziny (id_godziny),
    CONSTRAINT fk_wynagrodzenie_pensja FOREIGN KEY (id_pensji)
        REFERENCES ksiegowosc.pensja (id_pensji),
    CONSTRAINT fk_wynagrodzenie_premia FOREIGN KEY (id_premii)
        REFERENCES ksiegowosc.premia (id_premii));


-- Pracownicy
INSERT INTO ksiegowosc.pracownicy (id_pracownika, imie, nazwisko, adres, telefon) VALUES
(1, 'Maria', 'Zalewska', 'Kraków, ul. Zielona 10', '123456789'),
(2, 'Alicja', 'Nowak', 'Kraków, ul. Lipowa 20', '987654321'),
(3, 'Agata', 'Wiśniewska', 'Gdańsk, ul. Długa 15', '654321987'),
(4, 'Paweł', 'Piątkowski', 'Toruń, ul. Krótka 3', '321654987'),
(5, 'Piotr', 'Nowicki', 'Kraków, ul. Szeroka 8', '456789123'),
(6, 'Ewa', 'Farna', 'Łódź, ul. Prosta 18', '789123456'),
(7, 'Tomasz', 'Karolak', 'Kraków, ul. Leśna 12', '147258369'),
(8, 'Mikołaj', 'Ostrowski', 'Kraków, ul. Morska 22', '369258147'),
(9, 'Filip', 'Pawlak', 'Kraków, ul. Górnicza 9', '258147369'),
(10, 'Agnieszka', 'Nowicka', 'Kraków, ul. Polna 6', '159753486');

-- Godziny
INSERT INTO ksiegowosc.godziny (id_godziny, data, liczba_godzin, id_pracownika) VALUES
(1, '2024-11-30', 150, 1),
(2, '2024-11-29', 160, 2),
(3, '2024-11-28', 170, 3),
(4, '2024-11-30', 180, 4),
(5, '2024-11-30', 170, 5),
(6, '2024-11-29', 150, 6),
(7, '2024-11-29', 160, 7),
(8, '2024-11-28', 155, 8),
(9, '2024-11-30', 159, 9),
(10, '2024-11-29', 160, 10);

-- Pensja
INSERT INTO ksiegowosc.pensja (id_pensji, stanowisko, kwota) VALUES
(1, 'Manager', 3000),
(2, 'Kierownik', 4000),
(3, 'Kierownik', 5000),
(4, 'Specjalista', 6000),
(5, 'Dyrektor', 12000),
(6, 'Praktykant', 2000),
(7, 'Administrator', 4500),
(8, 'Kierownik', 5500),
(9, 'Analityk', 7000),
(10, 'Analityk', 7500);

-- Premia
INSERT INTO ksiegowosc.premia (id_premii, rodzaj, kwota) VALUES
(1, 'Okazjonalna', 500),
(2, 'Świąteczna', 1000),
(3, 'Roczna', 2000),
(4, 'Motywacyjna', 300),
(5, 'Za wyniki', 800),
(6, 'Uznaniowa', 600),
(7, 'Brak premii', 0),
(8, 'Projektowa', 1200),
(9, 'Sezonowa', 400),
(10, 'Specjalna', 1500);

-- Wynagrodzenie
INSERT INTO ksiegowosc.wynagrodzenie (id_wynagrodzenia, data, id_pracownika, id_godziny, id_pensji, id_premii) VALUES
(1, '2024-01-31', 1, 1, 1, 2),
(2, '2024-01-31', 2, 2, 2, 1),
(3, '2024-01-31', 3, 3, 3, 3),
(4, '2024-01-31', 4, 4, 4, null),
(5, '2024-01-31', 5, 5, 5, 5),
(6, '2024-01-31', 6, 6, 6, 6),
(7, '2024-01-31', 7, 7, 7, 1),
(8, '2024-01-31', 8, 8, 8, 8),
(9, '2024-01-31', 9, 9, 9, 9),
(10, '2024-01-31', 10, 10, 10, 10);

--A)
SELECT id_pracownika, nazwisko
FROM ksiegowosc.pracownicy;
--B)
SELECT w.id_pracownika
FROM ksiegowosc.wynagrodzenie w
JOIN ksiegowosc.pensja p ON w.id_pensji = p.id_pensji
WHERE p.kwota > 1000;
--C)
SELECT w.id_pracownika
FROM ksiegowosc.wynagrodzenie w
JOIN ksiegowosc.pensja p ON w.id_pensji = p.id_pensji
WHERE w.id_premii IS NULL
  AND p.kwota > 2000;
--D)
SELECT id_pracownika, imie, nazwisko
FROM ksiegowosc.pracownicy
WHERE imie LIKE 'J%';
--E)
SELECT id_pracownika, imie, nazwisko
FROM ksiegowosc.pracownicy
WHERE nazwisko LIKE '%n%'
  AND imie LIKE '%a';
--F)
SELECT p.imie, p.nazwisko, 
       (SUM(g.liczba_godzin) - 160) AS nadgodziny
FROM ksiegowosc.pracownicy p
JOIN ksiegowosc.godziny g ON p.id_pracownika = g.id_pracownika
GROUP BY p.id_pracownika
HAVING SUM(g.liczba_godzin) > 160;

--G)
SELECT p.imie, p.nazwisko
FROM ksiegowosc.pracownicy p
JOIN ksiegowosc.wynagrodzenie w ON p.id_pracownika = w.id_pracownika
JOIN ksiegowosc.pensja pe ON w.id_pensji = pe.id_pensji
WHERE pe.kwota BETWEEN 1500 AND 3000;

--H)
SELECT p.imie, p.nazwisko
FROM ksiegowosc.pracownicy p
JOIN ksiegowosc.godziny g ON p.id_pracownika = g.id_pracownika
JOIN ksiegowosc.wynagrodzenie w ON p.id_pracownika = w.id_pracownika
WHERE w.id_premii IS NULL
GROUP BY p.id_pracownika, p.imie, p.nazwisko
HAVING SUM(g.liczba_godzin) > 160;
--I)
SELECT p.imie, p.nazwisko, pe.kwota
FROM ksiegowosc.pracownicy p
JOIN ksiegowosc.wynagrodzenie w ON p.id_pracownika = w.id_pracownika
JOIN ksiegowosc.pensja pe ON w.id_pensji = pe.id_pensji
ORDER BY pe.kwota;

--J)
SELECT p.imie, p.nazwisko, pe.kwota AS pensja, pr.kwota AS premia
FROM ksiegowosc.pracownicy p
JOIN ksiegowosc.wynagrodzenie w ON p.id_pracownika = w.id_pracownika
JOIN ksiegowosc.pensja pe ON w.id_pensji = pe.id_pensji
LEFT JOIN ksiegowosc.premia pr ON w.id_premii = pr.id_premii
ORDER BY pe.kwota DESC, pr.kwota DESC;

--K)
SELECT p.stanowisko, COUNT(*) AS liczba_pracownikow
FROM ksiegowosc.pensja p
JOIN ksiegowosc.wynagrodzenie w ON p.id_pensji = w.id_pensji
GROUP BY p.stanowisko;
--L)
SELECT pe.stanowisko, AVG(pe.kwota) AS srednia_pensja, MIN(pe.kwota) AS min_pensja, MAX(pe.kwota) AS max_pensja
FROM ksiegowosc.pensja pe
JOIN ksiegowosc.wynagrodzenie w ON pe.id_pensji = w.id_pensji
WHERE pe.stanowisko = 'Kierownik'
GROUP BY pe.stanowisko;
--M)
SELECT SUM(pe.kwota) AS suma_wynagrodzen
FROM ksiegowosc.pensja pe
JOIN ksiegowosc.wynagrodzenie w ON pe.id_pensji = w.id_pensji;
--N)
SELECT pe.stanowisko, SUM(pe.kwota) AS suma_wynagrodzen
FROM ksiegowosc.pensja pe
JOIN ksiegowosc.wynagrodzenie w ON pe.id_pensji = w.id_pensji
JOIN ksiegowosc.pracownicy p ON w.id_pracownika = p.id_pracownika
GROUP BY pe.stanowisko;
--O)
SELECT pe.stanowisko, COUNT(pr.id_premii) AS liczba_premii
FROM ksiegowosc.pensja pe
JOIN ksiegowosc.wynagrodzenie w ON pe.id_pensji = w.id_pensji
LEFT JOIN ksiegowosc.premia pr ON w.id_premii = pr.id_premii
JOIN ksiegowosc.pracownicy p ON w.id_pracownika = p.id_pracownika
GROUP BY pe.stanowisko;

--P)
DELETE FROM ksiegowosc.pracownicy
WHERE id_pracownika IN (
    SELECT w.id_pracownika
    FROM ksiegowosc.wynagrodzenie w
    JOIN ksiegowosc.pensja pe ON w.id_pensji = pe.id_pensji
    WHERE pe.kwota < 1200
);





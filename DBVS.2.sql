USE RRT;
GO

-- 1. Miestų kiekis
SELECT COUNT(*) AS miestu_kiekis
FROM Miestas;
GO

-- 2. Planai su įtrauktu interneto planu + interneto plano info + operatorius
SELECT pl.planoPavadinimas        AS planas,
       pl.kaina                   AS plano_kaina,
       ip.intPlanoPavadinimas     AS interneto_planas,
       ip.kiekisMB                AS interneto_MB,
       ip.kaina                   AS interneto_plano_kaina,
       o.operatoriausPavadinimas  AS operatorius
FROM Planas pl
JOIN InternetoPlanas ip ON ip.internetoPlanoID = pl.internetoPlanoID
JOIN Operatorius o      ON o.operatoriausID   = pl.operatoriausID
ORDER BY operatorius, planas;
GO

-- 3. Operatoriai ir jų planai, kuriuose yra >= 100 nemokamų minučių.
SELECT o.operatoriausPavadinimas AS operatorius,
       pl.planoPavadinimas       AS planas,
       pl.kaina,
       l.kiekis                  AS nemokamos_minutes
FROM Planas pl
JOIN Operatorius o    ON o.operatoriausID = pl.operatoriausID
JOIN PlanoRinkinys pr ON pr.planoID       = pl.planoID
JOIN Paslauga p       ON p.paslaugosID    = pr.paslaugosID
JOIN Lengvata l       ON l.rinkinioID     = pr.rinkinioID
WHERE p.paslaugosPavadinimas LIKE '%Lietuv%'   -- pokalbiai Lietuvos tinkle
  AND (p.paslaugosPavadinimas LIKE '%pokalb%' OR p.paslaugosPavadinimas LIKE '%skamb%')
  AND l.kiekis >= 100
ORDER BY operatorius, planas;
GO

-- 4. Naudotojų kiekis kiekviename mieste
SELECT m.miestoPavadinimas AS miestas,
       COUNT(a.asmensID)   AS naudotoju_kiekis
FROM Miestas m
LEFT JOIN Asmuo a ON a.miestoID = m.miestoID
GROUP BY m.miestoID, m.miestoPavadinimas
ORDER BY naudotoju_kiekis DESC, miestas;
GO

-- 5. Miestai, kuriuose nėra naudotojų
SELECT m.miestoPavadinimas AS miestas
FROM Miestas m
WHERE NOT EXISTS (SELECT 1 FROM Asmuo a WHERE a.miestoID = m.miestoID)
ORDER BY miestas;
GO

-- 6. Vidutinis naudotojų kiekis mieste
SELECT CAST(AVG(CASE WHEN kiekis > 0 THEN kiekis * 1.0 END) AS DECIMAL(10, 2)) AS vidurkis_be_tusciu_miestu,
       CAST(AVG(kiekis * 1.0) AS DECIMAL(10, 2))                              AS vidurkis_su_tusciais_miestais
FROM (
    SELECT m.miestoID, COUNT(a.asmensID) AS kiekis
    FROM Miestas m
    LEFT JOIN Asmuo a ON a.miestoID = m.miestoID
    GROUP BY m.miestoID
) t;
GO

-- 7. Operatoriai, siūlantis daugiausiai planų
SELECT TOP 1 WITH TIES
       o.operatoriausPavadinimas AS operatorius,
       COUNT(pl.planoID)         AS planu_kiekis
FROM Operatorius o
JOIN Planas pl ON pl.operatoriausID = o.operatoriausID
GROUP BY o.operatoriausID, o.operatoriausPavadinimas
ORDER BY planu_kiekis DESC;
GO

-- 8. Asmenys, užsisakę planą 2025-01-03 – 2025-01-10
SELECT asm.vardas,
       asm.pavarde,
       pl.planoPavadinimas AS planas,
       a.sutartiesPradzia
FROM Abonentas a
JOIN Asmuo asm ON asm.asmensID = a.asmensID
JOIN Planas pl ON pl.planoID   = a.planoID
WHERE a.sutartiesPradzia BETWEEN '2025-01-03' AND '2025-01-10'
ORDER BY a.sutartiesPradzia, asm.pavarde;
GO

-- 9. Operatorių planų kainų vidurkis mažėjimo tvarka
SELECT o.operatoriausPavadinimas            AS operatorius,
       CAST(AVG(pl.kaina) AS DECIMAL(10, 2)) AS vidutine_kaina
FROM Operatorius o
JOIN Planas pl ON pl.operatoriausID = o.operatoriausID
GROUP BY o.operatoriausID, o.operatoriausPavadinimas
ORDER BY vidutine_kaina DESC;
GO

-- 10. Kiek papildomų paslaugų teikia kiekvienas operatorius
SELECT o.operatoriausPavadinimas             AS operatorius,
       COUNT(opp.papildomosPaslaugosID)      AS paslaugu_kiekis
FROM Operatorius o
LEFT JOIN OperatoriausPapildomaPaslauga opp ON opp.operatoriausID = o.operatoriausID
GROUP BY o.operatoriausID, o.operatoriausPavadinimas
ORDER BY paslaugu_kiekis DESC;
GO
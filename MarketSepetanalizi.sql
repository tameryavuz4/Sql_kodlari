
CREATE VIEW GENIUS3.WV_MARKET_SEPET
AS
SELECT TS.FK_TRANSACTION_HEADER AS ID,
       TS.CODE AS KOD
FROM GENIUS3.TRANSACTION_SALE TS
    INNER JOIN GENIUS3.TRANSACTION_HEADER TH
        ON TS.FK_TRANSACTION_HEADER = TH.ID
WHERE TH.TRANS_DATE >= '01.01.2025'
      AND TH.TRANS_DATE < '01.02.2025'
      AND TH.PTYPE = 0
      AND TH.STATUS = 0;
SELECT ID,
       COUNT(KOD) AS ÜrünSayýsý
FROM WV_MARKET_SEPET
GROUP BY ID
HAVING COUNT(KOD) > 10;
WITH TransactionProducts
AS (SELECT ID,
           KOD
    FROM WV_MARKET_SEPET)
SELECT tp1.KOD AS Product1,
       tp2.KOD AS Product2,
       COUNT(*) AS PairCount
FROM TransactionProducts tp1
    JOIN TransactionProducts tp2
        ON tp1.ID = tp2.ID
           AND tp1.KOD < tp2.KOD
GROUP BY tp1.KOD,
         tp2.KOD
ORDER BY PairCount DESC;

SELECT KOD,
       COUNT(DISTINCT ID) AS TransactionCount,
       COUNT(DISTINCT ID) * 1.0 /
       (
           SELECT COUNT(DISTINCT ID)FROM WV_MARKET_SEPET
       ) AS Support
FROM WV_MARKET_SEPET
GROUP BY KOD;
WITH ProductSupport
AS (SELECT KOD,
           COUNT(DISTINCT ID) AS TransactionCount,
           COUNT(DISTINCT ID) * 1.0 /
           (
               SELECT COUNT(DISTINCT ID)FROM WV_MARKET_SEPET
           ) AS Support
    FROM WV_MARKET_SEPET
    GROUP BY KOD),
     PairSupport
AS (SELECT tp1.KOD AS Ürün1,
           tp2.KOD AS Ürün2,
           COUNT(DISTINCT tp1.ID) AS PairTransactionCount,
           COUNT(DISTINCT tp1.ID) * 1.0 /
           (
               SELECT COUNT(DISTINCT ID)FROM WV_MARKET_SEPET
           ) AS PairSupport
    FROM WV_MARKET_SEPET tp1
        JOIN WV_MARKET_SEPET tp2
            ON tp1.ID = tp2.ID
               AND tp1.KOD < tp2.KOD
    GROUP BY tp1.KOD,
             tp2.KOD)
SELECT ps.Ürün1,
       ps.Ürün2,
       ps.PairSupport  AS 'Destek Ürün 1-Ürün2',
       ps.PairSupport / p1.Support AS 'Confidence_Ürün1-Ürün2',
       ps.PairSupport / p2.Support AS 'Confidence_Ürün2-Ürün1',
       (ps.PairSupport) / (p1.Support * p2.Support) AS 'Lift'
FROM PairSupport ps
    JOIN ProductSupport p1
        ON ps.Ürün1 = p1.KOD
    JOIN ProductSupport p2
        ON ps.Ürün2 = p2.KOD
        WHERE (ps.PairSupport) / (p1.Support * p2.Support)>1000
ORDER BY Lift DESC;


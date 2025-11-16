/**TABLOLAR VARSA SÝL  **/
IF OBJECT_ID('tempdb..#foo') IS NOT NULL DROP TABLE #foo
IF OBJECT_ID('bubbleSort') IS NOT NULL DROP PROCEDURE bubbleSort
GO
/**TABLO OLUÞTUR  **/
CREATE TABLE #foo (
	[position] INT IDENTITY (1,1)
	, [value] INT
	)
GO


/**TABLOYU DOLDUR  **/
DECLARE @i int = 0
WHILE @i < 500
BEGIN
INSERT #foo SELECT CONVERT(INT, RAND() * 10000)
  SET @i = @i + 1
  end



-- buble sort prosedürü. 
create PROCEDURE bubbleSort 
	AS BEGIN

	SET NOCOUNT ON
	CREATE TABLE #t (
		[order] INT
		, [value] INT
		)

	DECLARE
		@takas BIT
		, @sayac INT
		, @topVal INT

	-- Populate #t
	INSERT INTO #t (
		[order]
		, [value]
		)
	SELECT
		ROW_NUMBER() OVER(ORDER BY [position] ASC)
		, [value]
	FROM
		#foo

	SELECT
		@takas = 1
		, @sayac = 1
		, @topVal = COUNT([order])
	FROM
		#t

	IF ( ISNULL(@topVal, -1) < 2 ) BEGIN
		PRINT 'Veri yok'
		SELECT * FROM #t
		RETURN
	END

	WHILE (@takas = 1) BEGIN

		SET @sayac = 1
		SET @takas = 0

		WHILE (@sayac < @topVal) BEGIN
		
			IF ((SELECT [value] FROM #t WHERE [order] = @sayac) > (SELECT [value] FROM #t WHERE [order] = @sayac + 1)) BEGIN
				UPDATE #t SET [order] = -1 WHERE [order] = @sayac + 1
				UPDATE #t SET [order] = @sayac + 1 WHERE [order] = @sayac
				UPDATE #t SET [order] = @sayac WHERE [order] = -1
				SET @takas = 1
			END
		
			SET @sayac = @sayac + 1
		END
	END

	SELECT * FROM #t ORDER BY [order]
END
GO


-- prosedürü çaðýr 
EXEC bubbleSort

--sql order by
select value FROM #foo ORDER BY value 

CREATE TYPE CinemaType AS TABLE (Name VARCHAR(30), City VARCHAR(30), Street VARCHAR(100), PostCode CHAR(6), OpenedDate DATE);
CREATE TYPE HallsType AS TABLE (Name VARCHAR(50), Floor VARCHAR(5), ScreenQuality VARCHAR(10), NumberOfSeats INT, NumberOfRows INT);

CREATE OR ALTER PROCEDURE AddCinema
@cinema CinemaType READONLY,
@halls HallsType READONLY
AS
	DECLARE @CinemaId INT,
			@HallId INT,
			@Name VARCHAR(50), 
			@Floor VARCHAR(5), 
			@ScreenQuality VARCHAR(10), 
			@NumberOfSeats INT, 
			@NumberOfRows INT,
			@i INT;

	INSERT INTO Cinemas (Name, City, Street, PostCode, OpenedDate)
		SELECT Name, City, Street, PostCode, OpenedDate FROM @cinema;
	SET @CinemaId  = SCOPE_IDENTITY();

	DECLARE HallsCursor CURSOR FOR
	SELECT Name, Floor, ScreenQuality, NumberOfSeats, NumberOfRows
	FROM @halls;

	OPEN HallsCursor;

	FETCH NEXT FROM HallsCursor
	INTO @Name, @Floor, @ScreenQuality, @NumberOfSeats, @NumberOfRows
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO CinemaHalls (Name, Floor, ScreenQuality, CinemaId)
			VALUES (@Name, @Floor, @ScreenQuality, @CinemaId)
		SET @HallId = SCOPE_IDENTITY();
		SET @i = 0;
		WHILE @i < @NumberOfSeats
		BEGIN
			SET @i = @i +1;
			INSERT INTO CinemaHallsSeats (SeatNumber, Row, HallId)
				VALUES (@i, (SELECT (@i - 1) / @NumberOfRows + 1 AS INT), @HallId);

		END

		FETCH NEXT FROM HallsCursor
		INTO @Name, @Floor, @ScreenQuality, @NumberOfSeats, @NumberOfRows
	END


	CLOSE HallsCursor;
	DEALLOCATE HallsCursor;

SELECT * FROM @halls;

BEGIN 
DECLARE @NewCinema AS CinemaType,
		@HallsForCinema AS HallsType;

INSERT INTO @NewCinema VALUES ('Diamond Cinema - second attempt', 'Barcelona', 'La Rambla 21', '10-298', GETDATE());

INSERT INTO @HallsForCinema VALUES ('New Hall No. 1', '1', '4K', 40, 4);
INSERT INTO @HallsForCinema VALUES ('New Hall No. 2', '1', '4K', 50, 5);
INSERT INTO @HallsForCinema VALUES ('New Hall No. 3', '1', '4K', 60, 6);
INSERT INTO @HallsForCinema VALUES ('New Hall No. 4', '1', '4K', 20, 2);
INSERT INTO @HallsForCinema VALUES ('New Hall No. 5', '1', '4K', 5, 1);

EXECUTE AddCinema @NewCinema, @HallsForCinema;

END;



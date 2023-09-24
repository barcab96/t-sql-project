USE SmartCinemas;

CREATE OR ALTER FUNCTION FreeSeats (@SessionId INT, @NumberOfSeats INT)
RETURNS @SeatList TABLE (
SeatId INT,
SeatNumber INT,
Row INT
)

AS 
BEGIN
	DECLARE @HallId INT;
	SELECT @HallId = FilmId FROM Sessions WHERE Id = @SessionId;
	IF @HallId IS NOT NULL
	INSERT INTO @SeatList
	SELECT TOP (@NumberOfSeats) id, SeatNumber, Row
	FROM CinemaHallsSeats
	WHERE HallId = @HallId AND Id NOT IN (SELECT SeatId FROM Reservations WHERE SessionId = @SessionId);
	
	RETURN
END;
-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:UpcomingWeekdayTime_ToDtm_fn stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE FUNCTION UpcomingWeekdayTime_ToDtm_fn
(
    @Weekday _Weekday, -- 1 Monday, 2 Tuesday, ... , 7 Sunday
    @Time    _Time -- e.g. 12:00
) RETURNS _Dtm
AS
BEGIN

    IF @Weekday NOT BETWEEN 1 AND 7 OR @Time IS NULL
        RETURN NULL;

    DECLARE @CurrentDatetime DATETIMEOFFSET = SYSDATETIMEOFFSET();

    -- Get the current weekday as a number compatible with DayOfWeek numbering scheme.
    -- The numbering scheme is maintained regardless of the currently configured @@DATEFIRST.
    DECLARE @CurrentWeekday INT = (DATEPART(WEEKDAY, @CurrentDatetime) + @@DATEFIRST + 5) % 7 + 1;

    -- Calculate the number of days to add to reach the desired weekday
    DECLARE @DaysToAdd INT = CASE WHEN @CurrentWeekday <= @Weekday THEN @Weekday - @CurrentWeekday
                                  ELSE 7 - (@CurrentWeekday - @Weekday)
                             END

    -- Calculate the time difference in minutes between the current time and the input time
    DECLARE @TimeDiffMinutes INT = DATEDIFF(SECOND, CONVERT(TIME(0), @CurrentDatetime), @Time);

    -- Calculate the DATETIMEOFFSET of the upcoming weekday and time
    RETURN DATEADD(SECOND, @TimeDiffMinutes, DATEADD(DAY, @DaysToAdd, @CurrentDatetime));
END
GO
-- rollback DROP FUNCTION UpcomingWeekdayTime_ToDtm_fn;
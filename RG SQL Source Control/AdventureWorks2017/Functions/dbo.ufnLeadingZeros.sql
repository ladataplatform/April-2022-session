SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[ufnLeadingZeros](
    @Value int
) 
RETURNS varchar(8) 
WITH SCHEMABINDING 
AS 
BEGIN
    DECLARE @ReturnValue varchar(8);

    SET @ReturnValue = CONVERT(varchar(8), @Value);
    SET @ReturnValue = REPLICATE('0', 8 - DATALENGTH(@ReturnValue)) + @ReturnValue;

    RETURN (@ReturnValue);
END;
GO
EXEC sp_addextendedproperty N'MS_Description', N'Scalar function used by the Sales.Customer table to help set the account number.', 'SCHEMA', N'dbo', 'FUNCTION', N'ufnLeadingZeros', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Input parameter for the scalar function ufnLeadingZeros. Enter a valid integer.', 'SCHEMA', N'dbo', 'FUNCTION', N'ufnLeadingZeros', 'PARAMETER', N'@Value'
GO

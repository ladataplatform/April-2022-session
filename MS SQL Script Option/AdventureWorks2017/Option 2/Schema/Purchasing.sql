USE [AdventureWorks2017]
GO
/****** Object:  Schema [Purchasing]    Script Date: 4/20/2022 9:37:58 PM ******/
CREATE SCHEMA [Purchasing]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains objects related to vendors and purchase orders.' , @level0type=N'SCHEMA',@level0name=N'Purchasing'
GO

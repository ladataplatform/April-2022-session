USE [AdventureWorks2017]
GO
/****** Object:  Schema [Production]    Script Date: 4/20/2022 9:37:58 PM ******/
CREATE SCHEMA [Production]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains objects related to products, inventory, and manufacturing.' , @level0type=N'SCHEMA',@level0name=N'Production'
GO

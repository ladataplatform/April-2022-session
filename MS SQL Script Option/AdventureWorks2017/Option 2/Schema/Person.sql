USE [AdventureWorks2017]
GO
/****** Object:  Schema [Person]    Script Date: 4/20/2022 9:37:58 PM ******/
CREATE SCHEMA [Person]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains objects related to names and addresses of customers, vendors, and employees' , @level0type=N'SCHEMA',@level0name=N'Person'
GO

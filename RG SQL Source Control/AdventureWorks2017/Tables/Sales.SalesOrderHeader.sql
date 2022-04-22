CREATE TABLE [Sales].[SalesOrderHeader]
(
[SalesOrderID] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[RevisionNumber] [tinyint] NOT NULL CONSTRAINT [DF_SalesOrderHeader_RevisionNumber] DEFAULT ((0)),
[OrderDate] [datetime] NOT NULL CONSTRAINT [DF_SalesOrderHeader_OrderDate] DEFAULT (getdate()),
[DueDate] [datetime] NOT NULL,
[ShipDate] [datetime] NULL,
[Status] [tinyint] NOT NULL CONSTRAINT [DF_SalesOrderHeader_Status] DEFAULT ((1)),
[OnlineOrderFlag] [dbo].[Flag] NOT NULL CONSTRAINT [DF_SalesOrderHeader_OnlineOrderFlag] DEFAULT ((1)),
[SalesOrderNumber] AS (isnull(N'SO'+CONVERT([nvarchar](23),[SalesOrderID],(0)),N'*** ERROR ***')),
[PurchaseOrderNumber] [dbo].[OrderNumber] NULL,
[AccountNumber] [dbo].[AccountNumber] NULL,
[CustomerID] [int] NOT NULL,
[SalesPersonID] [int] NULL,
[TerritoryID] [int] NULL,
[BillToAddressID] [int] NOT NULL,
[ShipToAddressID] [int] NOT NULL,
[ShipMethodID] [int] NOT NULL,
[CreditCardID] [int] NULL,
[CreditCardApprovalCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyRateID] [int] NULL,
[SubTotal] [money] NOT NULL CONSTRAINT [DF_SalesOrderHeader_SubTotal] DEFAULT ((0.00)),
[TaxAmt] [money] NOT NULL CONSTRAINT [DF_SalesOrderHeader_TaxAmt] DEFAULT ((0.00)),
[Freight] [money] NOT NULL CONSTRAINT [DF_SalesOrderHeader_Freight] DEFAULT ((0.00)),
[TotalDue] AS (isnull(([SubTotal]+[TaxAmt])+[Freight],(0))),
[Comment] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowguid] [uniqueidentifier] NOT NULL ROWGUIDCOL CONSTRAINT [DF_SalesOrderHeader_rowguid] DEFAULT (newid()),
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SalesOrderHeader_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [Sales].[uSalesOrderHeader] ON [Sales].[SalesOrderHeader] 
AFTER UPDATE NOT FOR REPLICATION AS 
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    SET NOCOUNT ON;

    BEGIN TRY
        -- Update RevisionNumber for modification of any field EXCEPT the Status.
        IF NOT UPDATE([Status])
        BEGIN
            UPDATE [Sales].[SalesOrderHeader]
            SET [Sales].[SalesOrderHeader].[RevisionNumber] = 
                [Sales].[SalesOrderHeader].[RevisionNumber] + 1
            WHERE [Sales].[SalesOrderHeader].[SalesOrderID] IN 
                (SELECT inserted.[SalesOrderID] FROM inserted);
        END;

        -- Update the SalesPerson SalesYTD when SubTotal is updated
        IF UPDATE([SubTotal])
        BEGIN
            DECLARE @StartDate datetime,
                    @EndDate datetime

            SET @StartDate = [dbo].[ufnGetAccountingStartDate]();
            SET @EndDate = [dbo].[ufnGetAccountingEndDate]();

            UPDATE [Sales].[SalesPerson]
            SET [Sales].[SalesPerson].[SalesYTD] = 
                (SELECT SUM([Sales].[SalesOrderHeader].[SubTotal])
                FROM [Sales].[SalesOrderHeader] 
                WHERE [Sales].[SalesPerson].[BusinessEntityID] = [Sales].[SalesOrderHeader].[SalesPersonID]
                    AND ([Sales].[SalesOrderHeader].[Status] = 5) -- Shipped
                    AND [Sales].[SalesOrderHeader].[OrderDate] BETWEEN @StartDate AND @EndDate)
            WHERE [Sales].[SalesPerson].[BusinessEntityID] 
                IN (SELECT DISTINCT inserted.[SalesPersonID] FROM inserted 
                    WHERE inserted.[OrderDate] BETWEEN @StartDate AND @EndDate);

            -- Update the SalesTerritory SalesYTD when SubTotal is updated
            UPDATE [Sales].[SalesTerritory]
            SET [Sales].[SalesTerritory].[SalesYTD] = 
                (SELECT SUM([Sales].[SalesOrderHeader].[SubTotal])
                FROM [Sales].[SalesOrderHeader] 
                WHERE [Sales].[SalesTerritory].[TerritoryID] = [Sales].[SalesOrderHeader].[TerritoryID]
                    AND ([Sales].[SalesOrderHeader].[Status] = 5) -- Shipped
                    AND [Sales].[SalesOrderHeader].[OrderDate] BETWEEN @StartDate AND @EndDate)
            WHERE [Sales].[SalesTerritory].[TerritoryID] 
                IN (SELECT DISTINCT inserted.[TerritoryID] FROM inserted 
                    WHERE inserted.[OrderDate] BETWEEN @StartDate AND @EndDate);
        END;
    END TRY
    BEGIN CATCH
        EXECUTE [dbo].[uspPrintError];

        -- Rollback any active or uncommittable transactions before
        -- inserting information in the ErrorLog
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;
GO
ALTER TABLE [Sales].[SalesOrderHeader] ADD CONSTRAINT [CK_SalesOrderHeader_DueDate] CHECK (([DueDate]>=[OrderDate]))
GO
ALTER TABLE [Sales].[SalesOrderHeader] ADD CONSTRAINT [CK_SalesOrderHeader_Freight] CHECK (([Freight]>=(0.00)))
GO
ALTER TABLE [Sales].[SalesOrderHeader] ADD CONSTRAINT [CK_SalesOrderHeader_ShipDate] CHECK (([ShipDate]>=[OrderDate] OR [ShipDate] IS NULL))
GO
ALTER TABLE [Sales].[SalesOrderHeader] ADD CONSTRAINT [CK_SalesOrderHeader_Status] CHECK (([Status]>=(0) AND [Status]<=(8)))
GO
ALTER TABLE [Sales].[SalesOrderHeader] ADD CONSTRAINT [CK_SalesOrderHeader_SubTotal] CHECK (([SubTotal]>=(0.00)))
GO
ALTER TABLE [Sales].[SalesOrderHeader] ADD CONSTRAINT [CK_SalesOrderHeader_TaxAmt] CHECK (([TaxAmt]>=(0.00)))
GO
ALTER TABLE [Sales].[SalesOrderHeader] ADD CONSTRAINT [PK_SalesOrderHeader_SalesOrderID] PRIMARY KEY CLUSTERED ([SalesOrderID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SalesOrderHeader_CustomerID] ON [Sales].[SalesOrderHeader] ([CustomerID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_SalesOrderHeader_rowguid] ON [Sales].[SalesOrderHeader] ([rowguid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_SalesOrderHeader_SalesOrderNumber] ON [Sales].[SalesOrderHeader] ([SalesOrderNumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SalesOrderHeader_SalesPersonID] ON [Sales].[SalesOrderHeader] ([SalesPersonID]) ON [PRIMARY]
GO
ALTER TABLE [Sales].[SalesOrderHeader] ADD CONSTRAINT [FK_SalesOrderHeader_Address_BillToAddressID] FOREIGN KEY ([BillToAddressID]) REFERENCES [Person].[Address] ([AddressID])
GO
ALTER TABLE [Sales].[SalesOrderHeader] ADD CONSTRAINT [FK_SalesOrderHeader_Address_ShipToAddressID] FOREIGN KEY ([ShipToAddressID]) REFERENCES [Person].[Address] ([AddressID])
GO
ALTER TABLE [Sales].[SalesOrderHeader] ADD CONSTRAINT [FK_SalesOrderHeader_CreditCard_CreditCardID] FOREIGN KEY ([CreditCardID]) REFERENCES [Sales].[CreditCard] ([CreditCardID])
GO
ALTER TABLE [Sales].[SalesOrderHeader] ADD CONSTRAINT [FK_SalesOrderHeader_CurrencyRate_CurrencyRateID] FOREIGN KEY ([CurrencyRateID]) REFERENCES [Sales].[CurrencyRate] ([CurrencyRateID])
GO
ALTER TABLE [Sales].[SalesOrderHeader] ADD CONSTRAINT [FK_SalesOrderHeader_Customer_CustomerID] FOREIGN KEY ([CustomerID]) REFERENCES [Sales].[Customer] ([CustomerID])
GO
ALTER TABLE [Sales].[SalesOrderHeader] ADD CONSTRAINT [FK_SalesOrderHeader_SalesPerson_SalesPersonID] FOREIGN KEY ([SalesPersonID]) REFERENCES [Sales].[SalesPerson] ([BusinessEntityID])
GO
ALTER TABLE [Sales].[SalesOrderHeader] ADD CONSTRAINT [FK_SalesOrderHeader_SalesTerritory_TerritoryID] FOREIGN KEY ([TerritoryID]) REFERENCES [Sales].[SalesTerritory] ([TerritoryID])
GO
ALTER TABLE [Sales].[SalesOrderHeader] ADD CONSTRAINT [FK_SalesOrderHeader_ShipMethod_ShipMethodID] FOREIGN KEY ([ShipMethodID]) REFERENCES [Purchasing].[ShipMethod] ([ShipMethodID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'General sales order information.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Financial accounting number reference.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'AccountNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Customer billing address. Foreign key to Address.AddressID.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'BillToAddressID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sales representative comments.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'Comment'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Approval code provided by the credit card company.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'CreditCardApprovalCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Credit card identification number. Foreign key to CreditCard.CreditCardID.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'CreditCardID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Currency exchange rate used. Foreign key to CurrencyRate.CurrencyRateID.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'CurrencyRateID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Customer identification number. Foreign key to Customer.BusinessEntityID.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'CustomerID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date the order is due to the customer.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'DueDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Shipping cost.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'Freight'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'0 = Order placed by sales person. 1 = Order placed online by customer.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'OnlineOrderFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Dates the sales order was created.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'OrderDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Customer purchase order number reference. ', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'PurchaseOrderNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Incremental number to track changes to the sales order over time.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'RevisionNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'SalesOrderID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sales order identification number.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'SalesOrderNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sales person who created the sales order. Foreign key to SalesPerson.BusinessEntityID.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'SalesPersonID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date the order was shipped to the customer.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'ShipDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Shipping method. Foreign key to ShipMethod.ShipMethodID.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'ShipMethodID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Customer shipping address. Foreign key to Address.AddressID.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'ShipToAddressID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Order current status. 1 = In process; 2 = Approved; 3 = Backordered; 4 = Rejected; 5 = Shipped; 6 = Cancelled', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sales subtotal. Computed as SUM(SalesOrderDetail.LineTotal)for the appropriate SalesOrderID.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'SubTotal'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tax amount.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'TaxAmt'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Territory in which the sale was made. Foreign key to SalesTerritory.SalesTerritoryID.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'TerritoryID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total due from customer. Computed as Subtotal + TaxAmt + Freight.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'COLUMN', N'TotalDue'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [DueDate] >= [OrderDate]', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'CK_SalesOrderHeader_DueDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [Freight] >= (0.00)', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'CK_SalesOrderHeader_Freight'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [ShipDate] >= [OrderDate] OR [ShipDate] IS NULL', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'CK_SalesOrderHeader_ShipDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [Status] BETWEEN (0) AND (8)', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'CK_SalesOrderHeader_Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [SubTotal] >= (0.00)', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'CK_SalesOrderHeader_SubTotal'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [TaxAmt] >= (0.00)', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'CK_SalesOrderHeader_TaxAmt'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0.0', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'DF_SalesOrderHeader_Freight'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'DF_SalesOrderHeader_ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 1 (TRUE)', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'DF_SalesOrderHeader_OnlineOrderFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'DF_SalesOrderHeader_OrderDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'DF_SalesOrderHeader_RevisionNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of NEWID()', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'DF_SalesOrderHeader_rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 1', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'DF_SalesOrderHeader_Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0.0', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'DF_SalesOrderHeader_SubTotal'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0.0', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'DF_SalesOrderHeader_TaxAmt'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Address.AddressID.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'FK_SalesOrderHeader_Address_BillToAddressID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Address.AddressID.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'FK_SalesOrderHeader_Address_ShipToAddressID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing CreditCard.CreditCardID.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'FK_SalesOrderHeader_CreditCard_CreditCardID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing CurrencyRate.CurrencyRateID.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'FK_SalesOrderHeader_CurrencyRate_CurrencyRateID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Customer.CustomerID.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'FK_SalesOrderHeader_Customer_CustomerID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing SalesPerson.SalesPersonID.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'FK_SalesOrderHeader_SalesPerson_SalesPersonID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing SalesTerritory.TerritoryID.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'FK_SalesOrderHeader_SalesTerritory_TerritoryID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing ShipMethod.ShipMethodID.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'FK_SalesOrderHeader_ShipMethod_ShipMethodID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key (clustered) constraint', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'CONSTRAINT', N'PK_SalesOrderHeader_SalesOrderID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'INDEX', N'AK_SalesOrderHeader_rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique nonclustered index.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'INDEX', N'AK_SalesOrderHeader_SalesOrderNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Nonclustered index.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'INDEX', N'IX_SalesOrderHeader_CustomerID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Nonclustered index.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'INDEX', N'IX_SalesOrderHeader_SalesPersonID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Clustered index created by a primary key constraint.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'INDEX', N'PK_SalesOrderHeader_SalesOrderID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'AFTER UPDATE trigger that updates the RevisionNumber and ModifiedDate columns in the SalesOrderHeader table.Updates the SalesYTD column in the SalesPerson and SalesTerritory tables.', 'SCHEMA', N'Sales', 'TABLE', N'SalesOrderHeader', 'TRIGGER', N'uSalesOrderHeader'
GO

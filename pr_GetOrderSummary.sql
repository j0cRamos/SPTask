USE [Northwind]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jose Ramos
-- Create date: 07/01/2023
-- Description:	Derivco Test
-- =============================================
CREATE PROCEDURE [dbo].[pr_GetOrderSummary]
	@StartDate Date, 
	@EndDate Date,
	@EmployeeID Int = NULL,
	@CustomerID nChar(5) = NULL

AS
BEGIN
	SET NOCOUNT ON;

	SELECT	CONCAT(Emp.TitleOfCourtesy ,' ', Emp.FirstName ,' ', Emp.LastName) EmployeeFullName ,
			Shi.CompanyName AS ShipperCompanyName,
			Cus.CompanyName AS CustomerCompanyName,
			COUNT(DISTINCT Ord.OrderID) AS NumberOfOders,
			Ord.OrderDate AS Date,	
			SUM(Ord.Freight) AS TotalFreightCost,
			SUM(OrdD.NumberOfDifferentProducts) AS NumberOfDifferentProducts,
			SUM(OrdD.TotalOrderValue) AS TotalOrderValue
	FROM [dbo].[Orders] Ord
	INNER JOIN [dbo].[Employees] Emp
		ON Emp.EmployeeID=Ord.EmployeeID
	INNER JOIN [dbo].[Shippers] Shi
		ON Shi.ShipperID=Ord.ShipVia
	INNER JOIN [dbo].[Customers] Cus
		ON Cus.CustomerID=Ord.CustomerID
	INNER JOIN (SELECT OrdD.OrderID, COUNT(DISTINCT OrdD.ProductID) AS NumberOfDifferentProducts,
					SUM(CONVERT(money, (OrdD.UnitPrice * OrdD.Quantity) * (1 - OrdD.Discount) / 100) * 100) AS TotalOrderValue
				FROM [dbo].[Order Details] OrdD
				GROUP BY OrdD.OrderID
				) OrdD
		ON OrdD.OrderID=Ord.OrderID
	WHERE	[OrderDate]>= @StartDate and [OrderDate]<= @EndDate AND
			(@EmployeeID IS NULL OR Ord.EmployeeID = @EmployeeID) AND
			(@CustomerID IS NULL OR Ord.CustomerID = @CustomerID)
	GROUP BY	
			Ord.OrderDate,
			CONCAT(Emp.TitleOfCourtesy ,' ', Emp.FirstName ,' ', Emp.LastName),
			Cus.CompanyName,
			Shi.CompanyName


END
GO



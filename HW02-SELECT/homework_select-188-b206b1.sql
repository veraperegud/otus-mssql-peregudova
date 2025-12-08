/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT 
      [StockItemID]
      ,[StockItemName]
FROM [WideWorldImporters].[Warehouse].[StockItems]
WHERE ([StockItemName] LIKE '%urgent%') OR  ([StockItemName] LIKE 'Animal%')

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT S.[SupplierID]
      ,S.[SupplierName]
FROM [WideWorldImporters].[Purchasing].[Suppliers] S
LEFT JOIN [WideWorldImporters].[Purchasing].[PurchaseOrders] P ON P.SupplierID=S.SupplierID
WHERE P.[SupplierID] IS NULL

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

DECLARE @dt datetime2 = sysdatetime()
SELECT 
        CASE 
        WHEN MONTH(@dt) BETWEEN 1 AND 4 THEN '1'
        WHEN MONTH(@dt) BETWEEN 5 AND 8 THEN '2'
        WHEN MONTH(@dt) BETWEEN 9 AND 12 THEN '3'
        END AS [Треть года]
      ,T3.[OrderID]
      ,FORMAT(T1.[OrderDate], 'D', 'ru-ru') AS [Дата заказа]
      ,datename(month, @dt) AS "Месяц"
      ,datepart(quarter, @dt) AS 'Квартал'
      ,T2.[CustomerName]
  FROM [WideWorldImporters].[Sales].[Orders] T1
  JOIN [WideWorldImporters].[Sales].[Customers] T2 ON T2.[CustomerID] = T1.[CustomerID]
  JOIN [WideWorldImporters].[Sales].[OrderLines] T3 ON T3.[OrderID] = T1.[OrderID]
  WHERE  (T3.[UnitPrice] > 100 OR T3.[Quantity] > 20)
    AND T1.[PickingCompletedWhen] IS NOT NULL

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT 
T3.[DeliveryMethodName]
,T4.[ExpectedDeliveryDate]
,T1.[SupplierName]
,T4.[ContactPersonID]
  FROM [WideWorldImporters].[Purchasing].[Suppliers] T1
  JOIN [WideWorldImporters].[Application].[People] T2 ON  T2.[PersonID]= T1.[PrimaryContactPersonID]
  JOIN [WideWorldImporters].[Application].[DeliveryMethods] T3 ON T3.[DeliveryMethodID] = T1.[DeliveryMethodID]
  JOIN [WideWorldImporters].[Purchasing].[PurchaseOrders] T4 ON T4.[SupplierID] = T1.[SupplierID]
 WHERE T4.[ExpectedDeliveryDate]>='2013-01-01' and T4.[ExpectedDeliveryDate]<='2013-01-31' and (T3.[DeliveryMethodID]=8 OR T3.[DeliveryMethodID]=10) and T4.[IsOrderFinalized]=1
/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/
SELECT TOP 10
    T3.[OrderID]
    ,T3.[OrderDate]
    ,T4.[SearchName] AS [CustomerName]
    ,T5.[SearchName] AS [SalespersonName]
FROM [WideWorldImporters].[Sales].[Orders] T3
INNER JOIN [WideWorldImporters].[Application].[People] T4 
    ON T4.[PersonID] = T3.[CustomerID]
INNER JOIN [WideWorldImporters].[Application].[People] T5 
    ON T5.[PersonID] = T3.[SalespersonPersonID]
ORDER BY 
    T3.[OrderDate] DESC;

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT 
      T4.[CustomerID]
      ,T4.[PhoneNumber]
  FROM [WideWorldImporters].[Warehouse].[StockItems] T1
  JOIN [WideWorldImporters].[Sales].[OrderLines] T2 ON  T2.[StockItemID]= T1.[StockItemID]
  JOIN [WideWorldImporters].[Sales].[Orders] T3 ON T3.[OrderID]=T2.[OrderID]
  JOIN [WideWorldImporters].[Sales].[Customers] T4 ON T4.[CustomerID]=T3.[PickedByPersonID]
  WHERE T1.[StockItemName]='Chocolate frogs 250g'
  GROUP BY T4.[CustomerID],T4.[PhoneNumber]
/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT
YEAR (T1.[InvoiceDate]) AS Год
,DATENAME(MONTH, T1.[InvoiceDate]) AS Месяц
,SUM(T2.[UnitPrice]*T2.[Quantity]) AS Сумма_за_месяц
,avg(T2.[UnitPrice]) as Средняя_цена
FROM [WideWorldImporters].[Sales].[Invoices] T1
JOIN [WideWorldImporters].[Sales].[InvoiceLines] T2 ON T2.[InvoiceID]=T1.[InvoiceID]
GROUP BY 
    YEAR(T1.[InvoiceDate])
    ,DATENAME(MONTH, T1.[InvoiceDate])
ORDER BY Год, Месяц;
/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT
YEAR (T1.[InvoiceDate]) AS Год
,DATENAME(MONTH, T1.[InvoiceDate]) AS Месяц
,SUM(T2.[UnitPrice]*T2.[Quantity]) AS Сумма_за_месяц
FROM [WideWorldImporters].[Sales].[Invoices] T1
JOIN [WideWorldImporters].[Sales].[InvoiceLines] T2 ON T2.[InvoiceID]=T1.[InvoiceID]
GROUP BY 
    YEAR(T1.[InvoiceDate])
    ,DATENAME(MONTH, T1.[InvoiceDate])
HAVING SUM(T2.[UnitPrice] * T2.[Quantity]) > 4600000
ORDER BY Год, Месяц;
/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT
YEAR (T1.[InvoiceDate]) AS Год
,DATENAME(MONTH, T1.[InvoiceDate]) AS Месяц
,T3.[StockItemName]
,SUM(T2.[UnitPrice]*T2.[Quantity]) AS Сумма_за_месяц
,MIN(T1.[InvoiceDate]) AS Первая_продажа_в_месяце
,COUNT(T2.[Quantity]) AS Количество_проданного
FROM [WideWorldImporters].[Sales].[Invoices] T1
JOIN [WideWorldImporters].[Sales].[InvoiceLines] T2 ON T2.[InvoiceID]=T1.[InvoiceID]
JOIN [WideWorldImporters].[Warehouse].[StockItems] T3 ON T3.[StockItemID]=T2.[StockItemID]
GROUP BY 
    YEAR(T1.[InvoiceDate])
    ,DATENAME(MONTH, T1.[InvoiceDate])
    ,T3.[StockItemName]
HAVING COUNT(T2.[Quantity]) < 50
ORDER BY Год, Месяц;

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/

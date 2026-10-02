CREATE TABLE Client(
Client_Id SERIAL PRIMARY KEY,
Client_First_Name VARCHAR(20) NOT NULL,
Client_Last_Name VARCHAR(20)NOT NULL,
Client_Phone_Number VARCHAR(18) NOT NULL,
Client_Email VARCHAR NOT NULL CHECK(Client_Email LIKE '_%@_%._%'));

CREATE TABLE Vendors(
Vendor_ID SERIAL PRIMARY KEY,
Vendor_Name VARCHAR NOT NULL UNIQUE,
Vendor_Type VARCHAR NOT NULL,
Vendor_Phone_Number VARCHAR(18) NOT NULL,
Vendor_Email VARCHAR NOT NULL CHECK(Vendor_Email LIKE '_%@_%._%'),
Vendor_Price NUMERIC(10, 2) NOT NULL CHECK(Vendor_Price > '0'));

CREATE TABLE Venue(
Venue_ID SERIAL PRIMARY KEY,
Venue_Name VARCHAR NOT NULL UNIQUE,
Venue_Location VARCHAR NOT NULL,
--Venue_Availability_Status IN("Available","Occupied")
Venue_Phone_Number VARCHAR(18) NOT NULL,
Venue_Email VARCHAR NOT NULL CHECK(Venue_Email LIKE '_%@_%._%'),
Venue_Price NUMERIC(10, 2) NOT NULL CHECK(Venue_Price > '0'));

CREATE TABLE EventTable(
    Event_Id SERIAL PRIMARY KEY,
    Client_Id INT NOT NULL,
    Event_Name VARCHAR(100) NOT NULL,
    Event_Type VARCHAR(50) NOT NULL,
    Event_Date DATE NOT NULL,
    Event_Time TIME,
    Number_Of_Guests INT,
    Event_Status VARCHAR(20) DEFAULT 'Planned',

    CONSTRAINT fk_Event_Client
        FOREIGN KEY(Client_Id)
        REFERENCES Client(Client_Id),

    CONSTRAINT chk_Guests
        CHECK(Number_Of_Guests > 0),

    CONSTRAINT chk_Event_Status
        CHECK(Event_Status IN ('Planned', 'Confirmed', 'Completed', 'Cancelled'))
);

CREATE TABLE EventVenue(
    Event_Venue_Id SERIAL PRIMARY KEY,
    Event_Id INT NOT NULL,
    Venue_Id INT NOT NULL,

    CONSTRAINT fk_EventVenue_Event
        FOREIGN KEY(Event_Id)
        REFERENCES EventTable(Event_Id),

    CONSTRAINT fk_EventVenue_Venue
        FOREIGN KEY(Venue_Id)
        REFERENCES Venue(Venue_Id),

    CONSTRAINT unique_Event_Venue
        UNIQUE(Event_Id)
);

CREATE TABLE EventVendors(
    Event_Vendor_Id SERIAL PRIMARY KEY,
    Event_Id INT NOT NULL,
    Vendor_Id INT NOT NULL,

    CONSTRAINT fk_EventVendor_Event
        FOREIGN KEY(Event_Id)
        REFERENCES EventTable(Event_Id),

    CONSTRAINT fk_EventVendor_Vendor
        FOREIGN KEY(Vendor_Id)
        REFERENCES Vendors(Vendor_Id),

    CONSTRAINT unique_Event_Vendor
        UNIQUE(Event_Id, Vendor_Id)
);

CREATE TABLE Payment(
    Payment_Id SERIAL PRIMARY KEY,
    Event_Id INT NOT NULL,
    Payment_Amount NUMERIC(10, 2) NOT NULL,
    Payment_Date DATE DEFAULT CURRENT_DATE,
    Payment_Status VARCHAR(20) DEFAULT 'Paid',

    CONSTRAINT fk_Payment_Event
        FOREIGN KEY(Event_Id)
        REFERENCES EventTable(Event_Id),

    CONSTRAINT chk_Payment_Amount
        CHECK(Payment_Amount > '0'),

    CONSTRAINT chk_Payment_Status
        CHECK(Payment_Status IN ('Paid', 'Pending', 'Overdue'))
);

CREATE OR REPLACE PROCEDURE IntoClient(Input_Client_First_Name VARCHAR,Input_Client_Last_Name VARCHAR,Input_Client_Phone_Number VARCHAR,Input_Client_Email VARCHAR)
LANGUAGE plpgSQL
AS $$
BEGIN
INSERT INTO Client(Client_First_Name,Client_Last_Name,Client_Phone_Number,Client_Email)
VALUES
(Input_Client_First_Name,Input_Client_Last_Name,Input_Client_Phone_Number,Input_Client_Email);
END;
$$;

CREATE OR REPLACE PROCEDURE IntoVendor(Input_Vendor_Name VARCHAR,Input_Vendor_Type VARCHAR,Input_Vendor_Phone_Number VARCHAR,Input_Vendor_Email VARCHAR,Input_Vendor_Price NUMERIC(10, 2))
LANGUAGE plpgSQL
AS $$
BEGIN
INSERT INTO Vendors(Vendor_Name,Vendor_Type,Vendor_Phone_Number,Vendor_Email,Vendor_Price)
VALUES
(Input_Vendor_Name,Input_Vendor_Type,Input_Vendor_Phone_Number,Input_Vendor_Email,Input_Vendor_Price);
END;
$$

CREATE OR REPLACE PROCEDURE IntoVenue(Input_Venue_Name VARCHAR,Input_Venue_Location VARCHAR,Input_Venue_Phone_Number VARCHAR,Input_Venue_Email VARCHAR,Input_Venue_Price NUMERIC(10, 2))
LANGUAGE plpgSQL
AS $$
BEGIN
INSERT INTO Venue(Venue_Name,Venue_Location,Venue_Phone_Number,Venue_Email,Venue_Price)
VALUES
(Input_Venue_Name,Input_Venue_Location,Input_Venue_Phone_Number ,Input_Venue_Email,Input_Venue_Price);
END;
$$;

CREATE OR REPLACE FUNCTION search_client(input_name VARCHAR)
RETURNS TABLE(
    Client_ID INT,
    Client_First_Name VARCHAR,
    Client_Last_Name VARCHAR,
    Client_Phone_Number VARCHAR,
    Client_Email VARCHAR
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.Client_ID,
        c.Client_First_Name,
        c.Client_Last_Name,
        c.Client_Phone_Number,
        c.Client_Email
    FROM Client c
    WHERE c.Client_First_Name ILIKE '%' || input_name || '%'
       OR c.Client_Last_Name ILIKE '%' || input_name || '%';
END;
$$;

CREATE OR REPLACE FUNCTION search_vendors(input_vendor_name VARCHAR)
RETURNS TABLE(
Vendor_ID int,
Vendor_Name VARCHAR,
Vendor_Type VARCHAR,
Vendor_Phone_Number VARCHAR,
Vendor_Email VARCHAR,
Vendor_Price NUMERIC(10, 2)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	RETURN QUERY
	SELECT *
	FROM Vendors
	where Vendors.vendor_name ILIKE '%' || input_vendor_name || '%';
END;
$$;

CREATE OR REPLACE FUNCTION search_venues(input_venue_name VARCHAR)
RETURNS TABLE(
    Venue_ID INT,
    Venue_Name VARCHAR,
    Venue_Location VARCHAR,
    Venue_Phone_Number VARCHAR,
    Venue_Email VARCHAR,
    Venue_Price NUMERIC(10, 2)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    RETURN QUERY
    SELECT
        v.Venue_ID,
        v.Venue_Name,
        v.Venue_Location,
        v.Venue_Phone_Number,
        v.Venue_Email,
        v.Venue_Price
    FROM Venue v
    WHERE v.Venue_Name ILIKE '%' || input_venue_name || '%';
END;
$$;

CREATE OR REPLACE PROCEDURE IntoEvent_Vendors(Input_Event_Id INT,Input_Vendor_Id INT)
LANGUAGE plpgSQL
AS $$
BEGIN
if NOT EXISTS (SELECT 1 from EventTable where input_Event_Id=Event_Id)
THEN 
RAISE EXCEPTION 'NO EVENT MATCH: %',input_Event_id;
END IF;

if NOT EXISTS (SELECT 1 from Vendors where input_Vendor_Id=Vendor_ID)
THEN 
RAISE EXCEPTION 'NO VENDOR MATCH: %',input_Vendor_id;
END IF;

INSERT INTO EventVendors(Event_Id,Vendor_id )
VALUES
(Input_Event_Id,Input_Vendor_Id);
END;
$$;

CREATE OR REPLACE PROCEDURE IntoEvent_Venue(Input_Event_Id INT,Input_Venue_Id INT)
LANGUAGE plpgSQL
AS $$
BEGIN
if NOT EXISTS (SELECT 1 from EventTable where input_Event_Id=Event_Id)
THEN
RAISE EXCEPTION 'NO EVENT MATCH: %',input_Event_Id;
END IF;

if NOT EXISTS (SELECT 1 from Venue where input_Venue_Id=Venue_Id)
THEN 
RAISE EXCEPTION 'NO VENUE MATCH: %',input_venue_id;
END IF;
INSERT INTO EventVenue(Event_Id,Venue_id )
VALUES
(Input_Event_Id,Input_Venue_Id);
END;
$$;

CREATE OR REPLACE FUNCTION frequent_used_venue()
RETURNS TABLE(
    VenueID INT,
    VenueName VARCHAR,
    counter INT
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.Venue_Id,
        v.Venue_Name,
        COUNT(ev.Venue_Id)::INT AS counter
    FROM Venue v
    JOIN EventVenue ev
        ON v.Venue_Id = ev.Venue_Id
    GROUP BY 
        v.Venue_Id,
        v.Venue_Name
    ORDER BY counter DESC;
END;
$$;
Drop PROCEDURE pay(input_Event_Id INT, input_Payment_Amount NUMERIC(10, 2), input_Payment_Date DATE, input_Payment_Status VARCHAR)
CREATE OR REPLACE PROCEDURE pay(input_Event_Id INT, input_Payment_Amount NUMERIC(10, 2), input_Payment_Date DATE, input_Payment_Status VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
if input_Payment_Amount <= 0 then
    RAISE EXCEPTION 'Payment amount must be greater than zero';
END IF;
if NOT EXISTS (SELECT 1 FROM EventTable WHERE Event_Id = input_Event_Id) THEN
    RAISE EXCEPTION 'Event with ID % does not exist', input_Event_Id;
END IF;
if EXISTS (SELECT 1 FROM Payment WHERE Event_Id = input_Event_Id) THEN
    RAISE EXCEPTION 'Payment for Event ID % already exists', input_Event_Id;
END IF;
    INSERT INTO Payment(Event_Id, Payment_Amount, Payment_Date, Payment_Status)
    VALUES (input_Event_Id, input_Payment_Amount, input_Payment_Date, input_Payment_Status);
END;
$$;

CREATE OR REPLACE FUNCTION frequent_used_vendor()
RETURNS TABLE(
    VendorID INT,
    VendorName VARCHAR,
    VendorType VARCHAR,
    counter INT
)
LANGUAGE PLPGSQL
AS
$$
BEGIN
    RETURN QUERY
    SELECT 
        v.Vendor_Id,
        v.Vendor_Name,
        v.Vendor_Type,
        COUNT(ev.Vendor_Id)::INT AS counter
    FROM Vendors v
    JOIN EventVendors ev
        ON v.Vendor_Id = ev.Vendor_Id
    GROUP BY 
        v.Vendor_Id,
        v.Vendor_Name,
        v.Vendor_Type
    ORDER BY counter DESC;
END;
$$;

CREATE OR REPLACE FUNCTION Total_Revenue()
RETURNS TABLE(
Total_Events INT,
Total_sum NUMERIC(10, 2)
)
LANGUAGE PLPGSQL
AS
$$
BEGIN
RETURN QUERY 
select 
	(SELECT count(Event_Id) from EventTable) AS Total_Events,
	(SELECT sum(Payment_Amount) from payment) AS Total_sum;
end;
$$;

CREATE OR REPLACE PROCEDURE UpdateVendor(
    Input_Vendor_Id INT,
    Input_Vendor_Name VARCHAR,
    Input_Vendor_Type VARCHAR,
    Input_Vendor_Phone_Number VARCHAR,
    Input_Vendor_Email VARCHAR,
    Input_Vendor_Price NUMERIC(10, 2)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    UPDATE Vendors
    SET
        Vendor_Name = Input_Vendor_Name,
        Vendor_Type = Input_Vendor_Type,
        Vendor_Phone_Number = Input_Vendor_Phone_Number,
        Vendor_Email = Input_Vendor_Email,
        Vendor_Price = Input_Vendor_Price
    WHERE Vendor_Id = Input_Vendor_Id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Vendor % does not exist', Input_Vendor_Id;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE UpdateVenue(
    Input_Venue_Id INT,
    Input_Venue_Name VARCHAR,
    Input_Venue_Type VARCHAR,
    Input_Venue_Phone_Number VARCHAR,
    Input_Venue_Email VARCHAR,
    Input_Venue_Price NUMERIC(10, 2)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    UPDATE Venue
    SET
        Vend_Name = Input_Venue_Name,
        Venue_Type = Input_Venue_Type,
        Venue_Phone_Number = Input_Venue_Phone_Number,
        Venue_Email = Input_Venue_Email,
        Venue_Price = Input_Venue_Price
    WHERE Venue_Id = Input_Venue_Id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Venue % does not exist', Input_Venue_Id;
    END IF;
END;
$$;



CREATE OR REPLACE FUNCTION JOIN_EVENT(input_client_id INT)
RETURNS TABLE(
client_id INT,
client_full_Name VARCHAR,
Event_name VARCHAR,
Event_date DATE,
Event_time TIME,
Event_location VARCHAR, 
Event_description VARCHAR,
Event_type VARCHAR,
Venue_name VARCHAR,
Venue_Price NUMERIC(10, 2),
Vendor_name VARCHAR,
Vendor_Price NUMERIC(10, 2))
LANGUAGE PLPGSQL
AS $$
BEGIN
RETURN QUERY
SELECT
Client.client_id,
Client.client_First_Name || ' ' || Client.Client_Last_Name AS client_full_Name,
EventTable.Event_Name,
EventTable.Event_Date,
EventTable.Event_Time,
Venue.Venue_Location,
EventTable.Event_Description,
EventTable.Event_Type,
Venue.Venue_Name,
Venue.Venue_Price,
Vendors.Vendor_Name,
Vendors.Vendor_Price
FROM Client
INNER JOIN EventTable ON Client.client_id=EventTable.client_id
INNER JOIN EventVenue ON EventTable.event_id=EventVenue.event_id
INNER JOIN Venue ON EventVenue.venue_id=Venue.venue_id
INNER JOIN EventVendors ON EventTable.event_id=EventVendors.event_id
INNER JOIN Vendors ON EventVendors.vendor_id=Vendors.vendor_id
WHERE Client.client_id=input_client_id;
END;
$$;

Drop function Calculate_Venue_Cost(input_client_id INT)
Select Calculate_venue_cost(1)
CREATE OR REPLACE FUNCTION Calculate_Venue_Cost(input_client_id INT)
RETURNS TABLE
(Client_id INT,
client_Full_Name VARCHAR,
Venue_name VARCHAR,
Venue_Price NUMERIC(10, 2)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	RETURN QUERY 
	SELECT
		Client.client_id ,
		Client.client_First_Name || ' ' || Client.Client_Last_Name AS client_Full_Name,
		Venue.Venue_name ,
		Venue.Venue_Price
	FROM Client
	INNER JOIN EventVenue ON Client.Client_id=EventVenue.Client_id
	INNER JOIN Venue ON Venue.venue_id=eventVenue.venue_id
	WHERE Client.client_id=input_client_id;
END;
$$

Select Vendors_Cost(1)
Drop function Vendors_Cost(input_client_id INT)
CREATE OR REPLACE FUNCTION Vendors_Cost(input_client_id INT)
RETURNS TABLE
(Client_id INT,
client_Full_Name VARCHAR,
Vendor_name VARCHAR,
Vendor_Price NUMERIC(10, 2))
LANGUAGE PLPGSQL
AS $$
BEGIN
	RETURN QUERY
	SELECT
		Client.client_id,
		Client.client_First_Name || ' ' || Client.Client_Last_Name AS client_Full_Name,
		Vendors.Vendor_name,
		Vendors.Vendor_Price
	FROM Client
	INNER JOIN EventVendors ON Client.Client_id=EventVendors.Client_id
	INNER JOIN Vendors ON Vendors.vendor_id=eventVendors.vendor_id
	WHERE Client.client_id=input_client_id;
END;
$$

select Vendors_With_Total(1)
drop  FUNCTION Vendors_With_Total(input_client_id INT)
CREATE OR REPLACE FUNCTION Vendors_With_Total(input_client_id INT)
RETURNS TABLE
(Client_id INT,
 client_Full_Name VARCHAR,
 Vendor_name TEXT,
 Vendor_Price TEXT,
 Total_cost NUMERIC(10, 2))
LANGUAGE PLPGSQL
AS $$
BEGIN
    RETURN QUERY
	SELECT 
	vendor_costFn.Client_id,
	Client.client_First_Name || ' ' || Client.Client_Last_Name AS client_Full_Name,
	STRING_AGG(vendor_costFn.Vendor_name::TEXT,',') AS Vendor_name,
	STRING_AGG(vendor_costFn.Vendor_Price::TEXT,',')AS Vendor_Price,
	SUM(vendor_costFn.vendor_price) AS Total_cost
	FROM Vendors_cost(input_client_id) vendor_costFn
	INNER JOIN Client ON vendor_costFn.Client_id = Client.Client_id
	GROUP BY 
		vendor_costFn.Client_id,
		Client.client_First_Name,
		Client.Client_Last_Name;
END;
$$;

select TOTAL_EVENT_COST(1)
CREATE OR REPLACE FUNCTION TOTAL_EVENT_COST(input_client_id INT)
RETURNS TABLE(
	Client_id INT,
	Client_full_name VARCHAR,
	vendor_prices NUMERIC(10, 2),
	venue_prices NUMERIC(10, 2),
	total_prices NUMERIC(10, 2))
LANGUAGE PLPGSQL
AS $$
BEGIN
	RETURN QUERY 
	select 
	Vendors_With_Total.client_id,
	Client.client_First_Name || ' ' || Client.Client_Last_Name AS Client_full_name,
	Vendors_With_Total.Total_cost,
	Calculate_Venue_Cost.Venue_Price,
	Vendors_With_Total.Total_cost+Calculate_Venue_Cost.Venue_Price AS total_prices
	FROM Calculate_Venue_Cost(input_client_id)CROSS JOIN Vendors_With_Total(input_client_id)
	INNER JOIN Client ON Vendors_With_Total.client_id = Client.Client_id;
END;
$$;




--LES INSERTS
CALL IntoClient(
    'Abel',
    'Tesfaye',
    '0911234567',
    'abel@gmail.com'
);

CALL IntoClient(
    'Sara',
    'Bekele',
    '0922345678',
    'sara@gmail.com'
);

CALL IntoClient(
    'Daniel',
    'Mekonnen',
    '0933456789',
    'daniel@gmail.com'
);

CALL IntoClient(
    'Hana',
    'Solomon',
    '0944567890',
    'hana@gmail.com'
);

CALL IntoClient(
    'Michael',
    'Alemayehu',
    '0955678901',
    'michael@gmail.com'
);

SELECT * FROM Client;

CALL IntoVendor(
    'Elegant Catering',
    'Catering',
    '0911111111',
    'elegantcatering@gmail.com',
    '15000'::NUMERIC
);

CALL IntoVendor(
    'Golden Photography',
    'Photography',
    '0922222222',
    'goldenphoto@gmail.com',
    '10000'::NUMERIC
);

CALL IntoVendor(
    'Dream Decorations',
    'Decoration',
    '0933333333',
    'dreamdecor@gmail.com',
    '8000'::NUMERIC
);

CALL IntoVendor(
    'Addis DJ Services',
    'Entertainment',
    '0944444444',
    'addisdj@gmail.com',
    '5000'::NUMERIC
);

CALL IntoVendor(
    'Sweet Moments Bakery',
    'Cake',
    '0955555555',
    'sweetmoments@gmail.com',
    '6000'::NUMERIC
);

CALL IntoVendor(
    'Perfect Events Catering',
    'Catering',
    '0966666666',
    'perfectevents@gmail.com',
    '18000'::NUMERIC
);

SELECT * FROM Vendors;

CALL IntoVenue(
    'Skylight Ballroom',
    'Bole, Addis Ababa',
    '0910101010',
    'skylight@gmail.com',
    '50000'::NUMERIC
);

CALL IntoVenue(
    'Harmony Hall',
    'Kazanchis, Addis Ababa',
    '0920202020',
    'harmony@gmail.com',
    '30000'::NUMERIC
);

CALL IntoVenue(
    'Unity Garden Venue',
    'Meskel Square, Addis Ababa',
    '0930303030',
    'unitygarden@gmail.com',
    '25000'::NUMERIC
);

CALL IntoVenue(
    'Sunset Resort',
    'Entoto, Addis Ababa',
    '0940404040',
    'sunset@gmail.com',
    '40000'::NUMERIC
);
select * from Eventtable
INSERT INTO EventTable (Client_Id, Event_Name,Event_type, Event_Date,Event_Time,Number_Of_Guests,Event_Status)
VALUES
(1, 'Abel Wedding','Wedding', '2026-12-10', '18:00:00', 100, 'Planned'),
(2, 'Sara Birthday Party', 'Birthday', '2026-11-15', '14:00:00', 50, 'Confirmed'),
(3, 'Daniel Graduation', 'Graduation', '2026-10-20', '16:00:00', 80, 'Planned'),
(4, 'Hana Engagement Party', 'Engagement', '2026-12-25', '19:00:00', 60, 'Confirmed'),
(5, 'Michael Corporate Event', 'Corporate', '2027-01-10', '10:00:00', 120, 'Confirmed');

CALL IntoEvent_Vendors(2, 1);
CALL IntoEvent_Vendors(2, 2);
CALL IntoEvent_Vendors(2, 3);

CALL IntoEvent_Vendors(3, 1);
CALL IntoEvent_Vendors(3, 4);

CALL IntoEvent_Vendors(4, 2);
CALL IntoEvent_Vendors(4, 5);

CALL IntoEvent_Vendors(5, 1);
CALL IntoEvent_Vendors(5, 3);
CALL IntoEvent_Vendors(5, 5);

CALL IntoEvent_Vendors(6, 1);
CALL IntoEvent_Vendors(6, 2);
CALL IntoEvent_Vendors(6, 4);
a
CALL IntoEvent_Venue(6, 1);
CALL IntoEvent_Venue(2, 2);
CALL IntoEvent_Venue(3, 3);
CALL IntoEvent_Venue(4, 1);
CALL IntoEvent_Venue(5, 2);



CALL pay(
    6,
    '20000'::NUMERIC(10, 2),
    '2026-09-05',
    'Paid'
);



CALL pay(
    2,
    '5000'::NUMERIC(10, 2),
    '2026-09-06',
    'Paid'
);

CALL pay(
    3,
    '25000'::NUMERIC(10, 2),
    '2026-09-03',
    'Paid'
);

CALL pay(
    4,
    '40000'::NUMERIC(10, 2),
    '2026-09-04',
    'Paid'
);

CALL pay(
    5,
    '60000'::NUMERIC(10, 2),
    '2026-09-06',
    'Paid'
);

SELECT * 
FROM search_vendors('%Catering%');

CREATE VIEW frequent_used_venue AS
SELECT
    v.Venue_Id,
    v.Venue_Name,
    COUNT(ev.Venue_Id)::INT AS counter
    FROM Venue v
    JOIN EventVenue ev
        ON v.Venue_Id = ev.Venue_Id
    GROUP BY 
        v.Venue_Id,
        v.Venue_Name
    ORDER BY counter DESC;

 CREATE VIEW frequent_used_vendor AS
    SELECT 
        v.Vendor_Id,
        v.Vendor_Name,
        v.Vendor_Type,
        COUNT(ev.Vendor_Id)::INT AS counter
    FROM Vendors v
    JOIN EventVendors ev
        ON v.Vendor_Id = ev.Vendor_Id
    GROUP BY 
        v.Vendor_Id,
        v.Vendor_Name,
        v.Vendor_Type
    ORDER BY counter DESC;

CREATE VIEW Total_Revenue AS
select 
	(SELECT count(Event_Id) from EventTable) AS Total_Events,
	(SELECT sum(Payment_Amount) from payment) AS Total_sum;

CREATE VIEW event_dashboard AS
SELECT
    e.Event_Id,
    e.Event_Name,
    e.Event_Date,
    e.Event_Time,
    e.Number_Of_Guests,
    e.Event_Status,
    c.Client_Id,
    c.Client_First_Name || ' ' || c.Client_Last_Name AS Client_Name,
    v.Venue_Name,
    v.Venue_Location,
    p.Payment_Amount,
    p.Payment_Status
FROM EventTable e
LEFT JOIN Client c
    ON c.Client_Id = e.Client_Id
LEFT JOIN EventVenue ev
    ON ev.Event_Id = e.Event_Id
LEFT JOIN Venue v
    ON v.Venue_Id = ev.Venue_Id
LEFT JOIN Payment p
    ON p.Event_Id = e.Event_Id;



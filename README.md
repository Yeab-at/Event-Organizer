# Event-Organizer

## Event Planning Database & Visualization
This project is an event planning database that stores information about events, clients, vendors, venues, and payments. The data is then used to create visualizations in Tableau.

## Tools Used
* **PostgreSQL:** Database design, data storage, functions, procedures, and views
* **Tableau:** Data visualization and dashboard creation

## Database Tables

### Client
Stores client information, including:
* Client name
* Phone number
* Email
* Client ID

### Vendors
Stores information about vendors enlisted for events, including:
* Vendor name
* Vendor type
* Phone number
* Email
* Vendor price
* Vendor ID

### Venue
Stores information about available event venues, including:
* Venue name
* Location
* Phone number
* Email
* Venue price
* Venue ID

### EventTable
Stores the details of an event after the client has decided on the event arrangements, including:
* Event name
* Event type
* Event date and time
* Number of guests
* Event status
* Client ID

### EventVenue
Connects a venue to an event using the event ID and venue ID.

### EventVendors
Connects vendors to an event using the event ID and vendor ID.

### Payment
Stores payment information for an event using the event ID, including:
* Payment amount
* Payment date
* Payment status

## PostgreSQL Functions and Procedures
The database also includes functions and procedures for tasks such as:
* Searching for clients, vendors, and venues
* Adding clients, vendors, venues, and event relationships
* Recording payments
* Calculating event costs
* Finding frequently used vendors and venues
* Calculating total revenue

## Tableau Visualizations
The PostgreSQL data was connected to Tableau to create visualizations such as:

### Frequently Used Venues
Uses the `frequent_used_venue()` function to show which venues are used most frequently.

**Visualization:**
<img width="1217" height="817" alt="image" src="https://github.com/user-attachments/assets/8746af41-6310-4242-947a-6cdddc6e8cc3" />

### Frequently Used Vendors with vendor type
Uses the `frequent_used_vendor()` function to show which vendors are used most frequently.

**Visualization:**
<img width="1350" height="827" alt="image" src="https://github.com/user-attachments/assets/2887af41-612c-4fe6-b7f7-1d860066cd64" />

### Paid Events and Payments
Uses event names and payment amounts while filtering the data to show paid events.

**Visualization:**
<img width="1182" height="802" alt="image" src="https://github.com/user-attachments/assets/92a3a1b2-0ea9-48f9-bf57-3f5a01b16375" />

### Payment by events from Venues
Adds payment from venues including previous events to show revenue from each rvenue

**Visualization:**
<img width="1075" height="820" alt="image" src="https://github.com/user-attachments/assets/16cdcb9c-5473-4f06-b789-30233c556d1c" />
/>

### Confirmed Events
Filters for confirmed events and displays the event name, location, and time.

**Visualization:**
<img width="1423" height="822" alt="image" src="https://github.com/user-attachments/assets/03959a8b-c281-4211-b075-c7607b074376" />

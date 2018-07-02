/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name 
FROM Facilities
WHERE membercost != 0

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(facid) 
FROM Facilities
WHERE membercost = 0 

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost != 0 AND membercost < 0.2 * monthlymaintenance

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid in (1,5)


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
	 CASE WHEN monthlymaintenance > 100 THEN 'expensive'
		ELSE 'cheap' END AS maintenance_category
FROM Facilities
ORDER BY 2

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
WHERE joindate=(SELECT MAX(joindate) FROM Members)


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT f.name AS court_name,
        CONCAT(m.surname,',',m.firstname) AS member_name
FROM Bookings b
JOIN Members m ON b.memid = m.memid
JOIN Facilities f ON b.facid = f.facid
	AND f.name LIKE '%Tennis%Court%'
ORDER BY 2,1

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name AS facility_name,
	 CONCAT(m.surname,',',m.firstname) AS member_name,
	 CASE WHEN m.memid = 0 THEN b.slots*2*f.guestcost
		ELSE b.slots*2*f.membercost END AS cost_per_booking
FROM Bookings b
JOIN Members m ON b.memid=m.memid
JOIN Facilities f ON b.facid=f.facid
WHERE LEFT(b.starttime, 10) = '2012-09-14'
	AND (CASE WHEN m.memid = 0 THEN b.slots*2*f.guestcost
		ELSE b.slots*2*f.membercost END)> 30
ORDER BY cost_per_booking DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT sub.facility_name, sub.member_name, sub.cost_per_booking
FROM (
	SELECT f.name AS facility_name,
		CONCAT(m.surname,',',m.firstname) AS member_name,
		CASE WHEN m.memid = 0 THEN b.slots*2*f.guestcost
			ELSE b.slots*2*f.membercost END AS cost_per_booking
       FROM Bookings b
		JOIN Members m ON b.memid=m.memid
		JOIN Facilities f ON b.facid=f.facid
       WHERE LEFT(b.starttime, 10) = '2012-09-14'
       )sub
WHERE sub.cost_per_booking >30
ORDER BY sub.cost_per_booking DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT r.name,
	 r.revenue_total
FROM(
       SELECT f.name,
		   SUM(CASE WHEN m.memid = 0 THEN h.hours_total*2*f.guestcost
			 ELSE h.hours_total*2*f.membercost END) AS revenue_total
       FROM (
       	SELECT facid, memid, SUM(slots) AS hours_total
       	FROM Bookings
       	GROUP BY 1,2
       	) h
       JOIN Members m on h.memid = m.memid
       JOIN Facilities f on h.facid = f.facid
       GROUP BY 1
       ) r
WHERE r.revenue_total <1000
ORDER BY 2

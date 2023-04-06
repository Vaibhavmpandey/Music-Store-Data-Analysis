/* Q1: Who is the senior most employee based on job title? */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1

/* Q2: Which countries have the most Invoices? */

select billing_country,count(*) as no_of_invoices
from invoice group by billing_country
order by no_of_invoices desc limit 1;

/* Q3: What are top 3 values of total invoice? */

select total from invoice
order by total desc limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city,sum(total) as earning from invoice
group by(billing_city) order by earning desc limit 1 ;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select customer.customer_id,customer.first_name,customer.last_name,
sum(invoice.total) as total
from customer join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1;

/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select email,first_name,last_name
from customer join invoice on customer.Customer_Id = invoice.Customer_Id
join invoice_line on invoice_line.Invoice_ID = invoice.Invoice_ID
where track_id in (select track.track_id from track join genre
on track.genre_id = genre.genre_id
where genre.name='Rock')
order by email;

/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT artist.artist_id,artist.name, count(artist.artist_id)
AS number_of_songs FROM track
JOIN album on album.album_id = track.album_id
JOIN artist on album.artist_id = artist.artist_id
JOIN genre on genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name,milliseconds
FROM track 
where milliseconds >
(Select avg(milliseconds) from track)
order by milliseconds DESC;

/* Q9: Find how much amount spent by each customer on top artist? Write a query to return customer name, artist name and total spent */

with top_artist as 
 (
 SELECT artist.artist_id artist_id,artist.name as artist_name,
 SUM(invoice_line.unit_price * invoice_line.Quantity) as total_sales
 from artist join album on artist.artist_id = album.artist_id
 join track on album.album_id = track.album_id
 join invoice_line on track.track_id = invoice_line.track_id
 group by 1
 order by 3 desc
 limit 1
)

SELECT c.customer_id, c.first_name,c.last_name,ta.artist_name,
sum(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c on i.customer_id = c.customer_id
JOIN invoice_line il on i.invoice_id = il.invoice_id
JOIN track t on t.track_id = il.track_id
JOIN album alb on alb.album_id = t.album_id
JOIN top_artist ta on ta.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with music_genre as
(
SELECT COUNT(invoice_line.quantity) AS purchases,customer.country,
 genre.name,genre.genre_id, 
 ROW_NUMBER() OVER(PARTITION BY CUSTOMER.COUNTRY ORDER BY COUNT(invoice_line.quantity) DESC) AS rowno
 FROM invoice_line
 JOIN invoice on invoice.invoice_id = invoice_line.invoice_id
 JOIN customer 	on customer.customer_id = invoice.customer_id
 JOIN track on track.track_id = invoice_line.track_id
 JOIN genre on genre.genre_id = track.Genre_id
 GROUP BY 2,3,4
 ORDER BY 2 DESC,1 DESC
)

select * from music_genre where rowno=1;


/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */


with customer_country as
(select customer.customer_id,customer.first_name,customer.last_name,
invoice.billing_country, sum(invoice.total) as total_spending,
row_number()
over(partition by invoice.billing_country order by SUM(invoice.total) DESC)
as rowno
from invoice
join customer on invoice.customer_id=customer.customer_id
group by 1,2,3,4
order by 4 ASC, 5 DESC)
 
select * from customer_country where rowno<=1

/*We want to reward our users who have been around the longest.  
Find the 5 oldest users.*/
select username
from Users
order by created_at
limit 5;

/*What day of the week do most users register on?
We need to figure out when to schedule an ad campaign*/
select date_format(created_at, '%W') as day, count(*) as total_registration
from users
group by day
order by count(*) desc;

/*We want to target our inactive users with an email campaign.
Find the users who have never posted a photo*/
select distinct u.id, u.username
from users u
left join photos p on u.id=p.user_id
where p.user_id is null;

/*We're running a new contest to see who can get the most likes on a single photo.
WHO WON??!!*/
select u.id, u.username, l.photo_id, count(*) as total_likes
from users u
join photos p on u.id=p.user_id
join likes l on p.id=l.photo_id
group by u.id, u.username, l.photo_id
order by count(*) desc
limit 1;

/*Our Investors want to know...
How many times does the average user post?*/
/*total number of photos/total number of users*/
select (select count(*) from photos) / (select count(*) from users) as average_posts_per_user;

/*user ranking by postings higher to lower*/
select rank() over(order by count(p.id) desc) as 'rank', u.id, u.username, count(p.id) as total_posts
from users u
left join photos p on u.id=p.user_id
group by u.id, u.username
order by total_posts desc;

/*Total Posts by users */
select count(*)
from photos;

/*total numbers of users who have posted at least one time */
select count(distinct u.id) as number_of_users
from users u
join photos p on u.id=p.user_id;

/*A brand wants to know which hashtags to use in a post
What are the top 5 most commonly used hashtags?*/
select tag_name, count(*) as total
from tags t
join photo_tags pt on t.id=pt.tag_id
group by tag_name
order by count(*) desc
limit 5;

/*We have a small problem with bots on our site...
Find users who have liked every single photo on the site*/
select l.user_id, u.username
from likes l
join users u on l.user_id=u.id
group by user_id
having count(*) = (select count(*) from photos);

/*We also have a problem with celebrities
Find users who have never commented on a photo*/
select u.id, u.username
from users u
left join comments c on u.id=c.user_id
where c.user_id is null;

/*Find users who have ever commented on a photo*/
select id, username
from users
where (id, username) not in (
	select u.id, u.username
	from users u
	left join comments c on u.id=c.user_id
	where c.user_id is null
);
/*another solution*/
select distinct u.id, u.username
from users u
left join comments c on u.id=c.user_id
where c.user_id is not null;

/*Find users who have commented on every photo*/
select user_id, u.username
from comments c
join users u on c.user_id=u.id
group by user_id
having count(*) = (select count(*) from photos);

/*Are we overrun with bots and celebrity accounts?
Find the percentage of our users who have either never commented on a photo or have commented on every photo*/
select count(*) / (select count(*) from users) * 100 as percentage_of_bot_and_celebrity_accounts
from (
	(select u.id, u.username
	from users u
	left join comments c on u.id=c.user_id
	where c.user_id is null)
	union
	(select user_id, u.username
	from comments c
	join users u on c.user_id=u.id
	group by user_id
	having count(*) = (select count(*) from photos))
) as bot_or_celebrity_accounts;
# Social Media Analytics Database System 📊

## Project Overview
This project focuses on developing a comprehensive database system to manage and analyze data from various social media platforms. [cite_start]It tracks user interactions, engagement metrics (likes, comments, shares), and post performance trends to assist in data-driven decision-making[cite: 3, 4, 7].

## Core Features
* [cite_start]**User & Post Tracking:** Comprehensive management of user profiles and content history[cite: 6].
* [cite_start]**Engagement Analytics:** Real-time tracking of likes, comments, and shares[cite: 7].
* [cite_start]**Automated Logic:** Includes PL/SQL triggers for high-engagement notifications and hashtag limits[cite: 104, 120].
* [cite_start]**Advanced Reporting:** Custom SQL views for trending posts and country-wise engagement trends[cite: 10, 276, 417].

## Tech Stack
* **Database:** Oracle SQL / PL/SQL
* **Backend:** Node.js & Express
* **Frontend:** HTML5, CSS3 (Glassmorphism UI), and JavaScript

## Database Schema Highlights
* [cite_start]**Tables:** Users, Posts, Engagements1, Engagement_Summary[cite: 11, 155].
* [cite_start]**Triggers:** `notify_high_engagement`, `trg_update_engagement_summary`[cite: 106, 148].
* [cite_start]**Procedures:** `get_top_5_posts`, `insert_post`, `get_monthly_user_growth`[cite: 180, 212, 250].

## How to Run
1. Run the `database_setup.sql` script in your Oracle environment.
2. Update the `.env` file with your credentials.
3. Run `npm install` and `node server.js`.
4. Open `index.html` via a local server.

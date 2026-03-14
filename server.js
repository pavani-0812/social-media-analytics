require('dotenv').config();
const express = require('express');
const cors = require('cors');
const oracledb = require('oracledb');
const path = require('path'); // <-- ADD THIS LINE

const app = express();
app.use(cors());
app.use(express.json());

oracledb.outFormat = oracledb.OUT_FORMAT_OBJECT;

const dbConfig = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    connectString: process.env.DB_CONNECTION_STRING
};

// <-- ADD THIS BLOCK -->
// This completely fixes the "file:///" security error!
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// A simple route to test if the server is alive
app.get('/', (req, res) => {
    res.send('✅ Backend is running successfully! (Live Database Version)');
});

// 1. Fetch Top Performing Posts (>300 engagement view)
app.get('/api/top-posts', async (req, res) => {
    let connection;
    try {
        connection = await oracledb.getConnection(dbConfig);
        const result = await connection.execute(
            `SELECT post_id, content, username, total_engagement 
       FROM TopPerformingPosts 
       ORDER BY total_engagement DESC FETCH FIRST 10 ROWS ONLY`
        );
        res.json(result.rows);
    } catch (err) {
        console.error("Top Posts Error:", err);
        res.status(500).json({ error: err.message });
    } finally {
        if (connection) { try { await connection.close(); } catch (err) { } }
    }
});

// 2. Fetch Top Hashtags (Average Likes)
app.get('/api/hashtags', async (req, res) => {
    let connection;
    try {
        connection = await oracledb.getConnection(dbConfig);
        const result = await connection.execute(
            `SELECT p.hashtags, AVG(e.likes) AS avg_likes
       FROM Posts p
       JOIN Engagements1 e ON p.post_id = e.post_id
       GROUP BY p.hashtags
       ORDER BY avg_likes DESC FETCH FIRST 5 ROWS ONLY`
        );
        res.json(result.rows);
    } catch (err) {
        console.error("Hashtags Error:", err);
        res.status(500).json({ error: err.message });
    } finally {
        if (connection) { try { await connection.close(); } catch (err) { } }
    }
});

// 3. Fetch Country Trends
app.get('/api/countries', async (req, res) => {
    let connection;
    try {
        connection = await oracledb.getConnection(dbConfig);
        const result = await connection.execute(
            `SELECT u.country, SUM(e.likes) AS total_likes, SUM(e.comments) AS total_comments, SUM(e.shares) AS total_shares
       FROM Users u
       JOIN Posts p ON u.user_id = p.user_id
       JOIN Engagements1 e ON p.post_id = e.post_id
       GROUP BY u.country
       ORDER BY total_likes DESC FETCH FIRST 5 ROWS ONLY`
        );
        res.json(result.rows);
    } catch (err) {
        console.error("Countries Error:", err);
        res.status(500).json({ error: err.message });
    } finally {
        if (connection) { try { await connection.close(); } catch (err) { } }
    }
});

// 4. Create New User
app.post('/api/users', async (req, res) => {
    let connection;
    try {
        const { user_id, username, country } = req.body;
        connection = await oracledb.getConnection(dbConfig);
        await connection.execute(
            `INSERT INTO Users (user_id, username, joined_date, country) 
       VALUES (:user_id, :username, SYSDATE, :country)`,
            [user_id, username, country],
            { autoCommit: true }
        );
        res.json({ message: 'User created successfully!' });
    } catch (err) {
        console.error("Create User Error:", err);
        res.status(500).json({ error: err.message });
    } finally {
        if (connection) { try { await connection.close(); } catch (err) { } }
    }
});

// 5. SEARCH: User Profile
app.get('/api/users/:username', async (req, res) => {
    let connection;
    try {
        connection = await oracledb.getConnection(dbConfig);
        const result = await connection.execute(
            `SELECT u.user_id, u.username, u.country, COUNT(p.post_id) as total_posts 
       FROM Users u 
       LEFT JOIN Posts p ON u.user_id = p.user_id 
       WHERE u.username = :username 
       GROUP BY u.user_id, u.username, u.country`,
            [req.params.username]
        );
        if (result.rows.length > 0) res.json(result.rows[0]);
        else res.status(404).json({ error: 'User not found' });
    } catch (err) {
        console.error("Search User Error:", err);
        res.status(500).json({ error: err.message });
    } finally {
        if (connection) { try { await connection.close(); } catch (err) { } }
    }
});

// 6. SEARCH: Fetch Posts for a Specific User
app.get('/api/users/:userId/posts', async (req, res) => {
    let connection;
    try {
        connection = await oracledb.getConnection(dbConfig);
        const result = await connection.execute(
            `SELECT post_id, content, hashtags 
       FROM Posts 
       WHERE user_id = :userId 
       ORDER BY post_id DESC`,
            [req.params.userId]
        );
        res.json(result.rows);
    } catch (err) {
        console.error("Search Posts Error:", err);
        res.status(500).json({ error: err.message });
    } finally {
        if (connection) { try { await connection.close(); } catch (err) { } }
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Live backend server running on http://localhost:${PORT}`);
});
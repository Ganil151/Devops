const express = require('express');
const authenticateToken = require('./middleware/authenticateToken');

const app = express();

// Protected route
app.get('/api/protected', authenticateToken, (req, res) => {
  res.json({ message: 'This is a protected route', user: req.user });
});
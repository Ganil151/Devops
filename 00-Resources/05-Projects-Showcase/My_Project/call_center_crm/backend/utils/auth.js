const jwt = require('jsonwebtoken');

const SECRET_KEY = 'your_secret_key'; // Replace with your actual secret key

// Function to generate a JWT token
const generateToken = (user) => {
  return jwt.sign({ id: user.id, email: user.email }, SECRET_KEY, { expiresIn: '1h' });
};

// Middleware to verify JWT token
const verifyToken = (req, res, next) => {
  const token = req.headers['authorization'];
  if (!token) {
    return res.status(401).json({ message: 'No token provided' });
  }
  jwt.verify(token, SECRET_KEY, (err, decoded) => {
    if (err) {
      return res.status(401).json({ message: 'Invalid token' });
    }
    req.user = decoded;
    next();
  });
};

module.exports = {
  generateToken,
  verifyToken,
};
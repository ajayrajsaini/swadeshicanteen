// middleware/auth.js
const jwt = require('jsonwebtoken');

exports.authenticate = (req, res, next) => {
  const token = req.header('Authorization');
  if (!token) return res.status(401).json({ message: 'Access denied' });


  if (token == process.env.JWT_SECRET) {
    console.log("Verified");
    req.user = { role: 'admin' };
    next();
  } else {
    res.status(400).json({ message: 'Invalid token' });
  }
};

const jwt = require('jsonwebtoken');
const User = require('../models/User.js');

const protect = async (req, res, next) => {
    let token;
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        try {
            token = req.headers.authorization.split(' ')[1];
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            req.user = await User.findById(decoded.id).select('-password');
            next();
        } catch (error) {
            console.error(error);
            res.status(401).json({ message: 'Not authorized, token failed' });
        }
    } else {
        res.status(401).json({ message: 'Not authorized, no token' });
    }
};

const admin = (req, res, next) => {
    if (req.user && req.user.isAdmin) {
        next();
    } else {
        res.status(401).json({ message: 'Not authorized as an admin' });
    }
};

const restaurantOrAdmin = (req, res, next) => {
    if (req.user && (req.user.isRestaurant || req.user.isAdmin)) {
        next();
    } else {
        res.status(401).json({ message: 'Not authorized as a restaurant or admin' });
    }
};

module.exports = { protect, admin, restaurantOrAdmin };

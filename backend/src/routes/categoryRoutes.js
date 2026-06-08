const express = require('express');
const router = express.Router();
const { getCategories, createCategory } = require('../controllers/categoryController');
const { protect, restaurantOrAdmin } = require('../middleware/authMiddleware');

router.route('/')
    .get(getCategories)
    .post(protect, restaurantOrAdmin, createCategory);

module.exports = router;

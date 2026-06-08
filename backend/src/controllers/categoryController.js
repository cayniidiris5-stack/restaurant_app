const Category = require('../models/Category');

// @desc    Get all categories
// @route   GET /api/categories
// @access  Public
const getCategories = async (req, res) => {
    try {
        const categories = await Category.find({}).sort({ name: 1 });
        res.json(categories);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Create a category
// @route   POST /api/categories
// @access  Private/RestaurantOrAdmin
const createCategory = async (req, res) => {
    const { name } = req.body;
    if (!name) {
        return res.status(400).json({ message: 'Category name is required' });
    }
    try {
        const categoryExists = await Category.findOne({ name: { $regex: new RegExp(`^${name.trim()}$`, 'i') } });
        if (categoryExists) {
            return res.status(400).json({ message: 'Category already exists' });
        }
        const category = await Category.create({ name: name.trim() });
        res.status(201).json(category);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    getCategories,
    createCategory
};

const Meal = require('../models/Meal');
const path = require('path');

// @desc    Get all meals
// @route   GET /api/meals
// @access  Public
const getMeals = async (req, res) => {
    try {
        const { category, search } = req.query;
        let query = {};
        if (category && category !== 'All') {
            query.category = category;
        }
        if (search) {
            query.name = { $regex: search, $options: 'i' };
        }
        const meals = await Meal.find(query);
        res.json(meals);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get single meal by ID
// @route   GET /api/meals/:id
// @access  Public
const getMealById = async (req, res) => {
    try {
        const meal = await Meal.findById(req.params.id);
        if (meal) {
            res.json(meal);
        } else {
            res.status(404).json({ message: 'Meal not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Create a meal (Admin)
// @route   POST /api/meals
// @access  Private/Admin
const createMeal = async (req, res) => {
    try {
        const { name, description, price, category } = req.body;
        const imageFile = req.file;

        if (!imageFile) {
            return res.status(400).json({ message: 'Image is required' });
        }

        const imagePath = `/uploads/${imageFile.filename}`;

        const meal = new Meal({
            name,
            image: imagePath,
            description,
            price,
            category,
        });

        const createdMeal = await meal.save();
        res.status(201).json(createdMeal);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Update a meal (Admin)
// @route   PUT /api/meals/:id
// @access  Private/Admin
const updateMeal = async (req, res) => {
    try {
        const { name, description, price, category } = req.body;
        const meal = await Meal.findById(req.params.id);
        if (!meal) {
            return res.status(404).json({ message: 'Meal not found' });
        }
        meal.name = name || meal.name;
        meal.description = description || meal.description;
        meal.price = price || meal.price;
        meal.category = category || meal.category;
        if (req.file) {
            meal.image = `/uploads/${req.file.filename}`;
        }
        const updatedMeal = await meal.save();
        res.json(updatedMeal);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Delete a meal (Admin)
// @route   DELETE /api/meals/:id
// @access  Private/Admin
const deleteMeal = async (req, res) => {
    try {
        const meal = await Meal.findById(req.params.id);
        if (!meal) {
            return res.status(404).json({ message: 'Meal not found' });
        }
        await meal.deleteOne();
        res.json({ message: 'Meal removed' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { getMeals, getMealById, createMeal, updateMeal, deleteMeal };

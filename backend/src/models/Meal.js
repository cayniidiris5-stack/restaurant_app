const mongoose = require('mongoose');

const mealSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    image: {
        type: String, // URL or file path
        required: true
    },
    description: {
        type: String,
        required: true
    },
    price: {
        type: Number,
        required: true
    },
    category: {
        type: String,
        required: true,
        default: 'General'
    }
}, {
    timestamps: true
});

const Meal = mongoose.model('Meal', mealSchema);
module.exports = Meal;

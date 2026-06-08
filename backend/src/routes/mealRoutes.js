const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { getMeals, getMealById, createMeal, updateMeal, deleteMeal } = require('../controllers/mealController');
const { protect, admin, restaurantOrAdmin } = require('../middleware/authMiddleware');

// Always resolve uploads to an absolute path relative to this file:
// mealRoutes.js is at  backend/src/routes/  →  go up two levels to reach backend/uploads
const uploadsDir = path.join(__dirname, '../../uploads');

// Create uploads directory if it doesn't exist
if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
}

const storage = multer.diskStorage({
    destination(req, file, cb) {
        cb(null, uploadsDir);
    },
    filename(req, file, cb) {
        cb(null, `${file.fieldname}-${Date.now()}${path.extname(file.originalname)}`);
    },
});

function checkFileType(file, cb) {
    const filetypes = /jpg|jpeg|png|webp/;
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = file.mimetype ? filetypes.test(file.mimetype) : true;
    if (extname) {
        return cb(null, true);
    } else {
        cb(new Error('Images only! Allowed: jpg, jpeg, png, webp'));
    }
}

const upload = multer({
    storage,
    fileFilter: function (req, file, cb) {
        checkFileType(file, cb);
    },
});

// Wrap multer to catch its errors and return proper JSON
function uploadSingle(req, res, next) {
    upload.single('image')(req, res, (err) => {
        if (err) {
            return res.status(400).json({ message: err.message || 'File upload error' });
        }
        next();
    });
}

router.route('/')
    .get(getMeals)
    .post(protect, restaurantOrAdmin, uploadSingle, createMeal);

router.route('/:id')
    .get(getMealById)
    .put(protect, restaurantOrAdmin, uploadSingle, updateMeal)
    .delete(protect, restaurantOrAdmin, deleteMeal);

module.exports = router;

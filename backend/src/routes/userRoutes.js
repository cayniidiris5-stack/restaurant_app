const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const {
    registerUser,
    loginUser,
    getUserProfile,
    updateUserProfile,
    getUsers,
    createUserByAdmin,
    updateUserByAdmin,
    deleteUserByAdmin
} = require('../controllers/userController');
const { protect, admin } = require('../middleware/authMiddleware');

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

function uploadSingle(req, res, next) {
    upload.single('image')(req, res, (err) => {
        if (err) {
            return res.status(400).json({ message: err.message || 'File upload error' });
        }
        next();
    });
}

router.post('/register', registerUser);
router.post('/login', loginUser);
router.route('/profile')
    .get(protect, getUserProfile)
    .put(protect, uploadSingle, updateUserProfile);

// Admin user management routes
router.route('/')
    .get(protect, admin, getUsers)
    .post(protect, admin, createUserByAdmin);

router.route('/:id')
    .put(protect, admin, updateUserByAdmin)
    .delete(protect, admin, deleteUserByAdmin);

module.exports = router;

const User = require('../models/User');
const jwt = require('jsonwebtoken');

const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: '30d' });
};

// @desc    Register a new user
// @route   POST /api/users/register
// @access  Public
const registerUser = async (req, res) => {
    const { name, email, password } = req.body;
    try {
        const userExists = await User.findOne({ email });
        if (userExists) {
            return res.status(400).json({ message: 'User already exists' });
        }
        
        // Admin must register and provide a gmail and password.
        // We set isAdmin to true if the email is a gmail.com account.
        const isAdmin = email.toLowerCase().endsWith('@gmail.com');
        
        const user = await User.create({
            name,
            email,
            password,
            isAdmin,
            isRestaurant: false
        });

        if (user) {
            res.status(201).json({
                _id: user._id,
                name: user.name,
                email: user.email,
                isAdmin: user.isAdmin,
                isRestaurant: user.isRestaurant,
                image: user.image || '',
                token: generateToken(user._id),
            });
        } else {
            res.status(400).json({ message: 'Invalid user data' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Auth user & get token
// @route   POST /api/users/login
// @access  Public
const loginUser = async (req, res) => {
    const { email, password } = req.body;
    try {
        const user = await User.findOne({ email });
        if (user && (await user.matchPassword(password))) {
            res.json({
                _id: user._id,
                name: user.name,
                email: user.email,
                isAdmin: user.isAdmin,
                isRestaurant: user.isRestaurant,
                image: user.image || '',
                token: generateToken(user._id),
            });
        } else {
            res.status(401).json({ message: 'Invalid email or password' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get user profile
// @route   GET /api/users/profile
// @access  Private
const getUserProfile = async (req, res) => {
    try {
        const user = await User.findById(req.user._id);
        if (user) {
            res.json({
                _id: user._id,
                name: user.name,
                email: user.email,
                isAdmin: user.isAdmin,
                isRestaurant: user.isRestaurant,
                image: user.image || ''
            });
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get all users (admin)
// @route   GET /api/users
// @access  Private/Admin
const getUsers = async (req, res) => {
    try {
        const users = await User.find({}).select('-password');
        res.json(users);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Create a user or restaurant (Admin only)
// @route   POST /api/users
// @access  Private/Admin
const createUserByAdmin = async (req, res) => {
    const { name, email, password, isRestaurant } = req.body;
    try {
        const userExists = await User.findOne({ email });
        if (userExists) {
            return res.status(400).json({ message: 'User/restaurant already exists with this email' });
        }
        
        const isAdmin = email.toLowerCase().endsWith('@gmail.com');
        
        const user = await User.create({
            name,
            email,
            password,
            isAdmin,
            isRestaurant: isRestaurant || false
        });
        
        if (user) {
            res.status(201).json({
                _id: user._id,
                name: user.name,
                email: user.email,
                isAdmin: user.isAdmin,
                isRestaurant: user.isRestaurant
            });
        } else {
            res.status(400).json({ message: 'Invalid user/restaurant data' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Update user or restaurant (Admin only)
// @route   PUT /api/users/:id
// @access  Private/Admin
const updateUserByAdmin = async (req, res) => {
    try {
        const user = await User.findById(req.params.id);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        
        user.name = req.body.name || user.name;
        user.email = req.body.email || user.email;
        if (req.body.password) {
            user.password = req.body.password;
        }
        if (req.body.isRestaurant !== undefined) {
            user.isRestaurant = req.body.isRestaurant;
        }
        if (req.body.isAdmin !== undefined) {
            user.isAdmin = req.body.isAdmin;
        } else {
            user.isAdmin = user.email.toLowerCase().endsWith('@gmail.com');
        }
        
        const updatedUser = await user.save();
        res.json({
            _id: updatedUser._id,
            name: updatedUser.name,
            email: updatedUser.email,
            isAdmin: updatedUser.isAdmin,
            isRestaurant: updatedUser.isRestaurant
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Delete user or restaurant (Admin only)
// @route   DELETE /api/users/:id
// @access  Private/Admin
const deleteUserByAdmin = async (req, res) => {
    try {
        const user = await User.findById(req.params.id);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        await User.deleteOne({ _id: req.params.id });
        res.json({ message: 'User removed successfully' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Update user profile
// @route   PUT /api/users/profile
// @access  Private
const updateUserProfile = async (req, res) => {
    try {
        const user = await User.findById(req.user._id);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        
        user.name = req.body.name || user.name;
        user.email = req.body.email || user.email;
        if (req.body.password) {
            user.password = req.body.password;
        }
        if (req.file) {
            user.image = `/uploads/${req.file.filename}`;
        }
        
        const updatedUser = await user.save();
        res.json({
            _id: updatedUser._id,
            name: updatedUser.name,
            email: updatedUser.email,
            isAdmin: updatedUser.isAdmin,
            isRestaurant: updatedUser.isRestaurant,
            image: updatedUser.image || '',
            token: generateToken(updatedUser._id),
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    registerUser,
    loginUser,
    getUserProfile,
    updateUserProfile,
    getUsers,
    createUserByAdmin,
    updateUserByAdmin,
    deleteUserByAdmin
};

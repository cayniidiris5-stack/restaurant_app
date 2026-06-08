const Order = require('../models/Order');

// @desc    Create new order
// @route   POST /api/orders
// @access  Private
const createOrder = async (req, res) => {
    try {
        const { orderItems, totalPrice, phoneNumber, location } = req.body;
        if (!orderItems || orderItems.length === 0) {
            return res.status(400).json({ message: 'No order items' });
        }
        if (!phoneNumber || !location) {
            return res.status(400).json({ message: 'Phone number and location are required' });
        }
        const order = new Order({
            user: req.user._id,
            orderItems,
            totalPrice,
            phoneNumber,
            location,
        });
        const createdOrder = await order.save();
        res.status(201).json(createdOrder);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get order by ID
// @route   GET /api/orders/:id
// @access  Private
const getOrderById = async (req, res) => {
    try {
        const order = await Order.findById(req.params.id).populate('user', 'name email');
        if (!order) {
            return res.status(404).json({ message: 'Order not found' });
        }
        // Only allow owner or admin
        if (order.user._id.toString() !== req.user._id.toString() && !req.user.isAdmin) {
            return res.status(401).json({ message: 'Not authorized' });
        }
        res.json(order);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Update order to paid
// @route   PUT /api/orders/:id/pay
// @access  Private
const updateOrderToPaid = async (req, res) => {
    try {
        const order = await Order.findById(req.params.id);
        if (!order) {
            return res.status(404).json({ message: 'Order not found' });
        }
        order.isPaid = true;
        order.paidAt = Date.now();
        const updatedOrder = await order.save();
        res.json(updatedOrder);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Update order to delivered (Admin)
// @route   PUT /api/orders/:id/deliver
// @access  Private/Admin
const updateOrderToDelivered = async (req, res) => {
    try {
        const order = await Order.findById(req.params.id);
        if (!order) {
            return res.status(404).json({ message: 'Order not found' });
        }
        order.isDelivered = true;
        order.deliveredAt = Date.now();
        const updatedOrder = await order.save();
        res.json(updatedOrder);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get logged-in user orders
// @route   GET /api/orders/myorders
// @access  Private
const getMyOrders = async (req, res) => {
    try {
        const orders = await Order.find({ user: req.user._id }).sort({ createdAt: -1 });
        res.json(orders);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get all orders (Admin)
// @route   GET /api/orders
// @access  Private/Admin
const getAllOrders = async (req, res) => {
    try {
        const orders = await Order.find({}).populate('user', 'id name email').sort({ createdAt: -1 });
        res.json(orders);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get analytics (Admin)
// @route   GET /api/orders/analytics
// @access  Private/Admin
const getAnalytics = async (req, res) => {
    try {
        const totalOrders = await Order.countDocuments();
        const paidOrders = await Order.countDocuments({ isPaid: true });
        const deliveredOrders = await Order.countDocuments({ isDelivered: true });
        const revenueResult = await Order.aggregate([
            { $match: { isPaid: true } },
            { $group: { _id: null, total: { $sum: '$totalPrice' } } },
        ]);
        const totalRevenue = revenueResult.length > 0 ? revenueResult[0].total : 0;
        res.json({ totalOrders, paidOrders, deliveredOrders, totalRevenue });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    createOrder,
    getOrderById,
    updateOrderToPaid,
    updateOrderToDelivered,
    getMyOrders,
    getAllOrders,
    getAnalytics,
};

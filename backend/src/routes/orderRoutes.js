const express = require('express');
const router = express.Router();
const {
    createOrder,
    getOrderById,
    updateOrderToPaid,
    updateOrderToDelivered,
    getMyOrders,
    getAllOrders,
    getAnalytics,
} = require('../controllers/orderController');
const { protect, admin, restaurantOrAdmin } = require('../middleware/authMiddleware');

router.route('/')
    .post(protect, createOrder)
    .get(protect, restaurantOrAdmin, getAllOrders);

router.get('/myorders', protect, getMyOrders);
router.get('/analytics', protect, admin, getAnalytics);
router.route('/:id').get(protect, getOrderById);
router.put('/:id/pay', protect, updateOrderToPaid);
router.put('/:id/deliver', protect, restaurantOrAdmin, updateOrderToDelivered);

module.exports = router;

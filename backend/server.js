require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const connectDB = require('./src/config/db');

const userRoutes = require('./src/routes/userRoutes');
const mealRoutes = require('./src/routes/mealRoutes');
const orderRoutes = require('./src/routes/orderRoutes');
const categoryRoutes = require('./src/routes/categoryRoutes');

connectDB();

const app = express();

app.use(cors());
app.use(express.json());

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
}

// Serve static uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Routes
app.use('/api/users', userRoutes);
app.use('/api/meals', mealRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/categories', categoryRoutes);

app.get('/', (req, res) => {
    res.send('Somalia Food Hub API is running...');
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

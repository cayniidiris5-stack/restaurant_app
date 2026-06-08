require('dotenv').config();
const mongoose = require('mongoose');
const Meal = require('./src/models/Meal');
const User = require('./src/models/User');
const Order = require('./src/models/Order');

async function check() {
    try {
        const dbUri = process.env.MONGODB_URI || process.env.MONGO_URL || process.env.MONGO_URI;
        await mongoose.connect(dbUri);
        console.log('Connected to MongoDB.');

        const mealCount = await Meal.countDocuments();
        const userCount = await User.countDocuments();
        const orderCount = await Order.countDocuments();

        console.log(`Meals: ${mealCount}`);
        console.log(`Users: ${userCount}`);
        console.log(`Orders: ${orderCount}`);

        if (mealCount > 0) {
            const meals = await Meal.find().limit(5);
            console.log('\nSample Meals:');
            meals.forEach(m => console.log(`- ${m.name} (${m.category}) - $${m.price}`));
        }

        if (userCount > 0) {
            const users = await User.find().limit(5);
            console.log('\nSample Users:');
            users.forEach(u => console.log(`- ${u.name} (${u.email}) - Admin: ${u.isAdmin}`));
        }

        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

check();

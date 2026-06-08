require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./src/models/User');

async function seedAdmin() {
    try {
        const dbUri = process.env.MONGODB_URI || process.env.MONGO_URL || process.env.MONGO_URI;
        await mongoose.connect(dbUri);
        console.log('Connected to MongoDB.');

        // Delete existing admin user if exists
        const adminEmail = 'admin@gmail.com';
        await User.deleteOne({ email: adminEmail });

        // Create the admin user
        // Under our new userController rule, any register/creation check with @gmail.com
        // ends up setting isAdmin to true. We explicitly pass it here too just to be certain.
        const admin = await User.create({
            name: 'Admin',
            email: adminEmail,
            password: 'password123',
            isAdmin: true,
            isRestaurant: false
        });

        console.log(`\nSuccess! Admin account seeded:`);
        console.log(`Email: ${admin.email}`);
        console.log(`Password: password123`);
        console.log(`isAdmin: ${admin.isAdmin}`);
        
        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

seedAdmin();

const mongoose = require('mongoose');

const connectDB = async () => {
    try {
        const dbUri = process.env.MONGODB_URI || process.env.MONGO_URL || process.env.MONGO_URI;
        const conn = await mongoose.connect(dbUri);
        console.log(`MongoDB Connected: ${conn.connection.host}`);

        // Surgical index cleanup to solve duplicate key errors from old collection structures
        try {
            const collections = await mongoose.connection.db.listCollections({ name: 'users' }).toArray();
            if (collections.length > 0) {
                const indexes = await mongoose.connection.db.collection('users').indexes();
                const hasPhoneIndex = indexes.some(idx => idx.name === 'phone_1');
                if (hasPhoneIndex) {
                    await mongoose.connection.db.collection('users').dropIndex('phone_1');
                    console.log('Successfully dropped old unique index "phone_1" from users collection.');
                }
            }
        } catch (indexErr) {
            console.log('Index cleanup notice (skipped or index already removed):', indexErr.message);
        }

    } catch (error) {
        console.error(`Error: ${error.message}`);
        process.exit(1);
    }
};

module.exports = connectDB;

require('dotenv').config();
const mongoose = require('mongoose');
const Meal = require('./src/models/Meal');
const Category = require('./src/models/Category');

const meals = [
  {
    name: 'Traditional Bariis & Goat',
    image: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600&auto=format&fit=crop',
    description: 'Aromatic basmati rice (Bariis Iskukaris) slow-cooked with cumin, cardamom, cloves, and cinnamon. Served with incredibly tender, spice-rubbed roasted goat meat, fresh lime, and a sweet banana.',
    price: 14.50,
    category: 'Somali Traditional'
  },
  {
    name: 'Somali Beef Suqaar Combo',
    image: 'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=600&auto=format&fit=crop',
    description: 'Tender cubes of beef stir-fried with bell peppers, red onions, garlic, and traditional Somali Xawaash spice blend. Served with flaky, golden-brown Sabaayad flatbread or Canjeero.',
    price: 11.00,
    category: 'Somali Traditional'
  },
  {
    name: 'Camel Meat Platter (Hilib Geel)',
    image: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=600&auto=format&fit=crop',
    description: 'Traditional delicacy of premium camel meat slow-braised in a savory herb broth until melt-in-your-mouth tender. Served over spiced basmati rice with green hot sauce (Basbaas).',
    price: 16.50,
    category: 'Somali Traditional'
  },
  {
    name: 'Golden Beef Sambusa Duo',
    image: 'https://images.unsplash.com/photo-1601050690597-df056fb4ce78?w=600&auto=format&fit=crop',
    description: 'Two exceptionally crispy, golden pastry triangles filled to the brim with spiced minced beef, chopped coriander, spring onions, and green chilies. Crispy outside, savory inside.',
    price: 4.50,
    category: 'Snacks'
  },
  {
    name: 'Canjeero with Subag & Honey',
    image: 'https://images.unsplash.com/photo-1587314168485-3236d6710814?w=600&auto=format&fit=crop',
    description: 'Three warm, sourdough-fermented Somali crêpes (Canjeero) generously drizzled with local melted subag (clarified ghee) and pure wild honey. Perfect breakfast experience.',
    price: 6.00,
    category: 'Breakfast'
  },
  {
    name: 'Signature Gourmet Beef Burger',
    image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&auto=format&fit=crop',
    description: 'A 200g flame-grilled premium Angus beef patty topped with melted extra-sharp cheddar cheese, caramelized balsamic onions, butter lettuce, heirloom tomato, and house burger sauce inside a toasted artisan brioche bun. Served with crispy fries.',
    price: 12.00,
    category: 'Burgers'
  },
  {
    name: 'Creamy Tuscan Chicken Pasta',
    image: 'https://images.unsplash.com/photo-1645112411341-6c4fd023714a?w=600&auto=format&fit=crop',
    description: 'Al dente penne pasta tossed in a decadent, garlic-parmesan cream sauce with vine-ripened sun-dried tomatoes, fresh baby spinach, and juicy sliced grilled chicken breast.',
    price: 13.50,
    category: 'Pasta'
  },
  {
    name: 'Crispy Garlic Parmesan Wings',
    image: 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=600&auto=format&fit=crop',
    description: 'Eight crispy jumbo chicken wings fried to golden perfection and tossed in a rich, buttery emulsion of minced garlic, fresh parsley, and freshly grated imported parmesan cheese.',
    price: 9.50,
    category: 'Snacks'
  },
  {
    name: 'Stone-Baked Margherita Pizza',
    image: 'https://images.unsplash.com/photo-1604068549290-dea0e4a305ca?w=600&auto=format&fit=crop',
    description: 'Stone-baked thin crust topped with san marzano tomato sauce, fresh buffalo mozzarella, aromatic sweet basil leaves, and finished with a drizzle of robust extra virgin olive oil.',
    price: 11.50,
    category: 'Pizza'
  },
  {
    name: 'Somalian Mango Nectar',
    image: 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=600&auto=format&fit=crop',
    description: 'Pure, freshly squeezed juice made from sun-ripened organic Somali mangoes. Incredibly sweet, velvety, and served ice cold with a slice of fresh lime.',
    price: 4.00,
    category: 'Beverages'
  },
  {
    name: 'Aromatic Shaah Adays (Somali Tea)',
    image: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=600&auto=format&fit=crop',
    description: 'Rich loose-leaf black tea brewed with fresh milk and infused with crushed green cardamom, cloves, cinnamon bark, and fresh ginger. Warm, comforting, and authentic.',
    price: 2.50,
    category: 'Beverages'
  }
];

async function seedData() {
  try {
    const dbUri = process.env.MONGODB_URI || process.env.MONGO_URL || process.env.MONGO_URI;
    await mongoose.connect(dbUri);
    console.log('Connected to database for seeding...');

    // Clear existing meals
    await Meal.deleteMany({});
    console.log('Cleared existing meals.');

    // Seed new meals
    const createdMeals = await Meal.insertMany(meals);
    console.log(`Successfully seeded ${createdMeals.length} delicious meals!`);

    // Clear existing categories
    await Category.deleteMany({});
    console.log('Cleared existing categories.');

    // Seed new categories
    const categoriesToSeed = [
      { name: 'Somali Traditional' },
      { name: 'Snacks' },
      { name: 'Breakfast' },
      { name: 'Burgers' },
      { name: 'Pasta' },
      { name: 'Pizza' },
      { name: 'Beverages' }
    ];
    const createdCategories = await Category.insertMany(categoriesToSeed);
    console.log(`Successfully seeded ${createdCategories.length} categories!`);

    process.exit(0);
  } catch (error) {
    console.error(`Seeding error: ${error.message}`);
    process.exit(1);
  }
}

seedData();

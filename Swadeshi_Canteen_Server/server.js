const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const connectDB = require('./config/database');
const userRoutes = require('./routes/userRoutes');
const productRoutes = require('./routes/productRoutes');
const orderRoutes = require('./routes/orderRoutes');
const categoryRoutes = require('./routes/categoryRoutes');
const cartRoutes = require('./routes/cartRoutes');
const addressRoutes = require('./routes/addressRoutes');
const sliderRoutes = require('./routes/sliderRoutes');
const carouselRoutes = require('./routes/carouselRoutes');
const deliveryfeeRoutes = require('./routes/deliveryfeeRoutes')
const superCategoryRoutes = require('./routes/superCategoryRoutes')
const dotenv = require('dotenv');

dotenv.config();
const app = express();
const PORT = process.env.PORT || 5000;

// Connect to MongoDB
connectDB();

// Middleware
app.use(bodyParser.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/users', userRoutes);
app.use('/products', productRoutes);
app.use('/orders', orderRoutes);
app.use('/categories', categoryRoutes);
app.use('/superCategories',superCategoryRoutes);
app.use('/cart', cartRoutes);
app.use('/address', addressRoutes);
app.use('/orders',orderRoutes);
app.use('/sliders',sliderRoutes);
app.use('/carousels',carouselRoutes);
app.use('/deliveryfee',deliveryfeeRoutes);

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

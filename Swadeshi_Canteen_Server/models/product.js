const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  productId: {
    type: String,
    required: true,
    unique: true, // Ensures productId is unique
    trim: true // Removes any extra spaces from productId
  },
  name: {
    type: String,
    required: true, // Product name is required
    trim: true
  },
  description: {
    type: String,
    trim: true // Optional description field for the product
  },
  price: {
    type: Number,
    required: true // Price is required for the product
  },
  mrp: {
    type: Number,
    required: true // Price is required for the product
  },
  stock: {
    type: Number,
    required: true, // Stock quantity is required
    min: 0 // Ensures stock is non-negative
  },
  categoryId: {
    type: String,
    required: true // CategoryId is required
  },
  imageUrl: {
    type: String, // Optional field for storing the product image URL
    trim: true
  },
  additionalImages: {
    type: [String], // Array of strings for additional image URLs
    default: [] // Default is an empty array
  },  
  rating: {
    type: Number,
    min: 0,
    max: 5,
    default: 0 // Default rating is 0, out of 5
  },
  ratingCount: {
    type: Number,
    default: 0 // Tracks the number of ratings
  },
  createdAt: {
    type: Date,
    default: Date.now // Automatically sets the creation date
  },
  updatedAt: {
    type: Date,
    default: Date.now // Automatically sets the update date
  }
});

// Middleware to set 'updatedAt' on document update
productSchema.pre('save', function (next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('Product', productSchema);

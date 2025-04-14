const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema({
    categoryId: {
        type: String,
        required: true,
        unique: true, // Ensures categoryId is unique
        trim: true // Removes any extra spaces from categoryId
    },
    name: {
        type: String,
        required: true,
        unique: true,
        trim: true
    },
    superCategoryId:{
        type: String,
        required: true
    },
    description: {
        type: String,
    },
    imageUrl: {
        type: String, // Optional field for storing the image URL of the category
        trim: true
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
categorySchema.pre('save', function (next) {
    this.updatedAt = Date.now();
    next();
  });

const Category = mongoose.model('Category', categorySchema);

module.exports = Category;

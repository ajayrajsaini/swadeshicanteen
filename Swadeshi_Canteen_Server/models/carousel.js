// models/Carousel.js
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const carouselSchema = new Schema({
  title: {
    type: String,
    required: true
  },
  imageUrl: [{
    type: String,
    required: true
  }],
  description: {
    type: String,
    required: false
  },
  route: {
    type: String, // Optional: The route to which this carousel item links(i.e. product or category)
    required: false
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Carousel', carouselSchema);

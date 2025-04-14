const mongoose = require('mongoose');

// Define the schema for delivery fees
const deliveryFeeSchema = new mongoose.Schema({
  min_free_delivery: { 
    type: Number, 
    required: true, 
    default: 500,       // Default value for free delivery threshold
  },
  delivery_fee: { 
    type: Number, 
    required: true, 
    default: 50,        // Default delivery fee
  },
  updated_at: { 
    type: Date, 
    default: Date.now   // Automatically track updates
  }
});

// Create the model
const DeliveryFee = mongoose.model('DeliveryFee', deliveryFeeSchema);

module.exports = DeliveryFee;

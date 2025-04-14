const mongoose = require('mongoose');
const product = require('./product');


const orderSchema = new mongoose.Schema({
  user: {
    type: String,
    required: true
  },
  items: [{
    productId: {
      type: String,
      required: true
    },
    quantity: {
      type: Number,
      required: true
    },
    price: {
      type: Number,
      required: true
    }
  }],
  totalPrice: {
    type: Number,
    required: true,
  },
  orderStatus: {
    type: String,
    enum: ['Pending','assigned', 'Processing', 'Shipped', 'Delivered', 'Cancelled'],
    default: 'Pending',
  },
  paymentStatus: {
    type: String,
    enum: ['Pending', 'Paid', 'Failed'],
    default: 'Pending'
  },
  assignedDeliveryBoy:{
    type: String
  },
  deliveryAddress: {
    type: String,
    required: true,
  },
  paymentMethod: {
    type: String,
    enum: ['Credit Card', 'PayPal', 'Stripe', 'UPI', 'Cash On Delivery'],
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  deliveredAt: {
    type: Date
  }
});

const Order = mongoose.model('Order', orderSchema);

module.exports = Order;

const mongoose = require('mongoose');



const cartSchema = new mongoose.Schema({
    user: {
        type: String,
        required: true,
    },
    items: [{
        productId: { type: String},
        quantity: { type: Number, default: 1 },
        price:{type:String}
    }],
    totalPrice: {
        type: Number,
        default: 0
      },
      createdAt: {
        type: Date,
        default: Date.now
      }
});

const Cart = mongoose.model('Cart', cartSchema);

module.exports = Cart;

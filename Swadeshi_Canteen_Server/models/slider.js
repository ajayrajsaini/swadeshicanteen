const mongoose = require('mongoose');

const sliderSchema = new mongoose.Schema({
    title: { type: String, required: true },
    numberOfProducts: { type: Number, required: true },
    showViewAll: { type: Boolean, required: true },
    products: [{
        type:String,
        required:true
    }]
}, { timestamps: true });

const Slider = mongoose.model('Slider', sliderSchema);
module.exports = Slider;

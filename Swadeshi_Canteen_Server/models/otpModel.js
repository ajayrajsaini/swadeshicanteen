// otpModel.js
const mongoose = require('mongoose');

// Custom validation to ensure only one of phone or email is provided
const otpSchema = new mongoose.Schema({
    phone: {
        type: String,
        required: function() {
            return !this.email; // Require phone if email is not provided
        },
        unique: true, // Ensure each phone number is unique
        sparse: true,
    },
    email: {
        type: String,
        required: function() {
            return !this.phone; // Require email if phone is not provided
        },
        unique: true, // Ensure each email is unique
        sparse: true,
    },
    otp: {
        type: String,
        required: true,
    },
    createdAt: {
        type: Date,
        default: Date.now,
        expires: '10m', // Automatically delete the OTP after 10 minutes
    },
    isUsed: {
        type: Boolean,
        default: false,
    },
});
// Ensure at least one of `phone` or `email` is provided
otpSchema.pre('validate', function(next) {
    if (!this.phone && !this.email) {
        return next(new Error('Either phone or email must be provided'));
    }
    next();
});

const Otp = mongoose.model('Otp', otpSchema);

module.exports = Otp;

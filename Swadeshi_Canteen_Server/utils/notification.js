const nodemailer = require('nodemailer');
const axios = require('axios');

// Email setup (using nodemailer)
const transporter = nodemailer.createTransport({
    service: 'gmail',
    host: "smtp.gmail.com",
    port: 587,
    secure: false,
    auth: {
        user: 'pubgkorucbuy@gmail.com',
        pass: 'bipa tpko oybg udvb',
    },
});



// Send verification code via email or SMS
exports.sendVerificationCode = async (identifier, verificationCode) => {
    console.log("choosing verification method");
    if (identifier.includes('@')) { // If it's an email
        console.log("sending mail");
        await transporter.sendMail({
            from: {
                name: 'Ajay Raj',
                address: 'pubgkorucbuy@gmail.com'
            },
            to: identifier,
            subject: 'Verification Code',
            text: `Your verification code is: ${verificationCode}`,
        });
        console.log("mail sent");
    } else { // If it's a phone number
        try {
            const response = await axios.post('https://www.fast2sms.com/dev/bulkV2', {
                route: "dlt",
                sender_id: "GYTRGP",
                message: "175236", // Replace this with your actual template ID
                variables_values: `${verificationCode}|`, // Sending verification code here
                flash: 0,
                numbers: identifier // Phone number to send the SMS
            }, {
                headers: {
                    "authorization": "uyZG4YRXnhAvSU5KDCQbm2gJIpTeLOcrad3j0tzMW86kflwPE74TrQ5AWOe09XGR7yH6YUupKNjMv3Jo", // Your Fast2SMS API Key
                    "Content-Type": "application/json"
                }
            });
    
            console.log("SMS sent successfully:", response.data);
        } catch (error) {
            console.error("Error sending SMS:", error);
        }
    }
};

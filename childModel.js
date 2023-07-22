const mongoose = require('mongoose')

const childRegistrationSchema = mongoose.Schema(
    {
        username: {
        type: String,
        required: true
        },
        password: {
        type: String,
        required: true
        }
   },
   {
    timestamps: false,
    versionKey: false
   }
)

const childRegistration = mongoose.model('childRegistration', childRegistrationSchema)
module.exports = childRegistration
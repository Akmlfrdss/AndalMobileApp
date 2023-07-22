const mongoose = require('mongoose');

const childProfileSchema = mongoose.Schema({
    username: String,
    name: String,
    latitude: Number,
    longitude: Number,
});
  
const ChildProfile = mongoose.model('ChildProfile', childProfileSchema)
module.exports = ChildProfile;

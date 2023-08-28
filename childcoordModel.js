const mongoose = require('mongoose')

const childCoordSchema = mongoose.Schema(
  { 
    username: String,
    latitude: Number,
    longitude: Number,
  }
)

const ChildCoord = mongoose.model('ChildCoord', childCoordSchema)
module.exports = ChildCoord

const express = require('express');
const mongoose = require('mongoose');
const app = express();
const Registration = require('./userModel');
const childRegistration = require('./childModel');
const ChildProfile = require('./childprofileModel');
const ChildCoord = require('./childcoordModel');


// Express route to handle registration
app.use(express.json())

app.get('/', (req, res) =>{
  res.send('Hello Node API')
})

app.get('/register', async (req, res) =>{
  try{
    const registration = await Registration.find({})
    res.status(200).json(registration)
  } catch (error) {
    console.log(error.message)
    res.status(500).json({ message: error.message})
  }
})

app.get('/childregister', async (req, res) =>{
  try{
    const childregistration = await childRegistration.find({})
    res.status(200).json(childregistration)
  } catch (error) {
    console.log(error.message)
    res.status(500).json({ message: error.message})
  }
})

app.post('/register', async (req, res) => {
  try {
    const { username, password } = req.body;

    // Periksa apakah username sudah ada dalam database
    const existingUser = await Registration.findOne({ username });

    if (existingUser) {
      // Jika username sudah ada, kirimkan respons dengan pesan kesalahan
      return res.status(400).json({ message: 'Username already exists' });
    }

    // Buat pengguna baru dan simpan ke database
    const registration = await Registration.create({ username, password });

    res.status(200).json(registration);
  } catch (error) {
    console.log(error.message);
    res.status(500).json({ message: error.message });
  }
});

app.post('/childregister', async (req, res) => {
  try {
    const { username, password } = req.body;

    // Periksa apakah username sudah ada dalam database
    const existingUser = await childRegistration.findOne({ username });

    if (existingUser) {
      // Jika username sudah ada, kirimkan respons dengan pesan kesalahan
      return res.status(400).json({ message: 'Username already exists' });
    }

    // Buat pengguna baru dan simpan ke database
    const childregistration = await childRegistration.create({ username, password });

    res.status(200).json(childRegistration);
  } catch (error) {
    console.log(error.message);
    res.status(500).json({ message: error.message });
  }
});

app.get('/login', async (req, res) =>{
  try{
    const registration = await Registration.find({})
    res.status(200).json(registration)
  } catch (error) {
    console.log(error.message)
    res.status(500).json({ message: error.message})
  }
})

app.get('/childlogin', async (req, res) =>{
  try{
    const childregistration = await childRegistration.find({})
    res.status(200).json(childregistration)
  } catch (error) {
    console.log(error.message)
    res.status(500).json({ message: error.message})
  }
})

app.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    
    // Mencari pengguna berdasarkan username di database
    const user = await Registration.findOne({ username });

    if (!user) {
      // Jika pengguna tidak ditemukan, kirimkan respons dengan isAuthenticated: false
      res.status(401).json({ isAuthenticated: false });
    } else {
      // Jika pengguna ditemukan, periksa kecocokan password
      if (user.password === password) {
        // Jika password cocok, kirimkan respons dengan isAuthenticated: true
        res.status(200).json({ isAuthenticated: true });
      } else {
        // Jika password tidak cocok, kirimkan respons dengan isAuthenticated: false
        res.status(401).json({ isAuthenticated: false });
      }
    }
  } catch (error) {
    console.log(error.message);
    res.status(500).json({ message: error.message });
  }
});

app.post('/childlogin', async (req, res) => {
  try {
    const { username, password } = req.body;
    
    // Mencari pengguna berdasarkan username di database
    const user = await childRegistration.findOne({ username });

    if (!user) {
      // Jika pengguna tidak ditemukan, kirimkan respons dengan isAuthenticated: false
      res.status(401).json({ isAuthenticated: false });
    } else {
      // Jika pengguna ditemukan, periksa kecocokan password
      if (user.password === password) {
        // Jika password cocok, kirimkan respons dengan isAuthenticated: true
        res.status(200).json({ isAuthenticated: true });
      } else {
        // Jika password tidak cocok, kirimkan respons dengan isAuthenticated: false
        res.status(401).json({ isAuthenticated: false });
      }
    }
  } catch (error) {
    console.log(error.message);
    res.status(500).json({ message: error.message });
  }
});

app.get('/childProfiles', async (req, res) => {
  try {
    const childProfiles = await ChildProfile.find();
    res.status(200).json(childProfiles);
  } catch (error) {
    res.status(500).json({ error: 'Terjadi kesalahan dalam mengambil data Child Profile.' });
  }
});

app.get('/addProfile', async (req, res) =>{
  try{
    const newProfile = await ChildProfile.find({})
    res.status(200).json(newProfile)
  } catch (error) {
    console.log(error.message)
    res.status(500).json({ message: error.message})
  }
})


app.post('/addProfile', async (req, res) => {
  try {
    const { username,name, latitude, longitude } = req.body;

    const newProfile = await ChildProfile.create({
      username,
      name,
      latitude,
      longitude,
    });

    res.status(200).json(newProfile);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.delete('/childProfiles', async (req, res) => {
  try {
    const { id } = req.params;

    // Hapus child profile berdasarkan ID
    await ChildProfile.findByIdAndDelete(id);

    res.status(200).json({ message: 'Child profile deleted successfully' });
  } catch (error) {
    console.log(error.message);
    res.status(500).json({ message: error.message });
  }
});

app.post('/coordinates', async (req, res) => {
  try {
    const { username, latitude, longitude } = req.body
    console.log('Received data:', username, latitude, longitude);
    const newChildCoord = await ChildCoord.create({
      username,
      latitude,
      longitude,
    })

    res.status(200).json(newChildCoord)
  } catch (error) {
    console.error('Error saving coordinate:', error)
    res.status(500).json({ error: 'An error occurred' })
  }
})

app.get('/coordinates', async (req, res) => {
  try {
    const coordinates = await ChildCoord.find({})
    res.status(200).json(coordinates)
  } catch (error) {
    console.error('Error fetching coordinates:', error)
    res.status(500).json({ error: 'An error occurred' })
  }
})


// app.get('/save-location', async (req, res) =>{
//   try{
//     const newCoord = await ChildCoord.find({})
//     res.status(200).json(newCoord)
//   } catch (error) {
//     console.log(error.message)
//     res.status(500).json({ message: error.message})
//   }
// })

// app.post('/save-location', async (req, res) => {
//   try {
//     const { username, latitude, longitude } = req.body;

//     // Menggunakan model ChildCoord untuk menyimpan data lokasi
//     const newCoord = await ChildCoord.create({
//       username,
//       latitude,
//       longitude,
//     });

//     res.status(200).json(newCoord);
//   } catch (error) {
//     console.log(error.message);
//     res.status(500).json({ message: error.message });
//   }
// });

// Mongoose connection
mongoose.connect('mongodb+srv://abdillahakmal:akmal4km4l@cluster1.l2o724k.mongodb.net/TrackinglocApp?retryWrites=true&w=majority')
  .then(() => {
  console.log('Connected to MongoDB')
  app.listen(3000, () => {
    console.log(`Server is running on port 3000`)
  })
}).catch((error) => {
})
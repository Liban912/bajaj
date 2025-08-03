# iMap GPS Tracking - Setup Instructions

## Quick Setup Guide

### 1. Firebase Setup

1. **Create Firebase Project**

   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add project"
   - Follow the setup wizard

2. **Enable Services**

   - **Authentication**: Enable Email/Password sign-in method
   - **Realtime Database**: Create database in test mode initially

3. **Download Configuration**

   - Go to Project Settings > General
   - Download `google-services.json` for Android
   - Place it in `android/app/` directory

4. **Set Database Rules**
   - Go to Realtime Database > Rules
   - Replace with the rules from `firebase_rules.json`
   - Or use these basic rules for testing:
   ```json
   {
     "rules": {
       "location": {
         ".read": true,
         ".write": true
       }
     }
   }
   ```

### 2. Mapbox Setup

1. **Create Mapbox Account**

   - Go to [Mapbox](https://www.mapbox.com/)
   - Sign up for a free account

2. **Get Access Token**

   - Go to Account > Access tokens
   - Copy your default public token

3. **Create Environment File**
   - Create `.env` file in project root
   - Add: `MAPBOX_ACCESS_TOKEN=your_token_here`

### 3. App Configuration

1. **Install Dependencies**

   ```bash
   flutter pub get
   ```

2. **Run the App**
   ```bash
   flutter run
   ```

## Testing the Location Tracking

### Method 1: Using the Test Interface

1. Login to the app
2. Tap the science icon (🧪) in the app bar
3. Use the "Quick Test Locations" buttons
4. Watch real-time updates in the main interface

### Method 2: Manual Database Updates

1. Go to Firebase Console > Realtime Database
2. Add a new entry under `location`:
   ```json
   {
     "latitude": 40.7128,
     "longitude": -74.006,
     "timestamp": 1703123456789
   }
   ```
3. Watch the app update in real-time

### Method 3: Using Firebase CLI

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Set project
firebase use your-project-id

# Update location data
firebase database:set /location '{"latitude": 40.7128, "longitude": -74.0060, "timestamp": 1703123456789}'
```

## Database Structure

The app expects data in this exact format:

```json
{
  "location": {
    "latitude": 40.7128,
    "longitude": -74.006,
    "timestamp": 1703123456789
  }
}
```

**Important**: Field names must be exactly `latitude`, `longitude`, and `timestamp`.

## Troubleshooting

### Common Issues

1. **"Error loading .env file"**

   - Ensure `.env` file exists in project root
   - Check token format: `MAPBOX_ACCESS_TOKEN=your_token_here`

2. **"Permission denied" in Firebase**

   - Check database rules
   - Ensure user is authenticated
   - Verify database path is correct

3. **Map not loading**

   - Verify Mapbox token is valid
   - Check internet connection
   - Ensure token has proper permissions

4. **Location not updating**
   - Check Firebase connection
   - Verify database rules allow read/write
   - Ensure data format is correct

### Debug Steps

1. **Check Firebase Connection**

   ```dart
   // Add this to test Firebase connection
   FirebaseDatabase.instance.ref().child('test').set({'test': 'value'});
   ```

2. **Verify Environment Variables**

   ```dart
   // Add this to check token loading
   print('Token: ${dotenv.env["MAPBOX_ACCESS_TOKEN"]}');
   ```

3. **Test Database Rules**
   - Try reading/writing to database manually
   - Check Firebase Console logs

## Security Notes

- Use proper Firebase rules in production
- Implement user-specific location paths
- Add rate limiting for location updates
- Consider data retention policies
- Implement proper error handling

## Next Steps

After basic setup:

1. Implement user-specific location tracking
2. Add location history
3. Implement geofencing
4. Add location sharing features
5. Implement offline support

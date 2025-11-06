# Inventory Management App

A fully functional **Inventory Management Application** built with Flutter and Firebase Firestore, featuring real-time data synchronization and comprehensive CRUD operations.

## 📱 Features

### Core Functionality
- **Create**: Add new inventory items with name, quantity, price, and category
- **Read**: View all inventory items in real-time with automatic updates
- **Update**: Edit existing items with pre-filled forms
- **Delete**: Remove items using swipe-to-delete or delete button

### Enhanced Features Implemented

#### 1. **Advanced Search & Filtering** 🔍
- **Real-time Search**: Filter items by name as you type
- **Category Filters**: Quick filter chips for different categories (Electronics, Clothing, Food, Tools, Other)
- **Stock Status Filter**: Toggle to show only low-stock items (quantity < 5)
- **Smart Filtering**: Combine search and category filters for precise results

#### 2. **Data Insights Dashboard** 📊
- **Comprehensive Statistics**:
  - Total number of unique items in inventory
  - Total inventory value (sum of quantity × price for all items)
  - Total item count across all products
  - Out-of-stock items count and list
- **Stock Alerts**:
  - Low stock warnings for items with quantity < 5
  - Out-of-stock alerts for items with quantity = 0
- **Inventory Health Score**: Visual representation of overall inventory health
- **Color-coded Indicators**: 
  - Green: Good stock levels
  - Orange: Low stock warning
  - Red: Out of stock

## 🚀 How to Run the App

### Prerequisites
1. **Flutter SDK** (3.0 or higher)
2. **Android Studio** or **VS Code** with Flutter extensions
3. **Firebase account** and project setup

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/gsurjs/Inventory_Management_App.git
   cd Inventory_Management_App
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Enable Firestore Database in test mode
   - Install FlutterFire CLI:
     ```bash
     dart pub global activate flutterfire_cli
     ```
   - Configure Firebase in your project:
     ```bash
     flutterfire configure
     ```
   - Select your Firebase project and Android platform
   
   **Note**: This will generate `firebase_options.dart` which is gitignored for security.
   See `FIREBASE_SETUP.md` for detailed instructions.

4. **Run the app**:
   ```bash
   flutter run
   ```

5. **Build release APK** (optional):
   ```bash
   flutter build apk --release
   ```
   The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`

## 📂 Project Structure

```
inclass15/
├── lib/
│   ├── main.dart                    # App entry point & Firebase initialization
│   ├── firebase_options.dart        # Firebase configuration (generated)
│   ├── models/
│   │   └── item.dart                # Item data model with Firestore serialization
│   ├── services/
│   │   └── firestore_service.dart   # Firestore CRUD operations & database logic
│   └── screens/
│       ├── inventory_home_page.dart # Main screen with item list & search
│       ├── add_edit_item_screen.dart # Form for adding/editing items
│       └── dashboard_screen.dart    # Statistics and insights dashboard
├── pubspec.yaml                      # Dependencies configuration
└── README.md                         # Project documentation
```

## 🔧 Technical Implementation

### Data Model
The `Item` class includes:
- **id**: String (Firestore document ID)
- **name**: String (item name)
- **quantity**: int (stock quantity)
- **price**: double (unit price)
- **category**: String (item category)
- **createdAt**: DateTime (timestamp)

### Firestore Integration
- **Collection**: All items stored in 'items' collection
- **Real-time Updates**: Using Firestore streams for live data
- **Error Handling**: Comprehensive try-catch blocks for all operations
- **Data Validation**: Form validation before database operations

### UI Features
- **Material Design 3**: Modern, clean interface
- **Responsive Layout**: Adapts to different screen sizes
- **Loading States**: Visual feedback during data operations
- **Empty States**: Informative messages when no data
- **Error Handling**: User-friendly error messages
- **Swipe Actions**: Swipe-to-delete with confirmation
- **Color Coding**: Visual indicators for stock levels

## 🎨 Additional UI Enhancements

Beyond the required features, the app includes:
- **Floating Action Button**: Quick access to add new items
- **Pull-to-Refresh**: Update dashboard statistics
- **Confirmation Dialogs**: Prevent accidental deletions
- **Snackbar Notifications**: Feedback for user actions
- **Undo Actions**: Restore deleted items
- **Form Validation**: Ensure data integrity
- **Custom Theme**: Consistent Material Design theming
- **Gradient Cards**: Visually appealing statistics cards
- **Progress Indicators**: Health score visualization

## 📊 Firestore Database Structure

```json
{
  "items": {
    "documentId": {
      "name": "Item Name",
      "quantity": 10,
      "price": 29.99,
      "category": "Electronics",
      "createdAt": "Timestamp"
    }
  }
}
```

## 🛡️ Security Considerations

### Firebase Configuration
- **This is a public repository** - Firebase configuration files are gitignored
- Each developer needs to set up their own Firebase project
- See `FIREBASE_SETUP.md` for detailed setup instructions
- Firebase mobile API keys are designed to be public (security is handled by Firebase rules)

## 📝 License

This project is created for educational purposes as part of MAD In-Class Activity #15.

## 👥 Author

- Robert Stanley
(Created for Mobile Application Development Course - Fall 2025)
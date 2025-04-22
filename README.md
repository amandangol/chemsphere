# ChemSphere: Your Chemistry Exploration Companion

![ChemSphere Logo](assets/images/chemlogo.png)

## 📱 Overview

ChemSphere is a comprehensive chemistry exploration app designed to make chemistry accessible, engaging, and educational. Addressing both Chemistry and Geolocation challenge statements, ChemSphere combines rich chemical data with location-based services to deliver a unique educational experience. Whether you're a student, educator, or chemistry enthusiast, ChemSphere provides a suite of tools to explore elements, compounds, formulas, and geolocation-based air quality data in an intuitive and visually appealing interface.

## 🎥 Demo

[![ChemSphere Demo](https://img.youtube.com/vi/YOUTUBE_VIDEO_ID/0.jpg)](https://www.youtube.com/watch?v=YOUTUBE_VIDEO_ID)

*Note: Replace YOUTUBE_VIDEO_ID with your actual YouTube video ID*

## 🏆 Challenge Statements Addressed

ChemSphere successfully addresses two major challenge statements:

### Chemistry Challenge ⚛️
- Comprehensive chemistry data integration via PubChem API
- Interactive periodic table with detailed element information
- Molecular visualization in 3D for compounds and drugs
- Educational content on chemical properties and reactions

### Geolocation Challenge 🌍
- Real-time air quality monitoring based on user location
- Global air quality map showing AQI in major cities worldwide
- OpenStreetMap integration with custom AQI markers
- City search functionality with global coverage
- Geocoding and reverse geocoding using OpenStreetMap/Nominatim API

## ✨ Features

### 🏠 Home Dashboard
- Quick access to all major features
- Daily chemistry facts
- Real-time air quality indicator for current location
- Beautifully designed chemistry-themed interface
- Animated molecular patterns and visual elements

### ⚛️ Periodic Table
- Interactive periodic table with detailed element information
- Color-coded element categories
- Tap elements to view comprehensive details
- Search elements by name, symbol, or properties

### 🧪 Modern Periodic Table
- Educational version with group and period indicators
- Detailed comparison between modern and Mendeleev's tables
- Visual explanations of periodic trends
- Interactive zooming and panning

### 🔍 Compound Search
- Search chemical compounds by name
- View molecular structures
- Detailed property information
- Quick access to common compounds

### 📋 Formula Search
- Find compounds by molecular formula
- Educational information about formula notation
- Common formula examples
- Seamless integration with compound details

### 💊 Drug Explorer
- Search pharmaceutical compounds
- View medical applications
- Molecular structures and properties
- Educational information on drug classifications

### 🔬 Interactive 3D Molecular Viewer
- View compounds and drugs in 3D structure
- Interactive rotation, zooming, and panning
- Multiple viewing styles (stick, line, ball)
- Auto-rotation for better visualization
- Full-screen mode for detailed examination
- Color-coded atoms for easy identification
- Switch between 2D and 3D representations
- Featured molecules organized by categories (Common, Organic, Biochemical, Drug, Complex)
- Recent molecules history for quick access
- Share functionality for molecules

### ⚖️ Molecular Weight Calculator
- Calculate exact molecular weight for any chemical formula
- Beautiful and intuitive user interface with animated transitions
- Supports complex formulas including parentheses, hydrates, and multiple elements
- Detailed composition analysis showing mass percentage of each element
- Interactive formula parsing with color-coded elements
- Unit conversion between g/mol, kg/mol, amu, and Daltons
- View element details directly from the formula breakdown
- Calculation history with filtering options (All, Today, This Week)
- Element information cards with atomic details
- Formula entry guidelines with helpful tips
- Example formulas for quick access

### 💨 Air Quality Monitor
- Real-time AQI data for your current location
- Global air quality map showing AQI in major cities worldwide
- Toggle between local view and global view
- Detailed pollutant information for each location
- Color-coded AQI indicators based on air quality levels
- Health recommendations based on air quality
- City search for specific location air quality data
- Detailed breakdown of pollutants (PM2.5, PM10, Ozone, etc.)
- Visual representation of dominant pollutants

### 📚 Chemistry Guide
- Educational resources for chemistry learning
- Interactive guides and tutorials
- Organized by chemistry topics
- Visual explanations of complex concepts

### 🔄 Element Flashcards
- Study element properties with interactive flashcards
- Front side shows key information
- Back side reveals detailed properties
- Shuffle option for randomized study

### 📌 Bookmarks
- Save favorite elements, compounds, and educational content
- Organize saved items by category
- Quick access to frequently referenced information
- Seamless integration with other app features

## 🌐 APIs and Data Sources

ChemSphere integrates with several reputable APIs to provide accurate and comprehensive chemistry information:

### PubChem API
- **Base URL**: https://pubchem.ncbi.nlm.nih.gov/rest/pug
- **Service**: Comprehensive database of chemical molecules and their activities
- **Key Endpoints**:
  - `/compound/name` - Search compounds by name
  - `/compound/cid` - Retrieve compound details
  - `/compound/fastformula` - Search by molecular formula
  - PubChem View API for detailed information
  - PubChem Autocomplete API for search suggestions
- **Features**:
  - Access to over 100 million chemical compounds
  - Detailed physical and chemical properties
  - Molecular structures and 3D models
  - Compound classifications
  - Patent information
  - Assay data
  - Structure similarity search

### Wikipedia API
- **Base URL**: https://en.wikipedia.org/api/rest_v1
- **Service**: Educational content and reference information
- **Key Endpoints**:
  - `/page/summary` - Article summaries
  - `/page/mobile-sections` - Article content sections
  - `/page/related` - Related articles
  - `/page/media-list` - Article images
- **Features**:
  - Educational content for chemistry topics
  - Compound descriptions and applications
  - Historical information about elements and discoveries
  - Chemistry-filtered search results
  - Related articles and topic examples
  - Media content for educational purposes

### OpenStreetMap & Nominatim API
- **Base URL**: https://nominatim.openstreetmap.org
- **Service**: Maps, geocoding, and location services
- **Implementation**: Integrated via flutter_map package
- **Key Endpoints**:
  - `/search` - Location search by name
  - `/reverse` - Reverse geocoding (coordinates to location names)
- **Features**:
  - Interactive maps for global air quality data visualization
  - Custom map markers displaying AQI values for cities worldwide
  - Color-coded markers based on air quality levels
  - Location visualization for city search results
  - Reverse geocoding for current location identification
  - Zoom and pan functionality for map exploration
  - Toggle between local and global air quality views

### Open-Meteo Air Quality API
- **Base URL**: https://air-quality-api.open-meteo.com/v1/air-quality
- **Service**: Global air quality monitoring
- **Features**:
  - Real-time air quality data worldwide
  - Pollutant concentrations (PM2.5, PM10, O3, NO2, SO2, CO)
  - US AQI calculations 
  - Current air quality measurements
  - No API key required (free access)
  - Data for multiple major cities simultaneously

### 3Dmol.js Integration
- **Service**: Web-based molecular visualization
- **Implementation**: Custom WebView integration
- **Features**:
  - Interactive 3D visualization of molecular structures
  - Multiple viewing styles (stick, line, ball)
  - Color-coded atoms by element
  - Rotation, zooming, and manipulation controls
  - Toggle between 2D and 3D representations
  - Auto-rotation functionality
  - Full-screen viewing mode
  - Featured and recent molecules library

## 🛠️ Technical Features

- Modern Flutter UI with Material 3 design principles
- Provider state management architecture
- Integration with multiple chemistry APIs
- Smooth animations and transitions
- Responsive design for various device sizes
- Offline data caching for core functionality
- Comprehensive error handling
- Cross-platform compatibility
- WebView-based 3D molecular visualization
- Concurrent API requests for efficient data loading

## 🚀 Installation

### Prerequisites

- Flutter SDK (2.12.0 or later)
- Dart SDK (2.12.0 or later)
- Android Studio or VS Code with Flutter extensions
- Git

### Step 1: Clone the Repository

```bash
git clone https://github.com/amandangol/chemsphere.git
cd chem_explore
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Run the Application

```bash
flutter run
```

For a specific device or emulator:

```bash
flutter devices
flutter run -d <device_id>
```

### Building for Production

#### Android

```bash
flutter build apk --release
```

The APK file will be available at `build/app/outputs/flutter-apk/app-release.apk`

#### iOS

```bash
flutter build ios --release
```

Then open the iOS project in Xcode to archive and distribute:

```bash
open ios/Runner.xcworkspace
```

## 📋 Usage Guide

### First Launch

On first launch, you'll be presented with an onboarding sequence introducing the key features of ChemSphere. You can swipe through each screen or tap "Skip" to proceed directly to the main app.

### Navigation

The bottom navigation bar provides access to the main sections of the app:
- **Home**: Dashboard with quick access to all features
- **Elements**: Interactive periodic table
- **Air Quality**: Real-time air quality data
- **Compounds**: Chemical compound search and information
- **Saved**: Bookmarked elements, compounds, and content

### Exploring Elements

1. Navigate to the "Elements" tab
2. Tap on any element tile to view detailed information
3. Use the search bar to find specific elements
4. Toggle between the standard and modern periodic tables

### Searching Compounds

1. Navigate to the "Compounds" tab
2. Enter a compound name in the search bar
3. Tap on search results to view detailed information
4. Use the filter options to refine your search

### Using the 3D Molecular Viewer

1. Access from the Home screen or through compound details
2. Search for molecules by name or browse featured categories
3. View recent molecules in the "Recent" tab
4. Use touch gestures to rotate and zoom the molecule
5. Toggle between 2D and 3D viewing modes
6. Switch between different viewing styles (stick, line, ball)
7. Enter full-screen mode for an immersive experience
8. Share molecule information with others

### Formula Search

1. From the Home dashboard, tap on "Formula Search"
2. Enter a molecular formula (e.g., H2O, C6H12O6)
3. View matching compounds and their details

### Air Quality

1. Access the air quality feature from the Home screen
2. Allow location permissions for local air quality data
3. View your current location's air quality with color-coded indicators
4. Tap "Show Global AQI" to see air quality in major cities worldwide
5. Use the search bar to find specific cities
6. Tap on any city marker to view detailed air quality information
7. View health recommendations based on AQI levels
8. Examine specific pollutant data for any location

## 🧪 Features in Development

- Chemical reaction simulator
- Standalone molecular 3D viewer with advanced features:
  - Bond measurements
  - Electrostatic potential maps
  - Save and share molecular configurations
  - AR/VR integration for immersive visualization
- Custom flashcard creation
- Advanced quiz system
- Laboratory safety guides
- Integration with educational curricula
- Air quality historical data and trends
- Pollutant source mapping

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Contact

Project Link: [https://github.com/amandangol/chemsphere](https://github.com/amandangol/chemsphere)

## 🙏 Acknowledgements

- [PubChem](https://pubchem.ncbi.nlm.nih.gov/) for compound data
- [Open-Meteo](https://open-meteo.com/) for air quality data
- [OpenStreetMap & Nominatim](https://nominatim.openstreetmap.org/) for mapping and geocoding services
- [Wikipedia API](https://www.mediawiki.org/wiki/API:Main_page) for educational content
- [3Dmol.js](https://3dmol.csb.pitt.edu/) for molecular visualization
- All icons and images used in this app are either created specifically for this project or are properly licensed

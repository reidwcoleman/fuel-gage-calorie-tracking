# Fuel Gage - Calorie Tracker

A simple, intuitive calorie tracking app that treats your body like a fuel tank. Track your daily energy intake with a beautiful fuel gauge visualization.

## Features

- **Fuel Gauge Dashboard**: Visual representation of your daily calorie intake as a fuel gauge
- **Easy Food Logging**: Search from 70+ common foods or add custom entries
- **Meal Categories**: Organize your food by Breakfast, Lunch, Dinner, and Snacks
- **Daily History**: View your calorie trends over time
- **Customizable Goals**: Set your own daily calorie targets with preset options
- **Dark Theme**: Beautiful dark UI that's easy on the eyes
- **Offline First**: All data stored locally - no account required

## Screenshots

The app features:
- A fuel gauge that fills up as you log calories
- Status messages like "Running on Empty", "Half Tank", "Almost Full"
- Swipe-to-delete on food entries
- Quick add for custom foods
- Category-based food browsing

## Getting Started

### Prerequisites

- Flutter SDK 3.10 or higher
- Dart 3.10 or higher
- iOS 12.0+ / Android 5.0+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/reidwcoleman/fuel-gage-calorie-tracking.git
cd fuel-gage-calorie-tracking
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Building for Production

**iOS:**
```bash
flutter build ios
```

**Android:**
```bash
flutter build apk
```

## Project Structure

```
lib/
├── main.dart              # App entry point with splash screen
├── data/
│   └── food_database.dart # Built-in food database (70+ items)
├── models/
│   ├── daily_log.dart     # Daily calorie log model
│   ├── food_entry.dart    # Logged food entry model
│   └── food_item.dart     # Food item model
├── providers/
│   └── calorie_provider.dart  # State management
├── screens/
│   ├── add_food_screen.dart   # Food search & logging
│   ├── history_screen.dart    # Past days view
│   ├── home_screen.dart       # Main dashboard
│   ├── main_shell.dart        # Bottom navigation
│   └── settings_screen.dart   # Goal configuration
├── services/
│   └── storage_service.dart   # Local persistence
├── theme/
│   └── app_theme.dart         # App colors & styling
└── widgets/
    ├── fuel_gauge.dart        # Gauge visualization
    └── meal_section.dart      # Meal category widget
```

## Food Database

The app includes 70+ common foods across categories:
- Breakfast (eggs, oatmeal, pancakes, etc.)
- Proteins (chicken, beef, salmon, etc.)
- Grains (rice, pasta, quinoa, etc.)
- Vegetables (broccoli, spinach, etc.)
- Fruits (apple, banana, berries, etc.)
- Dairy (milk, cheese, yogurt, etc.)
- Snacks (chips, nuts, chocolate, etc.)
- Drinks (coffee, juice, smoothies, etc.)
- Fast Food (burgers, pizza, tacos, etc.)
- Salads

## Technologies Used

- **Flutter** - Cross-platform mobile framework
- **Provider** - State management
- **SharedPreferences** - Local data persistence
- **percent_indicator** - Progress visualization
- **flutter_slidable** - Swipe actions

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

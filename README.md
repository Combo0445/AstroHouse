# 🌟 Astro House - Premium Digital Menu Book

A sophisticated, interactive digital menu book built with Flutter. Designed for a premium restaurant experience with smooth page-flipping animations and elegant typography.

## ✨ Features
- **Realistic Page Flip**: Smooth interactive transitions between pages.
- **Premium Design**: Gold accents, vintage paper textures, and elegant fonts.
- **Offline-Ready QR**: Scanning system for local network or public internet access.
- **Mobile Responsive**: Optimized for both tablet displays and smartphone scanning.

## 📋 Menu Categories

### 🍹 Drinks
Coffee, Tea (Cup & Pot), Lemonade, Milk & Milk Shake, Smoothie & Yogurt Smoothie, Italian Soda, Soft Drink, Ice Cream & Affogato, Cold Pressed Juice

### 🍽️ Food
Breakfast, Salad, Sandwich, Toast, Roti, Pizza, Spaghetti, Gratin, Appetizer, Chorizo, Steak (Chicken / Pork / Salmon / Skillet), Japanese (Garlic Rice, Curry, Sashimi & Aburi, Noodle, Bento), Thai Foods (Salad, Traditional, Soup, Noodle, Rice)

### 🍰 Dessert
Toast, Waffle, Crepe, Pancake, Roti & Banana

## 🚀 Live Demo
[https://Combo0445.github.io/AstroHouse/](https://Combo0445.github.io/AstroHouse/)

## 🛠️ Tech Stack
- **Framework**: Flutter
- **UI Architecture**: Page Flip Design (`page_flip` package)
- **Typography**: Google Fonts (Cinzel, Playfair Display, Lora)
- **QR Code**: `qr_flutter`
- **Deployment**: GitHub Actions & GitHub Pages

## 📖 How to Use
1. **At the Restaurant**: Open the app on a tablet.
2. **For Customers**: Scan the QR code on the welcome page to view the menu on your phone.
3. **Admin**: Update `lib/pages/data/menu_data.dart` to change prices or add new dishes.

## 🏗️ Project Structure
```
lib/
├── main.dart                  # App entry point
└── pages/
    ├── menu_book_page.dart    # Main UI with page flip
    └── data/
        └── menu_data.dart     # All menu items & pricing
assets/images/
├── drinks/                    # Drink images
├── food/                      # Food images (13 subcategories)
└── dessert/                   # Dessert images (5 subcategories)
```

---
*Created with ❤️ for Astro House Gastronomy*

#  Resume Customizer  
A simple and customizable resume generator built using **Flutter**, **Riverpod**, **Hive**, and **HTTP**.  
The app fetches dynamic resume data from an API and allows the user to personalize the appearance of the resume in real-time.

---
## Project Overview

<p align="center">
  <img src="https://github.com/user-attachments/assets/f7a97d09-6988-4c8f-8541-0cde4ffff992" width="45%" />
  <img src="https://github.com/user-attachments/assets/1db81229-a3bd-4cd0-8952-8b0b6cc72d5f" width="45%" />
</p>

Youtube Video Link: 

Apk File Link: https://drive.google.com/drive/folders/1wVyUGJSgW3C0r62vHfiJUuNGOSp_ksLY?usp=drive_link


---

## Running the App

1. Install dependencies
```bash

flutter pub get

```

2. Run on emulator/device
```

flutter run

```
---
##  Features

### 🔹 Resume Generation
- Fetches resume details from a public API using an input name.
- Automatically formats skills and projects for readability.

### 🔹 Customization Options
- Adjust **font size** using a slider.
- Change **font color** and **background color** via a color picker.
- View a clean, readable formatted resume preview.

### 🔹 Persistent Storage (Hive)
- Saves user-selected:
  - Font size  
  - Font color  
  - Background color  
  - Last entered name  
- Settings are restored automatically when reopening the app.

### 🔹 Location Access
- Retrieves and displays the user’s current latitude & longitude.
- Uses Geolocator with proper runtime permissions.

---

## 📱 Screens Included
- Home Screen  
  - Resume preview  
  - Customization panel  
  - Name input field  
  - Regenerate button  
- Color Picker Dialog  
- Location display in AppBar  

---

## 🧰 Tech Stack

| Category | Tools / Packages |
|---------|------------------|
| **Frontend** | Flutter (Dart) |
| **State Management** | Riverpod 3 |
| **Local Storage** | Hive & Hive Flutter |
| **Networking** | HTTP 1.6.0 |
| **Location Services** | Geolocator 14.x |
| **UI Enhancements** | flutter_colorpicker |
| **Fonts** | Google Fonts (Poppins) |

---

## 🔧 How It Works

### 1. Enter a Name  
The user types a name into the text field.  
This value is saved and used to fetch resume data.

### 2. Click "Regenerate"  
- Hides the keyboard  
- Sends API request  
- Updates resume content  

### 3. Customize the Resume  
Adjust font size, font color, and background color.  
All changes appear instantly.

### 4. Auto Save  
All settings + name are automatically stored using Hive and restored on next app launch.

---




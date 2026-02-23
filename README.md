# 537 Machines

A full-stack industrial machine marketplace built for large-scale B2B equipment trading. The platform connects sellers and buyers of heavy machinery — CNC machines, lathes, milling equipment, and more — providing a modern, mobile-first experience for listing, discovering, and purchasing industrial equipment.

## Architecture

- **Frontend:** Flutter (iOS, Android, Web) using Stacked MVVM architecture
- **Backend:** Go REST API with layered architecture (Handlers → Services → Repositories)
- **Cloud Services:** Firebase (Auth, Firestore, Storage, Crashlytics)

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile & Web | Flutter / Dart |
| State Management | Stacked (MVVM) |
| Backend API | Go (Chi router) |
| Database | Cloud Firestore |
| Authentication | Firebase Auth |
| File Storage | Firebase Storage |
| Error Monitoring | Firebase Crashlytics |

## Project Structure

```
lib/
  app/          # App configuration, routing, dependency injection
  core/         # Constants, error handling, utilities
  models/       # Data models (AppUser, MachineListing, ListingFilter)
  repositories/ # Firebase SDK wrappers (Auth, Firestore, Storage)
  services/     # Business logic layer
  ui/
    common/     # Colors, text styles, helpers, validators
    widgets/    # Reusable components (MachineCard, CustomButton, etc.)
    views/      # Feature screens (listings, profile, auth, etc.)
```

## Features

- User authentication (email/password, Google Sign-In)
- Machine listing creation with multi-image upload
- Browse & search with filters (category, condition, price, year)
- Detailed listing view with image carousel
- User profiles with edit capability
- Real-time data with Firestore

# Machine Marketplace — Stacked Architecture Reference

> This document is the single source of truth for how every feature in the Machine Marketplace app is built.
> Follow it layer by layer, every time.

---

## 1. Architecture Overview

Machine Marketplace uses **Stacked** (by FilledStacks), an MVVM framework for Flutter. The architecture enforces strict separation of concerns across **five layers**:

```
┌─────────────────────────────────────────────────────────┐
│                      UI (Views)                         │
│  Reacts to: hasError, isBusy, modelError                │
│  Shows: Dialogs, loading states, error widgets          │
│  Does NOT use: try-catch, Executor, Failure             │
├─────────────────────────────────────────────────────────┤
│               Presentation (ViewModels)                 │
│  Uses: Executor.run() → .fold()                         │
│  Handles: UI decisions based on failure.type            │
│  Does NOT use: try-catch                                │
│  NEVER calls Repositories directly.                     │
├─────────────────────────────────────────────────────────┤
│            Services (Domain / Business Logic)           │
│  Uses: Executor.run() → .fold() OR throws Failure       │
│  Composes Repositories. Holds reactive state.           │
│  Does NOT use: try-catch (the Executor catches for you) │
│  NEVER knows about Views or ViewModels.                 │
├─────────────────────────────────────────────────────────┤
│              Repositories (Primitive Adapters)          │
│  Uses: try-catch to convert exceptions into Failures    │
│  This is the ONLY layer that uses try-catch             │
│  Wraps ONE external system each. Throws typed Failures. │
│  NEVER knows about Services, ViewModels, Views.         │
├─────────────────────────────────────────────────────────┤
│                    Models (Data Classes)                │
│  Pure Dart. fromJson / toJson / copyWith.               │
│  No logic, no dependencies.                             │
└─────────────────────────────────────────────────────────┘
```

**Core principle:** Exceptions exist only at the Repository boundary. Everything above works with typed `Failure` objects flowing through `Either<Failure, T>`.

### Hard Rules

| Rule | Why |
|------|-----|
| A View talks ONLY to its own ViewModel | Keeps UI decoupled from business logic |
| A ViewModel talks ONLY to Services (via locator) | ViewModels never touch Repositories or external systems |
| Services compose Repositories + other Services | Domain logic lives here |
| Repositories wrap exactly ONE external system | Single responsibility: Firestore, Auth, Storage |
| Repositories are the ONLY layer with `try-catch` | Convert raw exceptions into typed `Failure` objects by throwing them |
| Services and ViewModels use `Executor.run()` + `.fold()` | The Executor catches thrown Failures and wraps them in `Either<Failure, T>` |
| Shared state lives in Services, not ViewModels | Multiple screens can react to the same Service |
| Navigation, dialogs, snackbars go through stacked_services | No `BuildContext` leaking into ViewModels |

### Dependency Direction (strict — no violations)

```
Views → ViewModels → Services → Repositories → External SDKs / Firebase
                        ↓
                     Models (used by all layers except Views)
```

A layer may only depend on the layer directly below it (or Models). **Never skip a layer.**

---

## 2. Error Handling — The Executor Pattern

Error handling is centralized through two mechanisms:
1. **Failure hierarchy** — typed error objects with enums, replacing raw exceptions
2. **The Executor** — a bridge that catches thrown Failures and returns `Either<Failure, T>`

### Where to use `try-catch`

| Layer | Use `try-catch`? | Why |
|-------|-----------------|-----|
| **Repositories** | **YES** | Convert platform/SDK exceptions into typed `Failure` objects |
| **Services** | **NO** | Use `Executor.run()` + `.fold()` |
| **ViewModels** | **NO** | Use `Executor.run()` + `.fold()` |
| **Views** | **NO** | Observe ViewModel state |

### 2a. The Failure Hierarchy

All errors in the app are represented as `Failure` objects. A `Failure` carries: a **type** (enum), a **description** (string), a **stackTrace**, and optional **args**.

```
Failure (base class)
├── GeneralFailure      — network, parsing, platform, unexpected errors
├── AuthFailure         — authentication and session errors
└── DataFailure         — Firestore / Storage / business-logic data errors
```

#### Failure — Base Class

**File:** `lib/core/error_handling/failure.dart`

```dart
abstract class FailureAbstract {
  final dynamic type;
  final String description;
  final StackTrace? stackTrace;
  final dynamic args;
  @override
  String toString();
  FailureAbstract(this.type, this.description, this.args, this.stackTrace);
}

class Failure implements FailureAbstract {
  late String _description;
  StackTrace? _stackTrace;
  dynamic _type;
  dynamic _args;

  @override
  Failure(dynamic type, String? description, StackTrace? stackTrace, dynamic args) {
    _description = description ?? "";
    _type = type;
    _stackTrace = stackTrace;
    _args = args;
  }

  @override
  String get description => _description;

  @override
  String toString() => '${type.toString()} : $_description | args: $_args';

  @override
  get type => _type;

  @override
  get args => _args;

  @override
  StackTrace get stackTrace => _stackTrace ?? StackTrace.current;
}
```

#### GeneralFailure

**File:** `lib/core/error_handling/failures/general_failure.dart`

```dart
class GeneralFailure extends Failure {
  GeneralFailure(GeneralFailureType type, String description, StackTrace stackTrace, {args})
      : super(type, description, stackTrace, args);
}

enum GeneralFailureType {
  internetConnectionError,
  unexpectedError,
  formatError,
  socketException,
  platformError,
  jsonConversionError,
  timeoutError,
}
```

#### AuthFailure

**File:** `lib/core/error_handling/failures/auth_failure.dart`

```dart
class AuthFailure extends Failure {
  AuthFailure(AuthFailureType type, {String? description, StackTrace? stackTrace, args})
      : super(type, description, stackTrace, args);
}

enum AuthFailureType {
  invalidCredentials,
  userNotFound,
  userDisabled,
  emailAlreadyInUse,
  weakPassword,
  tooManyRequests,
  tokenExpired,
  error,
}
```

#### DataFailure

**File:** `lib/core/error_handling/failures/data_failure.dart`

```dart
class DataFailure extends Failure {
  DataFailure(DataFailureType type, {String? description, StackTrace? stackTrace, args})
      : super(type, description, stackTrace, args);
}

enum DataFailureType {
  notFound,
  permissionDenied,
  alreadyExists,
  resourceExhausted,
  unavailable,
  cancelled,
  uploadFailed,
  deleteFailed,
  requestFailed,
}
```

### 2b. The Executor

**File:** `lib/core/error_handling/executor.dart`

The `Executor` wraps any `Future<T>` and returns `Future<Either<Failure, T>>`.

```dart
import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';

class Executor<T> {
  static Future<Either<Failure, T>> run<T>(Future<T> f) => Task<T>(() => f)
      .attempt()
      .map((a) => a.leftMap((obj) {
            if (obj is Failure) {
              return obj;
            } else {
              locator<CrashlyticsService>().logToCrashlytics(
                  Level.error,
                  ['Executor Caught Exception', obj.toString()],
                  StackTrace.current);
              return GeneralFailure(GeneralFailureType.unexpectedError,
                  obj.toString(), StackTrace.current);
            }
          }))
      .run();
}
```

**What it does step by step:**
1. `Task(() => f)` — wraps the future in a lazy container
2. `.attempt()` — executes with try-catch, producing `Either<Object, T>`
3. `.leftMap(...)` — if error is already a `Failure`, keep it; otherwise wrap as `GeneralFailure`
4. `.run()` — executes the chain, returning `Future<Either<Failure, T>>`

### 2c. The Standard Call Pattern

Used in **both** Services and ViewModels:

```dart
Executor.run(someRepository.someMethod())
    .then((result) => result.fold(
      (failure) {
        // 1. Log to Crashlytics
        _crashlytics.logToCrashlytics(
            Level.warning,
            ['ClassName', 'methodName()', failure.toString()],
            failure.stackTrace);

        // 2. Handle the failure
        //    - In Services: re-throw if caller needs to know, or silently handle
        //    - In ViewModels: switch on failure.type for UI decisions
      },
      (data) {
        // Happy path
      },
    ));
```

### 2d. How Errors Flow Through the Layers

```
External System throws FirebaseException / SocketException / etc.
        │
        ▼
Repository — try-catch converts it to typed Failure, throws it
        │ throws AuthFailure / DataFailure / GeneralFailure
        ▼
Executor.run() — catches the Failure, wraps it as Either.Left
        │ returns Either<Failure, T>
        ▼
Service — .fold() handles failure branch (log, re-throw, or silently handle)
        │ may throw failure to propagate upward
        ▼
Executor.run() — catches re-thrown Failure, wraps it as Either.Left
        │ returns Either<Failure, T>
        ▼
ViewModel — .fold() switches on failure.type for UI decisions
        │ calls setError(failure), setBusy(false), shows dialog
        ▼
View — reads viewModel.hasError / viewModel.isBusy / viewModel.modelError
```

---

## 3. Project Structure

```
lib/
├── main.dart                           # Entry point: Firebase init, setupLocator, setupDialogUi, setupBottomSheetUi
├── firebase_options.dart               # Firebase configuration (generate with flutterfire configure)
├── app/
│   ├── app.dart                        # @StackedApp annotation (routes + dependencies + dialogs + sheets)
│   ├── app.locator.dart                # GENERATED — setupLocator()
│   ├── app.router.dart                 # GENERATED — StackedRouter, Routes class
│   ├── app.dialogs.dart                # GENERATED — DialogType enum, setupDialogUi()
│   └── app.bottomsheets.dart           # GENERATED — BottomSheetType enum, setupBottomSheetUi()
├── core/
│   ├── error_handling/
│   │   ├── failure.dart                # Failure base class
│   │   ├── executor.dart               # Executor — wraps futures into Either<Failure, T>
│   │   └── failures/
│   │       ├── general_failure.dart    # GeneralFailure + GeneralFailureType enum
│   │       ├── auth_failure.dart       # AuthFailure + AuthFailureType enum
│   │       └── data_failure.dart       # DataFailure + DataFailureType enum
│   ├── constants/
│   │   ├── app_constants.dart          # Machine categories, conditions, maxImages, page sizes
│   │   └── firebase_constants.dart     # Collection names, storage paths
│   ├── services/
│   │   └── crashlytics_service.dart    # Logger-based logging (replace with Firebase Crashlytics in production)
│   └── utils/
│       └── date_formatter.dart         # Human-friendly date formatting + time ago
├── models/
│   ├── app_user.dart                   # User data class
│   ├── machine_listing.dart            # Machine listing data class
│   └── listing_filter.dart             # Filter criteria for search
├── repositories/
│   ├── firestore_repository.dart       # Generic Firestore CRUD adapter
│   ├── auth_repository.dart            # Firebase Auth + Google Sign-In adapter
│   └── storage_repository.dart         # Firebase Storage adapter
├── services/
│   ├── auth_service.dart               # Auth domain logic (reactive user state)
│   ├── listing_service.dart            # Listing CRUD + search/filter
│   ├── storage_service.dart            # Image upload/delete facade
│   └── user_service.dart               # User profile read/update
├── ui/
│   ├── common/
│   │   ├── app_colors.dart             # All brand colors as constants
│   │   ├── app_text_styles.dart        # Text styles
│   │   ├── ui_helpers.dart             # Spacing constants + screen size helpers
│   │   └── validators.dart             # Form validation (email, password, price, etc.)
│   ├── widgets/
│   │   ├── machine_card.dart           # Reusable machine listing card (grid)
│   │   ├── custom_text_field.dart      # Styled text field with validation
│   │   ├── custom_button.dart          # Primary / outlined button with loading state
│   │   └── loading_indicator.dart      # Centered spinner with optional message
│   ├── dialogs/
│   │   └── confirm/
│   │       └── confirm_dialog.dart     # Confirmation dialog (delete, etc.)
│   ├── bottom_sheets/
│   │   └── filter/
│   │       └── filter_sheet.dart       # Filter by category, condition, price range
│   └── views/
│       ├── startup/                    # Check auth → navigate to Main or Login
│       │   ├── startup_view.dart
│       │   └── startup_viewmodel.dart
│       ├── login/                      # Email/password + Google Sign-In
│       │   ├── login_view.dart
│       │   └── login_viewmodel.dart
│       ├── register/                   # Name, email, password, confirm
│       │   ├── register_view.dart
│       │   └── register_viewmodel.dart
│       ├── main/                       # Bottom navigation shell
│       │   ├── main_view.dart
│       │   └── main_viewmodel.dart
│       ├── listings/                   # Browse grid + search + filter
│       │   ├── listings_view.dart
│       │   └── listings_viewmodel.dart
│       ├── listing_detail/             # Carousel, info, seller, edit/delete
│       │   ├── listing_detail_view.dart
│       │   └── listing_detail_viewmodel.dart
│       ├── create_listing/             # Form + image picker + submit
│       │   ├── create_listing_view.dart
│       │   └── create_listing_viewmodel.dart
│       ├── edit_listing/               # Pre-populated form + update
│       │   ├── edit_listing_view.dart
│       │   └── edit_listing_viewmodel.dart
│       ├── profile/                    # ReactiveViewModel watching AuthService
│       │   ├── profile_view.dart
│       │   └── profile_viewmodel.dart
│       └── edit_profile/               # Name + avatar upload
│           ├── edit_profile_view.dart
│           └── edit_profile_viewmodel.dart
```

---

## 4. The Layers — Detailed

### Layer 1: Models

**Location:** `lib/models/`

**Responsibility:** Pure data containers. No logic, no service calls, no Flutter imports. They define the shape of data that flows through the app.

**Every model must have:**
- `fromJson(Map<String, dynamic>)` factory constructor
- `toJson()` method returning `Map<String, dynamic>`
- `copyWith()` for immutable updates
- Firestore document ID as a field

#### AppUser

**File:** `lib/models/app_user.dart`

```dart
class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json, {String? id}) { ... }
  Map<String, dynamic> toJson() { ... }
  AppUser copyWith({ ... }) { ... }
}
```

#### MachineListing

**File:** `lib/models/machine_listing.dart`

```dart
class MachineListing {
  final String id;
  final String sellerId;
  final String sellerName;
  final String title;
  final String titleLowercase;   // stored for Firestore prefix search
  final String description;
  final String category;
  final double price;
  final String condition;
  final String location;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory MachineListing.fromJson(Map<String, dynamic> json, {String? id}) { ... }
  Map<String, dynamic> toJson() { ... }   // auto-generates titleLowercase
  MachineListing copyWith({ ... }) { ... }
}
```

#### ListingFilter

**File:** `lib/models/listing_filter.dart`

```dart
class ListingFilter {
  final String? searchQuery;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final String? condition;

  bool get isEmpty => ...;
  ListingFilter copyWith({ ..., bool clearSearch = false, ... }) { ... }
}
```

---

### Layer 2: Repositories

**Location:** `lib/repositories/`

**Responsibility:** Primitive adapters. Each wraps **exactly one** external system. **This is the ONLY layer with `try-catch`.** Catches SDK exceptions and throws typed `Failure` objects.

#### FirestoreRepository

**File:** `lib/repositories/firestore_repository.dart`

Generic CRUD adapter for Cloud Firestore.

| Method | Returns |
|--------|---------|
| `getDocument({collection, id})` | `Map<String, dynamic>?` |
| `addDocument({collection, data})` | `String` (doc ID) |
| `setDocument({collection, id, data, merge})` | `void` |
| `deleteDocument({collection, id})` | `void` |
| `getCollection({collection, queryBuilder, limit})` | `List<Map<String, dynamic>>` |

Each method follows this pattern:
```dart
try {
  // Firestore operation
} on FirebaseException catch (e, s) {
  throw _mapFirebaseException(e, s);
} on SocketException catch (e, s) {
  throw GeneralFailure(GeneralFailureType.socketException, e.toString(), s);
} catch (e, s) {
  throw GeneralFailure(GeneralFailureType.unexpectedError, e.toString(), s);
}
```

`_mapFirebaseException()` maps Firebase error codes to typed `DataFailure`:
- `not-found` → `DataFailureType.notFound`
- `permission-denied` → `DataFailureType.permissionDenied`
- `already-exists` → `DataFailureType.alreadyExists`
- default → `DataFailureType.requestFailed`

#### AuthRepository

**File:** `lib/repositories/auth_repository.dart`

Wraps Firebase Auth + Google Sign-In.

| Method | Returns |
|--------|---------|
| `signInWithEmail(email, password)` | `UserCredential` |
| `createAccountWithEmail(email, password)` | `UserCredential` |
| `signInWithGoogle()` | `UserCredential` |
| `signOut()` | `void` |
| `currentUser` | `User?` (getter) |
| `currentUserId` | `String?` (getter) |

`_mapAuthException()` maps Firebase Auth error codes to typed `AuthFailure`:
- `wrong-password` / `invalid-credential` → `AuthFailureType.invalidCredentials`
- `user-not-found` → `AuthFailureType.userNotFound`
- `email-already-in-use` → `AuthFailureType.emailAlreadyInUse`
- `weak-password` → `AuthFailureType.weakPassword`
- `too-many-requests` → `AuthFailureType.tooManyRequests`
- default → `AuthFailureType.error`

#### StorageRepository

**File:** `lib/repositories/storage_repository.dart`

Wraps Firebase Storage.

| Method | Returns |
|--------|---------|
| `uploadFile({path, file})` | `String` (download URL) |
| `deleteFile(path)` | `void` |
| `listFiles(path)` | `List<Reference>` |

---

### Layer 3: Services

**Location:** `lib/services/`

**Responsibility:** Domain/business logic. Services compose Repositories via `Executor.run()` + `.fold()`. **No `try-catch` here.**

#### AuthService (with ListenableServiceMixin)

**File:** `lib/services/auth_service.dart`

Holds reactive user state shared across the app.

```dart
class AuthService with ListenableServiceMixin {
  final ReactiveValue<AppUser?> _currentUser = ReactiveValue<AppUser?>(null);
  AppUser? get currentUser => _currentUser.value;
  bool get isLoggedIn => _currentUser.value != null;

  AuthService() {
    listenToReactiveValues([_currentUser]);
  }

  Future<void> signIn(String email, String password) { ... }
  Future<void> signUp(String email, String password, String name) { ... }
  Future<void> signInWithGoogle() { ... }
  Future<void> signOut() { ... }
  Future<void> tryAutoLogin() { ... }
}
```

- `signIn` → calls `_authRepo.signInWithEmail()` then loads user doc from Firestore
- `signUp` → creates Firebase account + creates Firestore user doc
- `signInWithGoogle` → Google flow + create or fetch existing user doc
- `signOut` → signs out of Firebase + Google, clears reactive state

#### ListingService

**File:** `lib/services/listing_service.dart`

```dart
class ListingService {
  Future<List<MachineListing>> getListings({ListingFilter? filter, int? limit}) { ... }
  Future<MachineListing> getListingById(String id) { ... }
  Future<List<MachineListing>> getListingsBySeller(String sellerId) { ... }
  Future<String> createListing(MachineListing listing) { ... }
  Future<void> updateListing(MachineListing listing) { ... }
  Future<void> deleteListing(String id) { ... }
}
```

`getListings()` builds Firestore queries dynamically based on `ListingFilter`:
- `category` → `where('category', isEqualTo: ...)`
- `condition` → `where('condition', isEqualTo: ...)`
- `minPrice` / `maxPrice` → `where('price', isGreaterThanOrEqualTo/isLessThanOrEqualTo: ...)`
- `searchQuery` → prefix search on `titleLowercase`

#### StorageService

**File:** `lib/services/storage_service.dart`

```dart
class StorageService {
  Future<List<String>> uploadListingImages({files, userId, listingId}) { ... }
  Future<void> deleteListingImages({userId, listingId}) { ... }
  Future<String> uploadAvatar({file, userId}) { ... }
}
```

#### UserService

**File:** `lib/services/user_service.dart`

```dart
class UserService {
  Future<AppUser> getUser(String uid) { ... }
  Future<void> updateUser(AppUser user) { ... }
}
```

#### Service Rules

| Do | Don't |
|----|-------|
| Wrap Repository calls with `Executor.run()` | Use `try-catch` |
| Use `.fold()` to handle both branches | Ignore the failure branch |
| Log failures to Crashlytics with `['ClassName', 'method()', failure]` | Show UI dialogs (that's the ViewModel's job) |
| Re-throw if the caller needs to know: `throw failure;` | Catch exceptions manually |
| Use `ListenableServiceMixin` for shared reactive state | |

---

### Layer 4: ViewModels

**Location:** `lib/ui/views/<feature>/<feature>_viewmodel.dart`

**Responsibility:** Presentation logic. Hold UI state, call Service methods through `Executor.run()`, use `.fold()` to make UI decisions based on `failure.type`.

#### ViewModel Types Used

| ViewModel | Type | Why |
|-----------|------|-----|
| StartupViewModel | `BaseViewModel` | One-shot auto-login check + navigate |
| LoginViewModel | `BaseViewModel` | Form submission + error handling |
| RegisterViewModel | `BaseViewModel` | Form submission + error handling |
| MainViewModel | `IndexTrackingViewModel` | Bottom nav tab index tracking |
| ListingsViewModel | `BaseViewModel` | Loads listings, search/filter state |
| ListingDetailViewModel | `BaseViewModel` | Loads single listing, owner actions |
| CreateListingViewModel | `BaseViewModel` | Form state + image picking + submit |
| EditListingViewModel | `BaseViewModel` | Pre-populated form + update |
| ProfileViewModel | `ReactiveViewModel` | Auto-rebuilds when `AuthService` changes |
| EditProfileViewModel | `BaseViewModel` | Name/avatar update |

#### Two Ways to Communicate Errors to UI

**1. Imperative — show a dialog immediately:**
```dart
_dialogService.showCustomDialog(
    variant: DialogType.confirm,
    title: 'Delete Listing',
    description: 'Are you sure?',
);
```

**2. Reactive — set error state for the View to observe:**
```dart
setError(failure);  // View reads viewModel.hasError / viewModel.modelError
```

#### Example: LoginViewModel

```dart
Future<void> signIn(String email, String password) async {
  setBusy(true);

  return Executor.run(_authService.signIn(email, password))
      .then((result) => result.fold(
            (failure) {
              _crashlytics.logToCrashlytics(Level.warning,
                  ['LoginViewModel', 'signIn()', failure.toString()],
                  failure.stackTrace);

              switch (failure.type) {
                case AuthFailureType.invalidCredentials:
                  setError('Invalid email or password');
                  break;
                case AuthFailureType.userNotFound:
                  setError('No account found with this email');
                  break;
                default:
                  setError('Sign in failed. Please try again');
                  break;
              }
              setBusy(false);
            },
            (_) {
              setBusy(false);
              _navigationService.clearStackAndShow(Routes.mainView);
            },
          ));
}
```

#### Example: ProfileViewModel (ReactiveViewModel)

```dart
class ProfileViewModel extends ReactiveViewModel {
  final _authService = locator<AuthService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_authService];

  AppUser? get currentUser => _authService.currentUser;
  // Auto-rebuilds whenever AuthService._currentUser changes
}
```

---

### Layer 5: Views

**Location:** `lib/ui/views/<feature>/<feature>_view.dart`

**Responsibility:** Build the widget tree. Read state from ViewModel. Forward user actions to ViewModel. **Never contain business logic.**

Every View extends `StackedView<T>` and overrides:
- `builder()` — builds the UI
- `viewModelBuilder()` — creates the ViewModel instance
- `onViewModelReady()` — (optional) called once after ViewModel creation

```dart
class ListingsView extends StackedView<ListingsViewModel> {
  @override
  Widget builder(BuildContext context, ListingsViewModel viewModel, Widget? child) {
    return Scaffold(
      body: viewModel.isBusy
          ? const LoadingIndicator()
          : viewModel.hasError
              ? Center(child: Text(viewModel.modelError.toString()))
              : GridView.builder(...),
    );
  }

  @override
  ListingsViewModel viewModelBuilder(BuildContext context) => ListingsViewModel();

  @override
  void onViewModelReady(ListingsViewModel viewModel) => viewModel.init();
}
```

---

## 5. Supporting Infrastructure

### 5a. app.dart — The Central Registry

**File:** `lib/app/app.dart`

```dart
@StackedApp(
  routes: [
    MaterialRoute(page: StartupView, initial: true),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: RegisterView),
    MaterialRoute(page: MainView),
    MaterialRoute(page: ListingsView),
    MaterialRoute(page: ListingDetailView),
    MaterialRoute(page: CreateListingView),
    MaterialRoute(page: EditListingView),
    MaterialRoute(page: ProfileView),
    MaterialRoute(page: EditProfileView),
  ],
  dependencies: [
    // Stacked built-in services
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: SnackbarService),

    // Core services
    LazySingleton(classType: CrashlyticsService),

    // Repositories
    LazySingleton(classType: FirestoreRepository),
    LazySingleton(classType: AuthRepository),
    LazySingleton(classType: StorageRepository),

    // Services
    LazySingleton(classType: AuthService),
    LazySingleton(classType: ListingService),
    LazySingleton(classType: StorageService),
    LazySingleton(classType: UserService),
  ],
  dialogs: [
    StackedDialog(classType: ConfirmDialog),
  ],
  bottomsheets: [
    StackedBottomsheet(classType: FilterSheet),
  ],
)
class App {}
```

After editing `app.dart`, always run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5b. main.dart

**File:** `lib/main.dart`

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();
  runApp(const MachineMarketplaceApp());
}
```

### 5c. Navigation Patterns

```dart
// Simple navigation
_navigationService.navigateTo(Routes.listingsView);

// With arguments (generated type-safe)
_navigationService.navigateTo(
  Routes.listingDetailView,
  arguments: ListingDetailViewArguments(listingId: 'abc123'),
);

// Replace (no back button)
_navigationService.replaceWith(Routes.mainView);

// Clear stack and show (after login/logout)
_navigationService.clearStackAndShow(Routes.mainView);

// Go back
_navigationService.back();
```

---

## 6. Firestore Schema

### users/{uid}
```json
{
  "email": "user@example.com",
  "displayName": "John Doe",
  "photoUrl": "https://...",
  "createdAt": Timestamp
}
```

### listings/{autoId}
```json
{
  "sellerId": "uid123",
  "sellerName": "John Doe",
  "title": "CNC Milling Machine",
  "titleLowercase": "cnc milling machine",
  "description": "Used CNC machine in great condition...",
  "category": "CNC Machines",
  "price": 15000.0,
  "condition": "Good",
  "location": "New York, NY",
  "imageUrls": ["https://..."],
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

### Firebase Storage Paths
```
machine_images/{userId}/{listingId}/image_0.jpg
machine_images/{userId}/{listingId}/image_1.jpg
avatars/{userId}/avatar.jpg
```

---

## 7. Step-by-Step: How to Build Any Feature

### Step 1: Model
Create or update model classes in `lib/models/`.
- [ ] All fields defined
- [ ] `fromJson()` factory with null-safety
- [ ] `toJson()` method
- [ ] `copyWith()` method
- [ ] Document ID field

### Step 2: Failure type (if needed)
Create `lib/core/error_handling/failures/your_failure.dart` if the feature introduces a new error domain.

### Step 3: Repository (if a new external system is involved)
- [ ] Wraps exactly ONE external system
- [ ] `try-catch` converts exceptions into typed `Failure` objects
- [ ] Catches specific exceptions first, then catch-all at bottom
- [ ] Registered as `LazySingleton` in `app.dart`

### Step 4: Service
- [ ] Composes Repositories (via locator)
- [ ] Uses `Executor.run()` + `.fold()` — **no try-catch**
- [ ] Logs failures to Crashlytics
- [ ] Re-throws failures the ViewModel needs to react to
- [ ] Uses `ListenableServiceMixin` if it holds shared state
- [ ] Registered in `app.dart`

### Step 5: ViewModel
- [ ] Correct base class chosen
- [ ] Uses `Executor.run()` + `.fold()` — **no try-catch**
- [ ] Switches on `failure.type` for specific UI reactions
- [ ] Manages `setBusy()` in **both** branches
- [ ] **NEVER calls Repositories directly**

### Step 6: View
- [ ] Extends `StackedView<MyViewModel>`
- [ ] Handles `isBusy`, `hasError` states
- [ ] User actions forwarded to ViewModel methods
- [ ] No service calls, no Executor, no business logic

### Step 7: Register in app.dart
Add route, repository, service, dialog, or bottom sheet to `@StackedApp`.

### Step 8: Generate
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 8. Rules & Conventions

### Naming

| Item | Convention | Example |
|------|-----------|---------|
| View file | `<feature>_view.dart` | `listings_view.dart` |
| ViewModel file | `<feature>_viewmodel.dart` | `listings_viewmodel.dart` |
| Service file | `<name>_service.dart` | `listing_service.dart` |
| Repository file | `<name>_repository.dart` | `firestore_repository.dart` |
| Model file | `<name>.dart` | `machine_listing.dart` |
| Failure file | `<name>_failure.dart` | `auth_failure.dart` |
| Dialog folder | `<name>/` | `confirm/` |
| Bottom sheet folder | `<name>/` | `filter/` |

### Imports — Who Can Import What

| Layer | CAN import | NEVER imports |
|-------|-----------|---------------|
| **Views** | Own ViewModel, shared widgets, `app_colors.dart` | Services, Repositories, Executor, `app.locator.dart` |
| **ViewModels** | `app.locator.dart`, `app.router.dart`, Services, Models, Executor, Failure types | Flutter widgets, Views, Repositories |
| **Services** | `app.locator.dart`, Repositories, other Services, Models, Executor, Failure types | Flutter widgets, ViewModels, Views |
| **Repositories** | External SDK packages, Models, Failure types | Services, ViewModels, Views, Executor |
| **Models** | Dart core only | Everything else |

### Busy/Error State

- `viewModel.isBusy` — whole-screen loading
- `viewModel.busy(objectKey)` — per-item loading (e.g., each button)
- `viewModel.hasError` / `viewModel.modelError` — whole-screen errors
- Always set `setBusy(false)` in **both** branches of `.fold()`

### Crashlytics Logging Format

```dart
_crashlytics.logToCrashlytics(
    Level.warning,
    ['ClassName', 'method(args)', failure.toString()],
    failure.stackTrace);
```

### Machine Categories

Defined in `lib/core/constants/app_constants.dart`:
CNC Machines, Lathes, Milling Machines, Drilling Machines, Grinding Machines, Welding Equipment, Compressors, Generators, Pumps, Conveyor Systems, Packaging Machines, Printing Machines, Woodworking, Construction Equipment, Agricultural Machinery, Other

### Machine Conditions

New, Like New, Good, Fair, For Parts

---

## 9. Package Versions

```yaml
dependencies:
  flutter: sdk
  stacked: ^3.4.3
  stacked_services: ^1.6.0
  get_it: ^8.0.0
  dartz: ^0.10.1
  logger: ^2.0.0
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_storage: ^12.0.0
  google_sign_in: ^6.2.1
  cached_network_image: ^3.3.1
  carousel_slider: ^5.0.0
  image_picker: ^1.0.7
  intl: ^0.19.0

dev_dependencies:
  build_runner: ^2.4.0
  stacked_generator: ^1.6.0
```

---

## 10. Summary Cheat Sheet

```
To build a feature:

  1. MODEL      → lib/models/                           → Data class with fromJson/toJson/copyWith
  2. FAILURE    → lib/core/error_handling/failures/      → (if needed) New Failure subclass + enum
  3. REPOSITORY → lib/repositories/                      → try-catch: convert exceptions to Failures, throw them
  4. SERVICE    → lib/services/                          → Executor.run() + .fold(): log, re-throw or silently handle
  5. VIEWMODEL  → lib/ui/views/<name>/                   → Executor.run() + .fold(): switch on failure.type for UI
  6. VIEW       → lib/ui/views/<name>/                   → Observe isBusy, hasError, show retry
  7. WIDGETS    → lib/ui/widgets/                        → Reusable UI, receives data via constructor
  8. REGISTER   → lib/app/app.dart                       → Add route + repository + service
  9. GENERATE   → dart run build_runner build             → Regenerate router + locator + dialogs + sheets

Error flow:
  SDK throws → Repository CATCHES → throws typed Failure
            → Executor wraps as Either.Left
            → Service .fold() logs + re-throws
            → Executor wraps as Either.Left
            → ViewModel .fold() switches on failure.type for UI

Where try-catch lives:
  ONLY in Repositories. Nowhere else. The Executor catches everything above.

Dependency direction:
  Views → ViewModels → Services → Repositories → External SDKs
                          ↓
                       Models (shared across all layers except Views)
```

# 537 Machines — Go Backend Architecture Reference

> The single source of truth for how every backend feature is built.
> Mirrors the frontend architecture_marketplace.md — same layered discipline, different language.

---

## 1. Architecture Overview

The Go backend follows the same **strict layered architecture** as the Flutter frontend. Four layers, one direction.

```
┌─────────────────────────────────────────────────────────┐
│                    Router + Middleware                    │
│  Routes HTTP requests to handlers                        │
│  Auth middleware verifies Firebase ID tokens              │
│  CORS, logging, rate limiting, panic recovery            │
├─────────────────────────────────────────────────────────┤
│                     Handlers (HTTP)                       │
│  Parse request → validate → call Service → write response│
│  Same role as Flutter ViewModels                         │
│  NEVER touches Firestore or external SDKs directly       │
├─────────────────────────────────────────────────────────┤
│                  Services (Business Logic)                │
│  Compose Repositories. Enforce rules. Apply logic.       │
│  Same role as Flutter Services                           │
│  NEVER knows about HTTP, request/response                │
├─────────────────────────────────────────────────────────┤
│               Repositories (Data Access)                 │
│  Wrap ONE external system each (Firestore, Storage, etc) │
│  Same role as Flutter Repositories                       │
│  ONLY layer that talks to Firebase Admin SDK             │
├─────────────────────────────────────────────────────────┤
│                   Models (Data Structs)                   │
│  Pure Go structs. ToMap / FromMap. JSON tags.            │
│  Mirror the Flutter models exactly.                      │
└─────────────────────────────────────────────────────────┘
```

### Dependency Direction

```
Router → Handlers → Services → Repositories → Firebase Admin SDK
                       ↓
                    Models (used by all layers)
```

A layer may only depend on the layer directly below it (or Models). Never skip.

### Hard Rules

| Rule | Why |
|------|-----|
| Handlers talk ONLY to Services | Keep HTTP concerns out of business logic |
| Services compose Repositories + other Services | Domain logic lives here |
| Repositories wrap exactly ONE external system | Single responsibility |
| Auth is ALWAYS verified by middleware | Never trust client claims |
| Handlers never import repository packages | Enforces the layer boundary |
| Services never import `net/http` | They don't know about HTTP |

---

## 2. Project Structure

```
backend/
├── cmd/
│   └── server/
│       └── main.go                    # Entry point: init Firebase, wire dependencies, start server
│
├── internal/
│   ├── config/
│   │   └── config.go                  # Environment variables, Firebase project ID, port, etc.
│   │
│   ├── middleware/
│   │   ├── auth.go                    # Firebase ID token verification middleware
│   │   ├── cors.go                    # CORS headers for Flutter web
│   │   ├── logger.go                  # Request/response logging
│   │   └── recovery.go               # Panic recovery → 500 response
│   │
│   ├── model/
│   │   ├── user.go                    # AppUser struct — mirrors Flutter AppUser
│   │   ├── listing.go                 # MachineListing struct — mirrors Flutter MachineListing
│   │   ├── filter.go                  # ListingFilter struct — mirrors Flutter ListingFilter
│   │   └── errors.go                  # AppError type + error codes (mirrors Failure hierarchy)
│   │
│   ├── repository/
│   │   ├── user_repository.go         # Firestore CRUD for users collection
│   │   ├── listing_repository.go      # Firestore CRUD for listings collection
│   │   └── storage_repository.go      # Firebase Storage operations (signed URLs, delete)
│   │
│   ├── service/
│   │   ├── auth_service.go            # Token verification, user lookup after auth
│   │   ├── listing_service.go         # Listing CRUD + filtering + business rules
│   │   ├── storage_service.go         # Image upload coordination, signed URLs
│   │   └── user_service.go            # Profile CRUD + validation
│   │
│   ├── handler/
│   │   ├── auth_handler.go            # POST /auth/verify, POST /auth/register-complete
│   │   ├── listing_handler.go         # CRUD endpoints for /listings
│   │   ├── storage_handler.go         # POST /upload/listing-images, POST /upload/avatar
│   │   ├── user_handler.go            # GET/PUT /users/me, GET /users/{id}
│   │   └── response.go               # Shared JSON response helpers (success, error)
│   │
│   └── router/
│       └── router.go                  # All route definitions + middleware wiring
│
├── go.mod
├── go.sum
├── Dockerfile
└── .env.example
```

---

## 3. Models

Mirror the Flutter models exactly. Same field names, same JSON keys, same Firestore document structure.

### User (`model/user.go`)

```go
type User struct {
    UID         string    `json:"uid"         firestore:"-"`
    Email       string    `json:"email"       firestore:"email"`
    FirstName   string    `json:"firstName"   firestore:"firstName"`
    LastName    string    `json:"lastName"    firestore:"lastName"`
    DisplayName string    `json:"displayName" firestore:"displayName"`
    PhotoURL    string    `json:"photoUrl"    firestore:"photoUrl"`
    Company     string    `json:"company"     firestore:"company"`
    Phone       string    `json:"phone"       firestore:"phone"`
    Location    string    `json:"location"    firestore:"location"`
    Bio         string    `json:"bio"         firestore:"bio"`
    CreatedAt   time.Time `json:"createdAt"   firestore:"createdAt"`
}

func (u *User) Initials() string { ... }
func UserFromDoc(id string, data map[string]interface{}) *User { ... }
func (u *User) ToMap() map[string]interface{} { ... }
```

### Listing (`model/listing.go`)

```go
type Listing struct {
    ID             string    `json:"id"             firestore:"-"`
    SellerID       string    `json:"sellerId"       firestore:"sellerId"`
    SellerName     string    `json:"sellerName"     firestore:"sellerName"`
    Title          string    `json:"title"          firestore:"title"`
    TitleLowercase string    `json:"titleLowercase" firestore:"titleLowercase"`
    Description    string    `json:"description"    firestore:"description"`
    Category       string    `json:"category"       firestore:"category"`
    Price          float64   `json:"price"          firestore:"price"`
    Condition      string    `json:"condition"      firestore:"condition"`
    Location       string    `json:"location"       firestore:"location"`
    Brand          string    `json:"brand"          firestore:"brand"`
    Model          string    `json:"model"          firestore:"model"`
    Year           *int      `json:"year"           firestore:"year,omitempty"`
    Hours          *int      `json:"hours"          firestore:"hours,omitempty"`
    ImageURLs      []string  `json:"imageUrls"      firestore:"imageUrls"`
    CreatedAt      time.Time `json:"createdAt"      firestore:"createdAt"`
    UpdatedAt      time.Time `json:"updatedAt"      firestore:"updatedAt"`
}

func ListingFromDoc(id string, data map[string]interface{}) *Listing { ... }
func (l *Listing) ToMap() map[string]interface{} { ... }
```

### ListingFilter (`model/filter.go`)

```go
type ListingFilter struct {
    SearchQuery string   `json:"searchQuery"`
    Category    string   `json:"category"`
    Condition   string   `json:"condition"`
    MinPrice    *float64 `json:"minPrice"`
    MaxPrice    *float64 `json:"maxPrice"`
    MinYear     *int     `json:"minYear"`
    MaxYear     *int     `json:"maxYear"`
    SortBy      string   `json:"sortBy"`      // "newest", "price_asc", "price_desc"
    Location    string   `json:"location"`
    Limit       int      `json:"limit"`
}
```

### AppError (`model/errors.go`)

Mirrors the Flutter Failure hierarchy. One error type, typed codes.

```go
type ErrorCode string

const (
    // Auth errors
    ErrInvalidToken       ErrorCode = "invalid_token"
    ErrTokenExpired       ErrorCode = "token_expired"
    ErrUserNotFound       ErrorCode = "user_not_found"
    ErrEmailAlreadyInUse  ErrorCode = "email_already_in_use"

    // Data errors
    ErrNotFound           ErrorCode = "not_found"
    ErrPermissionDenied   ErrorCode = "permission_denied"
    ErrAlreadyExists      ErrorCode = "already_exists"
    ErrValidation         ErrorCode = "validation_error"

    // General errors
    ErrInternal           ErrorCode = "internal_error"
    ErrBadRequest         ErrorCode = "bad_request"
    ErrUploadFailed       ErrorCode = "upload_failed"
)

type AppError struct {
    Code    ErrorCode `json:"code"`
    Message string    `json:"message"`
    Err     error     `json:"-"`       // Original error, not serialized
}

func (e *AppError) Error() string { return e.Message }

func NewAppError(code ErrorCode, message string, err error) *AppError { ... }

// Maps AppError codes to HTTP status codes
func (e *AppError) HTTPStatus() int {
    switch e.Code {
    case ErrNotFound, ErrUserNotFound:
        return 404
    case ErrPermissionDenied:
        return 403
    case ErrInvalidToken, ErrTokenExpired:
        return 401
    case ErrValidation, ErrBadRequest:
        return 400
    case ErrAlreadyExists, ErrEmailAlreadyInUse:
        return 409
    default:
        return 500
    }
}
```

---

## 4. Repositories

Each repository wraps **one** external system. This is the only layer that imports Firebase Admin SDK packages.

### UserRepository (`repository/user_repository.go`)

```go
type UserRepository struct {
    firestore *firestore.Client
}

func NewUserRepository(fs *firestore.Client) *UserRepository { ... }

func (r *UserRepository) GetByID(ctx context.Context, uid string) (*model.User, error)
func (r *UserRepository) Create(ctx context.Context, user *model.User) error
func (r *UserRepository) Update(ctx context.Context, user *model.User) error
```

| Method | Firestore Operation | Error Mapping |
|--------|-------------------|---------------|
| `GetByID` | `doc.Get()` | not found → `ErrNotFound` |
| `Create` | `doc.Set()` | already exists → `ErrAlreadyExists` |
| `Update` | `doc.Set(data, firestore.MergeAll)` | not found → `ErrNotFound` |

### ListingRepository (`repository/listing_repository.go`)

```go
type ListingRepository struct {
    firestore *firestore.Client
}

func NewListingRepository(fs *firestore.Client) *ListingRepository { ... }

func (r *ListingRepository) Create(ctx context.Context, listing *model.Listing) (string, error)
func (r *ListingRepository) GetByID(ctx context.Context, id string) (*model.Listing, error)
func (r *ListingRepository) Update(ctx context.Context, listing *model.Listing) error
func (r *ListingRepository) Delete(ctx context.Context, id string) error
func (r *ListingRepository) Query(ctx context.Context, filter *model.ListingFilter) ([]*model.Listing, error)
func (r *ListingRepository) GetBySeller(ctx context.Context, sellerID string) ([]*model.Listing, error)
```

**Query** builds Firestore queries dynamically:

```go
func (r *ListingRepository) Query(ctx context.Context, f *model.ListingFilter) ([]*model.Listing, error) {
    q := r.firestore.Collection("listings").Query

    if f.Category != "" {
        q = q.Where("category", "==", f.Category)
    }
    if f.Condition != "" {
        q = q.Where("condition", "==", f.Condition)
    }
    if f.MinPrice != nil {
        q = q.Where("price", ">=", *f.MinPrice)
    }
    if f.MaxPrice != nil {
        q = q.Where("price", "<=", *f.MaxPrice)
    }
    if f.SearchQuery != "" {
        lower := strings.ToLower(f.SearchQuery)
        q = q.Where("titleLowercase", ">=", lower)
        q = q.Where("titleLowercase", "<=", lower+"\uf8ff")
    }

    // Sorting
    switch f.SortBy {
    case "price_asc":
        q = q.OrderBy("price", firestore.Asc)
    case "price_desc":
        q = q.OrderBy("price", firestore.Desc)
    default:
        q = q.OrderBy("createdAt", firestore.Desc)
    }

    if f.Limit > 0 {
        q = q.Limit(f.Limit)
    }

    // Execute and parse
    docs, err := q.Documents(ctx).GetAll()
    // ... map docs to model.Listing
}
```

### StorageRepository (`repository/storage_repository.go`)

```go
type StorageRepository struct {
    bucket *storage.BucketHandle
}

func NewStorageRepository(bucket *storage.BucketHandle) *StorageRepository { ... }

func (r *StorageRepository) GenerateSignedUploadURL(path string, expiry time.Duration) (string, error)
func (r *StorageRepository) GenerateSignedDownloadURL(path string, expiry time.Duration) (string, error)
func (r *StorageRepository) Delete(ctx context.Context, path string) error
func (r *StorageRepository) ListFiles(ctx context.Context, prefix string) ([]string, error)
```

---

## 5. Services

Business logic layer. Composes repositories. Never imports HTTP or Firebase packages.

### AuthService (`service/auth_service.go`)

```go
type AuthService struct {
    firebaseAuth *auth.Client     // Firebase Admin Auth (only for token verification)
    userRepo     *repository.UserRepository
}

func NewAuthService(fa *auth.Client, ur *repository.UserRepository) *AuthService { ... }
```

| Method | What It Does |
|--------|-------------|
| `VerifyToken(ctx, idToken) → (uid, error)` | Verifies Firebase ID token, returns uid |
| `GetOrCreateUser(ctx, firebaseUser) → (*User, error)` | After Google sign-in: check if user doc exists, create if not |
| `CompleteRegistration(ctx, uid, req) → error` | After sign-up: create the Firestore user doc with profile fields |

### ListingService (`service/listing_service.go`)

```go
type ListingService struct {
    listingRepo *repository.ListingRepository
    userRepo    *repository.UserRepository
    storageRepo *repository.StorageRepository
}

func NewListingService(lr, ur, sr) *ListingService { ... }
```

| Method | What It Does |
|--------|-------------|
| `Create(ctx, sellerUID, req) → (id, error)` | Validates fields, loads seller name, saves listing |
| `GetByID(ctx, id) → (*Listing, error)` | Fetch single listing |
| `List(ctx, filter) → ([]*Listing, error)` | Query with filters + sorting |
| `GetBySeller(ctx, sellerID) → ([]*Listing, error)` | All listings by one seller |
| `Update(ctx, uid, id, req) → error` | Verify ownership, update fields |
| `Delete(ctx, uid, id) → error` | Verify ownership, delete listing + images |

**Business rules enforced here:**
- Seller can only edit/delete their own listings
- Price must be positive
- Category must be from the allowed list
- Title is required, max length
- TitleLowercase auto-generated for search

### StorageService (`service/storage_service.go`)

```go
type StorageService struct {
    storageRepo *repository.StorageRepository
}

func NewStorageService(sr *repository.StorageRepository) *StorageService { ... }
```

| Method | What It Does |
|--------|-------------|
| `GetUploadURLs(uid, listingID, count) → ([]SignedURL, error)` | Generate signed upload URLs for client-side upload |
| `GetAvatarUploadURL(uid) → (SignedURL, error)` | Signed URL for avatar upload |
| `DeleteListingImages(ctx, uid, listingID) → error` | Delete all images for a listing |

**Image upload strategy:** Backend generates signed URLs → Flutter uploads directly to Storage → Backend stores the final URLs in the listing document. This avoids routing large files through the backend.

### UserService (`service/user_service.go`)

```go
type UserService struct {
    userRepo *repository.UserRepository
}

func NewUserService(ur *repository.UserRepository) *UserService { ... }
```

| Method | What It Does |
|--------|-------------|
| `GetProfile(ctx, uid) → (*User, error)` | Fetch user profile |
| `UpdateProfile(ctx, uid, req) → error` | Update allowed fields (name, company, phone, location, bio) |
| `GetPublicProfile(ctx, uid) → (*User, error)` | Fetch limited public info (for seller cards) |

---

## 6. Handlers

Parse HTTP → call Service → write JSON response. Same role as Flutter ViewModels.

### ListingHandler (`handler/listing_handler.go`)

```go
type ListingHandler struct {
    listingService *service.ListingService
}

func NewListingHandler(ls *service.ListingService) *ListingHandler { ... }
```

| Endpoint | Method | Handler | Description |
|----------|--------|---------|-------------|
| `/api/v1/listings` | `GET` | `List` | Browse with filters (query params) |
| `/api/v1/listings` | `POST` | `Create` | Create new listing |
| `/api/v1/listings/{id}` | `GET` | `GetByID` | Single listing detail |
| `/api/v1/listings/{id}` | `PUT` | `Update` | Update listing (owner only) |
| `/api/v1/listings/{id}` | `DELETE` | `Delete` | Delete listing (owner only) |
| `/api/v1/listings/mine` | `GET` | `GetMine` | Current user's listings |

### UserHandler (`handler/user_handler.go`)

| Endpoint | Method | Handler | Description |
|----------|--------|---------|-------------|
| `/api/v1/users/me` | `GET` | `GetMe` | Current user's profile |
| `/api/v1/users/me` | `PUT` | `UpdateMe` | Update own profile |
| `/api/v1/users/{id}` | `GET` | `GetPublic` | Public seller profile |

### AuthHandler (`handler/auth_handler.go`)

| Endpoint | Method | Handler | Description |
|----------|--------|---------|-------------|
| `/api/v1/auth/complete-registration` | `POST` | `CompleteRegistration` | Create user doc after sign-up |
| `/api/v1/auth/google-callback` | `POST` | `GoogleCallback` | Get/create user after Google sign-in |

### StorageHandler (`handler/storage_handler.go`)

| Endpoint | Method | Handler | Description |
|----------|--------|---------|-------------|
| `/api/v1/upload/listing-images` | `POST` | `GetListingUploadURLs` | Get signed URLs for image upload |
| `/api/v1/upload/avatar` | `POST` | `GetAvatarUploadURL` | Get signed URL for avatar upload |

### Response Helpers (`handler/response.go`)

```go
func WriteJSON(w http.ResponseWriter, status int, data interface{}) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    json.NewEncoder(w).Encode(data)
}

func WriteError(w http.ResponseWriter, err error) {
    if appErr, ok := err.(*model.AppError); ok {
        WriteJSON(w, appErr.HTTPStatus(), map[string]interface{}{
            "error": map[string]interface{}{
                "code":    appErr.Code,
                "message": appErr.Message,
            },
        })
        return
    }
    // Unknown error → 500
    WriteJSON(w, 500, map[string]interface{}{
        "error": map[string]interface{}{
            "code":    "internal_error",
            "message": "An unexpected error occurred",
        },
    })
}
```

---

## 7. Middleware

### Auth Middleware (`middleware/auth.go`)

Every protected route verifies the Firebase ID token.

```go
type AuthMiddleware struct {
    firebaseAuth *auth.Client
}

func (m *AuthMiddleware) VerifyToken(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // 1. Extract token from Authorization header
        token := extractBearerToken(r)
        if token == "" {
            WriteError(w, NewAppError(ErrInvalidToken, "Missing auth token", nil))
            return
        }

        // 2. Verify with Firebase Admin SDK
        decoded, err := m.firebaseAuth.VerifyIDToken(r.Context(), token)
        if err != nil {
            WriteError(w, NewAppError(ErrInvalidToken, "Invalid auth token", err))
            return
        }

        // 3. Set uid in context for handlers
        ctx := context.WithValue(r.Context(), "uid", decoded.UID)
        next.ServeHTTP(w, r.WithContext(ctx))
    })
}
```

---

## 8. Router (`router/router.go`)

```go
func SetupRouter(
    authMW     *middleware.AuthMiddleware,
    listingH   *handler.ListingHandler,
    userH      *handler.UserHandler,
    authH      *handler.AuthHandler,
    storageH   *handler.StorageHandler,
) http.Handler {
    r := chi.NewRouter()

    // Global middleware
    r.Use(middleware.Logger)
    r.Use(middleware.Recovery)
    r.Use(middleware.CORS)

    // Health check (no auth)
    r.Get("/health", func(w http.ResponseWriter, r *http.Request) {
        w.Write([]byte("ok"))
    })

    // Protected routes
    r.Route("/api/v1", func(r chi.Router) {
        r.Use(authMW.VerifyToken)

        // Auth completion
        r.Post("/auth/complete-registration", authH.CompleteRegistration)
        r.Post("/auth/google-callback", authH.GoogleCallback)

        // Listings
        r.Get("/listings", listingH.List)
        r.Post("/listings", listingH.Create)
        r.Get("/listings/mine", listingH.GetMine)
        r.Get("/listings/{id}", listingH.GetByID)
        r.Put("/listings/{id}", listingH.Update)
        r.Delete("/listings/{id}", listingH.Delete)

        // Users
        r.Get("/users/me", userH.GetMe)
        r.Put("/users/me", userH.UpdateMe)
        r.Get("/users/{id}", userH.GetPublic)

        // Upload URLs
        r.Post("/upload/listing-images", storageH.GetListingUploadURLs)
        r.Post("/upload/avatar", storageH.GetAvatarUploadURL)
    })

    return r
}
```

---

## 9. Entry Point (`cmd/server/main.go`)

```go
func main() {
    // 1. Load config
    cfg := config.Load()

    // 2. Initialize Firebase Admin SDK
    app, err := firebase.NewApp(ctx, nil)  // uses GOOGLE_APPLICATION_CREDENTIALS env var
    firebaseAuth, _ := app.Auth(ctx)
    firestoreClient, _ := app.Firestore(ctx)
    storageBucket, _ := storageClient.Bucket(cfg.StorageBucket)

    // 3. Wire dependencies (manual DI — no framework needed)
    userRepo := repository.NewUserRepository(firestoreClient)
    listingRepo := repository.NewListingRepository(firestoreClient)
    storageRepo := repository.NewStorageRepository(storageBucket)

    authService := service.NewAuthService(firebaseAuth, userRepo)
    listingService := service.NewListingService(listingRepo, userRepo, storageRepo)
    storageService := service.NewStorageService(storageRepo)
    userService := service.NewUserService(userRepo)

    authMW := middleware.NewAuthMiddleware(firebaseAuth)

    listingHandler := handler.NewListingHandler(listingService)
    userHandler := handler.NewUserHandler(userService)
    authHandler := handler.NewAuthHandler(authService)
    storageHandler := handler.NewStorageHandler(storageService)

    // 4. Setup router
    router := router.SetupRouter(authMW, listingHandler, userHandler, authHandler, storageHandler)

    // 5. Start server
    log.Printf("Starting server on :%s", cfg.Port)
    http.ListenAndServe(":"+cfg.Port, router)
}
```

---

## 10. Firebase Cloud Services — What Each One Does

### Firebase Auth
- **Flutter uses:** Client SDK for sign-in/sign-up UI flows
- **Go uses:** Admin SDK to verify ID tokens
- **No passwords stored by us** — Firebase handles all credential management
- ID tokens expire after 1 hour, auto-refreshed by Flutter SDK

### Cloud Firestore
- **Flutter uses:** (future) Real-time listeners for live updates (optional)
- **Go uses:** Admin SDK for all CRUD operations
- **Collections:** `users`, `listings`
- **Indexes needed:**
  - `listings`: composite index on `category` + `createdAt` (desc)
  - `listings`: composite index on `condition` + `price`
  - `listings`: composite index on `titleLowercase` range + `createdAt`
  - `listings`: composite index on `sellerId` + `createdAt` (desc)

### Firebase Storage
- **Flutter uses:** Upload images directly via signed URLs
- **Go uses:** Generate signed URLs, delete files
- **Paths:**
  ```
  machine_images/{userId}/{listingId}/image_0.jpg
  machine_images/{userId}/{listingId}/image_1.jpg
  avatars/{userId}/avatar.jpg
  ```

### Firebase Crashlytics
- **Flutter uses:** Client SDK for frontend crash reporting
- **Go uses:** Structured logging (log to stdout → Cloud Logging in production)

---

## 11. Firestore Security Rules

With a Go backend handling all writes, security rules can be restrictive:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Default: deny all direct client access
    match /{document=**} {
      allow read, write: if false;
    }

    // If Flutter needs real-time listeners (read-only):
    match /listings/{listingId} {
      allow read: if request.auth != null;
    }

    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
    }
  }
}
// Note: Go backend uses Admin SDK which bypasses these rules entirely.
```

---

## 12. Full API Reference

### Auth Endpoints

| Method | Endpoint | Body | Response | Auth |
|--------|----------|------|----------|------|
| `POST` | `/api/v1/auth/complete-registration` | `{firstName, lastName, company}` | `{user}` | Required |
| `POST` | `/api/v1/auth/google-callback` | `{}` | `{user, isNew}` | Required |

### Listing Endpoints

| Method | Endpoint | Query/Body | Response | Auth |
|--------|----------|-----------|----------|------|
| `GET` | `/api/v1/listings` | `?category=&condition=&minPrice=&maxPrice=&search=&sortBy=&limit=` | `{listings: [...]}` | Required |
| `POST` | `/api/v1/listings` | `{title, brand, model, year, price, condition, category, location, description, imageUrls}` | `{id}` | Required |
| `GET` | `/api/v1/listings/mine` | — | `{listings: [...]}` | Required |
| `GET` | `/api/v1/listings/{id}` | — | `{listing}` | Required |
| `PUT` | `/api/v1/listings/{id}` | `{title, brand, model, ...}` | `{listing}` | Required (owner) |
| `DELETE` | `/api/v1/listings/{id}` | — | `204 No Content` | Required (owner) |

### User Endpoints

| Method | Endpoint | Body | Response | Auth |
|--------|----------|------|----------|------|
| `GET` | `/api/v1/users/me` | — | `{user}` | Required |
| `PUT` | `/api/v1/users/me` | `{firstName, lastName, company, phone, location, bio}` | `{user}` | Required |
| `GET` | `/api/v1/users/{id}` | — | `{user}` (public fields only) | Required |

### Upload Endpoints

| Method | Endpoint | Body | Response | Auth |
|--------|----------|------|----------|------|
| `POST` | `/api/v1/upload/listing-images` | `{listingId, count}` | `{urls: [{path, signedUrl}]}` | Required |
| `POST` | `/api/v1/upload/avatar` | — | `{path, signedUrl}` | Required |

---

## 13. Error Response Format

All errors follow one consistent shape:

```json
{
  "error": {
    "code": "not_found",
    "message": "Listing not found"
  }
}
```

Flutter maps these to its Failure types:

| Backend `code` | Flutter Failure |
|----------------|----------------|
| `invalid_token` / `token_expired` | `AuthFailure.tokenExpired` |
| `user_not_found` | `AuthFailure.userNotFound` |
| `not_found` | `DataFailure.notFound` |
| `permission_denied` | `DataFailure.permissionDenied` |
| `validation_error` | `DataFailure.requestFailed` |
| `internal_error` | `GeneralFailure.unexpectedError` |

---

## 14. Step-by-Step: How to Build Any Backend Feature

### Step 1: Model
- [ ] Create Go struct in `internal/model/`
- [ ] Add `ToMap()` and `FromDoc()` methods
- [ ] JSON tags match Flutter model exactly
- [ ] Add request/response structs if needed

### Step 2: Error Codes
- [ ] Add new `ErrorCode` constants to `model/errors.go` if needed
- [ ] Map to HTTP status in `HTTPStatus()`

### Step 3: Repository
- [ ] Create in `internal/repository/`
- [ ] Wraps ONE external system
- [ ] Returns `*AppError` for known failures
- [ ] Constructor takes Firebase client as parameter

### Step 4: Service
- [ ] Create in `internal/service/`
- [ ] Composes repositories via constructor injection
- [ ] Enforces business rules (ownership, validation, limits)
- [ ] Never imports `net/http`

### Step 5: Handler
- [ ] Create in `internal/handler/`
- [ ] Parse request → validate → call Service → write response
- [ ] Uses `WriteJSON()` and `WriteError()` helpers
- [ ] Gets `uid` from context (set by auth middleware)

### Step 6: Router
- [ ] Add route to `router/router.go`
- [ ] Choose correct middleware (auth required or public)

### Step 7: Wire in main.go
- [ ] Instantiate repository, service, handler
- [ ] Pass to router setup

---

## 15. Summary Cheat Sheet

```
To build a backend feature:

  1. MODEL       → internal/model/              → Go struct with ToMap/FromDoc + JSON tags
  2. ERROR CODES → internal/model/errors.go     → Add new ErrorCode if needed
  3. REPOSITORY  → internal/repository/          → Firestore/Storage CRUD, returns *AppError
  4. SERVICE     → internal/service/             → Business logic, composes repos, enforces rules
  5. HANDLER     → internal/handler/             → Parse HTTP, call service, write JSON
  6. ROUTER      → internal/router/router.go     → Add route + middleware
  7. WIRE        → cmd/server/main.go            → Instantiate and inject dependencies

Layer responsibilities:
  Handler  = "What did the client ask for?"
  Service  = "Is this allowed? What's the business logic?"
  Repository = "How do I talk to Firestore/Storage?"

Error flow:
  Firestore error → Repository returns *AppError
                   → Service adds business context
                   → Handler calls WriteError()
                   → Client receives { error: { code, message } }

Dependency direction:
  Router → Handlers → Services → Repositories → Firebase Admin SDK
                         ↓
                      Models (shared across all layers)

Firebase services:
  Auth      → Flutter does login → sends ID token → Go verifies
  Firestore → Go reads/writes via Admin SDK
  Storage   → Go generates signed URLs → Flutter uploads directly
```

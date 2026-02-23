# 537 Machines — Full-Stack Infrastructure Overview

> One example traced end-to-end through every layer: Flutter frontend, Go backend, Firebase cloud services.

---

## The Big Picture

```
┌──────────────────────────────────────────────────────────────────────┐
│                        FLUTTER FRONTEND                              │
│                                                                      │
│   View ──▶ ViewModel ──▶ Service ──▶ Repository                     │
│   (UI)      (state)       (logic)     (HTTP calls to Go backend)    │
│                                                                      │
│   Today: Repositories talk directly to Firebase SDKs                │
│   Tomorrow: Repositories talk to your Go backend via REST/gRPC      │
│                                                                      │
└─────────────────────────┬────────────────────────────────────────────┘
                          │  HTTPS (REST API)
                          ▼
┌──────────────────────────────────────────────────────────────────────┐
│                          GO BACKEND                                  │
│                                                                      │
│   Router ──▶ Handler ──▶ Service ──▶ Repository                     │
│   (routes)   (request)   (logic)     (Firestore/Storage SDK)        │
│                                                                      │
│   Validates tokens, enforces rules, runs business logic             │
│   This is the single source of truth for data mutations             │
│                                                                      │
└─────────────────────────┬────────────────────────────────────────────┘
                          │  Firebase Admin SDK
                          ▼
┌──────────────────────────────────────────────────────────────────────┐
│                     FIREBASE CLOUD SERVICES                          │
│                                                                      │
│   Auth            Firestore           Storage          Crashlytics  │
│   (users +        (users, listings    (machine images   (error       │
│    tokens)         collections)        avatars)          logging)    │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## What Changes, What Stays

| Layer | Today (Firebase-direct) | Tomorrow (with Go backend) |
|-------|------------------------|----------------------------|
| **View** | No change | No change |
| **ViewModel** | No change | No change |
| **Service** | No change | No change |
| **Repository** | Calls Firebase SDK directly | Calls Go backend via HTTP |
| **Models** | Shared shape | Same models, backend has Go structs that mirror them |
| **Auth** | Firebase Auth client SDK | Firebase Auth for login → sends ID token → Go verifies it |

**Key insight:** Only the Repository layer changes. Everything above it stays identical. This is why the layered architecture matters.

---

## One Example: "Create a Listing"

Let's trace the full journey of a user publishing a new machine listing.

---

### Step 1 — FLUTTER VIEW (`create_listing_view.dart`)

The user fills in the form and taps "Publish Listing".

```dart
// View just forwards the action to the ViewModel
CustomButton(
  title: 'Publish Listing',
  onTap: () {
    if (formKey.currentState!.validate()) {
      viewModel.submit(
        title: titleController.text.trim(),
        brand: brandController.text.trim(),
        price: priceController.text.trim(),
        // ... other fields
      );
    }
  },
);
```

**View's job:** Build UI, validate form, forward action. Zero logic.

---

### Step 2 — FLUTTER VIEWMODEL (`create_listing_viewmodel.dart`)

Manages UI state (busy, error) and calls the Service.

```dart
Future<void> submit({required String title, ...}) async {
  setBusy(true);

  // Upload images first via StorageService
  // Then create listing via ListingService

  return Executor.run(_listingService.createListing(listing))
      .then((result) => result.fold(
            (failure) {
              // Log to Crashlytics
              // Switch on failure.type for user-friendly message
              setError('Failed to create listing');
              setBusy(false);
            },
            (_) {
              setBusy(false);
              _snackbarService.showSnackbar(message: 'Listing created!');
              _navigationService.back();
            },
          ));
}
```

**ViewModel's job:** Orchestrate UI state. Never touches repositories or HTTP.

---

### Step 3 — FLUTTER SERVICE (`listing_service.dart`)

Composes repositories. Applies business rules.

```dart
Future<String> createListing(MachineListing listing) async {
  // Today: calls FirestoreRepository directly
  // Tomorrow: calls ApiRepository which hits the Go backend

  final docId = await _firestoreRepo.addDocument(
    collection: FirebaseConstants.listingsCollection,
    data: listing.toJson(),
  );
  return docId;
}
```

**Service's job:** Business logic, compose repos. No try-catch (Executor handles it).

---

### Step 4 — FLUTTER REPOSITORY (the layer that changes)

**Today — Firebase direct:**
```dart
// firestore_repository.dart
Future<String> addDocument({required String collection, required Map<String, dynamic> data}) async {
  try {
    final ref = await _firestore.collection(collection).add(data);
    return ref.id;
  } on FirebaseException catch (e, s) {
    throw _mapFirebaseException(e, s);
  }
}
```

**Tomorrow — HTTP to Go backend:**
```dart
// api_repository.dart
Future<String> createListing(Map<String, dynamic> data) async {
  try {
    final token = await _authRepo.getIdToken();  // Firebase ID token
    final response = await _http.post(
      Uri.parse('$baseUrl/api/v1/listings'),
      headers: {'Authorization': 'Bearer $token'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body)['id'];
    }
    throw _mapHttpError(response);
  } on SocketException catch (e, s) {
    throw GeneralFailure(GeneralFailureType.socketException, e.toString(), s);
  }
}
```

**Repository's job:** Wrap ONE external system. try-catch → typed Failure.

---

### Step 5 — GO BACKEND ROUTER

```go
// router.go
func SetupRouter(h *handler.ListingHandler, auth middleware.AuthMiddleware) *chi.Mux {
    r := chi.NewRouter()
    r.Use(middleware.Logger)

    r.Route("/api/v1", func(r chi.Router) {
        r.Use(auth.VerifyToken)  // Firebase ID token verification

        r.Post("/listings", h.Create)
        r.Get("/listings", h.List)
        r.Get("/listings/{id}", h.GetByID)
        r.Put("/listings/{id}", h.Update)
        r.Delete("/listings/{id}", h.Delete)
    })

    return r
}
```

---

### Step 6 — GO HANDLER (`listing_handler.go`)

Parses HTTP request, calls service, writes HTTP response. Same role as Flutter ViewModel.

```go
func (h *ListingHandler) Create(w http.ResponseWriter, r *http.Request) {
    // 1. Get authenticated user from context (set by auth middleware)
    uid := r.Context().Value("uid").(string)

    // 2. Parse request body
    var req CreateListingRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, "Invalid request body", http.StatusBadRequest)
        return
    }

    // 3. Validate
    if err := req.Validate(); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    // 4. Call service
    id, err := h.listingService.Create(r.Context(), uid, &req)
    if err != nil {
        h.handleError(w, err)
        return
    }

    // 5. Respond
    w.WriteHeader(http.StatusCreated)
    json.NewEncoder(w).Encode(map[string]string{"id": id})
}
```

---

### Step 7 — GO SERVICE (`listing_service.go`)

Business logic. Same role as Flutter Service layer.

```go
func (s *ListingService) Create(ctx context.Context, sellerUID string, req *CreateListingRequest) (string, error) {
    // 1. Load seller info (to stamp sellerName on the listing)
    seller, err := s.userRepo.GetByID(ctx, sellerUID)
    if err != nil {
        return "", fmt.Errorf("seller not found: %w", err)
    }

    // 2. Build the listing document
    listing := &model.Listing{
        SellerID:       sellerUID,
        SellerName:     seller.DisplayName,
        Title:          req.Title,
        TitleLowercase: strings.ToLower(req.Title),
        Brand:          req.Brand,
        Model:          req.Model,
        Year:           req.Year,
        Price:          req.Price,
        Condition:      req.Condition,
        Category:       req.Category,
        Location:       req.Location,
        Description:    req.Description,
        ImageURLs:      req.ImageURLs,
        CreatedAt:      time.Now(),
        UpdatedAt:      time.Now(),
    }

    // 3. Save to Firestore
    return s.listingRepo.Create(ctx, listing)
}
```

---

### Step 8 — GO REPOSITORY (`listing_repository.go`)

Talks to Firestore via Admin SDK. Same role as Flutter Repository.

```go
func (r *ListingRepository) Create(ctx context.Context, listing *model.Listing) (string, error) {
    ref, _, err := r.firestore.Collection("listings").Add(ctx, listing.ToMap())
    if err != nil {
        return "", fmt.Errorf("firestore add failed: %w", err)
    }
    return ref.ID, nil
}
```

---

### Step 9 — FIREBASE (the actual data store)

```
Firestore: listings/{autoId} ← document created
Storage: machine_images/{uid}/{listingId}/image_0.jpg ← images uploaded earlier
Auth: ID token verified by Go middleware using Firebase Admin SDK
```

---

## The Full Request Flow (summary)

```
User taps "Publish"
    │
    ▼
[View] ── validates form ──▶ viewModel.submit()
    │
    ▼
[ViewModel] ── setBusy(true) ──▶ Executor.run(service.createListing())
    │
    ▼
[Service] ── business logic ──▶ apiRepo.createListing(data)
    │
    ▼
[Repository] ── HTTP POST /api/v1/listings ──▶ { Authorization: Bearer <firebase-id-token> }
    │
    ▼  ════════════ NETWORK ════════════
    │
    ▼
[Go Router] ── auth middleware verifies token ──▶ handler.Create()
    │
    ▼
[Go Handler] ── parses body, validates ──▶ service.Create()
    │
    ▼
[Go Service] ── loads seller, builds doc ──▶ repo.Create()
    │
    ▼
[Go Repository] ── Firestore Admin SDK ──▶ firestore.Collection("listings").Add()
    │
    ▼
[Firestore] ── document stored ──▶ response flows back up the chain
```

---

## Auth Flow — How Firebase Ties It Together

```
1. User signs in via Flutter (Firebase Auth SDK)
   └── Gets a Firebase ID Token (JWT)

2. Flutter stores the token, attaches it to every API call
   └── Authorization: Bearer <id-token>

3. Go middleware intercepts every request
   └── firebase.Auth().VerifyIDToken(ctx, idToken)
   └── Extracts uid, sets it in request context

4. Go handlers use uid from context
   └── Never trust the client for "who am I" — always from the verified token

5. Firestore Security Rules can be minimal
   └── Backend has Admin SDK (bypasses rules)
   └── Rules only needed if Flutter still reads Firestore directly (e.g., real-time listeners)
```

---

## What Firebase Provides (cloud services)

| Service | Role | Who Talks to It |
|---------|------|-----------------|
| **Firebase Auth** | User identity + ID tokens | Flutter (login/register), Go (token verification) |
| **Firestore** | Document database | Go backend (via Admin SDK) |
| **Firebase Storage** | File/image hosting | Flutter (upload via signed URLs) or Go (generate signed URLs) |
| **Crashlytics** | Error monitoring | Flutter client + Go backend logs |
| **Hosting** | (optional) Host Go backend or Flutter web | Deployment |

---

## Summary

The architecture is the same pattern repeated at two levels:

```
Flutter:  View → ViewModel → Service → Repository → (HTTP)
Go:       Router → Handler → Service → Repository → (Firestore)
```

Both follow the same principles:
- **Strict layer separation** — each layer has one job
- **Errors flow as typed objects** — not raw exceptions
- **Only the outermost layer touches external systems** — Repository
- **Business logic lives in Services** — not in handlers, not in views
- **Auth is verified server-side** — never trust the client

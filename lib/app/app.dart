import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

// Views
import '../ui/views/startup/startup_view.dart';
import '../ui/views/login/login_view.dart';
import '../ui/views/register/register_view.dart';
import '../ui/views/main/main_view.dart';
import '../ui/views/listings/listings_view.dart';
import '../ui/views/listing_detail/listing_detail_view.dart';
import '../ui/views/create_listing/create_listing_view.dart';
import '../ui/views/edit_listing/edit_listing_view.dart';
import '../ui/views/profile/profile_view.dart';
import '../ui/views/edit_profile/edit_profile_view.dart';
import '../ui/views/search/search_view.dart';
import '../ui/views/messages/messages_view.dart';

// Repositories (primitive adapters — try-catch layer)
import '../repositories/firestore_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/storage_repository.dart';

// Services (domain facades — Executor.run + .fold)
import '../services/auth_service.dart';
import '../services/listing_service.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';

// Core services
import '../core/services/crashlytics_service.dart';

// Dialogs
import '../ui/dialogs/confirm/confirm_dialog.dart';

// Bottom Sheets
import '../ui/bottom_sheets/filter/filter_sheet.dart';

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
    MaterialRoute(page: SearchView),
    MaterialRoute(page: MessagesView),
  ],
  dependencies: [
    // --- Stacked built-in services ---
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: SnackbarService),

    // --- Core services ---
    LazySingleton(classType: CrashlyticsService),

    // --- Repositories (primitive adapters — one per external system) ---
    LazySingleton(classType: FirestoreRepository),
    LazySingleton(classType: AuthRepository),
    LazySingleton(classType: StorageRepository),

    // --- Services (domain facades — compose repositories) ---
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

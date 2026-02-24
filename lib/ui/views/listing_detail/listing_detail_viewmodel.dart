import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../app/app.dialogs.dart';
import '../../../core/error_handling/executor.dart';
import '../../../core/services/crashlytics_service.dart';
import '../../../models/machine_listing.dart';
import '../../../models/listing_filter.dart';
import '../../../services/listing_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/message_service.dart';
import '../../../services/favorite_service.dart';
import '../../../services/offer_service.dart';
import '../../../models/offer.dart';

class ListingDetailViewModel extends BaseViewModel {
  final _listingService = locator<ListingService>();
  final _storageService = locator<StorageService>();
  final _authService = locator<AuthService>();
  final _messageService = locator<MessageService>();
  final _favoriteService = locator<FavoriteService>();
  final _offerService = locator<OfferService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _crashlytics = locator<CrashlyticsService>();

  final String listingId;
  ListingDetailViewModel({required this.listingId});

  MachineListing? _listing;
  MachineListing? get listing => _listing;

  bool _isFavorited = false;
  bool get isFavorited => _isFavorited;

  List<MachineListing> _similarListings = [];
  List<MachineListing> get similarListings => _similarListings;

  bool get isOwner =>
      _listing != null &&
      _authService.currentUser != null &&
      _listing!.sellerId == _authService.currentUser!.uid;

  String? get _currentUserId => _authService.currentUser?.uid;

  Future<void> init() async {
    setBusy(true);

    return Executor.run(_listingService.getListingById(listingId))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    [
                      'ListingDetailViewModel',
                      'init($listingId)',
                      failure.toString()
                    ],
                    failure.stackTrace);
                setError(failure);
                setBusy(false);
              },
              (data) async {
                _listing = data;
                setBusy(false);
                rebuildUi();
                // Check favorite status in background
                if (_currentUserId != null) {
                  _isFavorited = await _favoriteService.isFavorite(
                      _currentUserId!, listingId);
                  rebuildUi();
                }
                // Load similar machines in background
                _loadSimilarListings(data.category);
              },
            ));
  }

  Future<void> _loadSimilarListings(String category) async {
    await Executor.run(_listingService.getListings(
      filter: ListingFilter(category: category),
      limit: 5,
    )).then((result) => result.fold(
          (failure) {}, // Silent fail for similar listings
          (data) {
            _similarListings =
                data.where((l) => l.id != listingId).take(4).toList();
            rebuildUi();
          },
        ));
  }

  Future<void> toggleFavorite() async {
    if (_currentUserId == null) return;

    // Optimistic update
    _isFavorited = !_isFavorited;
    rebuildUi();

    if (_isFavorited) {
      await Executor.run(
        _favoriteService.addFavorite(_currentUserId!, listingId),
      ).then((result) => result.fold(
            (failure) {
              _isFavorited = false;
              rebuildUi();
            },
            (_) {},
          ));
    } else {
      await Executor.run(
        _favoriteService.removeFavorite(_currentUserId!, listingId),
      ).then((result) => result.fold(
            (failure) {
              _isFavorited = true;
              rebuildUi();
            },
            (_) {},
          ));
    }
  }

  Future<void> makeOffer(double amount) async {
    if (_listing == null || _currentUserId == null) return;

    final offer = Offer(
      id: '',
      listingId: listingId,
      buyerId: _currentUserId!,
      sellerId: _listing!.sellerId,
      amount: amount,
      createdAt: DateTime.now(),
    );

    setBusy(true);

    return Executor.run(_offerService.makeOffer(offer))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    [
                      'ListingDetailViewModel',
                      'makeOffer()',
                      failure.toString()
                    ],
                    failure.stackTrace);
                setError('Could not submit offer');
                setBusy(false);
              },
              (_) {
                setBusy(false);
                rebuildUi();
              },
            ));
  }

  void openListingDetail(String id) {
    _navigationService.navigateTo(
      Routes.listingDetailView,
      arguments: ListingDetailViewArguments(listingId: id),
    );
  }

  void navigateToEdit() {
    _navigationService.navigateTo(
      Routes.editListingView,
      arguments: EditListingViewArguments(listingId: listingId),
    );
  }

  Future<void> contactSeller() async {
    if (_listing == null || _authService.currentUser == null) return;

    setBusy(true);

    return Executor.run(_messageService.getOrCreateConversation(
      senderId: _authService.currentUser!.uid,
      receiverId: _listing!.sellerId,
      listingId: listingId,
      listingTitle: _listing!.title,
      listingPrice: _listing!.price,
      listingImageUrl:
          _listing!.imageUrls.isNotEmpty ? _listing!.imageUrls.first : '',
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                [
                  'ListingDetailViewModel',
                  'contactSeller()',
                  failure.toString()
                ],
                failure.stackTrace);
            setError('Could not start conversation');
            setBusy(false);
          },
          (conversation) {
            setBusy(false);
            _navigationService.navigateTo(
              Routes.messagesView,
              arguments: MessagesViewArguments(
                  initialConversationId: conversation.id),
            );
          },
        ));
  }

  Future<void> deleteListing() async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.confirm,
      title: 'Delete Listing',
      description: 'Are you sure you want to delete this listing?',
    );

    if (response?.confirmed != true) return;

    setBusy(true);

    // Delete images first
    await Executor.run(_storageService.deleteListingImages(
      userId: _listing!.sellerId,
      listingId: listingId,
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                [
                  'ListingDetailViewModel',
                  'deleteListing(images)',
                  failure.toString()
                ],
                failure.stackTrace);
            // Continue with listing delete even if image delete fails
          },
          (_) {},
        ));

    return Executor.run(_listingService.deleteListing(listingId))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    [
                      'ListingDetailViewModel',
                      'deleteListing()',
                      failure.toString()
                    ],
                    failure.stackTrace);
                setError('Could not delete listing');
                setBusy(false);
              },
              (_) {
                setBusy(false);
                _navigationService.back();
              },
            ));
  }
}

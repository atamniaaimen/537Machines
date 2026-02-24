import 'package:logger/logger.dart';
import '../app/app.locator.dart';
import '../core/error_handling/executor.dart';
import '../core/services/crashlytics_service.dart';
import '../core/constants/firebase_constants.dart';
import '../models/offer.dart';
import '../repositories/firestore_repository.dart';

class OfferService {
  final _firestoreRepo = locator<FirestoreRepository>();
  final _crashlytics = locator<CrashlyticsService>();

  Future<String> makeOffer(Offer offer) {
    return Executor.run(_firestoreRepo.addDocument(
      collection:
          '${FirebaseConstants.listingsCollection}/${offer.listingId}/offers',
      data: offer.toJson(),
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                [
                  'OfferService',
                  'makeOffer(${offer.listingId})',
                  failure.toString()
                ],
                failure.stackTrace);
            throw failure;
          },
          (docId) => docId,
        ));
  }

  Future<List<Offer>> getOffersForListing(String listingId) {
    return Executor.run(_firestoreRepo.getCollection(
      collection:
          '${FirebaseConstants.listingsCollection}/$listingId/offers',
      queryBuilder: (ref) => ref.orderBy('createdAt', descending: true),
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                [
                  'OfferService',
                  'getOffersForListing($listingId)',
                  failure.toString()
                ],
                failure.stackTrace);
            throw failure;
          },
          (docs) =>
              docs.map((d) => Offer.fromJson(d, id: d['id'])).toList(),
        ));
  }

  Future<void> updateOfferStatus(
      String listingId, String offerId, String status) {
    return Executor.run(_firestoreRepo.setDocument(
      collection:
          '${FirebaseConstants.listingsCollection}/$listingId/offers',
      id: offerId,
      data: {'status': status},
      merge: true,
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                [
                  'OfferService',
                  'updateOfferStatus($listingId, $offerId)',
                  failure.toString()
                ],
                failure.stackTrace);
            throw failure;
          },
          (_) {},
        ));
  }
}

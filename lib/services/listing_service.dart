import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../app/app.locator.dart';
import '../core/error_handling/executor.dart';
import '../core/error_handling/failures/data_failure.dart';
import '../core/services/crashlytics_service.dart';
import '../core/constants/firebase_constants.dart';
import '../models/machine_listing.dart';
import '../models/listing_filter.dart';
import '../repositories/firestore_repository.dart';

class ListingService {
  final _firestoreRepo = locator<FirestoreRepository>();
  final _crashlytics = locator<CrashlyticsService>();

  Future<List<MachineListing>> getListings({
    ListingFilter? filter,
    int? limit,
  }) {
    return Executor.run(_firestoreRepo.getCollection(
      collection: FirebaseConstants.listingsCollection,
      queryBuilder: (ref) {
        Query<Map<String, dynamic>> query = ref;

        if (filter != null) {
          if (filter.category != null) {
            query = query.where('category', isEqualTo: filter.category);
          }
          if (filter.condition != null) {
            query = query.where('condition', isEqualTo: filter.condition);
          }
          if (filter.minPrice != null) {
            query = query.where('price',
                isGreaterThanOrEqualTo: filter.minPrice);
          }
          if (filter.maxPrice != null) {
            query =
                query.where('price', isLessThanOrEqualTo: filter.maxPrice);
          }
          if (filter.minYear != null) {
            query = query.where('year',
                isGreaterThanOrEqualTo: filter.minYear);
          }
          if (filter.maxYear != null) {
            query =
                query.where('year', isLessThanOrEqualTo: filter.maxYear);
          }
          if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
            final searchLower = filter.searchQuery!.toLowerCase();
            query = query
                .where('titleLowercase',
                    isGreaterThanOrEqualTo: searchLower)
                .where('titleLowercase',
                    isLessThanOrEqualTo: '$searchLower\uf8ff');
          }
        }

        // Sort
        final sortBy = filter?.sortBy;
        if (sortBy == 'Price: Low to High') {
          query = query.orderBy('price', descending: false);
        } else if (sortBy == 'Price: High to Low') {
          query = query.orderBy('price', descending: true);
        } else {
          query = query.orderBy('createdAt', descending: true);
        }

        return query;
      },
      limit: limit,
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                ['ListingService', 'getListings()', failure.toString()],
                failure.stackTrace);
            throw failure;
          },
          (docs) => docs
              .map((d) => MachineListing.fromJson(d, id: d['id']))
              .toList(),
        ));
  }

  Future<MachineListing> getListingById(String id) {
    return Executor.run(_firestoreRepo.getDocument(
      collection: FirebaseConstants.listingsCollection,
      id: id,
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                ['ListingService', 'getListingById($id)', failure.toString()],
                failure.stackTrace);
            throw failure;
          },
          (data) {
            if (data == null) {
              throw DataFailure(DataFailureType.notFound,
                  description: 'Listing $id not found',
                  stackTrace: StackTrace.current);
            }
            return MachineListing.fromJson(data, id: id);
          },
        ));
  }

  Future<List<MachineListing>> getListingsBySeller(String sellerId) {
    return Executor.run(_firestoreRepo.getCollection(
      collection: FirebaseConstants.listingsCollection,
      queryBuilder: (ref) =>
          ref.where('sellerId', isEqualTo: sellerId)
              .orderBy('createdAt', descending: true),
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                [
                  'ListingService',
                  'getListingsBySeller($sellerId)',
                  failure.toString()
                ],
                failure.stackTrace);
            throw failure;
          },
          (docs) => docs
              .map((d) => MachineListing.fromJson(d, id: d['id']))
              .toList(),
        ));
  }

  Future<String> createListing(MachineListing listing) {
    return Executor.run(_firestoreRepo.addDocument(
      collection: FirebaseConstants.listingsCollection,
      data: listing.toJson(),
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                ['ListingService', 'createListing()', failure.toString()],
                failure.stackTrace);
            throw failure;
          },
          (docId) => docId,
        ));
  }

  Future<void> updateListing(MachineListing listing) {
    return Executor.run(_firestoreRepo.setDocument(
      collection: FirebaseConstants.listingsCollection,
      id: listing.id,
      data: listing.toJson(),
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                [
                  'ListingService',
                  'updateListing(${listing.id})',
                  failure.toString()
                ],
                failure.stackTrace);
            throw failure;
          },
          (_) {},
        ));
  }

  Future<void> deleteListing(String id) {
    return Executor.run(_firestoreRepo.deleteDocument(
      collection: FirebaseConstants.listingsCollection,
      id: id,
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                ['ListingService', 'deleteListing($id)', failure.toString()],
                failure.stackTrace);
            throw failure;
          },
          (_) {},
        ));
  }
}

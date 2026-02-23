import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/error_handling/failure.dart';
import '../core/error_handling/failures/general_failure.dart';
import '../core/error_handling/failures/data_failure.dart';

/// Primitive adapter for Cloud Firestore.
/// Single responsibility: CRUD operations on Firestore documents.
/// Catches FirebaseException and throws typed Failures.
class FirestoreRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String id,
  }) async {
    try {
      final doc = await _db.collection(collection).doc(id).get();
      if (!doc.exists) return null;
      return doc.data();
    } on FirebaseException catch (e, s) {
      throw _mapFirebaseException(e, s);
    } on SocketException catch (e, s) {
      throw GeneralFailure(
          GeneralFailureType.socketException, e.toString(), s);
    } catch (e, s) {
      throw GeneralFailure(
          GeneralFailureType.unexpectedError, e.toString(), s);
    }
  }

  Future<String> addDocument({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    try {
      final ref = await _db.collection(collection).add(data);
      return ref.id;
    } on FirebaseException catch (e, s) {
      throw _mapFirebaseException(e, s);
    } on SocketException catch (e, s) {
      throw GeneralFailure(
          GeneralFailureType.socketException, e.toString(), s);
    } catch (e, s) {
      throw GeneralFailure(
          GeneralFailureType.unexpectedError, e.toString(), s);
    }
  }

  Future<void> setDocument({
    required String collection,
    required String id,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    try {
      await _db
          .collection(collection)
          .doc(id)
          .set(data, SetOptions(merge: merge));
    } on FirebaseException catch (e, s) {
      throw _mapFirebaseException(e, s);
    } on SocketException catch (e, s) {
      throw GeneralFailure(
          GeneralFailureType.socketException, e.toString(), s);
    } catch (e, s) {
      throw GeneralFailure(
          GeneralFailureType.unexpectedError, e.toString(), s);
    }
  }

  Future<void> deleteDocument({
    required String collection,
    required String id,
  }) async {
    try {
      await _db.collection(collection).doc(id).delete();
    } on FirebaseException catch (e, s) {
      throw _mapFirebaseException(e, s);
    } on SocketException catch (e, s) {
      throw GeneralFailure(
          GeneralFailureType.socketException, e.toString(), s);
    } catch (e, s) {
      throw GeneralFailure(
          GeneralFailureType.unexpectedError, e.toString(), s);
    }
  }

  Future<List<Map<String, dynamic>>> getCollection({
    required String collection,
    Query<Map<String, dynamic>> Function(
            CollectionReference<Map<String, dynamic>>)?
        queryBuilder,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _db.collection(collection);
      if (queryBuilder != null) {
        query = queryBuilder(_db.collection(collection));
      }
      if (limit != null) {
        query = query.limit(limit);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } on FirebaseException catch (e, s) {
      throw _mapFirebaseException(e, s);
    } on SocketException catch (e, s) {
      throw GeneralFailure(
          GeneralFailureType.socketException, e.toString(), s);
    } catch (e, s) {
      throw GeneralFailure(
          GeneralFailureType.unexpectedError, e.toString(), s);
    }
  }

  Failure _mapFirebaseException(FirebaseException e, StackTrace s) {
    switch (e.code) {
      case 'not-found':
        return DataFailure(DataFailureType.notFound,
            description: e.message, stackTrace: s);
      case 'permission-denied':
        return DataFailure(DataFailureType.permissionDenied,
            description: e.message, stackTrace: s);
      case 'already-exists':
        return DataFailure(DataFailureType.alreadyExists,
            description: e.message, stackTrace: s);
      case 'resource-exhausted':
        return DataFailure(DataFailureType.resourceExhausted,
            description: e.message, stackTrace: s);
      case 'unavailable':
        return DataFailure(DataFailureType.unavailable,
            description: e.message, stackTrace: s);
      case 'cancelled':
        return DataFailure(DataFailureType.cancelled,
            description: e.message, stackTrace: s);
      default:
        return DataFailure(DataFailureType.requestFailed,
            description: '${e.code}: ${e.message}', stackTrace: s);
    }
  }
}

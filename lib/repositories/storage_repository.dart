import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../core/error_handling/failures/general_failure.dart';
import '../core/error_handling/failures/data_failure.dart';

/// Primitive adapter for Firebase Storage.
/// Single responsibility: file upload/download/delete.
/// Catches FirebaseException and throws typed Failures.
class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile({
    required String path,
    required Uint8List bytes,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putData(bytes);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e, s) {
      throw DataFailure(DataFailureType.uploadFailed,
          description: '${e.code}: ${e.message}', stackTrace: s);
    } catch (e, s) {
      throw GeneralFailure(
          GeneralFailureType.unexpectedError, e.toString(), s);
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
    } on FirebaseException catch (e, s) {
      throw DataFailure(DataFailureType.deleteFailed,
          description: '${e.code}: ${e.message}', stackTrace: s);
    } catch (e, s) {
      throw GeneralFailure(
          GeneralFailureType.unexpectedError, e.toString(), s);
    }
  }

  Future<List<Reference>> listFiles(String path) async {
    try {
      final result = await _storage.ref().child(path).listAll();
      return result.items;
    } on FirebaseException catch (e, s) {
      throw DataFailure(DataFailureType.requestFailed,
          description: '${e.code}: ${e.message}', stackTrace: s);
    } catch (e, s) {
      throw GeneralFailure(
          GeneralFailureType.unexpectedError, e.toString(), s);
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreFunctions {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create Document
  static Future<void> createDocument({
    required String collection,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    try {
      if (documentId != null) {
        await _firestore.collection(collection).doc(documentId).set(data);
      } else {
        await _firestore.collection(collection).add(data);
      }
    } catch (e) {
      throw 'Error creating document: $e';
    }
  }

  // Read Document
  static Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(collection)
          .doc(documentId)
          .get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw 'Error getting document: $e';
    }
  }

  // Update Document
  static Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      throw 'Error updating document: $e';
    }
  }

  // Listen to Document
  static void listenToDocument({
    required String collection,
    required String documentId,
    required Function(Map<String, dynamic>?) onData,
    Function(dynamic)? onError,
  }) {
    _firestore
        .collection(collection)
        .doc(documentId)
        .snapshots()
        .listen(
          (doc) =>
              onData(doc.exists ? doc.data() as Map<String, dynamic> : null),
          onError: onError,
        );
  }

  // Delete Document
  static Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw 'Error deleting document: $e';
    }
  }

  // Query Collection
  static Future<List<Map<String, dynamic>>> queryCollection({
    required String collection,
    String? field,
    dynamic isEqualTo,
    dynamic isGreaterThan,
    dynamic isLessThan,
    int? limit,
    String? orderBy,
    bool? descending,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      if (field != null) {
        if (isEqualTo != null) {
          query = query.where(field, isEqualTo: isEqualTo);
        }
        if (isGreaterThan != null) {
          query = query.where(field, isGreaterThan: isGreaterThan);
        }
        if (isLessThan != null) {
          query = query.where(field, isLessThan: isLessThan);
        }
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending ?? false);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final QuerySnapshot querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      throw 'Error querying collection: $e';
    }
  }

  // Stream Document
  static Stream<Map<String, dynamic>?> streamDocument({
    required String collection,
    required String documentId,
  }) {
    return _firestore
        .collection(collection)
        .doc(documentId)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() as Map<String, dynamic> : null);
  }

  // Stream Collection
  static Stream<List<Map<String, dynamic>>> streamCollection({
    required String collection,
    String? field,
    dynamic isEqualTo,
    String? orderBy,
    bool? descending,
    int? limit,
  }) {
    Query query = _firestore.collection(collection);

    if (field != null && isEqualTo != null) {
      query = query.where(field, isEqualTo: isEqualTo);
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending ?? false);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList(),
    );
  }

  // Batch Write
  static Future<void> batchWrite({
    required List<Map<String, dynamic>> operations,
  }) async {
    try {
      final WriteBatch batch = _firestore.batch();

      for (final operation in operations) {
        final String type = operation['type'];
        final String collection = operation['collection'];
        final String documentId = operation['documentId'];
        final Map<String, dynamic>? data = operation['data'];

        final DocumentReference docRef = _firestore
            .collection(collection)
            .doc(documentId);

        switch (type) {
          case 'set':
            batch.set(docRef, data!);
            break;
          case 'update':
            batch.update(docRef, data!);
            break;
          case 'delete':
            batch.delete(docRef);
            break;
          default:
            throw 'Invalid operation type: $type';
        }
      }

      await batch.commit();
    } catch (e) {
      throw 'Error in batch write: $e';
    }
  }

  // Transaction
  static Future<T> runTransaction<T>({
    required Future<T> Function(Transaction transaction) transactionHandler,
  }) async {
    try {
      return await _firestore.runTransaction(transactionHandler);
    } catch (e) {
      throw 'Error in transaction: $e';
    }
  }

  // Add Array Element
  static Future<void> arrayUnion({
    required String collection,
    required String documentId,
    required String field,
    required List<dynamic> elements,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).update({
        field: FieldValue.arrayUnion(elements),
      });
    } catch (e) {
      throw 'Error adding to array: $e';
    }
  }

  // Remove Array Element
  static Future<void> arrayRemove({
    required String collection,
    required String documentId,
    required String field,
    required List<dynamic> elements,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).update({
        field: FieldValue.arrayRemove(elements),
      });
    } catch (e) {
      throw 'Error removing from array: $e';
    }
  }

  // Increment Field
  static Future<void> incrementField({
    required String collection,
    required String documentId,
    required String field,
    required num value,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).update({
        field: FieldValue.increment(value),
      });
    } catch (e) {
      throw 'Error incrementing field: $e';
    }
  }
}

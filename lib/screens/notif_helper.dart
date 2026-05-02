import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NotifHelper — centralised notification sender that respects user prefs
//
// HOW IT WORKS:
//   Before writing to a user's notifications subcollection it fetches their
//   notifPrefs map from Firestore.  If the relevant toggle is false the write
//   is skipped.  Default is true so new accounts get all notifications.
//
// USAGE:
//   import 'notif_helper.dart';
//
//   await NotifHelper.sendNewOrder(sellerId: id, payload: {...});
//   await NotifHelper.sendNewQuestion(sellerId: id, payload: {...});
//   await NotifHelper.sendNewAnswer(askerId: id, payload: {...});
//   await NotifHelper.sendPostLike(authorId: id, payload: {...});
//   await NotifHelper.sendPostComment(authorId: id, payload: {...});
// ─────────────────────────────────────────────────────────────────────────────

class NotifHelper {
  static final _db = FirebaseFirestore.instance;

  // ── Internal: fetch prefs once, then decide ──────────────────────────────

  /// Returns the notifPrefs map for [userId].
  /// Falls back to all-true defaults if the document / field is missing.
  static Future<Map<String, dynamic>> _prefs(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      return (doc.data()?['notifPrefs'] as Map<String, dynamic>?) ?? {};
    } catch (_) {
      return {}; // network error → default to sending
    }
  }

  /// Writes [payload] to users/{recipientId}/notifications if [prefKey] is
  /// enabled (or absent — absent = true by default).
  static Future<void> _send({
    required String recipientId,
    required String prefKey,
    required Map<String, dynamic> payload,
  }) async {
    final prefs = await _prefs(recipientId);
    final enabled = prefs[prefKey] as bool? ?? true;
    if (!enabled) return; // user has this notification type turned off

    await _db
        .collection('users')
        .doc(recipientId)
        .collection('notifications')
        .add({
          ...payload,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  // ── Public senders ───────────────────────────────────────────────────────

  /// New order notification → seller.
  /// prefKey: 'orders'
  static Future<void> sendNewOrder({
    required String sellerId,
    required Map<String, dynamic> payload,
  }) => _send(recipientId: sellerId, prefKey: 'orders', payload: payload);

  /// New Q&A question → seller.
  /// prefKey: 'qa'
  static Future<void> sendNewQuestion({
    required String sellerId,
    required Map<String, dynamic> payload,
  }) => _send(recipientId: sellerId, prefKey: 'qa', payload: payload);

  /// New Q&A answer → the original question asker.
  /// prefKey: 'qa'
  static Future<void> sendNewAnswer({
    required String askerId,
    required Map<String, dynamic> payload,
  }) => _send(recipientId: askerId, prefKey: 'qa', payload: payload);

  /// Post liked → post author.
  /// prefKey: 'likes'
  static Future<void> sendPostLike({
    required String authorId,
    required Map<String, dynamic> payload,
  }) => _send(recipientId: authorId, prefKey: 'likes', payload: payload);

  /// New comment → post author.
  /// prefKey: 'comments'
  static Future<void> sendPostComment({
    required String authorId,
    required Map<String, dynamic> payload,
  }) => _send(recipientId: authorId, prefKey: 'comments', payload: payload);
}

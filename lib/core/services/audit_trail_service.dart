import 'package:petmatch/core/config/supabase_config.dart';

class AuditTrailService {
  Future<void> track({
    required String action,
    String? actorId,
    String? actorEmail,
    String? actorRole,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? metadata,
  }) async {
    final currentUser = supabase.auth.currentUser;
    final resolvedActorId = actorId ?? currentUser?.id;

    print(
        '📝 [AuditTrailService] Attempting to log action: "$action" | Actor: "$resolvedActorId" | Email: "${actorEmail ?? currentUser?.email}"');

    if (resolvedActorId == null) {
      print(
          '⚠️ [AuditTrailService] Logging skipped: resolvedActorId is null (user is not logged in / authenticated).');
      return;
    }

    try {
      await supabase.from('audit_events').insert({
        'actor_id': resolvedActorId,
        'actor_email': actorEmail ?? currentUser?.email,
        'actor_role': actorRole,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'metadata': metadata ?? <String, dynamic>{},
      });
      print(
          '✅ [AuditTrailService] Successfully logged event: "$action" to database.');
    } catch (e) {
      print('❌ [AuditTrailService] Failed to write audit event: $e');
    }
  }

  Future<void> trackButtonClick({
    required String buttonLabel,
    String? actorId,
    String? actorEmail,
    String? actorRole,
    String? screen,
    Map<String, dynamic>? metadata,
  }) {
    return track(
      action: 'button_clicked',
      actorId: actorId,
      actorEmail: actorEmail,
      actorRole: actorRole,
      entityType: 'button',
      entityId: buttonLabel,
      metadata: {
        ...?metadata,
        'button_label': buttonLabel,
        if (screen != null) 'screen': screen,
      },
    );
  }
}

final auditTrailService = AuditTrailService();

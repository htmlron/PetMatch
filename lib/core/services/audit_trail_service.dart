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

    if (resolvedActorId == null) {
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
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Failed to write audit event: $e');
    }
  }
}

final auditTrailService = AuditTrailService();
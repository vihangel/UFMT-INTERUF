import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _c;
  ProfileService(this._c);

  Future<void> chooseAthletic(String athleticId) async {
    final uid = _c.auth.currentUser!.id;
    await _c
        .from('profiles')
        .update({
          'selected_athletic_id': athleticId,
          'accepted_terms_at': DateTime.now().toIso8601String(),
        })
        .eq('id', uid);
  }

  Future<Map<String, dynamic>?> getMyProfile() async {
    final uid = _c.auth.currentUser!.id;
    return await _c.from('profiles').select().eq('id', uid).maybeSingle();
  }
}

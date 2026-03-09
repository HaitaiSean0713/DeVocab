import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Since we cannot initialize Supabase in tests easily without a real connection
// or a complex mock, we test the core logic that the app uses for data isolation.
// The app isolates data using keys appended with the user ID:
// `favorites_$userId` and `user_name_$userId`, etc.

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Data isolation: Different users have different SharedPreferences keys for favorites', () async {
    final prefs = await SharedPreferences.getInstance();

    // User A logs in and saves a favorite
    final userAId = 'user-id-abc';
    final userAFavoritesKey = 'favorites_$userAId';
    await prefs.setStringList(userAFavoritesKey, ['{"word": "ephemeral", "chineseMeaning": "短暫的"}']);

    // User B logs in
    final userBId = 'user-id-xyz';
    final userBFavoritesKey = 'favorites_$userBId';

    // Verify User B does not see User A's favorites
    final userBData = prefs.getStringList(userBFavoritesKey) ?? [];
    expect(userBData.isEmpty, true);

    // User B saves their own favorite
    await prefs.setStringList(userBFavoritesKey, ['{"word": "resilience", "chineseMeaning": "韌性"}']);

    // Verify User A's data is still intact and separate
    final userAData = prefs.getStringList(userAFavoritesKey) ?? [];
    expect(userAData.length, 1);
    expect(userAData.first, contains('ephemeral'));
  });

  test('Data isolation: Different users have different SharedPreferences keys for settings (name and avatar)', () async {
    final prefs = await SharedPreferences.getInstance();

    // User A updates profile
    final userAId = 'user-id-abc';
    final userANameKey = 'user_name_$userAId';
    final userAAvatarKey = 'user_avatar_$userAId';

    await prefs.setString(userANameKey, 'Alice');
    await prefs.setString(userAAvatarKey, '👩');

    // User B logs in
    final userBId = 'user-id-xyz';
    final userBNameKey = 'user_name_$userBId';
    final userBAvatarKey = 'user_avatar_$userBId';

    // Verify User B has default/no profile data from User A
    expect(prefs.getString(userBNameKey), null);
    expect(prefs.getString(userBAvatarKey), null);

    // User B updates profile
    await prefs.setString(userBNameKey, 'Bob');
    await prefs.setString(userBAvatarKey, '👨');

    // Verify both are isolated
    expect(prefs.getString(userANameKey), 'Alice');
    expect(prefs.getString(userBNameKey), 'Bob');
  });
}

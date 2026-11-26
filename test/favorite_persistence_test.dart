import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tapefit/data/favorite_repository.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('T-38 즐겨찾기를 저장하면 새 저장소 객체(앱 재시작)에서도 남아 있다', () async {
    await PersistentFavoriteRepository().setFavorite('ankle_instability', true);

    final reloaded = await PersistentFavoriteRepository().loadFavorites();
    expect(reloaded, {'ankle_instability'});
  });

  test('T-39 즐겨찾기를 해제하면 저장소에서도 사라진다', () async {
    final repo = PersistentFavoriteRepository();
    await repo.setFavorite('ankle_instability', true);
    await repo.setFavorite('ankle_instability', false);

    expect(await PersistentFavoriteRepository().loadFavorites(), isEmpty);
  });
}

import 'package:lexcore/features/profile/domain/entities/profile_summary.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/services/mock/mock_legal_repository.dart';

class ProfileRepository {
  const ProfileRepository(this._mock);

  final MockLegalRepository _mock;

  ProfileSummary summary() {
    return const ProfileSummary(
      name: 'LexCore 用户',
      role: '个人法律顾问',
      phone: '138****2601',
      email: 'lexcore_user@example.com',
      membership: 'PRO 会员',
      nextBillingDate: '2024年12月1日',
      benefits: ['无限次智能对话次数', '优先访问 GPT-4 模型'],
    );
  }

  List<ProfileMenuItem> menus() => _mock.profileMenus();
}

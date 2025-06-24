import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 配對偏好設定狀態管理
final matchingPreferencesProvider = StateNotifierProvider<MatchingPreferencesNotifier, MatchingPreferences>((ref) {
  return MatchingPreferencesNotifier();
});

class MatchingPreferences {
  final int minAge;
  final int maxAge;
  final int maxDistance;
  final List<String> preferredGenders;
  final List<String> dealBreakers;
  final List<String> mustHaves;
  final List<String> preferredInterests;
  final String relationshipGoal;
  final bool prioritizeMBTI;
  final bool prioritizeInterests;
  final bool prioritizeLocation;
  final bool showOnlyVerifiedUsers;
  final bool enableSmartRecommendations;
  final String datingMode;
  final List<String> preferredEducationLevels;
  final List<String> preferredLifestyles;

  MatchingPreferences({
    this.minAge = 18,
    this.maxAge = 35,
    this.maxDistance = 50,
    this.preferredGenders = const ['女性'],
    this.dealBreakers = const [],
    this.mustHaves = const [],
    this.preferredInterests = const [],
    this.relationshipGoal = '長期關係',
    this.prioritizeMBTI = true,
    this.prioritizeInterests = true,
    this.prioritizeLocation = false,
    this.showOnlyVerifiedUsers = false,
    this.enableSmartRecommendations = true,
    this.datingMode = 'serious',
    this.preferredEducationLevels = const [],
    this.preferredLifestyles = const [],
  });

  MatchingPreferences copyWith({
    int? minAge,
    int? maxAge,
    int? maxDistance,
    List<String>? preferredGenders,
    List<String>? dealBreakers,
    List<String>? mustHaves,
    List<String>? preferredInterests,
    String? relationshipGoal,
    bool? prioritizeMBTI,
    bool? prioritizeInterests,
    bool? prioritizeLocation,
    bool? showOnlyVerifiedUsers,
    bool? enableSmartRecommendations,
    String? datingMode,
    List<String>? preferredEducationLevels,
    List<String>? preferredLifestyles,
  }) {
    return MatchingPreferences(
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      maxDistance: maxDistance ?? this.maxDistance,
      preferredGenders: preferredGenders ?? this.preferredGenders,
      dealBreakers: dealBreakers ?? this.dealBreakers,
      mustHaves: mustHaves ?? this.mustHaves,
      preferredInterests: preferredInterests ?? this.preferredInterests,
      relationshipGoal: relationshipGoal ?? this.relationshipGoal,
      prioritizeMBTI: prioritizeMBTI ?? this.prioritizeMBTI,
      prioritizeInterests: prioritizeInterests ?? this.prioritizeInterests,
      prioritizeLocation: prioritizeLocation ?? this.prioritizeLocation,
      showOnlyVerifiedUsers: showOnlyVerifiedUsers ?? this.showOnlyVerifiedUsers,
      enableSmartRecommendations: enableSmartRecommendations ?? this.enableSmartRecommendations,
      datingMode: datingMode ?? this.datingMode,
      preferredEducationLevels: preferredEducationLevels ?? this.preferredEducationLevels,
      preferredLifestyles: preferredLifestyles ?? this.preferredLifestyles,
    );
  }
}

class MatchingPreferencesNotifier extends StateNotifier<MatchingPreferences> {
  MatchingPreferencesNotifier() : super(MatchingPreferences());

  void updateAgeRange(int minAge, int maxAge) {
    state = state.copyWith(minAge: minAge, maxAge: maxAge);
  }

  void updateMaxDistance(int distance) {
    state = state.copyWith(maxDistance: distance);
  }

  void updatePreferredGenders(List<String> genders) {
    state = state.copyWith(preferredGenders: genders);
  }

  void updateRelationshipGoal(String goal) {
    state = state.copyWith(relationshipGoal: goal);
  }

  void updateDatingMode(String mode) {
    state = state.copyWith(datingMode: mode);
  }

  void updatePrioritizeMBTI(bool value) {
    state = state.copyWith(prioritizeMBTI: value);
  }

  void updatePrioritizeInterests(bool value) {
    state = state.copyWith(prioritizeInterests: value);
  }

  void updatePrioritizeLocation(bool value) {
    state = state.copyWith(prioritizeLocation: value);
  }

  void updateShowOnlyVerifiedUsers(bool value) {
    state = state.copyWith(showOnlyVerifiedUsers: value);
  }

  void updateSmartRecommendations(bool value) {
    state = state.copyWith(enableSmartRecommendations: value);
  }

  void toggleDealBreaker(String item) {
    final currentList = List<String>.from(state.dealBreakers);
    if (currentList.contains(item)) {
      currentList.remove(item);
    } else {
      currentList.add(item);
    }
    state = state.copyWith(dealBreakers: currentList);
  }

  void toggleMustHave(String item) {
    final currentList = List<String>.from(state.mustHaves);
    if (currentList.contains(item)) {
      currentList.remove(item);
    } else {
      currentList.add(item);
    }
    state = state.copyWith(mustHaves: currentList);
  }

  void togglePreferredInterest(String interest) {
    final currentList = List<String>.from(state.preferredInterests);
    if (currentList.contains(interest)) {
      currentList.remove(interest);
    } else {
      currentList.add(interest);
    }
    state = state.copyWith(preferredInterests: currentList);
  }
}

class MatchingPreferencesPage extends ConsumerWidget {
  const MatchingPreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          '配對偏好設定',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE91E63),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => _savePreferences(context),
            child: const Text(
              '保存',
              style: TextStyle(
                color: Color(0xFFE91E63),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              size: 64,
              color: Color(0xFFE91E63),
            ),
            SizedBox(height: 16),
            Text(
              '配對偏好設定',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '功能開發中...',
              style: TextStyle(
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _savePreferences(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('配對偏好已保存'),
        backgroundColor: Color(0xFF38A169),
      ),
    );
    Navigator.pop(context);
  }
} 
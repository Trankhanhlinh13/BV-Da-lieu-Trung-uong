import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../mock/mock_data.dart';
import '../../models/family_member.dart';

class FamilyMembersController extends Notifier<List<FamilyMember>> {
  @override
  List<FamilyMember> build() => [
        FamilyMember(
          id: 'owner',
          name: MockData.user.name,
          phone: MockData.user.phone,
          birthDate: MockData.user.birthDate,
          gender: MockData.user.gender,
          relationship: 'Chủ tài khoản',
          isOwner: true,
        ),
        for (var index = 0; index < MockData.familyMembers.length; index++)
          FamilyMember(
            id: 'mock-family-$index',
            name: MockData.familyMembers[index].name,
            phone: MockData.familyMembers[index].phone,
            birthDate: MockData.familyMembers[index].birthDate,
            gender: MockData.familyMembers[index].gender,
            relationship: 'Người thân',
          ),
      ];

  void addMember(FamilyMember member) {
    state = [...state, member];
  }

  void updateMember(FamilyMember member) {
    state = [
      for (final current in state)
        if (current.id == member.id) member else current,
    ];
  }

  void removeMember(String id) {
    state = state.where((member) => member.id != id || member.isOwner).toList();
  }
}

final familyMembersProvider =
    NotifierProvider<FamilyMembersController, List<FamilyMember>>(
  FamilyMembersController.new,
);

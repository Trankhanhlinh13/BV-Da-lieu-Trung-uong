class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.name,
    required this.phone,
    required this.birthDate,
    required this.gender,
    required this.relationship,
    this.identityNumber = '',
    this.isOwner = false,
  });

  final String id;
  final String name;
  final String phone;
  final DateTime birthDate;
  final String gender;
  final String relationship;
  final String identityNumber;
  final bool isOwner;

  FamilyMember copyWith({
    String? name,
    String? phone,
    DateTime? birthDate,
    String? gender,
    String? relationship,
    String? identityNumber,
  }) =>
      FamilyMember(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        birthDate: birthDate ?? this.birthDate,
        gender: gender ?? this.gender,
        relationship: relationship ?? this.relationship,
        identityNumber: identityNumber ?? this.identityNumber,
        isOwner: isOwner,
      );
}

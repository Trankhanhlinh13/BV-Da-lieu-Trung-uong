class UserProfile {
  const UserProfile({required this.name, required this.phone, required this.birthDate, required this.gender, this.avatarAsset, this.isOwner = true});
  final String name;
  final String phone;
  final DateTime birthDate;
  final String gender;
  final String? avatarAsset;
  final bool isOwner;
}

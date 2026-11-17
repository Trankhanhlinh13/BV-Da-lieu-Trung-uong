import 'package:flutter/material.dart';
class AppSearchField extends StatelessWidget {
  const AppSearchField({super.key, this.hint = 'Tìm kiếm', this.onChanged}); final String hint; final ValueChanged<String>? onChanged;
  @override Widget build(BuildContext context) => TextField(onChanged: onChanged, decoration: InputDecoration(hintText: hint, prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white));
}

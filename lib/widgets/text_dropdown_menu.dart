import 'package:flutter/material.dart';
import 'package:usper/constants/colors_constants.dart';

class TextDropdownMenu<T extends Object> extends StatelessWidget {
  final String label;
  final Function(T) onSelectedCallback;
  final List<DropdownMenuEntry<T>> dropdownEntries;
  final double width;

  TextDropdownMenu.fromList(
      {super.key,
      required List<String> values,
      required this.label,
      required this.onSelectedCallback,
      this.width = 140})
      : dropdownEntries = values
            .map<DropdownMenuEntry<T>>(
              (String value) => DropdownMenuEntry<T>(
                value: value as T,
                style: const ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(white)),
                label: value,
              ),
            )
            .toList();

  TextDropdownMenu.fromMap(
      {super.key,
      required Map<int, String> values,
      required this.label,
      required this.onSelectedCallback,
      this.width = 140})
      : dropdownEntries = values.entries
            .map<DropdownMenuEntry<T>>(
              (entry) => DropdownMenuEntry<T>(
                value: entry.key as T,
                style: const ButtonStyle(
                  foregroundColor: MaterialStatePropertyAll(white),
                ),
                label: entry.value,
              ),
            )
            .toList();

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      initialSelection: dropdownEntries.first.value,
      label: Text(label),
      width: width,
      onSelected: (T? value) {
        if (value != null) {
          onSelectedCallback(value);
        }
      },
      textStyle: const TextStyle(color: white),
      dropdownMenuEntries: dropdownEntries,
      menuHeight: 250,
      menuStyle: const MenuStyle(
          backgroundColor: MaterialStatePropertyAll(Colors.black)),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: white),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        constraints: BoxConstraints.tight(const Size.fromHeight(40)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

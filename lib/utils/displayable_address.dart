String displayableAddress(Map<String, dynamic> addressData) {
  String road = addressData['road'] ?? '';
  String houseNumber = addressData['house_number'] ?? '';
  String suburb = addressData['suburb'] ?? '';
  String city = addressData['city'] ?? '';

  String address = '';

  if (road.isNotEmpty) {
    address += road;
  }

  if (houseNumber.isNotEmpty) {
    if (address.isNotEmpty) {
      address += ", ";
    }
    address += houseNumber;
  }

  if (suburb.isNotEmpty) {
    if (address.isNotEmpty) {
      address += " - ";
    }
    address += suburb;
  }

  if (city.isNotEmpty) {
    if (address.isNotEmpty) {
      address += " - ";
    }
    address += city;
  }

  if (address.isNotEmpty) {
    return address;
  }

  List<String> nonNullParts = addressData.entries
      .where(
          (entry) => entry.value != null && entry.value.toString().isNotEmpty)
      .map((entry) => entry.value.toString())
      .toList();

  return nonNullParts.isNotEmpty
      ? nonNullParts.join(', ')
      : 'Endereço não disponível';
}

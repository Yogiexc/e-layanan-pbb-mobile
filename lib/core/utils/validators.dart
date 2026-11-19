class AppValidators {
  static String? validateNik(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'NIK wajib diisi';
    }
    final trimmed = value.trim();
    final regExp = RegExp(r'^[0-9]{16}$');
    if (!regExp.hasMatch(trimmed)) {
      return 'NIK harus tepat 16 digit angka';
    }
    return null;
  }

  static String? validateNpwp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // NPWP opsional sesuai PRD
    }
    final clean = value.replaceAll(RegExp(r'[\.\-]'), '').trim();
    if (clean.length != 15 && clean.length != 16) {
      return 'NPWP harus 15 atau 16 digit angka';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(clean)) {
      return 'NPWP hanya boleh berisi angka';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon wajib diisi';
    }
    final trimmed = value.trim();
    final regExp = RegExp(r'^\+?[0-9]{8,15}$');
    if (!regExp.hasMatch(trimmed)) {
      return 'Nomor telepon harus 8-15 digit (boleh diawali +)';
    }
    return null;
  }

  static String? validatePostalCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kode pos wajib diisi';
    }
    if (!RegExp(r'^[0-9]{5}$').hasMatch(value.trim())) {
      return 'Kode pos harus 5 digit angka';
    }
    return null;
  }

  static String? validateRtRw(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    if (!RegExp(r'^[0-9]{1,3}$').hasMatch(value.trim())) {
      return '$fieldName harus 1-3 digit angka';
    }
    return null;
  }

  static String maskNik(String? nik) {
    if (nik == null || nik.length < 8) return nik ?? '-';
    // Format masker: 3372********0001
    final first = nik.substring(0, 4);
    final last = nik.substring(nik.length - 4);
    return '$first********$last';
  }
}

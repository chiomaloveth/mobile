class ElectricityVerificationModel {
  final String customerName;
  final String meterNumber;
  final String customerAddress;
  final bool isSuccess;

  ElectricityVerificationModel({
    required this.customerName,
    required this.meterNumber,
    required this.customerAddress,
    required this.isSuccess,
  });

  factory ElectricityVerificationModel.fromJson(Map<String, dynamic> json) {
    try {
      final firstData = json['data'] as Map<String, dynamic>?;
      final secondData = firstData?['data'] as Map<String, dynamic>?;
      final thirdData = secondData?['data'] as Map<String, dynamic>?;

      if (thirdData != null) {
        return ElectricityVerificationModel(
          customerName: thirdData['customer_name']?.toString() ?? '',
          meterNumber: thirdData['meter_number']?.toString() ?? '',
          customerAddress: thirdData['customer_address']?.toString() ?? '',
          isSuccess: secondData?['code'] == 'success',
        );
      }
    } catch (e) {
      // If anything fails during parsing, we catch it here gracefully
      print("Error parsing model: $e");
    }

    return ElectricityVerificationModel(
      customerName: '',
      meterNumber: '',
      customerAddress: '',
      isSuccess: false,
    );
  }
}
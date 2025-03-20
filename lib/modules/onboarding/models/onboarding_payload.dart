// import 'package:app/modules/organization/models/organization_type.dart';

class OnboardingPayload {
  final String organizationName;
  // final OrganizationType? organizationType;

  const OnboardingPayload({
    required this.organizationName,
    // this.organizationType = OrganizationType.home,
  });

  Map<String, dynamic> toJson() => {
    'organization_name': organizationName,
    // 'organization_type': organizationType?.name,
  };
} 
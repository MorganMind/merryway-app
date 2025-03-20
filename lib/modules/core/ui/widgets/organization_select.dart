// import 'package:app/modules/core/theme/theme_extension.dart';
// import 'package:app/modules/core/ui/widgets/m_select.dart';
// import 'package:app/modules/organization/blocs/organization_bloc.dart';
// import 'package:app/modules/organization/blocs/organization_event.dart';
// import 'package:app/modules/organization/blocs/organization_state.dart';
// import 'package:app/modules/organization/models/organization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shadcn_ui/shadcn_ui.dart';

// class OrganizationSelect extends StatelessWidget {
//   const OrganizationSelect({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.appTheme;
    
//     return BlocBuilder<OrganizationBloc, OrganizationState>(
//       builder: (context, state) {
//         if (state.organizations.isEmpty) return const SizedBox.shrink();

//         final sortedOrgs = List<Organization>.from(state.organizations)
//           ..sort((a, b) => a.createdAt?.compareTo(b.createdAt ?? DateTime.now()) ?? 0);

//         return SizedBox(
//           width: 200,
//           child: MSelect<Organization>(
//             icon: LucideIcons.layoutGrid,
//             placeholder: 'Select organization',
//             initialValue: state.currentOrganization,
//             boxShadow: false,
//             border: false,
//             onChanged: (org) {
//               if (org != null) {
//                 context.read<OrganizationBloc>().add(SetCurrentOrganization(org.id));
//               }
//             },
//             options: sortedOrgs.map((org) => 
//               ShadOption(
//                 value: org,
//                 child: Text(
//                   org.name,
//                   style: TextStyle(
//                     color: colors.mutedForeground,
//                   ),
//                 ),
//               )
//             ).toList(),
//             selectedOptionBuilder: (context, org) {
//               return Text(
//                 org.name,
//                 style: TextStyle(
//                   color: colors.mutedForeground,
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// } 
// import 'package:app/modules/core/blocs/layout_bloc.dart';
// import 'package:app/modules/core/blocs/layout_state.dart';
// import 'package:app/modules/core/di/service_locator.dart';
// import 'package:app/modules/core/theme/theme_extension.dart';
// import 'package:app/modules/core/ui/widgets/m_content_card.dart';
// import 'package:app/modules/organization/blocs/organization_bloc.dart';
// import 'package:app/modules/organization/blocs/organization_state.dart';
// import 'package:app/modules/organization/models/organization_role.dart';
// import 'package:app/modules/organization/models/organization_type.dart';
// import 'package:app/modules/organization/widgets/invite_organization_members_modal.dart';
// import 'package:app/modules/user/repositories/user_repository.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shadcn_ui/shadcn_ui.dart';
// import 'package:app/modules/organization/blocs/manage_organizations_bloc.dart';
// import 'package:app/modules/organization/blocs/manage_organizations_state.dart';
// import 'package:app/modules/organization/blocs/manage_organizations_event.dart';
// import 'package:app/modules/organization/widgets/organization_members_list.dart';
// import 'package:app/modules/organization/widgets/create_organization_modal.dart';
// import 'package:collection/collection.dart';

// class GroupsPage extends StatelessWidget {
//   const GroupsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => ManageOrganizationsBloc(),
//       child: const _GroupsPageContent(),
//     );
//   }
// }

// class _GroupsPageContent extends StatelessWidget {
//   const _GroupsPageContent();

//   @override
//   Widget build(BuildContext context) {
//     final theme = ShadTheme.of(context);
//     final colors = context.appTheme;
//     final isMobile = sl<LayoutBloc>().state.layoutType == LayoutType.mobile;

//     return Align(
//       alignment: Alignment.topLeft,
//       child: Padding(
//         padding: isMobile ? const EdgeInsets.all(12.0) : const EdgeInsets.all(24.0),
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: double.infinity),
//           child: SingleChildScrollView(
//             child: BlocBuilder<ManageOrganizationsBloc, ManageOrganizationsState>(
//               builder: (context, manageState) {
//                 return BlocBuilder<OrganizationBloc, OrganizationState>(
//                   builder: (context, orgState) {
//                     if (orgState.isLoading) {
//                       return const Center(child: CircularProgressIndicator());
//                     }

//                     return Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Header (changes based on view)
//                         if (manageState.selectedOrganization != null) ...[
//                           Row(
//                             children: [
//                               IconButton(
//                                 icon: const Icon(Icons.arrow_back),
//                                 onPressed: () {
//                                   context.read<ManageOrganizationsBloc>()
//                                     .add(ClearSelectedOrganization());
//                                 },
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       manageState.selectedOrganization!.name,
//                                       style: theme.textTheme.h3.copyWith(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w600,
//                                         color: colors.foreground,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       'Invite and manage your family or team members',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: colors.mutedForeground,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ] else ...[
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Groups',
//                                       style: theme.textTheme.h3.copyWith(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w600,
//                                         color: colors.foreground,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       'Manage your organization settings and members',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: colors.mutedForeground,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               ShadButton(
//                                 onPressed: () {
//                                   final isDesktop = sl<LayoutBloc>().state.layoutType == LayoutType.desktop;
//                                   if (isDesktop) {
//                                     showDialog(
//                                       context: context,
//                                       builder: (context) => const CreateOrganizationModal(),
//                                     );
//                                   } else {
//                                     showModalBottomSheet(
//                                       context: context,
//                                       isScrollControlled: true,
//                                       useRootNavigator: true,
//                                       builder: (context) => const CreateOrganizationModal(),
//                                     );
//                                   }
//                                 },
//                                 backgroundColor: colors.primary,
//                                 foregroundColor: colors.primaryForeground,
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(
//                                       Icons.add_circle_outline,
//                                       size: 16,
//                                       color: colors.primaryForeground,
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Text(
//                                       'Create New Group',
//                                       style: TextStyle(color: colors.primaryForeground),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                         const SizedBox(height: 24),

//                         if (manageState.selectedOrganization != null) ...[
//                           // Better Together Section
//                           if (manageState.isLoadingMembers)
//                             const Center(child: CircularProgressIndicator())
//                           else ...[
//                             // Only show for non-member roles
//                             if (manageState.members
//                                 .firstWhereOrNull((m) => 
//                                   m.userId == sl<UserRepository>().userData!.id && 
//                                   m.role != OrganizationRole.member) != null) 
//                               ShadCard(
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(0),
//                                   child: Row(
//                                     children: [
//                                       Icon(
//                                         LucideIcons.send,
//                                         size: 24,
//                                         color: colors.foreground,
//                                       ),
//                                       const SizedBox(width: 16),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               'Better together',
//                                               style: theme.textTheme.h4.copyWith(
//                                                 color: colors.foreground,
//                                                 fontWeight: FontWeight.w300,
//                                                 fontSize: 16,
//                                               ),
//                                             ),
//                                             const SizedBox(height: 4),
//                                             Text(
//                                               'Invite members to collaborate with you on Morgan',
//                                               style: TextStyle(
//                                                 color: colors.mutedForeground,
//                                                 fontSize: 14,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       ShadButton(
//                                         onPressed: () {
//                                           final isDesktop = sl<LayoutBloc>().state.layoutType == LayoutType.desktop;
//                                           if (isDesktop) {
//                                             showDialog(
//                                               context: context,
//                                               builder: (context) => InviteOrganizationMembersModal(
//                                                 organizationName: manageState.selectedOrganization!.name,
//                                                 organizationId: manageState.selectedOrganization!.id,
//                                                 userId: sl<UserRepository>().userData!.id,
//                                               ),
//                                             );
//                                           } else {
//                                             showModalBottomSheet(
//                                               context: context,
//                                               isScrollControlled: true,
//                                               useRootNavigator: true,
//                                               builder: (context) => InviteOrganizationMembersModal(
//                                                 organizationName: manageState.selectedOrganization!.name,
//                                                 organizationId: manageState.selectedOrganization!.id,
//                                                 userId: sl<UserRepository>().userData!.id,
//                                               ),
//                                             );
//                                           }
//                                         },
//                                         backgroundColor: colors.primary,
//                                         foregroundColor: colors.primaryForeground,
//                                         child: Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Icon(
//                                               LucideIcons.mail,
//                                               size: 16,
//                                               color: colors.primaryForeground,
//                                             ),
//                                             const SizedBox(width: 8),
//                                             const Text('Invite new members'),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),

//                             const SizedBox(height: 24),

//                             // Members list
//                             OrganizationMembersList(
//                               members: manageState.members,
//                               isLoading: manageState.isLoadingMembers,
//                             ),
//                           ],
//                         ] else ...[
//                           // Organizations Grid
//                           if (orgState.organizations.isEmpty)
//                             Center(
//                               child: Text(
//                                 'No organizations found',
//                                 style: TextStyle(color: colors.mutedForeground),
//                               ),
//                             )
//                           else
//                             Wrap(
//                               spacing: 24,
//                               runSpacing: 24,
//                               children: [...orgState.organizations]
//                                 .sorted((a, b) { 
//                                   // Then sort by creation date ascending
//                                   return a.createdAt?.compareTo(b.createdAt ?? DateTime.now()) ?? 0;
//                                 })
//                                 .map((org) {
//                                   return MContentCard(
//                                     size: const Size(200, 256),
//                                     imageUrl: org.imageUrl,
//                                     defaultIcon: LucideIcons.users,
//                                     title: org.name,
//                                     subtitle: org.type == OrganizationType.home 
//                                         ? 'Personal Group' 
//                                         : 'Professional Group',
//                                     onPressed: () {
//                                       context.read<ManageOrganizationsBloc>()
//                                         .add(SelectOrganization(org));
//                                     },
//                                   );
//                                 }).toList(),
//                             ),
//                         ],
//                       ],
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// } 
import 'package:app/modules/core/blocs/layout_bloc.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:app/modules/core/theme/theme_extension.dart';

class HomeLayout extends StatefulWidget {
  final Widget child;

  const HomeLayout({
    super.key,
    required this.child,
  });

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> with SingleTickerProviderStateMixin {
  final layoutBloc = sl<LayoutBloc>();
 
  @override
  Widget build(BuildContext context) {
    final colors = context.appTheme;

    return SizedBox.expand(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: colors.background,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
} 
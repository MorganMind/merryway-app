import 'package:app/modules/core/blocs/layout_bloc.dart';
import 'package:app/modules/core/blocs/layout_event.dart';
import 'package:app/modules/core/blocs/layout_state.dart';
import 'package:app/modules/core/di/service_locator.dart';
import 'package:app/modules/home/widgets/action_cards.dart';
import 'package:app/modules/home/widgets/feed_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _items = List.generate(20, (i) => 'Item ${i + 1}'); // Initial items
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // TODO: Get router based show/hide to work

    final layoutBloc = sl<LayoutBloc>();

    if (layoutBloc.state.layoutType == LayoutType.mobile) {
      layoutBloc.add(SetSidebarVisibility(true));
      layoutBloc.add(SetHeaderVisibility(true));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length + 1,
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return _buildLoadingIndicator();
        }

        // Example of different card types
        if (index % 2 == 0) {
          return FeedCard(
            agentName: 'Lorem',
            message: "I came a long way.",
            date: DateTime.now(),
            agentIcon: Icons.diamond_outlined,
            actionCard: const UpdateScheduleCard(),
          );
        } else {
          return FeedCard(
            agentName: 'Ipsum',
            message: "I never left.",
            date: DateTime.now(),
            agentIcon: Icons.lightbulb_outline,
            actionCard: const ProgressCard(
              title: 'Progress Today',
              progress: 0.76,
            ),
          );
        }
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return _isLoading
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
        : const SizedBox();
  }
} 
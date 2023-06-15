import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:type_racer/fetures/game/widgets/game_text_feild.dart';
import 'package:type_racer/providers/client_state_provider.dart';
import 'package:type_racer/utils/socket_methods.dart';

import '../../../providers/game_state_provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final SocketMethods _socketMethods = SocketMethods();

  @override
  void initState() {
    super.initState();
    _socketMethods.updateTimer(context);
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameStateProvider>(context);
    final clientStateProvider = Provider.of<ClientStateProvider>(context);
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          children: [
            Text(
              clientStateProvider.clientState['timer']['msg'].toString(),
            ),
            Text(
              clientStateProvider.clientState['timer']['countDown'].toString(),
            )
          ],
        ),
      )),
      bottomNavigationBar: const GameTextField(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:type_racer/providers/client_state_provider.dart';
import 'package:type_racer/providers/game_state_provider.dart';
import 'package:type_racer/utils/socket_client.dart';

class SocketMethods {
  final _socketClient = SocketClient.instance.socket!;
  // create game

  createGame(String nickname) {
    try {
      if (nickname.isNotEmpty) {
        _socketClient.emit('create-game', {
          'nickname': nickname,
        });
      }
    } catch (e) {
      print(e);
    }
  }

  //join game

  joinGame(String gameId, String nickname) {
    try {
      if (nickname.isNotEmpty && gameId.isNotEmpty) {
        _socketClient.emit('join-game', {
          'nickname': nickname,
          'gameId': gameId,
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // listeners
  updateGameListener(BuildContext context) {
    _socketClient.on('updateGame', (data) {
      final gameStateProvider =
          Provider.of<GameStateProvider>(context, listen: false)
              .updateGameState(
        id: data['_id'],
        players: data['players'],
        isJoin: data['isJoin'],
        words: data['words'],
        isOver: data['isOver'],
      );

      if (data['_id'].isNotEmpty) {
        Navigator.pushNamed(context, '/game-screen');
      }
    });
  }

  startTimer(playerId, gameID) {
    _socketClient.emit(
      'timer',
      {
        'playerId': playerId,
        'gameID': gameID,
      },
    );
  }

  notCorrectGameListener(BuildContext context) {
    _socketClient.on(
      'notCorrectGame',
      (data) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data),
        ),
      ),
    );
  }

  updateTimer(BuildContext context) {
    final clientStateProvider =
        Provider.of<ClientStateProvider>(context, listen: false);

    _socketClient.on('timer', (data) {
      clientStateProvider.setClientState(data);
    });
  }
}

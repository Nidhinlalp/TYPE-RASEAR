import 'package:flutter/material.dart';
import 'package:type_racer/utils/socket_methods.dart';

import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_textfeild.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _gamaIdController = TextEditingController();
  final SocketMethods _socketMethods = SocketMethods();

  @override
  void initState() {
    super.initState();
    _socketMethods.updateGameListener(context);
    _socketMethods.notCorrectGameListener(context);
  }

  @override
  void dispose() {
    super.dispose();
    _gamaIdController.dispose();
    _nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Join Room',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                SizedBox(height: size.height * 0.08),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Enter your nickname',
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _gamaIdController,
                  hintText: 'Enter Game id',
                ),
                const SizedBox(height: 50),
                CustomButton(
                  text: 'Join',
                  onTap: () => _socketMethods.joinGame(
                    _gamaIdController.text,
                    _nameController.text,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

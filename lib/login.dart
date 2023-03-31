import 'package:chat_gpt_4/chat.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _controller = TextEditingController();
  bool hidePassword = true;
  String password = "";

  @override
  Widget build(BuildContext context) {
    String chrisKey =
        "b07f62df59a21bcd61d18d3a4b90635332811868c04aed89f78ac23050d023b0";
    String milesKey = "8d365020dcba534614e5ce77b39c28f20baf1a0840eacc3e2c6af722696801f4";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _controller,
                onChanged: (val) => setState(() => password = val),
                obscureText: hidePassword,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Enter the secret password',
                  suffixIcon: IconButton(onPressed: () => setState(() => hidePassword = !hidePassword), icon: Icon(hidePassword ? Icons.visibility : Icons.visibility_off))
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Convert input string to bytes
                List<int> inputBytes = utf8.encode(password);
                // Hash bytes using SHA-256
                Digest digest = sha256.convert(inputBytes);
                // Convert digest to hex string
                String hashString = digest.toString();

                if (hashString == milesKey || hashString == chrisKey) {
                  String user = hashString == milesKey ? "miles" : "chris";
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(user)));
                } else {
                  const snackBar = SnackBar(
                    content: Text('Wrong password.'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);

                  _controller.clear();
                }
              },
              child: Text("Submit"),
            )
          ],
        ),
      ),
    );
  }
}

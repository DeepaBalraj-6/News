import 'package:flutter/material.dart';
import 'main.dart'; // Make sure to import this to call MyApp.of(context)?.toggleTheme

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isDarkTheme = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
    child:Column(
      children: [
        const SizedBox(height: 20),
        Center(
          child: CircleAvatar(
            radius: 50,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'User Name',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        ),
        const Divider(height: 40, thickness: 1),
        ListTile(
          leading: const Icon(Icons.bookmark),
          title: const Text('Saved News'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Account'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {},
        ),
        SwitchListTile(
          secondary: const Icon(Icons.brightness_6),
          title: const Text('Dark Theme'),
          value: isDarkTheme,
          onChanged: (value) {
            setState(() {
              isDarkTheme = value;
            });
            MyApp.of(context)?.toggleTheme(value);
          },
        ),
      ],
    ),
    ),
      ),
    );
  }
}

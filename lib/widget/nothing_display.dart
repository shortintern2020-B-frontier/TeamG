import 'package:flutter/material.dart';

// import '../const.dart';

class NothingDisplay extends StatelessWidget {
  const NothingDisplay();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: const Text('該当するユーザーがいません'),
      ),
    );
  }
}

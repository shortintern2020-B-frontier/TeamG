import 'package:flutter/material.dart';

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

class CannotSelect extends StatelessWidget {
  const CannotSelect();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: const Text(
          '選択できる授業がありません\n授業を登録してください',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

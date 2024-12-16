import 'package:flutter/cupertino.dart';
import 'quiz.dart';

void main() {
  runApp(const CupertinoApp(
    debugShowCheckedModeBanner: false,
    title: 'Adivinhe a Bandeira',
    home: FirstRoute(),
  ));
}

class FirstRoute extends StatelessWidget {
  const FirstRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Color(0xFF042940),
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: Color(0xFF005C53),
        middle: Text(
          'Adivinhe a Bandeira',
          style: TextStyle(color: Color(0xFFDBF227)),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Selecione o Tempo do Jogo:',
              style: TextStyle(fontSize: 20, color: Color(0xFFDBF227)),
            ),
            const SizedBox(height: 20),
            for (var duration in [30, 60, 180, 300])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CupertinoButton(
                  color: Color(0xFF9FC131),
                  borderRadius: BorderRadius.circular(90),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => SecondRoute(duration: duration),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: 150,
                    child: Center(
                      child: Text(
                        '$duration segundos',
                        style: const TextStyle(color: CupertinoColors.white),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

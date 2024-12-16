import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:convert';
import 'dart:math';

class SecondRoute extends StatefulWidget {
  final int duration;
  const SecondRoute({super.key, required this.duration});

  @override
  _SecondRouteState createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  late Timer _timer;
  int _timeRemaining = 0;
  bool _gameStarted = false;
  int _score = 0;
  int _questionsAnswered = 0;
  List<Map<String, String>> _countries = [];
  Map<String, String> _currentCountry = {};
  List<Map<String, String>> _options = [];
  Map<String, Color> _buttonColors = {};

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.duration;
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    final String response = await rootBundle.loadString('assets/paises.json');
    final data = json.decode(response) as Map<String, dynamic>;
    final paises = data['paises'] as List<dynamic>;
    _countries = paises.map((pais) {
      return {
        'nome': pais['nome'].toString(),
        'bandeira': pais['bandeira'].toString(),
      };
    }).toList();
    _setNextQuestion();
  }

  void _setNextQuestion() {
    if (_countries.isEmpty) return;
    _currentCountry = _countries[Random().nextInt(_countries.length)];
    _options = List.from(_countries)..shuffle();
    _options = _options.take(4).toList();
    if (!_options.any((option) => option['nome'] == _currentCountry['nome'])) {
      _options[Random().nextInt(4)] = _currentCountry;
    }
    _options.shuffle();
    _buttonColors = {
      for (var option in _options) option['nome']!: Color(0xFF9FC131)
    };
    setState(() {});
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _endGame();
        }
      });
    });
  }

  void _endGame() {
    _timer.cancel();
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Tempo Esgotado!'),
        content: Text(
          'Você acertou $_score de $_questionsAnswered perguntas.\nPorcentagem: ${((_score / _questionsAnswered) * 100).toStringAsFixed(1)}%',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
    );
  }

  void _answerQuestion(String selectedCountry) {
    setState(() {
      _questionsAnswered++;
      if (selectedCountry == _currentCountry['nome']) {
        _score++; // Incrementa o número de acertos
        _buttonColors[selectedCountry] = Color(0xFF00FF00); // Verde vivo
      } else {
        _buttonColors[selectedCountry] = Color(0xFFFF0000); // Vermelho vivo
        _buttonColors[_currentCountry['nome']!] =
            Color(0xFF00FF00); // Verde vivo para a correta
      }
    });

    // Aguarda 1 segundo antes de carregar a próxima pergunta
    Future.delayed(const Duration(seconds: 1), _setNextQuestion);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Color(0xFF042940),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Color(0xFF005C53),
        middle: Text(
          _gameStarted ? 'Tempo: $_timeRemaining s' : 'Jogo de Bandeiras',
          style: const TextStyle(color: Color(0xFFDBF227)),
        ),
      ),
      child: Center(
        child: _gameStarted
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    _currentCountry['bandeira'] ?? '',
                    width: 200,
                    height: 150,
                  ),
                  const SizedBox(height: 20),
                  for (var option in _options)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: CupertinoButton(
                        color: _buttonColors[option['nome']!],
                        borderRadius: BorderRadius.circular(90),
                        onPressed: () => _answerQuestion(option['nome']!),
                        child: SizedBox(
                          width: 200,
                          child: Center(
                            child: Text(
                              option['nome']!,
                              style:
                                  const TextStyle(color: CupertinoColors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              )
            : CupertinoButton(
                color: Color(0xFF9FC131),
                borderRadius: BorderRadius.circular(90),
                onPressed: _startGame,
                child: const Text(
                  'Começar',
                  style: TextStyle(color: CupertinoColors.white),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

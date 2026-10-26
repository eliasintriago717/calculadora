import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculadora Flutter',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF17171C),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // Estado de la calculadora
  String _input = '';
  String _result = '0';
  double _num1 = 0;
  double _num2 = 0;
  String _operand = '';
  bool _isOperandPressed = false;

  void _onButtonPressed(String value) {
    setState(() {
      // Borrar todo (AC)
      if (value == 'C') {
        _input = '';
        _result = '0';
        _num1 = 0;
        _num2 = 0;
        _operand = '';
        _isOperandPressed = false;
        return;
      }

      // Borrado carácter por carácter (⌫)
      if (value == '⌫') {
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
          _result = _input.isEmpty ? '0' : _input;
        }
        return;
      }

      // Cambio de signo (+/-)
      if (value == '+/-') {
        if (_result != '0' && _result.isNotEmpty) {
          if (_result.startsWith('-')) {
            _result = _result.substring(1);
          } else {
            _result = '-$_result';
          }
          _input = _result;
        }
        return;
      }

      // Porcentaje (%)
      if (value == '%') {
        if (_result != '0' && _result.isNotEmpty) {
          double val = double.tryParse(_result) ?? 0;
          _result = _formatResult(val / 100);
          _input = _result;
        }
        return;
      }

      // Operadores (+, -, ×, ÷)
      if (value == '+' || value == '-' || value == '×' || value == '÷') {
        if (_input.isNotEmpty) {
          _num1 = double.tryParse(_result) ?? 0;
          _operand = value;
          _isOperandPressed = true;
        }
        return;
      }

      // Resultado (=)
      if (value == '=') {
        if (_operand.isNotEmpty && _input.isNotEmpty) {
          _num2 = double.tryParse(_input) ?? 0;

          switch (_operand) {
            case '+':
              _result = _formatResult(_num1 + _num2);
              break;
            case '-':
              _result = _formatResult(_num1 - _num2);
              break;
            case '×':
              _result = _formatResult(_num1 * _num2);
              break;
            case '÷':
              if (_num2 == 0) {
                _result = 'Error';
              } else {
                _result = _formatResult(_num1 / _num2);
              }
              break;
          }

          _input = _result;
          _operand = '';
          _isOperandPressed = false;
        }
        return;
      }

      // Manejo de Números y Punto (.)
      if (_isOperandPressed) {
        _input = '';
        _isOperandPressed = false;
      }

      if (value == '.') {
        if (!_input.contains('.')) {
          _input = _input.isEmpty ? '0.' : _input + '.';
        }
      } else {
        // Evitar múltiples ceros al inicio
        if (_input == '0') {
          _input = value;
        } else {
          _input += value;
        }
      }

      _result = _input;
    });
  }

  // Formatea ceros innecesarios (ej: 5.0 -> 5)
  String _formatResult(double val) {
    if (val.isNaN || val.isInfinite) return 'Error';
    String str = val.toStringAsFixed(6);
    // Eliminar ceros a la derecha y el punto decimal sobrante
    str = str.replaceAll(RegExp(r'0+$'), '');
    if (str.endsWith('.')) {
      str = str.substring(0, str.length - 1);
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Área de Pantalla / Display
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_operand.isNotEmpty)
                      Text(
                        '${_formatResult(_num1)} $_operand',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white54,
                        ),
                      ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _result,
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Teclado de Botones
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildRow(['C', '+/-', '%', '÷'], isTopRow: true),
                  const SizedBox(height: 12),
                  _buildRow(['7', '8', '9', '×']),
                  const SizedBox(height: 12),
                  _buildRow(['4', '5', '6', '-']),
                  const SizedBox(height: 12),
                  _buildRow(['1', '2', '3', '+']),
                  const SizedBox(height: 12),
                  _buildRow(['⌫', '0', '.', '=']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper para construir una fila de botones
  Widget _buildRow(List<String> buttons, {bool isTopRow = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: buttons.map((text) {
        return _buildButton(
          text,
          isTopRow: isTopRow,
          isOperator: ['÷', '×', '-', '+', '='].contains(text),
        );
      }).toList(),
    );
  }

  // Helper para construir cada botón individual
  Widget _buildButton(String text, {bool isTopRow = false, bool isOperator = false}) {
    Color buttonBg;
    Color textColor = Colors.white;

    if (isOperator) {
      buttonBg = const Color(0xFF4B5EAA); // Color primario para operadores
    } else if (isTopRow || text == '⌫') {
      buttonBg = const Color(0xFF2E2F38); // Gris medio para funciones secundarias
      textColor = const Color(0xFFA5A5A5);
    } else {
      buttonBg = const Color(0xFF2E2F38); // Gris oscuro para números
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: AspectRatio(
          aspectRatio: 1, // Garantiza que los botones sean perfectamente circulares
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: EdgeInsets.zero,
              elevation: 0,
            ),
            onPressed: () => _onButtonPressed(text),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
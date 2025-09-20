import 'package:flutter/material.dart';
import 'dart:math';
import 'constantes.dart' as cons;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // 6x6 grid = 36 tiles
  List<String> tileContents = List.generate(36, (index) => (index + 1).toString());

  // Estados de los tiles: 0=inactivo, 1=seguro(verde), 2=mina(rojo)
  List<int> tileStates = List.filled(36, 0);

  // Posición de la mina (0-35)
  int minePosition = 0;

  // Estado del juego: 0=jugando, 1=perdido, 2=ganado
  int gameState = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // Resetear todos los estados
    tileStates = List.filled(36, 0);
    gameState = 0;

    // Colocar la mina en posición aleatoria
    minePosition = Random().nextInt(36);
  }

  Color _getTileColor(int index) {
    switch (tileStates[index]) {
      case 0:
        return cons.grisInactivo; // Inactivo
      case 1:
        return cons.verde; // Seguro
      case 2:
        return cons.rojo; // Mina
      default:
        return cons.grisInactivo;
    }
  }

  void _onTileTap(int index) {
    // Si el juego ya terminó, no hacer nada
    if (gameState != 0) return;

    // Si el tile ya fue clickeado, no hacer nada
    if (tileStates[index] != 0) return;

    setState(() {
      if (index == minePosition) {
        // Toco mina
        tileStates[index] = 2; // Rojo
        gameState = 1; // Perdido
      } else {
        // Tile seguro
        tileStates[index] = 1; // Verde

        // Verificar victoria (todos los tiles seguros clickeados)
        int safeTilesRevealed = 0;
        for (int i = 0; i < 36; i++) {
          if (i != minePosition && tileStates[i] == 1) {
            safeTilesRevealed++;
          }
        }

        if (safeTilesRevealed == 35) { // 36 - 1 mina = 35 tiles seguros
          gameState = 2; // Ganado
        }
      }
    });
  }

  void _retryGame() {
    setState(() {
      _initializeGame();
    });
  }

  String _getGameStatusText() {
    switch (gameState) {
      case 1:
        return '¡Perdiste! Tocaste la mina';
      case 2:
        return '¡Ganaste! Evitaste la mina';
      default:
        return 'Evita la mina oculta';
    }
  }

  Widget _buildTile(int index) {
    return Expanded(
      flex: 1,
      child: Container(
        margin: EdgeInsets.all(3), // margen entre tiles
        child: InkWell(
          onTap: () => _onTileTap(index),
          child: Container(
            decoration: BoxDecoration(
              color: _getTileColor(index),
              borderRadius: BorderRadius.circular(8), // Esquinas redondeadas
            ),
            child: Container(), // Sin contenido
          ),
        ),
      ),
    );
  }

  Widget _buildRow(int startIndex) {
    return Expanded(
      flex: 1,
      child: Row(
        children: List.generate(6, (colIndex) => _buildTile(startIndex + colIndex)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscaminas 6x6, por: Erick Porfirio Quintana López'),
        backgroundColor: cons.azulito,
        foregroundColor: cons.blanco,
      ),
      body: Column(
        children: [
          // Status del juego
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  _getGameStatusText(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (gameState == 1) // Mostrar boton retry si perdio
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: ElevatedButton(
                      onPressed: _retryGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cons.azulito2,
                        foregroundColor: cons.blanco,
                      ),
                      child: Text('Intentar de nuevo'),
                    ),
                  ),
              ],
            ),
          ),

          // Grid 6x6
          Expanded(
            child: Column(
              children: [
                _buildRow(0),  // Fila 1: tiles 1-6
                _buildRow(6),  // Fila 2: tiles 7-12
                _buildRow(12), // Fila 3: tiles 13-18
                _buildRow(18), // Fila 4: tiles 19-24
                _buildRow(24), // Fila 5: tiles 25-30
                _buildRow(30), // Fila 6: tiles 31-36
              ],
            ),
          ),
        ],
      ),
    );
  }
}
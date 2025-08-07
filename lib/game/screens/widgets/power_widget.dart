
import 'package:flutter/material.dart';

import '../../logic/power.dart';

class PowerWidget extends StatelessWidget {
  final Power power;
  final VoidCallback onTap;

  const PowerWidget({super.key, required this.power, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.blueGrey[700], // Base color for the power button
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.blueGrey[900]!, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueGrey[800]!,
              Colors.blueGrey[600]!,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(power.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            Text(power.description, style: const TextStyle(color: Colors.white70)),
            Text('Mana: ${power.manaCost}', style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

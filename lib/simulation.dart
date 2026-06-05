import 'package:calebh101_server_flutter/calebh101_server_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:links/home.dart';
import 'package:links/logic.dart';
import 'package:localpkg_flutter/localpkg.dart';

class SimulationMachine {
  Map<String, String> properties;

  SimulationMachine({required this.properties});

  bool simulate(List<LinkGet200ResponseDataLogicPathsInnerConditionsInner> conditions) {
    return conditions.every((con) {
      return properties[con.type.value] == con.value.value;
    });
  }
}

class SimulationCreation extends StatefulWidget {
  final SimulationMachine machine;
  final String defaultUrl;
  final List<Path> paths;

  const SimulationCreation({super.key, required this.machine, required this.defaultUrl, required this.paths});

  @override
  State<SimulationCreation> createState() => _SimulationCreationState();
}

class _SimulationCreationState extends State<SimulationCreation> {
  (int, Path)? result;
  bool simulated = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Simulation"),
      content: Column(
        mainAxisSize: .min,
        children: [
          Wrap(
            children: schema!.map((s) {
              return Column(
                mainAxisSize: .min,
                children: [
                  Text(s.pretty),
                  DropdownButton<String>(value: widget.machine.properties[s.id.value], items: s.options.mapTo((k, v) {
                    return DropdownMenuItem<String>(
                      value: k,
                      child: Text(v),
                    );
                  }).toList(), onChanged: (value) {
                    if (value == null) return;
                    widget.machine.properties[s.id.value] = value;
                    setState(() {});
                  }),
                ],
              );
            }).toList(),
          ),
          ElevatedButton(
            onPressed: () {
              simulated = true;
              result = simulate();

              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              fixedSize: Size(150, 70),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: TextStyle(
                fontSize: 20,
              ),
            ),
            child: Text("Simulate"),
          ),
          if (simulated) ...[
            10.vert(),
            Text(result == null ? "Default URL: ${widget.defaultUrl}" : "Path #${result!.$1 + 1}: ${result?.$2.url?.text.nullIfEmptyTrimmed ?? "Nothing inputted"}"),
          ],
        ],
      ),
    );
  }

  (int, Path)? simulate() {
    final x = widget.paths.mapIndexed((i, x) => (i, x)).firstWhereOrNull((x) => widget.machine.simulate(x.$2.conditions));
    return x;
  }
}
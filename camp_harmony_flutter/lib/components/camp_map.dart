import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class CampMap extends StatelessWidget {
  const CampMap({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        appBar: PlatformAppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Camp Ramah Ojai"),
        ),
        body: InteractiveViewer(
          clipBehavior: Clip.none,
          scaleEnabled: true,
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: const Image(
            image: AssetImage('images/CampRamahOjaiMap.png'),
          ),
        ));
  }
}

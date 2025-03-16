import 'package:ar_flutter_plugin_2/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_2/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_2/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_2/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ARHome(),
    );
  }
}

class ARHome extends StatefulWidget {
  @override
  _ARHomeState createState() => _ARHomeState();
}

class _ARHomeState extends State<ARHome> {
  late ARSessionManager _arSessionManager;
  late ARObjectManager _arObjectManager;

  @override
  void dispose() {
    _arSessionManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter AR App'),
      ),
      body: Container(
        child: Stack(
          children: [
            ARView(
              onARViewCreated: onARViewCreated,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: addWebObject,
                  child: Text('Add Local Object'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    _arSessionManager = arSessionManager;
    _arObjectManager = arObjectManager;

    _arSessionManager.onInitialize(
      showFeaturePoints: true,
      showPlanes: true,
      showWorldOrigin: true,
      handleTaps: true,
    );
    _arObjectManager.onInitialize();

    addWebObject();
  }

  Future<void> addWebObject() async {
    var newNode = ARNode(
      type: NodeType.webGLB, 
      uri: "https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Fox/glTF-Binary/Fox.glb", 
      scale: vector.Vector3(0.2, 0.2, 0.2),
      position: vector.Vector3(0.0, 0.0, 0.0),
      rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0),
    );

    bool? didAddNode = await _arObjectManager.addNode(newNode);
    if (didAddNode != null && didAddNode) {
      print("Local object added successfully!");
    } else {
      print("Failed to add local object.");
    }
  }
}
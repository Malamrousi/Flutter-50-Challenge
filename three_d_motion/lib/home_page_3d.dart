import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class HomePage3d extends StatefulWidget {
  const HomePage3d({super.key});

  @override
  State<HomePage3d> createState() => _HomePage3dState();
}

class _HomePage3dState extends State<HomePage3d> {
  Flutter3DController controller = Flutter3DController();
  String? chosenAnimation;
  String? chosenTexture;
  bool changeModel = false;
  String srcObj = 'assets/flutter_dash.obj';
  String srcGlb = 'assets/business_man.glb';

  @override
  void initState() {
    super.initState();
    controller.onModelLoaded.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0d2039),
        title: Text(
          "Flutter 3D",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: Column(
        spacing: 4,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              controller.playAnimation();
            },
            icon: const Icon(Icons.play_arrow),
          ),
          IconButton(
            onPressed: () {
              controller.pauseAnimation();
            },
            icon: const Icon(Icons.pause),
          ),
          IconButton(
            onPressed: () {
              controller.resetAnimation();
            },
            icon: const Icon(Icons.replay),
          ),
          IconButton(
            onPressed: () async {
              List<String> availableAnimations =
                  await controller.getAvailableAnimations();
              debugPrint(
                  'Animations : $availableAnimations --- Length : ${availableAnimations.length}');
              chosenAnimation = await showPickerDialog(
                  'Animations', availableAnimations, chosenAnimation);
              controller.playAnimation(animationName: chosenAnimation);
            },
            icon: const Icon(Icons.format_list_bulleted_outlined),
          ),
          IconButton(
            onPressed: () async {
              List<String> availableTextures =
                  await controller.getAvailableTextures();
              debugPrint(
                  'Textures : $availableTextures --- Length : ${availableTextures.length}');
              chosenTexture = await showPickerDialog(
                  'Textures', availableTextures, chosenTexture);
              controller.setTexture(textureName: chosenTexture ?? '');
            },
            icon: const Icon(Icons.list_alt_rounded),
          ),
          const SizedBox(
            height: 4,
          ),
          IconButton(
            onPressed: () {
              controller.setCameraOrbit(20, 20, 5);
            },
            icon: const Icon(Icons.camera_alt_outlined),
          ),
          IconButton(
            onPressed: () {
              controller.resetCameraOrbit();
              //controller.resetCameraTarget();
            },
            icon: const Icon(Icons.cameraswitch_outlined),
          ),
          const SizedBox(
            height: 4,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                changeModel = !changeModel;
                chosenAnimation = null;
                chosenTexture = null;
                if (changeModel) {
                  srcObj = 'assets/Football.obj';
                  srcGlb = 'assets/sheen_chair.glb';
                } else {
                  srcObj = 'assets/flutter_dash.obj';
                  srcGlb = 'assets/business_man.glb';
                }
              });
            },
            icon: const Icon(
              Icons.restore_page_outlined,
              size: 30,
            ),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.grey,
          gradient: RadialGradient(
            colors: [
              Color(0xffffffff),
              Colors.grey,
            ],
            stops: [0.1, 1.0],
            radius: 0.7,
            center: Alignment.center,
          ),
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Flexible(
              flex: 1,
              child: Flutter3DViewer.obj(
                src: srcObj,
                scale: 5,
                cameraX: 0,
                cameraY: 0,
                cameraZ: 10,
              ),
            ),
            Flexible(
              flex: 1,
              child: Flutter3DViewer(
                activeGestureInterceptor: true,
                progressBarColor: Colors.orange,
                enableTouch: true,
                onProgress: (double progressValue) {
                  debugPrint('model loading progress : $progressValue');
                },
                onLoad: (String modelAddress) {
                  debugPrint('model loaded : $modelAddress');
                  controller.playAnimation();
                },
                onError: (String error) {
                  debugPrint('model failed to load : $error');
                },
                controller: controller,
                src: srcGlb,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<String?> showPickerDialog(String title, List<String> inputList,
      [String? chosenItem]) async {
    return await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SizedBox(
          height: 250,
          child: inputList.isEmpty
              ? Center(
                  child: Text('$title list is empty'),
                )
              : ListView.separated(
                  itemCount: inputList.length,
                  padding: const EdgeInsets.only(top: 16),
                  itemBuilder: (ctx, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, inputList[index]);
                      },
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${index + 1}'),
                            Text(inputList[index]),
                            Icon(
                              chosenItem == inputList[index]
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (ctx, index) {
                    return const Divider(
                      color: Colors.grey,
                      thickness: 0.6,
                      indent: 10,
                      endIndent: 10,
                    );
                  },
                ),
        );
      },
    );
  }
}

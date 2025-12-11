import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';

import '../providers/resume_provider.dart';
import '../providers/settings_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late TextEditingController nameController;
  late Box settingsBox;

  String fetchName = "demo";
  Position? pos;
  bool loadingPos = false;

  @override
  void initState() {
    super.initState();

    settingsBox = Hive.box('resume_settings');

    // Load saved name OR "demo" if not saved
    fetchName = settingsBox.get('savedName', defaultValue: "demo");

    nameController = TextEditingController(text: fetchName);

    // Refresh resume with loaded name
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.refresh(resumeProvider(fetchName));
    });

    getLocation();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> getLocation() async {
    setState(() => loadingPos = true);

    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.always ||
          perm == LocationPermission.whileInUse) {
        pos = await Geolocator.getCurrentPosition();
      }
    } catch (_) {}

    setState(() => loadingPos = false);
  }

  void pickColor(Color current, Function(Color) onPick) {
    Color temp = current;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Pick Color"),
        content: ColorPicker(
          pickerColor: current,
          onColorChanged: (c) => temp = c,
          showLabel: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              onPick(temp);
              Navigator.pop(context);
            },
            child: const Text("Select"),
          ),
        ],
      ),
    );
  }

  /// Updates name, saves to Hive, triggers provider refresh
  void updateNameAndRefresh(String newName) {
    final value = newName.trim().isEmpty ? "demo" : newName.trim();

    fetchName = value;
    settingsBox.put('savedName', value);

    ref.refresh(resumeProvider(fetchName));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final resumeAsync = ref.watch(resumeProvider(fetchName));
    final settingsCtrl = ref.read(settingsProvider.notifier);

    final fontColor = Color(settings.fontColor);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Resume Customizer"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: loadingPos
                ? const Text("Locating...", style: TextStyle(fontSize: 12))
                : pos != null
                ? Text(
              "${pos!.latitude.toStringAsFixed(4)}, ${pos!.longitude.toStringAsFixed(4)}",
              style: const TextStyle(fontSize: 12),
            )
                : GestureDetector(
              onTap: getLocation,
              child: const Text("Get Loc", style: TextStyle(fontSize: 12)),
            ),
          )
        ],
      ),
      body: Container(
        color: Color(settings.bgColor),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // SETTINGS CARD
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // FONT SIZE SLIDER
                    Row(
                      children: [
                        const Text("Font Size"),
                        Expanded(
                          child: Slider(
                            value: settings.fontSize,
                            min: 10,
                            max: 30,
                            onChanged: (v) => settingsCtrl.updateFontSize(v),
                          ),
                        ),
                        Text(settings.fontSize.toStringAsFixed(0)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // COLOR PICKERS
                    Row(
                      children: [
                        const Text("Font: "),
                        GestureDetector(
                          onTap: () => pickColor(
                            Color(settings.fontColor),
                                (c) => settingsCtrl.updateFontColor(c.value),
                          ),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color(settings.fontColor),
                              border: Border.all(color: Colors.black26),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Text("Background: "),
                        GestureDetector(
                          onTap: () => pickColor(
                            Color(settings.bgColor),
                                (c) => settingsCtrl.updateBgColor(c.value),
                          ),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color(settings.bgColor),
                              border: Border.all(color: Colors.black26),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // NAME FIELD + REGENERATE BUTTON
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus(); // HIDE KEYBOARD
                            updateNameAndRefresh(nameController.text);
                          },
                          child: const Text("Regenerate"),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              hintText: "Enter name",
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (val) {
                              FocusScope.of(context).unfocus(); // HIDE KEYBOARD
                              updateNameAndRefresh(val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // RESUME PREVIEW
            Expanded(
              child: resumeAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("Error: $e")),
                data: (resume) => SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: SelectableText.rich(
                    _styledResume(resume.toReadableText(), fontColor, settings.fontSize),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Makes Name:, SKILLS:, PROJECTS: bold
  TextSpan _styledResume(String text, Color color, double size) {
    final lines = text.split('\n');
    final spans = <TextSpan>[];

    for (final line in lines) {
      final trimmed = line.trim();
      final isHeader = trimmed.toUpperCase() == "SKILLS:" ||
          trimmed.toUpperCase() == "PROJECTS:" ||
          trimmed.startsWith("Name:");

      spans.add(
        TextSpan(
          text: line + "\n",
          style: TextStyle(
            fontSize: size,
            color: color,
            height: 1.4,
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
    }

    return TextSpan(children: spans);
  }
}

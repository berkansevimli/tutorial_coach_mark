// ignore_for_file: avoid_print

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutorial Coach Mark Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = <TargetFocus>[];

  // Widget'lar için global key'ler
  GlobalKey keyButton = GlobalKey();
  GlobalKey keyButton1 = GlobalKey();
  GlobalKey keyButton2 = GlobalKey();
  GlobalKey keyButton3 = GlobalKey();
  GlobalKey keyButton4 = GlobalKey();
  GlobalKey keyButton5 = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tutorial Coach Mark Demo"),
      ),
      body: Container(
        color: Colors.white,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // Auto-close after cycle demo
                  Container(
                    key: keyButton,
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        "Auto-Close Demo\n(Döngü bitince otomatik kapanır)",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),

                  // Target tap as overlay demo
                  Container(
                    key: keyButton1,
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        "Target Tap as Overlay\n(Target'a tıklama = overlay)",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),

                  // Tap animations demo
                  Container(
                    key: keyButton2,
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        "Tap Animations Demo\n(Tıklama animasyonları aktif)",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),

                  Container(
                    key: keyButton3,
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        "Normal Target\n(Animasyon yok)",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          key: keyButton4,
                          height: 60,
                          margin: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text(
                              "Son Target",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          key: keyButton5,
                          height: 60,
                          margin: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text(
                              "Finished!",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTutorialCoachMark();
        },
        child: Icon(Icons.play_arrow),
        tooltip: "Tutorial'ı Başlat",
      ),
    );
  }

  void _showTutorialCoachMark() {
    _initTarget();
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.red,
      textSkip: "ATLA",
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter:
          ImageFilter.blur(sigmaX: 2, sigmaY: 2), // ✅ Blur azaltıldı (8→2)
      onFinish: () {
        print("Tutorial tamamlandı");
        _showCompletionDialog();
      },
      onClickTarget: (target) {
        print('onClickTarget: ${target.identify}');
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        print("target: ${target.identify}");
        print(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        print('onClickOverlay: ${target.identify}');
      },
      onCycleComplete: (target) {
        print('Global onCycleComplete: ${target.identify}');
        // Global cycle complete callback
      },
      onSkip: () {
        print("Tutorial atlandı");
        return true;
      },
    );
    tutorialCoachMark.show(context: context);
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("🎉 Tebrikler!"),
        content: Text(
          "Tüm yeni özellikleri başarıyla test ettiniz!\n\n"
          "✅ Auto-close after cycle\n"
          "✅ Target tap as overlay\n"
          "✅ Tap animations control\n\n"
          "Paket artık tam anlamıyla production-ready! 🚀",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Mükemmel!"),
          ),
        ],
      ),
    );
  }

  void _initTarget() {
    targets.clear();

    // 1. Auto-close after cycle demo
    targets.add(
      TargetFocus(
        identify: "auto_close_demo",
        keyTarget: keyButton,
        enableContentCycling: true,
        autoCloseAfterCycle: true, // ✅ Döngü bitince otomatik kapat
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: EdgeInsets.all(20),
            builder: (context, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "🔄 Auto-Close Demo",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Bu target döngü tamamlandığında otomatik kapanır.\n\n" +
                          "Overlay'e tıklayarak 2 farklı içeriği gördükten sonra direkt bir sonraki target'a geçecek.\n\n" +
                          "🖱️ Overlay'e tıklayın →",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        alternativeContents: [
          [
            TargetContent(
              align: ContentAlign.bottom,
              padding: EdgeInsets.all(20),
              builder: (context, controller) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "🎯 Son İçerik",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Bu son içerik! Tekrar tıklayın ve direkt kapanacak (anlık content görünmeyecek).",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );

    // 2. Target tap as overlay demo
    targets.add(
      TargetFocus(
        identify: "target_tap_as_overlay_demo",
        keyTarget: keyButton1,
        enableContentCycling: true,
        enableOverlayTab: true,
        enableTargetTabAsOverlay:
            true, // ✅ Target'a tıklama da overlay gibi davranır
        autoCloseAfterCycle: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: EdgeInsets.all(20),
            builder: (context, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "🎯 Target Tap as Overlay",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Bu target'ta hem overlay'e hem de target'a tıklama aynı etkiyi yapar!\n\n" +
                          "İstediğinize tıklayın: Target'a 👆 veya Overlay'e 🖱️",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        alternativeContents: [
          [
            TargetContent(
              align: ContentAlign.bottom,
              padding: EdgeInsets.all(20),
              builder: (context, controller) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Perfect! Her iki tıklama da aynı etkiyi yaptı. Bir kez daha tıklayın!",
                    style: TextStyle(color: Colors.black87),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );

    // 3. Cycle fix demo (2 alternative content)
    targets.add(
      TargetFocus(
        identify: "cycle_fix_demo",
        keyTarget: keyButton2,
        enableContentCycling: true,
        autoCloseAfterCycle: true,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            padding: EdgeInsets.all(20),
            builder: (context, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "🔧 Cycle Fix Demo",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Bu demo cycle fix'ini test eder.\n\n" +
                          "2 alternatif content var. Son content'ten sonra anlık ilk content görünmeyecek!",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        alternativeContents: [
          [
            TargetContent(
              align: ContentAlign.top,
              padding: EdgeInsets.all(20),
              builder: (context, controller) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.orange, width: 2),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "İlk alternatif content. Bir daha tıklayın!",
                    style: TextStyle(color: Colors.black87),
                  ),
                );
              },
            ),
          ],
          [
            TargetContent(
              align: ContentAlign.top,
              padding: EdgeInsets.all(20),
              builder: (context, controller) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.deepOrange, width: 2),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "İkinci (son) alternatif content. Bir daha tıklayın - direkt kapanacak!",
                    style: TextStyle(color: Colors.black87),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );

    // 3. Tap animations demo
    targets.add(
      TargetFocus(
        identify: "tap_animations_demo",
        keyTarget: keyButton2,
        enableContentCycling: true,
        autoCloseAfterCycle: true,
        enableOverlayTab: true,
        enableTapAnimations: true, // ✅ Bu target'ta tıklama animasyonları aktif
        contents: [
          TargetContent(
            align: ContentAlign.top,
            padding: EdgeInsets.all(20),
            builder: (context, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "🎭 Tap Animations Demo",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Bu target'ta tıklama animasyonları (ripple effect) aktif!\n\n" +
                          "Overlay'e veya target'a tıklayınca animasyon göreceksiniz.",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        alternativeContents: [
          [
            TargetContent(
              align: ContentAlign.top,
              padding: EdgeInsets.all(20),
              builder: (context, controller) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.orange, width: 2),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Gördünüz mü? Tıklama animasyonu vardı! Tekrar tıklayın ve karşılaştırın.",
                    style: TextStyle(color: Colors.black87),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );

    // 4. Normal target (döngü yok, animasyon yok)
    targets.add(
      TargetFocus(
        identify: "normal_target",
        keyTarget: keyButton3,
        // enableTapAnimations: false (varsayılan), global da false
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "📄 Normal Target",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Bu normal target. Tıklama animasyonu yok.\n\n" +
                          "Önceki target'la karşılaştırın!",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    // 5. Son target
    targets.add(
      TargetFocus(
        identify: "final_target",
        keyTarget: keyButton4,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "🏁 Tutorial Tamamlandı!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Tüm yeni özellikleri test ettiniz!\n\n" +
                          "• Auto-close after cycle ✅\n" +
                          "• Target tap as overlay ✅\n" +
                          "• Tap animations control ✅",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

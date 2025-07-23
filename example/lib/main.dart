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

                  // Custom callback demo
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
                        "Custom Callback Demo\n(Özel kapatma mantığı)",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),

                  // Manual control demo
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
                        "Manual Control Demo\n(Döngü devam eder)",
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
                        "Normal Target\n(Cycle özelliği yok)",
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
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
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
          "Cycle Complete özelliğini başarıyla test ettiniz!\n\n"
          "• Auto-close after cycle\n"
          "• Custom callback control\n"
          "• Manuel cycle control\n\n"
          "artık kullanıma hazır!",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Tamam"),
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
                          "Overlay'e tıklayarak 3 farklı içeriği gördükten sonra otomatik olarak bir sonraki target'a geçecek.\n\n" +
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
                        "📖 İkinci İçerik",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Bu ikinci içerik. Bir daha tıklayın.",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "🎯 Son İçerik",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Bu son içerik! Tekrar tıklayın ve otomatik olarak kapanacak.",
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

    // 2. Custom callback demo
    targets.add(
      TargetFocus(
        identify: "custom_callback_demo",
        keyTarget: keyButton1,
        enableContentCycling: true,
        autoCloseAfterCycle: false, // Manuel kontrol
        enableOverlayTab: true,
        onCycleComplete: () {
          // Özel kapatma mantığı
          print("Custom callback çağrıldı!");

          // Dialog göster ve kullanıcıya sor
          bool shouldClose = true; // Varsayılan olarak kapat

          // Bu örnekte her zaman kapat, gerçek uygulamada dialog vs. gösterebilirsiniz
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Döngü tamamlandı! Özel callback ile kapatıldı."),
              duration: Duration(seconds: 2),
            ),
          );

          return shouldClose; // true: kapat, false: devam et
        },
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
                      "🎛️ Custom Callback Demo",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Bu target özel callback kullanır.\n\n" +
                          "Döngü bittiğinde custom mantık çalışır ve size SnackBar gösterir.",
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
                  child: Text("Custom callback son içerik!"),
                );
              },
            ),
          ],
        ],
      ),
    );

    // 3. Manuel control demo (döngü devam eder)
    targets.add(
      TargetFocus(
        identify: "manual_control_demo",
        keyTarget: keyButton2,
        enableContentCycling: true,
        autoCloseAfterCycle: false, // Otomatik kapanmaz
        enableOverlayTab: true,
        // onCycleComplete callback'i yok, bu yüzden döngü devam eder
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
                      "♾️ Manuel Control Demo",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Bu target döngü bittikten sonra da devam eder.\n\n" +
                          "Target'a tıklayarak manuel olarak geçebilirsiniz.",
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
                    "Manuel control - döngü bitince de devam eder!\n\nTarget'a tıklayın →",
                    style: TextStyle(color: Colors.black87),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );

    // 4. Normal target (döngü yok)
    targets.add(
      TargetFocus(
        identify: "normal_target",
        keyTarget: keyButton3,
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
                      "Bu normal bir target. Content cycling özelliği yok.",
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
                      "Cycle Complete özelliklerini başarıyla test ettiniz!\n\n" +
                          "• Auto-close after cycle ✅\n" +
                          "• Custom callback control ✅\n" +
                          "• Manuel cycle control ✅",
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

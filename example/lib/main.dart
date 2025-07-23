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
                  // Content Cycling özelliğini gösteren buton
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
                        "Content Cycling Demo\n(Overlay'e tıklayın)",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  // Normal tutorial butonu
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
                        "Normal Tutorial Button",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  // Diğer butonlar
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
                        "Another Button",
                        style: TextStyle(color: Colors.white),
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
                        "Purple Button",
                        style: TextStyle(color: Colors.white),
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
                              "Left Button",
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
                              "Right Button",
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
        // Content cycling aktifse bu callback overlay'e her tıklamada çağrılır
        // Ancak target kapanmaz, sadece içerik değişir
      },
      onSkip: () {
        print("Tutorial atlandı");
        return true;
      },
    );
    tutorialCoachMark.show(context: context);
  }

  void _initTarget() {
    targets.clear();

    // Content Cycling özelliği olan target
    targets.add(
      TargetFocus(
        identify: "content_cycling_demo",
        keyTarget: keyButton,
        enableContentCycling: true, // Bu özelliği aktifleştir
        enableOverlayTab: true, // Overlay'e tıklamayı aktifleştir
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
                      "Content Cycling Demo 🎯",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Bu, content cycling özelliğinin ilk içeriğidir.\n\n" +
                          "Overlay'e (gri alan) tıklayarak farklı içerikleri görebilirsiniz!\n\n" +
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
          // İkinci içerik seti
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "İkinci İçerik! 🎉",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Harika! Overlay'e tıkladığınız için içerik değişti.\n\n" +
                            "Bu özellik sayesinde aynı target için farklı açıklamalar gösterebilirsiniz.\n\n" +
                            "🖱️ Tekrar tıklayın →",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          // Üçüncü içerik seti
          [
            TargetContent(
              align: ContentAlign.bottom,
              padding: EdgeInsets.all(20),
              builder: (context, controller) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.orange, width: 2),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Üçüncü İçerik! 🚀",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Mükemmel! Bu son alternatif içerik.\n\n" +
                            "Tekrar tıklarsanız döngü başa dönecek.\n\n" +
                            "Target'a tıklayarak bir sonraki adıma geçebilirsiniz! 👆",
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

    // Normal target'lar
    targets.add(
      TargetFocus(
        identify: "normal_target",
        keyTarget: keyButton1,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Normal Tutorial",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Bu normal bir tutorial target'ıdır.\n\n" +
                          "Content cycling özelliği aktif değil, bu yüzden overlay'e tıklandığında bir sonraki adıma geçecek.",
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

    targets.add(
      TargetFocus(
        identify: "last_target",
        keyTarget: keyButton2,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Tutorial Tamamlandı! 🎊",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Content cycling özelliğini test ettiniz!\n\n" +
                          "Bu özellik sayesinde kullanıcılara daha detaylı açıklamalar sunabilirsiniz.",
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

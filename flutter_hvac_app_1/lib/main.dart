import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Controllers.dart';
import 'package:flutter_neumorphic_null_safety/flutter_neumorphic.dart';
// import 'package:bezier_chart/bezier_chart.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

final plugcontroller = PlugController();
final logincontroller = LoginController();
var page_index = 0.obs;
var data_val_index = 'co2'.obs;
var user_id = 'ehrnc';
Map sensor_info = {
  '0': '최댓값',
  '44': '거실',
  '45': '거실(청정기옆)',
  '46': '안방',
  '47': '안쪽방',
  '48': '중간방',
  '49': '서재(가장아래)',
  '50': '서재(아래)',
  '51': '서재(중간)',
  '53': '서재(맨위)',
};
var box;
RxList boxobs = [].obs;

void main() async {
  plugcontroller.set_plug_list(user_id);
  plugcontroller.load_data();

  var path = Directory.current.path;
  // Hive..init(path);
  await Hive.initFlutter();
  Box bbox = await Hive.openBox('alarm_db');
  // await bbox.clear();
  box = bbox;
  boxobs.value = box.values.toList().map((e) {
    RxInt rxstate = 0.obs;
    rxstate.value = e['state'];
    Map alarmdata = {
      'name': e['name'],
      'start': e['start'],
      'end': e['end'],
      'state': rxstate,
    };
    return alarmdata;
  }).toList();
  runApp(GetMaterialApp(
    home: Home(),
    theme: ThemeData(fontFamily: 'NanumGothic'),
  ));
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Home_page();
    return Obx(() =>
        logincontroller.login_index.value == 0 ? Login_page() : Home_page());
  }
}

class Login_page extends StatelessWidget {
  const Login_page({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // imagecontroller.adt_opc();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
              // color: Color.fromARGB(255, 209, 155, 155),
              image: DecorationImage(
                  colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(1), BlendMode.dstATop),
                  fit: BoxFit.fitHeight,
                  image: AssetImage('images/loginpage_base.png'))),
          // color: Colors.white,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment(0.0, 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text(
              //   'HVAC System',
              //   style: TextStyle(fontFamily: 'RobotoMono', fontWeight: FontWeight.w700, fontSize: 20),
              // ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'ehrnc@ehrnc.com',
                    labelText: '아이디',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    // hintText: 'ehrnc@ehrnc.com',
                    labelText: '비밀번호',
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(onPressed: () {}, child: Text('회원가입')),
                  TextButton(
                      onPressed: () {
                        logincontroller.adt_opc();
                      },
                      child: Text('로그인')),
                ],
              ),
              // IconButton(
              //   onPressed: () {
              //     logincontroller.adt_opc();
              //     // login_index.value = 1;
              //   },
              //   icon: Icon(Icons.abc),
              // ),
            ],
          ),
        ));
  }
}

class Home_page extends StatelessWidget {
  const Home_page({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          decoration: BoxDecoration(
              // color: Color.fromARGB(255, 209, 155, 155),
              image: DecorationImage(
                  colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(1), BlendMode.dstATop),
                  fit: BoxFit.fitHeight,
                  image: AssetImage('images/backgroundbase.png'))),
          child: Scaffold(
            // backgroundColor: NeumorphicTheme.baseColor(context),
            backgroundColor: Colors.transparent,
            // backgroundColor: Color.fromARGB(255, 255, 255, 255),
            // appBar: AppBar(
            //   toolbarHeight: page_index == 0 ? 100 : 0,
            //   backgroundColor: Colors.white,
            // ),
            body: page_index == 0
                ? Mainhome()
                : page_index == 1
                    ? Secondpage()
                    : Datapage(),
            bottomNavigationBar: Container(
              height: 70,
              child: Bottombox(),
            ),
          ),
        ));
  }
}

class Secondpage extends StatelessWidget {
  const Secondpage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 70,
          ),
          Neumorphic(
            // height: 70,
            // color: Color.fromARGB(255, 255, 255, 255),
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  // height: 30,
                  child: NeumorphicText(
                    'Schedule',
                    style: NeumorphicStyle(
                      shape: NeumorphicShape.flat,
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(12)),
                      depth: 10,
                      lightSource: LightSource.topLeft,
                      color: Color.fromARGB(146, 31, 31, 30),
                      surfaceIntensity: 10,
                    ),
                    textStyle: NeumorphicTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            // plugcontroller.pluglist.value
            child: Obx(() => ListView(
                  children: List<Widget>.generate(
                      plugcontroller.pluglist.value.length, (index) {
                    return Neumorphic(
                      style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(10)),
                        depth: 7,
                        lightSource: LightSource.topLeft,
                        color: plugcontroller.pluglist.value[index]
                                    .rulebasestate.value ==
                                0
                            ? Color.fromARGB(146, 197, 199, 185)
                            : Color.fromARGB(255, 255, 255, 255),
                        shadowDarkColor: Color.fromARGB(170, 0, 0, 0),
                        shadowLightColor: Color.fromARGB(255, 255, 255, 255),
                        surfaceIntensity: 10,
                      ),
                      // color: Color.fromARGB(255, 212, 212, 212),
                      // height: 200,
                      margin: EdgeInsets.all(10),
                      // padding: EdgeInsets.all(4),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Flexible(
                                flex: 1,
                                child: IconButton(
                                  icon: Icon(Icons.add_box_outlined),
                                  onPressed: () async {
                                    // Box box = await Hive.openBox('alarm_db');
                                    // await box.clear();
                                    String name = plugcontroller
                                        .pluglist.value[index].name;
                                    String start = '09';
                                    String end = '15';
                                    int state = 0;
                                    // print(box.getAt(8));
                                    // print(box.getAt(1));
                                    print(box.keys);
                                    print(box.values);
                                    // print(box.values.toList()[0]);
                                    Get.dialog(AlertDialog(
                                      title: const Text('Schedule'),
                                      content: const Text('추가 정보를 입력하세요.'),
                                      actions: [
                                        Container(
                                            height: 300,
                                            child: SingleChildScrollView(
                                                child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 50,
                                                  child: TextField(
                                                    decoration: const InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                        hintText:
                                                            'Start_time_ex: 09'),
                                                    onChanged: (value) {
                                                      start = value;
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 50,
                                                  child: TextField(
                                                    decoration: const InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                        hintText:
                                                            'End_time_ex: 14'),
                                                    onChanged: (value) {
                                                      end = value;
                                                    },
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    List<String> check_list = [
                                                      '00',
                                                      '01',
                                                      '02',
                                                      '03',
                                                      '04',
                                                      '05',
                                                      '06',
                                                      '07',
                                                      '08',
                                                      '09',
                                                      '10',
                                                      '11',
                                                      '12',
                                                      '13',
                                                      '14',
                                                      '15',
                                                      '16',
                                                      '17',
                                                      '18',
                                                      '19',
                                                      '20',
                                                      '21',
                                                      '22',
                                                      '23',
                                                      '24',
                                                    ];
                                                    if (check_list
                                                            .contains(start) &
                                                        check_list
                                                            .contains(end)) {
                                                      Map alarm = {
                                                        'name': name,
                                                        'start': start,
                                                        'end': end,
                                                        'state': state,
                                                      };
                                                      box.add(alarm);
                                                      boxobs.value = box.values
                                                          .toList()
                                                          .map((e) {
                                                        RxInt rxstate = 0.obs;
                                                        rxstate.value =
                                                            e['state'];
                                                        Map alarmdata = {
                                                          'name': e['name'],
                                                          'start': e['start'],
                                                          'end': e['end'],
                                                          'state': rxstate,
                                                        };
                                                        return alarmdata;
                                                      }).toList();
                                                      Get.back();
                                                    } else {
                                                      AlertDialog(
                                                        title: const Text(
                                                            '시간 양식이 맞지 않습니다.'),
                                                      );
                                                    }
                                                  },
                                                  child: const Text("추가"),
                                                ),
                                              ],
                                            )))
                                      ],
                                    ));
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                child: NeumorphicText(
                                  plugcontroller.pluglist.value[index].name,
                                  // +
                                  //     ': ' +
                                  //     plugcontroller
                                  //         .pluglist.value[index].schedule.value
                                  //         .toString(),
                                  style: NeumorphicStyle(
                                    shape: NeumorphicShape.flat,
                                    boxShape: NeumorphicBoxShape.roundRect(
                                        BorderRadius.circular(12)),
                                    depth: 10,
                                    lightSource: LightSource.top,
                                    color: Color.fromARGB(146, 41, 41, 41),
                                    surfaceIntensity: 10,
                                  ),
                                  textStyle: NeumorphicTextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: SizedBox(
                                  width: 30,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 2,
                            color: Color.fromARGB(31, 36, 35, 35),
                          ),
                          Column(
                            // children: [Text(box.values.toList().toString())],
                            children: List<Widget>.generate(boxobs.value.length,
                                (index2) {
                              if (boxobs.value[index2]['name'] ==
                                  plugcontroller.pluglist.value[index].name) {
                                // return Text(box.toList()[index2]['name'].toString());
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 2, 50, 2),
                                      child: NeumorphicText(
                                        boxobs.value[index2]['start'] +
                                            '-' +
                                            boxobs.value[index2]['end'],
                                        style: NeumorphicStyle(
                                          shape: NeumorphicShape.flat,
                                          boxShape:
                                              NeumorphicBoxShape.roundRect(
                                                  BorderRadius.circular(12)),
                                          depth: 10,
                                          lightSource: LightSource.topLeft,
                                          color: boxobs.value[index2]['state']
                                                      .value ==
                                                  0
                                              ? Color.fromARGB(
                                                  255, 167, 167, 167)
                                              : Color.fromARGB(255, 73, 73, 73),
                                          surfaceIntensity: 10,
                                        ),
                                        textStyle: NeumorphicTextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        width: 100,
                                        height: 30,
                                        child: Obx(
                                          () => NeumorphicToggle(
                                            selectedIndex: boxobs
                                                .value[index2]['state'].value,
                                            displayForegroundOnlyIfSelected:
                                                true,
                                            onChanged: (value) async {
                                              if (plugcontroller
                                                      .pluglist
                                                      .value[index]
                                                      .schedule
                                                      .value ==
                                                  0) {
                                                boxobs.value[index2]['state']
                                                    .value = value;
                                                Map alarm = {
                                                  'name': boxobs.value[index2]
                                                      ['name'],
                                                  'start': boxobs.value[index2]
                                                      ['start'],
                                                  'end': boxobs.value[index2]
                                                      ['end'],
                                                  'state': value,
                                                };

                                                box.putAt(index2, alarm);
                                                plugcontroller.set_alarm(
                                                    user_id,
                                                    plugcontroller.pluglist
                                                        .value[index].ip,
                                                    boxobs.value[index2]
                                                        ['start'],
                                                    boxobs.value[index2]['end'],
                                                    value.toString());

                                                if (value == 1) {
                                                  plugcontroller
                                                      .pluglist
                                                      .value[index]
                                                      .schedule
                                                      .value = 1;
                                                } else {
                                                  num testind = 0;
                                                  for (var it = 0;
                                                      it < boxobs.value.length;
                                                      it++) {
                                                    if (boxobs.value[it]
                                                            ['name'] ==
                                                        plugcontroller
                                                            .pluglist
                                                            .value[index]
                                                            .name) {
                                                      testind = testind +
                                                          boxobs
                                                              .value[it]
                                                                  ['state']
                                                              .value;
                                                    }
                                                  }
                                                  if (testind == 0) {
                                                    plugcontroller
                                                        .pluglist
                                                        .value[index]
                                                        .schedule
                                                        .value = 0;
                                                  }
                                                }
                                              } else {
                                                // 임시로 0으로 지정해서 돌게함
                                                // 제거할때나 켜진상태에서 추가할때 0으로 바뀌도록 수정
                                                plugcontroller
                                                    .pluglist
                                                    .value[index]
                                                    .schedule
                                                    .value = 0;
                                                print('이미 알람이 켜져있다');
                                              }
                                            },
                                            // thumb: Neumorphic(),
                                            thumb: Container(
                                              color: boxobs
                                                          .value[index2]
                                                              ['state']
                                                          .value ==
                                                      0
                                                  ? Color.fromARGB(
                                                      255, 141, 141, 141)
                                                  : Color.fromARGB(
                                                      255, 220, 225, 238),
                                            ),
                                            children: [
                                              ToggleElement(
                                                  background: Center()),
                                              ToggleElement(
                                                  background: Center()),
                                            ],
                                          ),
                                        )),
                                    IconButton(
                                        onPressed: () {
                                          box.deleteAt(index2);
                                          boxobs.value =
                                              box.values.toList().map((e) {
                                            RxInt rxstate = 0.obs;
                                            rxstate.value = e['state'];
                                            Map alarmdata = {
                                              'name': e['name'],
                                              'start': e['start'],
                                              'end': e['end'],
                                              'state': rxstate,
                                            };
                                            return alarmdata;
                                          }).toList();
                                        },
                                        icon: Icon(
                                          Icons.remove_circle_outline,
                                          size: 20,
                                        )),
                                  ],
                                );
                              } else {
                                return SizedBox();
                              }
                            }).toList(),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                )),
          )
        ],
      ),
    );
  }
}

class Mainhome extends StatelessWidget {
  const Mainhome({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 70,
          ),
          Neumorphic(
            // height: 70,
            // color: Color.fromARGB(255, 255, 255, 255),
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.add_box_outlined),
                  onPressed: () {
                    String name_t = '';
                    String ip_t = '';
                    String sensornum_t = '';
                    String typeagent_t = '';
                    String ruleset_t = '';
                    Get.dialog(AlertDialog(
                      title: const Text('시스템 요소 추가'),
                      content: const Text('추가할 요소의 정보를 입력하세요.'),
                      actions: [
                        TextField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter name'),
                          onChanged: (value) {
                            name_t = value;
                          },
                        ),
                        TextField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter ip'),
                          onChanged: (value) {
                            ip_t = value;
                          },
                        ),
                        TextField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter sensor number'),
                          onChanged: (value) {
                            sensornum_t = value;
                          },
                        ),
                        TextField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'S: 공기순환기, V: 환풍기, A: 공기청정기'),
                          onChanged: (value) {
                            typeagent_t = value;
                          },
                        ),
                        TextField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '자동감시 기준치 ex: 1000'),
                          onChanged: (value) {
                            ruleset_t = value;
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                plugcontroller.add_plug(user_id, ip_t, name_t,
                                    sensornum_t, typeagent_t, ruleset_t);
                                Get.back();
                              },
                              child: Text("추가"),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text("취소"),
                            ),
                          ],
                        ),
                      ],
                    ));
                  },
                ),
                NeumorphicText(
                  'EHR&C HVAC SYSTEM',
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                    depth: 10,
                    lightSource: LightSource.topLeft,
                    color: Color.fromARGB(146, 51, 51, 49),
                    surfaceIntensity: 10,
                  ),
                  textStyle: NeumorphicTextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                    onPressed: () {
                      plugcontroller.set_plug_list(user_id);
                    },
                    icon: Icon(Icons.restart_alt)),
              ],
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            // plugcontroller.pluglist.value
            child: Obx(() => ListView(
                  children: List<Widget>.generate(
                      plugcontroller.pluglist.value.length, (index) {
                    return Neumorphic(
                      style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(10)),
                        depth: 7,
                        lightSource: LightSource.topLeft,
                        color: plugcontroller.pluglist.value[index]
                                    .rulebasestate.value ==
                                0
                            ? Color.fromARGB(146, 197, 199, 185)
                            : Color.fromARGB(255, 255, 255, 255),
                        shadowDarkColor: Color.fromARGB(170, 0, 0, 0),
                        shadowLightColor: Color.fromARGB(255, 255, 255, 255),
                        surfaceIntensity: 10,
                      ),
                      // color: Color.fromARGB(255, 212, 212, 212),
                      // height: 200,
                      margin: EdgeInsets.all(10),
                      // padding: EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Row(
                              children: [
                                plugcontroller.pluglist.value[index].onoffstate
                                            .value ==
                                        true
                                    ? IconButton(
                                        onPressed: () {
                                          plugcontroller.pluglist.value[index]
                                              .turn_off(user_id);
                                        },
                                        icon: Icon(Icons.offline_bolt),
                                        color:
                                            Color.fromARGB(255, 61, 173, 104),
                                        iconSize: 40,
                                      )
                                    : IconButton(
                                        onPressed: () {
                                          plugcontroller.pluglist.value[index]
                                              .turn_on(user_id);
                                        },
                                        icon: Icon(Icons.offline_bolt),
                                        color:
                                            Color.fromARGB(255, 172, 172, 172),
                                        iconSize: 40,
                                      ),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 3,
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      NeumorphicText(
                                        plugcontroller
                                            .pluglist.value[index].name,
                                        style: NeumorphicStyle(
                                          shape: NeumorphicShape.flat,
                                          boxShape:
                                              NeumorphicBoxShape.roundRect(
                                                  BorderRadius.circular(12)),
                                          depth: 10,
                                          lightSource: LightSource.top,
                                          color:
                                              Color.fromARGB(146, 41, 41, 41),
                                          surfaceIntensity: 10,
                                        ),
                                        textStyle: NeumorphicTextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      NeumorphicText(
                                        sensor_info[plugcontroller.pluglist
                                                    .value[index].sensornum] !=
                                                null
                                            ? sensor_info[plugcontroller
                                                    .pluglist
                                                    .value[index]
                                                    .sensornum] +
                                                '(' +
                                                plugcontroller.pluglist
                                                    .value[index].sensornum +
                                                ')'
                                            : '센서수정중',
                                        style: NeumorphicStyle(
                                          shape: NeumorphicShape.flat,
                                          boxShape:
                                              NeumorphicBoxShape.roundRect(
                                                  BorderRadius.circular(12)),
                                          depth: 10,
                                          lightSource: LightSource.top,
                                          color: Color.fromARGB(146, 7, 7, 7),
                                          surfaceIntensity: 10,
                                        ),
                                        textStyle: NeumorphicTextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      plugcontroller.pluglist.value[index]
                                                  .rulebasestate.value ==
                                              1
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                NeumorphicText(
                                                  '자동감시' +
                                                      '기준: ' +
                                                      plugcontroller
                                                          .pluglist
                                                          .value[index]
                                                          .ruleset
                                                          .value
                                                          .toString() +
                                                      'ppm',
                                                  style: NeumorphicStyle(
                                                    shape: NeumorphicShape.flat,
                                                    boxShape: NeumorphicBoxShape
                                                        .roundRect(BorderRadius
                                                            .circular(12)),
                                                    depth: 10,
                                                    lightSource:
                                                        LightSource.top,
                                                    color: Color.fromARGB(
                                                        146, 7, 7, 7),
                                                    surfaceIntensity: 10,
                                                  ),
                                                  textStyle:
                                                      NeumorphicTextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                NeumorphicText(
                                                  plugcontroller
                                                              .pluglist
                                                              .value[index]
                                                              .typeagent ==
                                                          'A'
                                                      ? 'PM2.5: ' +
                                                          plugcontroller
                                                              .pluglist
                                                              .value[index]
                                                              .sensorval
                                                              .value +
                                                          ' ppm'
                                                      : 'CO2: ' +
                                                          plugcontroller
                                                              .pluglist
                                                              .value[index]
                                                              .sensorval
                                                              .value +
                                                          ' ppm',
                                                  style: NeumorphicStyle(
                                                    shape: NeumorphicShape.flat,
                                                    boxShape: NeumorphicBoxShape
                                                        .roundRect(BorderRadius
                                                            .circular(12)),
                                                    depth: 10,
                                                    lightSource:
                                                        LightSource.top,
                                                    color: Color.fromARGB(
                                                        146, 7, 7, 7),
                                                    surfaceIntensity: 10,
                                                  ),
                                                  textStyle:
                                                      NeumorphicTextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : NeumorphicText(
                                              '수동감시모드',
                                              style: NeumorphicStyle(
                                                shape: NeumorphicShape.flat,
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(
                                                        BorderRadius.circular(
                                                            12)),
                                                depth: 10,
                                                lightSource: LightSource.top,
                                                color: Color.fromARGB(
                                                    146, 7, 7, 7),
                                                surfaceIntensity: 10,
                                              ),
                                              textStyle: NeumorphicTextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: NeumorphicToggle(
                                    selectedIndex: plugcontroller.pluglist
                                        .value[index].rulebasestate.value,
                                    displayForegroundOnlyIfSelected: true,
                                    onChanged: (value) async {
                                      plugcontroller.pluglist.value[index]
                                          .rulebasestate.value = value;
                                      if (value == 1) {
                                        await plugcontroller
                                            .pluglist.value[index]
                                            .rule_base_on(user_id);
                                        sleep(Duration(seconds: 1));
                                        await plugcontroller
                                            .pluglist.value[index]
                                            .rule_base_on2(user_id);
                                      } else {
                                        plugcontroller.pluglist.value[index]
                                            .rule_base_off(user_id);
                                      }

                                      // plugcontroller.set_plug_list(user_id);
                                    },
                                    thumb: Neumorphic(),
                                    children: [
                                      ToggleElement(
                                          background: Center(
                                        child: NeumorphicText(
                                          'OFF',
                                          style: NeumorphicStyle(
                                            shape: NeumorphicShape.flat,
                                            boxShape:
                                                NeumorphicBoxShape.roundRect(
                                                    BorderRadius.circular(12)),
                                            depth: 10,
                                            lightSource: LightSource.top,
                                            color:
                                                Color.fromARGB(146, 41, 41, 41),
                                            surfaceIntensity: 10,
                                          ),
                                          textStyle: NeumorphicTextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )),
                                      ToggleElement(
                                          background: Center(
                                        child: NeumorphicText(
                                          'ON',
                                          style: NeumorphicStyle(
                                            shape: NeumorphicShape.flat,
                                            boxShape:
                                                NeumorphicBoxShape.roundRect(
                                                    BorderRadius.circular(12)),
                                            depth: 10,
                                            lightSource: LightSource.top,
                                            color:
                                                Color.fromARGB(146, 41, 41, 41),
                                            surfaceIntensity: 10,
                                          ),
                                          textStyle: NeumorphicTextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        // plugcontroller.pluglist.removeAt(index);
                                        var ip_t = plugcontroller
                                            .pluglist.value[index].ip;
                                        var name_t = plugcontroller
                                            .pluglist.value[index].name;
                                        var sensornum_t = plugcontroller
                                            .pluglist.value[index].sensornum;
                                        var typeagent_t = plugcontroller
                                            .pluglist.value[index].typeagent;
                                        var ruleset_t = plugcontroller
                                            .pluglist.value[index].ruleset.value
                                            .toString();

                                        // user_id, ip_t, name_t,sensornum_t, typeagent_t, ruleset_t
                                        // plugcontroller.remove_plug(
                                        //     user_id, ip_t, name_t);
                                        Get.dialog(AlertDialog(
                                          title: const Text('정보'),
                                          content:
                                              const Text('수정하거나 기기를 삭제하세요.'),
                                          actions: [
                                            Container(
                                              height: 300,
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child: Text('name: ' +
                                                              name_t),
                                                        ),
                                                      ],
                                                    ),
                                                    // SizedBox(
                                                    //   height: 50,
                                                    //   child: TextField(
                                                    //     controller:
                                                    //         TextEditingController()
                                                    //           ..text = name_t,
                                                    //     decoration:
                                                    //         const InputDecoration(
                                                    //             border:
                                                    //                 OutlineInputBorder(),
                                                    //             hintText:
                                                    //                 'Enter name'),
                                                    //     onChanged: (value) {
                                                    //       name_t = value;
                                                    //     },
                                                    //   ),
                                                    // ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child: Text(
                                                              'ip: ' + ip_t),
                                                        ),
                                                      ],
                                                    ),
                                                    // SizedBox(
                                                    //   height: 50,
                                                    //   child: TextField(
                                                    //     controller:
                                                    //         TextEditingController()
                                                    //           ..text = ip_t,
                                                    //     decoration:
                                                    //         const InputDecoration(
                                                    //             border:
                                                    //                 OutlineInputBorder(),
                                                    //             hintText:
                                                    //                 'Enter ip'),
                                                    //     onChanged: (value) {
                                                    //       ip_t = value;
                                                    //     },
                                                    //   ),
                                                    // ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child: Text(
                                                              'sensor number'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 50,
                                                      child: TextField(
                                                        controller:
                                                            TextEditingController()
                                                              ..text =
                                                                  sensornum_t,
                                                        decoration: const InputDecoration(
                                                            border:
                                                                OutlineInputBorder(),
                                                            hintText:
                                                                'Enter sensor number'),
                                                        onChanged: (value) {
                                                          sensornum_t = value;
                                                        },
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child: Text('type'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 50,
                                                      child: TextField(
                                                        controller:
                                                            TextEditingController()
                                                              ..text =
                                                                  typeagent_t,
                                                        decoration: const InputDecoration(
                                                            border:
                                                                OutlineInputBorder(),
                                                            hintText:
                                                                'S: 공기순환기, V: 환풍기, A: 공기청정기'),
                                                        onChanged: (value) {
                                                          typeagent_t = value;
                                                        },
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child: Text(
                                                              'monitoring levels'),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 50,
                                                      child: TextField(
                                                        controller:
                                                            TextEditingController()
                                                              ..text = ruleset_t
                                                                  .toString(),
                                                        decoration: const InputDecoration(
                                                            border:
                                                                OutlineInputBorder(),
                                                            hintText:
                                                                '자동감시 기준치 ex: 1000'),
                                                        onChanged: (value) {
                                                          ruleset_t = value;
                                                        },
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        TextButton(
                                                          onPressed: () async {
                                                            if (sensor_info[
                                                                    sensornum_t] !=
                                                                null) {
                                                              Get.back();
                                                              await plugcontroller
                                                                  .remove_plug(
                                                                      user_id,
                                                                      ip_t,
                                                                      name_t);
                                                              sleep(Duration(
                                                                  seconds: 1));
                                                              await plugcontroller
                                                                  .add_plug(
                                                                      user_id,
                                                                      ip_t,
                                                                      name_t,
                                                                      sensornum_t,
                                                                      typeagent_t,
                                                                      ruleset_t);
                                                              sleep(Duration(
                                                                  seconds: 1));
                                                              plugcontroller
                                                                  .set_plug_list(
                                                                      user_id);
                                                            } else {
                                                              Get.dialog(AlertDialog(
                                                                  title:
                                                                      const Text(
                                                                          '경고'),
                                                                  content: const Text('없는 센서 번호입니다.'),
                                                                  actions: [
                                                                    Text(sensor_info
                                                                        .toString())
                                                                  ]));
                                                              Get.back();
                                                            }
                                                          },
                                                          child: Text("수정"),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            plugcontroller
                                                                .remove_plug(
                                                                    user_id,
                                                                    ip_t,
                                                                    name_t);
                                                            Get.back();
                                                          },
                                                          child: Text("삭제"),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Get.back();
                                                          },
                                                          child: Text("취소"),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ));
                                      },
                                      icon: Icon(
                                        Icons.info_outline,
                                      ),
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                    // return ListTile(
                    //   title: Text(plugcontroller.pluglist.value[index].name),
                    // );
                  }).toList(),
                )),
          )
        ],
      ),
    );
  }
}

class Datapage extends StatelessWidget {
  const Datapage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 70,
            ),
            Neumorphic(
              // height: 70,
              // color: Color.fromARGB(255, 255, 255, 255),
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    // height: 30,
                    child: NeumorphicText(
                      'Monitoring system',
                      style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(12)),
                        depth: 10,
                        lightSource: LightSource.topLeft,
                        color: Color.fromARGB(146, 31, 31, 30),
                        surfaceIntensity: 10,
                      ),
                      textStyle: NeumorphicTextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 0, 1),
              child: Text(
                '* 모든 데이터는 30분 평균이며, 실내공기질은 모니터링지점 평균값을 사용합니다.',
                style: TextStyle(
                  color: Color.fromARGB(255, 100, 100, 100),
                  fontFamily: 'NanumGothic',
                  fontSize: 8,
                ),
              ),
            ),
            Flexible(
              // padding: const EdgeInsets.fromLTRB(16, 1, 16, 16),
              fit: FlexFit.tight,
              child: Obx(
                () => plugcontroller.dataset_index.value == 0
                    ? Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        width: MediaQuery.of(context).size.width,
                        alignment: const Alignment(0.0, 0.0),
                        child: SpinKitFadingCircle(
                          color: Colors.white,
                          size: 50.0,
                        ),
                      )
                    : ListView(
                        children: [
                          Neumorphic(
                              style: NeumorphicStyle(
                                shape: NeumorphicShape.flat,
                                boxShape: NeumorphicBoxShape.roundRect(
                                    BorderRadius.circular(10)),
                                depth: 7,
                                lightSource: LightSource.topLeft,
                                color: Color.fromARGB(146, 197, 199, 185),
                                shadowDarkColor: Color.fromARGB(170, 0, 0, 0),
                                shadowLightColor:
                                    Color.fromARGB(255, 255, 255, 255),
                                surfaceIntensity: 10,
                              ),
                              // color: Color.fromARGB(255, 212, 212, 212),
                              // height: 200,
                              margin: EdgeInsets.all(10),
                              // padding: EdgeInsets.all(4),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                width: MediaQuery.of(context).size.width * 0.9,
                                color: Color.fromARGB(153, 206, 214, 240),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: const Icon(
                                            Icons.snowing,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                        ),
                                        NeumorphicText(
                                          '실내공기질',
                                          style: NeumorphicStyle(
                                            shape: NeumorphicShape.flat,
                                            boxShape:
                                                NeumorphicBoxShape.roundRect(
                                                    BorderRadius.circular(12)),
                                            // depth: 10,
                                            // lightSource: LightSource.top,
                                            color: Color.fromARGB(255, 7, 7, 7),
                                            surfaceIntensity: 10,
                                          ),
                                          textStyle: NeumorphicTextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Flexible(
                                      fit: FlexFit.tight,
                                      child: Row(
                                        // crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Flexible(
                                            fit: FlexFit.tight,
                                            flex: 1,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                      255, 190, 190, 190),
                                                  width: 0.3,
                                                ),
                                                // borderRadius: BorderRadius.circular(3),
                                              ),
                                              padding: EdgeInsets.all(6),
                                              // color: Color.fromARGB(159, 217, 232, 233),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  NeumorphicText(
                                                    '이산화탄소',
                                                    style: NeumorphicStyle(
                                                      shape:
                                                          NeumorphicShape.flat,
                                                      boxShape:
                                                          NeumorphicBoxShape
                                                              .roundRect(
                                                                  BorderRadius
                                                                      .circular(
                                                                          12)),
                                                      // depth: 10,
                                                      // lightSource: LightSource.top,
                                                      color: Color.fromARGB(
                                                          255, 7, 7, 7),
                                                      surfaceIntensity: 10,
                                                    ),
                                                    textStyle:
                                                        NeumorphicTextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      NeumorphicText(
                                                        plugcontroller
                                                            .sensor_map['평균']
                                                                ['co2']
                                                            .last
                                                            .round()
                                                            .toString(),
                                                        style: NeumorphicStyle(
                                                          shape: NeumorphicShape
                                                              .flat,
                                                          boxShape: NeumorphicBoxShape
                                                              .roundRect(
                                                                  BorderRadius
                                                                      .circular(
                                                                          12)),
                                                          // depth: 10,
                                                          // lightSource: LightSource.top,
                                                          color: Color.fromARGB(
                                                              255, 7, 7, 7),
                                                          surfaceIntensity: 10,
                                                        ),
                                                        textStyle:
                                                            NeumorphicTextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                        ),
                                                      ),
                                                      NeumorphicText(
                                                        ' ppm',
                                                        style: NeumorphicStyle(
                                                          shape: NeumorphicShape
                                                              .flat,
                                                          boxShape: NeumorphicBoxShape
                                                              .roundRect(
                                                                  BorderRadius
                                                                      .circular(
                                                                          12)),
                                                          // depth: 10,
                                                          // lightSource: LightSource.top,
                                                          color: Color.fromARGB(
                                                              255, 7, 7, 7),
                                                          surfaceIntensity: 10,
                                                        ),
                                                        textStyle:
                                                            NeumorphicTextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            fit: FlexFit.tight,
                                            flex: 1,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                      255, 190, 190, 190),
                                                  width: 0.3,
                                                ),
                                                // borderRadius: BorderRadius.circular(3),
                                              ),
                                              padding: EdgeInsets.all(6),
                                              // color: Color.fromARGB(159, 217, 232, 233),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  NeumorphicText(
                                                    '미세먼지',
                                                    style: NeumorphicStyle(
                                                      shape:
                                                          NeumorphicShape.flat,
                                                      boxShape:
                                                          NeumorphicBoxShape
                                                              .roundRect(
                                                                  BorderRadius
                                                                      .circular(
                                                                          12)),
                                                      // depth: 10,
                                                      // lightSource: LightSource.top,
                                                      color: Color.fromARGB(
                                                          255, 0, 0, 0),
                                                      surfaceIntensity: 10,
                                                    ),
                                                    textStyle:
                                                        NeumorphicTextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      NeumorphicText(
                                                        plugcontroller
                                                            .sensor_map['평균']
                                                                ['pm']
                                                            .last
                                                            .toString(),
                                                        style: NeumorphicStyle(
                                                          shape: NeumorphicShape
                                                              .flat,
                                                          boxShape: NeumorphicBoxShape
                                                              .roundRect(
                                                                  BorderRadius
                                                                      .circular(
                                                                          12)),
                                                          // depth: 10,
                                                          // lightSource: LightSource.top,
                                                          color: Color.fromARGB(
                                                              255, 7, 7, 7),
                                                          surfaceIntensity: 10,
                                                        ),
                                                        textStyle:
                                                            NeumorphicTextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                        ),
                                                      ),
                                                      NeumorphicText(
                                                        ' ppm',
                                                        style: NeumorphicStyle(
                                                          shape: NeumorphicShape
                                                              .flat,
                                                          boxShape: NeumorphicBoxShape
                                                              .roundRect(
                                                                  BorderRadius
                                                                      .circular(
                                                                          12)),
                                                          // depth: 10,
                                                          // lightSource: LightSource.top,
                                                          color: Color.fromARGB(
                                                              255, 7, 7, 7),
                                                          surfaceIntensity: 10,
                                                        ),
                                                        textStyle:
                                                            NeumorphicTextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Flexible(
                                          //   fit: FlexFit.tight,
                                          //   flex: 1,
                                          //   child: Container(
                                          //     decoration: BoxDecoration(
                                          //       color: Color.fromARGB(
                                          //           255, 255, 255, 255),
                                          //       border: Border.all(
                                          //         color: Color.fromARGB(
                                          //             255, 190, 190, 190),
                                          //         width: 0.3,
                                          //       ),
                                          //       // borderRadius: BorderRadius.circular(3),
                                          //     ),
                                          //     padding: EdgeInsets.all(6),
                                          //     // color: Color.fromARGB(159, 217, 232, 233),
                                          //     child: Column(
                                          //       mainAxisAlignment:
                                          //           MainAxisAlignment.center,
                                          //       children: [
                                          //         NeumorphicText(
                                          //           '기온',
                                          //           style: NeumorphicStyle(
                                          //             shape:
                                          //                 NeumorphicShape.flat,
                                          //             boxShape:
                                          //                 NeumorphicBoxShape
                                          //                     .roundRect(
                                          //                         BorderRadius
                                          //                             .circular(
                                          //                                 12)),
                                          //             // depth: 10,
                                          //             // lightSource: LightSource.top,
                                          //             color: Color.fromARGB(
                                          //                 255, 7, 7, 7),
                                          //             surfaceIntensity: 10,
                                          //           ),
                                          //           textStyle:
                                          //               NeumorphicTextStyle(
                                          //             fontSize: 14,
                                          //             fontWeight:
                                          //                 FontWeight.w300,
                                          //           ),
                                          //         ),
                                          //         Row(
                                          //           mainAxisAlignment:
                                          //               MainAxisAlignment
                                          //                   .center,
                                          //           children: [
                                          //             NeumorphicText(
                                          //               plugcontroller
                                          //                   .sensor_map['평균']
                                          //                       ['temp']
                                          //                   .last
                                          //                   .toString(),
                                          //               style: NeumorphicStyle(
                                          //                 shape: NeumorphicShape
                                          //                     .flat,
                                          //                 boxShape: NeumorphicBoxShape
                                          //                     .roundRect(
                                          //                         BorderRadius
                                          //                             .circular(
                                          //                                 12)),
                                          //                 // depth: 10,
                                          //                 // lightSource: LightSource.top,
                                          //                 color: Color.fromARGB(
                                          //                     255, 7, 7, 7),
                                          //                 surfaceIntensity: 10,
                                          //               ),
                                          //               textStyle:
                                          //                   NeumorphicTextStyle(
                                          //                 fontSize: 20,
                                          //                 fontWeight:
                                          //                     FontWeight.w300,
                                          //               ),
                                          //             ),
                                          //             NeumorphicText(
                                          //               ' °C',
                                          //               style: NeumorphicStyle(
                                          //                 shape: NeumorphicShape
                                          //                     .flat,
                                          //                 boxShape: NeumorphicBoxShape
                                          //                     .roundRect(
                                          //                         BorderRadius
                                          //                             .circular(
                                          //                                 12)),
                                          //                 // depth: 10,
                                          //                 // lightSource: LightSource.top,
                                          //                 color: Color.fromARGB(
                                          //                     255, 7, 7, 7),
                                          //                 surfaceIntensity: 10,
                                          //               ),
                                          //               textStyle:
                                          //                   NeumorphicTextStyle(
                                          //                 fontSize: 14,
                                          //                 fontWeight:
                                          //                     FontWeight.w300,
                                          //               ),
                                          //             ),
                                          //           ],
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )),
                          LineChart(
                            datamap: plugcontroller.sensor_map,
                            valname: data_val_index.value,
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                            // height: MediaQuery.of(context).size.height*0.1,
                            // width: MediaQuery.of(context).size.width*0.7,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    data_val_index.value = 'co2';
                                  },
                                  child: Container(
                                    // color: Color.fromARGB(255, 247, 245, 244),
                                    margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    decoration: BoxDecoration(
                                      color: data_val_index.value == 'co2'
                                          ? Color.fromARGB(255, 209, 209, 209)
                                          : null,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: NeumorphicText(
                                      '이산화탄소',
                                      style: NeumorphicStyle(
                                        shape: NeumorphicShape.flat,
                                        boxShape: NeumorphicBoxShape.roundRect(
                                            BorderRadius.circular(12)),
                                        depth: 10,
                                        lightSource: LightSource.topLeft,
                                        color: data_val_index.value == 'co2'
                                            ? Color.fromARGB(255, 255, 255, 255)
                                            : Color.fromARGB(146, 39, 39, 37),
                                        surfaceIntensity: 10,
                                      ),
                                      textStyle: NeumorphicTextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    data_val_index.value = 'pm';
                                  },
                                  child: Container(
                                    // color: Color.fromARGB(255, 247, 245, 244),
                                    margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    decoration: BoxDecoration(
                                      color: data_val_index.value == 'pm'
                                          ? Color.fromARGB(255, 209, 209, 209)
                                          : null,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: NeumorphicText(
                                      '미세먼지',
                                      style: NeumorphicStyle(
                                        shape: NeumorphicShape.flat,
                                        boxShape: NeumorphicBoxShape.roundRect(
                                            BorderRadius.circular(12)),
                                        depth: 10,
                                        lightSource: LightSource.topLeft,
                                        color: data_val_index.value == 'pm'
                                            ? Color.fromARGB(255, 255, 255, 255)
                                            : Color.fromARGB(146, 39, 39, 37),
                                        surfaceIntensity: 10,
                                      ),
                                      textStyle: NeumorphicTextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                                // InkWell(
                                //   onTap: () {
                                //     data_val_index.value = 'temp';
                                //   },
                                //   child: Container(
                                //     // color: Color.fromARGB(255, 247, 245, 244),
                                //     margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                //     decoration: BoxDecoration(
                                //       color: data_val_index.value == 'temp'
                                //           ? Color.fromARGB(255, 209, 209, 209)
                                //           : null,
                                //       borderRadius: BorderRadius.circular(10),
                                //     ),
                                //     child: NeumorphicText(
                                //       '기온',
                                //       style: NeumorphicStyle(
                                //         shape: NeumorphicShape.flat,
                                //         boxShape: NeumorphicBoxShape.roundRect(
                                //             BorderRadius.circular(12)),
                                //         depth: 10,
                                //         lightSource: LightSource.topLeft,
                                //         color: data_val_index.value == 'temp'
                                //             ? Color.fromARGB(255, 255, 255, 255)
                                //             : Color.fromARGB(146, 39, 39, 37),
                                //         surfaceIntensity: 10,
                                //       ),
                                //       textStyle: NeumorphicTextStyle(
                                //         fontSize: 17,
                                //         fontWeight: FontWeight.w400,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 200,
                          )
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Bottombox extends StatelessWidget {
  const Bottombox({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Neumorphic(
              style: page_index.value == 0
                  ? NeumorphicStyle(color: Color.fromARGB(255, 215, 234, 255))
                  : null,
              child: IconButton(
                  onPressed: () {
                    page_index.value = 0;
                  },
                  icon: Icon(Icons.laptop_mac)),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: NeumorphicText(
                'HOME',
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                  depth: 10,
                  lightSource: LightSource.top,
                  color: Color.fromARGB(146, 7, 7, 7),
                  surfaceIntensity: 10,
                ),
                textStyle: NeumorphicTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
        Column(
          children: [
            Neumorphic(
              style: page_index.value == 1
                  ? NeumorphicStyle(color: Color.fromARGB(255, 215, 234, 255))
                  : null,
              child: IconButton(
                  onPressed: () {
                    page_index.value = 1;
                  },
                  icon: Icon(Icons.schedule)),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: NeumorphicText(
                'SCHEDULE',
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                  depth: 10,
                  lightSource: LightSource.top,
                  color: Color.fromARGB(146, 7, 7, 7),
                  surfaceIntensity: 10,
                ),
                textStyle: NeumorphicTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
        Column(
          children: [
            Neumorphic(
              style: page_index.value == 2
                  ? NeumorphicStyle(color: Color.fromARGB(255, 215, 234, 255))
                  : null,
              child: IconButton(
                  onPressed: () {
                    page_index.value = 2;
                  },
                  icon: Icon(Icons.leaderboard)),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: NeumorphicText(
                'DATA',
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                  depth: 10,
                  lightSource: LightSource.top,
                  color: Color.fromARGB(146, 7, 7, 7),
                  surfaceIntensity: 10,
                ),
                textStyle: NeumorphicTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}

class LineChart extends StatelessWidget {
  LineChart({
    Key? key,
    required this.datamap,
    required this.valname,
  }) : super(key: key);
  Map datamap;
  String valname;
  // DateTime min;
  // DateTime max;

  @override
  Widget build(BuildContext context) {
    List<LineSeries<ChartData, dynamic>> linelist =
        datamap.entries.map<LineSeries<ChartData, dynamic>>((e) {
      // min = e.value['time'][0];
      // max = e.value['time'][-1];
      return LineSeries(
          name: e.key,
          dataSource:
              List<ChartData>.generate(datamap[e.key]['time'].length, (index) {
            return ChartData(e.value['time'][index], e.value[valname][index]);
          }).toList(),
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y);
    }).toList();
    return Neumorphic(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(4),
      child: SfCartesianChart(
        enableAxisAnimation: true,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        primaryXAxis: DateTimeAxis(
          // minimum: DateTime(datamap['거실']['time'][0].year,
          //     datamap['거실']['time'][0].month, datamap['거실']['time'][0].day, datamap['거실']['time'][0].hour),
          // maximum: DateTime(datamap['거실']['time'].last.year,
          //     datamap['거실']['time'].last.month, datamap['거실']['time'].last.day),
          // anchorRangeToVisiblePoints: false,
          // labelRotation: 10,
          desiredIntervals: 6,
          // minorTicksPerInterval: 3000,
          autoScrollingDeltaType: DateTimeIntervalType.hours,
          intervalType: DateTimeIntervalType.days,
          // autoScrollingDeltaType: DateTimeIntervalType.days,
        ),
        legend: Legend(
            isVisible: true,
            toggleSeriesVisibility: true,
            overflowMode: LegendItemOverflowMode.wrap,
            textStyle: TextStyle(
              color: Color.fromARGB(255, 104, 76, 76).withOpacity(0.7),
            ),

            // offset: Offset(20, 40),
            // height: '200',
            position: LegendPosition.bottom
            // borderWidth: 2,
            ),
        series: linelist,
        zoomPanBehavior: ZoomPanBehavior(
          enablePinching: true,
          zoomMode: ZoomMode.x,
          enablePanning: true,
          enableDoubleTapZooming: true,
          enableMouseWheelZooming: true,
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final DateTime x;
  final double y;
}

class Alarm {
  Alarm(this.name, this.start, this.end, this.state);
  final String name;
  final String start;
  final String end;
  final int state;
}

// class Chart extends StatelessWidget {
//   Chart({
//     Key? key,
//     required this.xdata,
//     required this.ydata,
//     required this.label,
//   }) : super(key: key);
//   List xdata;
//   List ydata;
//   String label;
//   @override
//   Widget build(BuildContext context) {
//     final fromDate = DateTime.now().subtract(Duration(days: 1));
//     final toDate = DateTime.now();

//     return Center(
//       child: Container(
//         color: Color.fromARGB(255, 0, 0, 0),
//         height: MediaQuery.of(context).size.height / 5,
//         width: MediaQuery.of(context).size.width,
//         child: BezierChart(
//           fromDate: fromDate,
//           bezierChartScale: BezierChartScale.HOURLY,
//           toDate: toDate,
//           selectedDate: toDate,
//           series: [
//             BezierLine(
//               lineColor: Colors.blue,
//               lineStrokeWidth: 1.0,
              
//                 label: label,
//                 data: List<DataPoint>.generate(xdata.length, (index) {
//                   return DataPoint<DateTime>(
//                       value: ydata[index], xAxis: xdata[index]);
//                 }).toList()),
//           ],
//           config: BezierChartConfig(
//             displayYAxis: false,
//             showDataPoints: false,
//             xAxisTextStyle: TextStyle(
//               color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.7),
//               ),
            
//             verticalIndicatorStrokeWidth: 3.0,
//             verticalIndicatorColor: Colors.black26,
//             showVerticalIndicator: true,
//             verticalIndicatorFixedPosition: false,
//             backgroundColor: Color.fromARGB(255, 255, 255, 255),
//             footerHeight: 30.0,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class Chartcol extends StatelessWidget {
//   Chartcol({Key? key, required this.roomname}) : super(key: key);
//   String roomname;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Chart(
//           xdata: plugcontroller.sensor_map[roomname]['time'],
//           ydata: plugcontroller.sensor_map[roomname]['co2'],
//           label: 'co2',
//         ),
//         Chart(
//           xdata: plugcontroller.sensor_map[roomname]['time'],
//           ydata: plugcontroller.sensor_map[roomname]['pm'],
//           label: 'pm',
//         ),
//         Chart(
//           xdata: plugcontroller.sensor_map[roomname]['time'],
//           ydata: plugcontroller.sensor_map[roomname]['temp'],
//           label: 'temp',
//         ),
//       ],
//     );
//   }
// }

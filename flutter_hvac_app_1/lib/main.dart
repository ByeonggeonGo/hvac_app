import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Controllers.dart';
import 'package:flutter_neumorphic_null_safety/flutter_neumorphic.dart';
// import 'package:bezier_chart/bezier_chart.dart';
import 'dart:io';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

final plugcontroller = PlugController();
var page_index = 0.obs;
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

void main() async {
  plugcontroller.set_plug_list(user_id);
  plugcontroller.load_data();

  runApp(GetMaterialApp(home: Home()));
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Home_page();
  }
}

class Home_page extends StatelessWidget {
  const Home_page({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: NeumorphicTheme.baseColor(context),
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
        ));
  }
}

class Secondpage extends StatelessWidget {
  const Secondpage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 100,
          ),
          Text('Update......'),
          SizedBox(
            height: 400,
          ),
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
                    shape: NeumorphicShape.concave,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                    depth: 10,
                    lightSource: LightSource.topLeft,
                    color: Color.fromARGB(146, 113, 114, 104),
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
                            BorderRadius.circular(30)),
                        depth: 7,
                        lightSource: LightSource.topLeft,
                        color: plugcontroller.pluglist.value[index]
                                    .rulebasestate.value ==
                                0
                            ? Color.fromARGB(146, 197, 199, 185)
                            : Color.fromARGB(146, 148, 160, 82),
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
                                          var test = plugcontroller.pluglist();
                                          test[index].turn_off(user_id);
                                        },
                                        icon: Icon(Icons.offline_bolt),
                                        color:
                                            Color.fromARGB(255, 61, 173, 104),
                                        iconSize: 40,
                                      )
                                    : IconButton(
                                        onPressed: () {
                                          var test = plugcontroller.pluglist();
                                          test[index].turn_on(user_id);
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
                                            shape: NeumorphicShape.concave,
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
                                            shape: NeumorphicShape.concave,
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
                InkWell(
                  child: Container(
                    child: Text('test'),
                  ),
                  onTap: () {},
                )
              ],
            ),
          ),
          // Flexible(
          //     flex: 1,
          //     child: Container(
          //       color: Colors.red,
          //       padding: const EdgeInsets.all(6.0),
          //       // margin: EdgeInsets.all(10),
          //       )),
          // SizedBox(height: 100,),
          Flexible(
              flex: 4,
              fit: FlexFit.tight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Obx(() => plugcontroller.dataset_index.value == 0
                      ? Text('로딩중...')
                      : LineChart(
                        xdata: plugcontroller.sensor_map['거실']['time'],
                        ydata: plugcontroller.sensor_map['거실']['co2'],
                        label: 'co2',
                      ),),
                ),
              )),
        ],
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
    required this.xdata,
    required this.ydata,
    required this.label,
  }) : super(key: key);
  List xdata;
  List ydata;
  String label;

  @override
  Widget build(BuildContext context) {
    
    List<ChartData> datasource = List<ChartData>.generate(xdata.length, (index) {
          return ChartData(xdata[index], ydata[index]);
        }).toList();
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      series: <ChartSeries<ChartData, dynamic>>[
        LineSeries(
            dataSource: datasource,
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y)
      ],
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final DateTime x;
  final double y;
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

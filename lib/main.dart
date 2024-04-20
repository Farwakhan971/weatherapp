import 'package:weatherapp_11/consts/images.dart';
import 'package:weatherapp_11/consts/strings.dart';
import 'package:weatherapp_11/controllers/main_controller.dart';
import 'package:weatherapp_11/models/current_weather_model.dart';
import 'package:weatherapp_11/models/hourly_weather_model.dart';
import 'package:weatherapp_11/utils/our_themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';
import 'models/weather_chart.dart';

main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: CustomThemes.lightTheme,
      darkTheme: CustomThemes.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const WeatherApp(),
      title: "Weather App",
    );
  }
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    var date = DateFormat("yMMMMd").format(DateTime.now());
    var theme = Theme.of(context);
    var controller = Get.put(MainController());

    return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            date,
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 24,
              fontFamily: 'Roboto', // Change the font family to Roboto
              shadows: [
                Shadow(
                  blurRadius: 2,
                  color: Colors.grey.withOpacity(0.5),
                  offset: Offset(1, 2),
                ),
              ],
            ),
          ),

          backgroundColor: Colors.transparent,
          elevation: 0.0,
          actions: [
            Obx(
              () => IconButton(
                onPressed: () {
                  controller.changeTheme();
                },
                icon: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0.0, -0.5),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    controller.isDark.value ? Icons.light_mode : Icons.dark_mode,
                    key: ValueKey<bool>(controller.isDark.value),
                    color: theme.iconTheme.color,
                  ),
                ),
              ),

            ),
            IconButton(onPressed: () {}, icon: Icon(Icons.more_vert, color: theme.iconTheme.color))
          ],
        ),
        body: Obx(
          () => controller.isloaded.value == true
              ? Container(
                  padding: const EdgeInsets.all(12),
                  child: FutureBuilder(
                    future: controller.currentWeatherData,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        CurrentWeatherData data = snapshot.data;

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              "${data.name}"
                                  .text
                                  .uppercase
                                  .fontFamily("poppins_bold")
                                  .size(32)
                                  .letterSpacing(3)
                                  .color(theme.primaryColor)
                                  .make(),
                          Row(
                            children: [
                              // Left side with temperature and weather description
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0), // Adjust the left padding as needed
                                      child: Text(
                                        "${data.main?.temp ?? '-'}$degree",
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                          fontSize: 64,
                                          fontFamily: "Poppins",
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 40.0), // Increase the left padding to shift the text more to the right
                                      child: Text(
                                        "${data.weather != null && data.weather!.isNotEmpty ? data.weather![0].main ?? '-' : '-'}",
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                          letterSpacing: 3,
                                          fontSize: 14,
                                          fontFamily: "Poppins",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Right side with the image
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 500),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  );
                                },
                                child: data.weather != null && data.weather!.isNotEmpty
                                    ? Image.asset(
                                  "assets/weather/${data.weather![0].icon ?? 'default'}.png",
                                  key: ValueKey<String>(data.weather![0].icon ?? 'default'),
                                  width: 80,
                                  height: 80,
                                )
                                    : Container(),
                              ),
                            ],
                          ),

                          SizedBox(
                          height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: null,
                                    icon: Icon(Icons.arrow_upward_rounded, color: theme.iconTheme.color), // Use arrow_upward_rounded icon for up arrow
                                  ),
                                  Text(
                                    "${data.main!.tempMax}$degree",
                                    style: TextStyle(
                                      color: theme.primaryColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: null,
                                    icon: Icon(Icons.arrow_downward_rounded, color: theme.iconTheme.color), // Use arrow_downward_rounded icon for down arrow
                                  ),
                                  Text(
                                    "${data.main!.tempMin}$degree",
                                    style: TextStyle(
                                      color: theme.primaryColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),


                              30.heightBox,
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(3, (index) {
                                    var iconsList = [clouds, humidity, windspeed];
                                    var values = [
                                      "${data.clouds!.all}",
                                      "${data.main!.humidity}",
                                      "${data.wind!.speed} km/h"
                                    ];
                                    return Container(
                                      margin: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12.0),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            iconsList[index],
                                            width: 60,
                                            height: 60,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            values[index],
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),

                          10.heightBox,
                              const Divider(),
                              10.heightBox,
                              FutureBuilder(
                                future: controller.hourlyWeatherData,
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    HourlyWeatherData hourlyData = snapshot.data;

                                    return SizedBox(
                                      height: 160,
                                      child: ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemCount: hourlyData.list!.length > 6 ? 6 : hourlyData.list!.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          var time = DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(
                                              hourlyData.list![index].dt!.toInt() * 1000));

                                          return Container(
                                            padding: const EdgeInsets.all(8),
                                            margin: const EdgeInsets.only(right: 4),
                                            decoration: BoxDecoration(
                                              color: Vx.gray200,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              children: [
                                                time.text.make(),
                                                Image.asset(
                                                  "assets/weather/${hourlyData.list![index].weather![0].icon}.png",
                                                  width: 80,
                                                ),
                                                10.heightBox,
                                                "${hourlyData.list![index].main!.temp}$degree".text.make(),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              ),
                              10.heightBox,
                              const Divider(),
                              10.heightBox,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  "Next 7 Days".text.semiBold.size(16).color(theme.primaryColor).make(),
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: 7,
                                itemBuilder: (BuildContext context, int index) {
                                  var day = DateFormat("EEEE").format(DateTime.now().add(Duration(days: index + 1)));
                                  var maxTemperature = "37°";
                                  var minTemperature = "26°";

                                  return Container(
                                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.0),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                                      leading: Image.asset(
                                        "assets/weather/50n.png", // Assuming this is the correct path to the weather icon
                                        width: 40,
                                      ),
                                      title: Text(
                                        day,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black, // Set text color to black
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          SizedBox(height: 8),
                                          Text(
                                            'Max: $maxTemperature',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black, // Set text color to black
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Min: $minTemperature',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black, // Set text color to black
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),






                            ],
                          ),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ));
  }
}

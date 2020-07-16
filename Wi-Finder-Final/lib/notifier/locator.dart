import 'package:get_it/get_it.dart';
import 'package:WiFinder/api/data.dart';

///Wi-Fi hotspot locator
GetIt locator = GetIt.instance;

void dataLocator(){
    locator.registerSingleton<Data>(Data());
}


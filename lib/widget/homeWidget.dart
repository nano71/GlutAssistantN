import 'package:home_widget/home_widget.dart';

import '../config.dart';
import '../data.dart';

void updateWidgetContent(){
  if (!isLogin()) {
    HomeWidget.saveWidgetData<String>("title", Global.appTitle);
    HomeWidget.saveWidgetData<String>("message", Global.notLoginError);
  } else {
    HomeWidget.saveWidgetData<String>("title", "今天的课表");
    HomeWidget.saveWidgetData<String>("message", Global.notLoginError);
  }
}

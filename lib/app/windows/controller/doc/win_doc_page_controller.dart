import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:wenznote/app/windows/controller/doc/win_doc_list_controller.dart';
import 'package:wenznote/app/windows/controller/home/win_home_controller.dart';
import 'package:wenznote/commons/mvc/controller.dart';
import 'package:wenznote/model/note/po/doc_po.dart';

class WinDocPageController extends MvcController {
  WinHomeController homeController;
  var searchController = TextEditingController();
  var searchContent = "".obs;
  WinDocListController? docListController;
  var docListControllerMap = <String, WinDocListController>{};

  WinDocPageController(this.homeController);

  void createDoc(BuildContext context, String text) async {
    var doc = await docListController?.createDoc(context, text);
    docListController?.selectItem.value = doc?.uuid;
  }

  void createDirectory(BuildContext context, String text) async {
    var dir = await docListController?.createDirectory(context, text);
    docListController?.selectItem.value = dir?.uuid;
  }

  void onPushRoute(Route? route) {}

  void onPopRoute(Route? route) {}

  void openDoc(DocPO doc, bool isCreateMode) {
    homeController.openDoc(doc,isCreateMode);
  }
}
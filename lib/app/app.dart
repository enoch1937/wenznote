import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:note/app/mobile/view/card/detail/mobile_card_detail_controller.dart';
import 'package:note/app/mobile/view/card/detail/mobile_card_detail_page.dart';
import 'package:note/app/mobile/view/card/edit/mobile_card_edit_controller.dart';
import 'package:note/app/mobile/view/card/mobile_card_page.dart';
import 'package:note/app/mobile/view/card/mobile_card_page_controller.dart';
import 'package:note/app/mobile/view/card/settings/mobile_card_settings_controller.dart';
import 'package:note/app/mobile/view/card/settings/mobile_card_settings_page.dart';
import 'package:note/app/mobile/view/card/study/mobile_study_controller.dart';
import 'package:note/app/mobile/view/card/study/mobile_study_page.dart';
import 'package:note/app/mobile/view/doc/mobile_doc_page.dart';
import 'package:note/app/mobile/view/doc/mobile_doc_page_controller.dart';
import 'package:note/app/mobile/view/edit/doc_edit_controller.dart';
import 'package:note/app/mobile/view/edit/doc_edit_widget.dart';
import 'package:note/app/mobile/view/home/mobile_home_page.dart';
import 'package:note/app/mobile/view/today/mobile_today_controller.dart';
import 'package:note/commons/mvc/controller.dart';
import 'package:note/commons/mvc/view.dart';
import 'package:note/commons/widget/ignore_parent_pointer.dart';
import 'package:note/config/theme_settings.dart';
import 'package:note/widgets/root_widget.dart';
import 'package:oktoast/oktoast.dart';

import 'mobile/view/today/mobile_today_page.dart';

class AppController extends MvcController {}

final GlobalKey<NavigatorState> _appNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'app');

class AppWidget extends MvcView<AppController> {
  AppWidget({super.key, required super.controller});

  final GoRouter _router = GoRouter(
    navigatorKey: _appNavigatorKey,
    initialLocation: (Platform.isIOS || Platform.isAndroid)
        ? "/mobile/local/today"
        : "/mobile/local/today",
    routes: [
      GoRoute(
        path: "/mobile/:userId",
        redirect: (context, state) {
          return null;
        },
        routes: [
          buildHomeRoute(),
          GoRoute(
            path: "doc/edit",
            builder: (context, state) {
              var params = state.extra as Map;
              return MobileDocEditWidget(
                controller: MobileDocEditController(
                  doc: params['doc'],
                  editOnOpen: params["editOnOpen"] ?? false,
                ),
              );
            },
          ),
          GoRoute(
            path: "card/edit",
            builder: (context, state) {
              var params = state.extra as Map;
              return MobileDocEditWidget(
                controller: MobileCardEditController(
                  card: params['card'],
                  editOnOpen: params['editOnOpen'],
                ),
              );
            },
          ),
          GoRoute(
            path: "cardSet/:cardSetId",
            builder: (context, state) {
              return MobileCardDetailPage(
                controller: MobileCardDetailController(
                    cardSetId: state.pathParameters["cardSetId"]),
              );
            },
          ),
          GoRoute(
            path: "cardSet/:cardSetId/settings",
            builder: (context, state) {
              var map = state.extra as Map;
              return MobileCardSettingsPage(
                controller:
                MobileCardSettingsController(cardSet: map['cardSet']),
              );
            },
          ),
          GoRoute(
            path: "cardSet/:cardSetId/study",
            builder: (context, state) {
              var map = state.extra as Map;
              return MobileStudyPage(
                controller:
                MobileStudyController(cardSet: map['cardSet']),
              );
            },
          ),
        ],
      ),
    ],
  );

  static StatefulShellRoute buildHomeRoute() {
    return StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state,
          StatefulNavigationShell navigationShell) {
        return MobileHomePage(navigationShell: navigationShell);
      },
      branches: [
        // today
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: 'today',
              builder: (BuildContext context, GoRouterState state) {
                return MobileTodayPageWidget(
                    controller: MobileTodayController());
              },
            ),
          ],
        ),
        // note
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: 'doc',
              pageBuilder: (context, state) {
                return CustomTransitionPage(
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                  child: MobileDocPage(controller: MobileDocPageController()),
                  transitionsBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation,
                      Widget child) {
                    return child;
                  },
                );
              },
              routes: [
                GoRoute(
                  path: "dir/:pid",
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                      child: MobileDocPage(
                        controller: MobileDocPageController(
                          pid: state.pathParameters['pid'],
                        ),
                      ),
                      transitionsBuilder: (BuildContext context,
                          Animation<double> animation,
                          Animation<double> secondaryAnimation,
                          Widget child) {
                        return child;
                      },
                    );
                  },
                )
              ],
            ),
          ],
        ),
        // card
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: 'card',
              builder: (BuildContext context, GoRouterState state) {
                return MobileCardPage(controller: MobileCardPageController());
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var brightness = ThemeSettings.instance.getBrightness();
    return ServiceManagerWidget(builder: (context) {
      return OKToast(
        child: IgnoreParentMousePointerContainer(
          child: MaterialApp.router(
            title: "温知笔记",
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: "MiSans",
              brightness: brightness,
            ),
            locale: const Locale('zh', 'CN'),
            supportedLocales: const [
              Locale('zh', 'CN'), // English, no country code
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              fluent.FluentLocalizations.delegate,
            ],
            builder: (context, child) {
              return fluent.FluentTheme(
                data: fluent.FluentThemeData(
                  fontFamily: "MiSans",
                  brightness: brightness,
                  acrylicBackgroundColor: Colors.grey.withAlpha(10),
                ),
                child: Container(child: child ?? Container()),
              );
            },
          ),
        ),
      );
    });
  }
}
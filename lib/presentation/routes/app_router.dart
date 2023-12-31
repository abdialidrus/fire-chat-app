import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/presentation/pages/auth/auth_page.dart';
import 'package:flutter_chat_app/presentation/pages/auth/sign_in_or_sign_up_page.dart';
import 'package:flutter_chat_app/presentation/pages/auth/sign_in_page.dart';
import 'package:flutter_chat_app/presentation/pages/auth/sign_up_page.dart';
import 'package:flutter_chat_app/presentation/pages/chat_room_page.dart';
import 'package:flutter_chat_app/presentation/pages/home_page.dart';
import 'package:flutter_chat_app/presentation/pages/landing_page.dart';
import 'package:flutter_chat_app/presentation/pages/profile_page.dart';
import 'package:flutter_chat_app/presentation/pages/select_recipient_page.dart';
import 'package:flutter_chat_app/presentation/pages/splash_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: AuthRoute.page),
        AutoRoute(page: LandingRoute.page),
        AutoRoute(page: SignInOrSignUpRoute.page),
        AutoRoute(page: SignInRoute.page),
        AutoRoute(page: SignUpRoute.page),
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: SelectRecipientRoute.page),
        AutoRoute(page: ChatRoomRoute.page),
        AutoRoute(page: ProfileRoute.page),
      ];
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../pages/splash_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/home_page.dart';
import '../pages/couple_bind_page.dart';
import '../pages/profile_edit_page.dart';
import '../pages/couple_profile_page.dart';
import '../pages/chat_list_page.dart';
import '../pages/chat_page.dart';
import '../pages/album_page.dart';
import '../pages/photo_view_page.dart';
import '../pages/upload_photo_page.dart';

/// 路由配置
class AppRoutes {
  AppRoutes._();

  // ===== 路由名称 =====
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String coupleBind = '/couple-bind';
  static const String profileEdit = '/profile-edit';
  static const String coupleProfile = '/couple-profile';
  static const String chatList = '/chat-list';
  static const String chat = '/chat';
  static const String photoView = '/photo-view';
  static const String uploadPhoto = '/upload-photo';

  // ===== 路由页面列表 =====
  static final List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashPage(),
      transition: Transition.fade,
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: coupleBind,
      page: () => const CoupleBindPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: profileEdit,
      page: () => const ProfileEditPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: coupleProfile,
      page: () => const CoupleProfilePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: chatList,
      page: () => const ChatListPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: chat,
      page: () => const ChatPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: photoView,
      page: () => const PhotoViewPage(),
      transition: Transition.fade,
    ),
    GetPage(
      name: uploadPhoto,
      page: () => const UploadPhotoPage(),
      transition: Transition.rightToLeft,
    ),
  ];
}

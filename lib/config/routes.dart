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
import '../pages/anniversary_page.dart';
import '../pages/anniversary_form_page.dart';
import '../pages/mood_page.dart';
import '../pages/mood_checkin_page.dart';
import '../pages/location_share_page.dart';
import '../pages/location_history_page.dart';
import '../pages/diary_page.dart';
import '../pages/diary_write_page.dart';
import '../pages/diary_detail_page.dart';

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
  static const String album = '/album';
  static const String anniversary = '/anniversary';
  static const String anniversaryForm = '/anniversary-form';
  static const String mood = '/mood';
  static const String moodCheckin = '/mood-checkin';
  static const String locationShare = '/location-share';
  static const String locationHistory = '/location-history';
  static const String diary = '/diary';
  static const String diaryWrite = '/diary-write';
  static const String diaryDetail = '/diary-detail';

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
    GetPage(
      name: album,
      page: () => const AlbumPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: anniversary,
      page: () => const AnniversaryPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: anniversaryForm,
      page: () => const AnniversaryFormPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: mood,
      page: () => const MoodPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: moodCheckin,
      page: () => const MoodCheckinPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: locationShare,
      page: () => const LocationSharePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: locationHistory,
      page: () => const LocationHistoryPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: diary,
      page: () => const DiaryPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: diaryWrite,
      page: () => const DiaryWritePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: diaryDetail,
      page: () => const DiaryDetailPage(),
      transition: Transition.rightToLeft,
    ),
  ];
}

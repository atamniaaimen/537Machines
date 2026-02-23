// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/material.dart' as _i14;
import 'package:flutter/material.dart';
import 'package:machine_marketplace/ui/views/create_listing/create_listing_view.dart'
    as _i8;
import 'package:machine_marketplace/ui/views/edit_listing/edit_listing_view.dart'
    as _i9;
import 'package:machine_marketplace/ui/views/edit_profile/edit_profile_view.dart'
    as _i11;
import 'package:machine_marketplace/ui/views/listing_detail/listing_detail_view.dart'
    as _i7;
import 'package:machine_marketplace/ui/views/listings/listings_view.dart'
    as _i6;
import 'package:machine_marketplace/ui/views/login/login_view.dart' as _i3;
import 'package:machine_marketplace/ui/views/main/main_view.dart' as _i5;
import 'package:machine_marketplace/ui/views/messages/messages_view.dart'
    as _i13;
import 'package:machine_marketplace/ui/views/profile/profile_view.dart' as _i10;
import 'package:machine_marketplace/ui/views/register/register_view.dart'
    as _i4;
import 'package:machine_marketplace/ui/views/search/search_view.dart' as _i12;
import 'package:machine_marketplace/ui/views/startup/startup_view.dart' as _i2;
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i15;

class Routes {
  static const startupView = '/';

  static const loginView = '/login-view';

  static const registerView = '/register-view';

  static const mainView = '/main-view';

  static const listingsView = '/listings-view';

  static const listingDetailView = '/listing-detail-view';

  static const createListingView = '/create-listing-view';

  static const editListingView = '/edit-listing-view';

  static const profileView = '/profile-view';

  static const editProfileView = '/edit-profile-view';

  static const searchView = '/search-view';

  static const messagesView = '/messages-view';

  static const all = <String>{
    startupView,
    loginView,
    registerView,
    mainView,
    listingsView,
    listingDetailView,
    createListingView,
    editListingView,
    profileView,
    editProfileView,
    searchView,
    messagesView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.startupView,
      page: _i2.StartupView,
    ),
    _i1.RouteDef(
      Routes.loginView,
      page: _i3.LoginView,
    ),
    _i1.RouteDef(
      Routes.registerView,
      page: _i4.RegisterView,
    ),
    _i1.RouteDef(
      Routes.mainView,
      page: _i5.MainView,
    ),
    _i1.RouteDef(
      Routes.listingsView,
      page: _i6.ListingsView,
    ),
    _i1.RouteDef(
      Routes.listingDetailView,
      page: _i7.ListingDetailView,
    ),
    _i1.RouteDef(
      Routes.createListingView,
      page: _i8.CreateListingView,
    ),
    _i1.RouteDef(
      Routes.editListingView,
      page: _i9.EditListingView,
    ),
    _i1.RouteDef(
      Routes.profileView,
      page: _i10.ProfileView,
    ),
    _i1.RouteDef(
      Routes.editProfileView,
      page: _i11.EditProfileView,
    ),
    _i1.RouteDef(
      Routes.searchView,
      page: _i12.SearchView,
    ),
    _i1.RouteDef(
      Routes.messagesView,
      page: _i13.MessagesView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.StartupView: (data) {
      return _i14.MaterialPageRoute<dynamic>(
        builder: (context) => const _i2.StartupView(),
        settings: data,
      );
    },
    _i3.LoginView: (data) {
      return _i14.MaterialPageRoute<dynamic>(
        builder: (context) => const _i3.LoginView(),
        settings: data,
      );
    },
    _i4.RegisterView: (data) {
      return _i14.MaterialPageRoute<dynamic>(
        builder: (context) => const _i4.RegisterView(),
        settings: data,
      );
    },
    _i5.MainView: (data) {
      return _i14.MaterialPageRoute<dynamic>(
        builder: (context) => const _i5.MainView(),
        settings: data,
      );
    },
    _i6.ListingsView: (data) {
      return _i14.MaterialPageRoute<dynamic>(
        builder: (context) => const _i6.ListingsView(),
        settings: data,
      );
    },
    _i7.ListingDetailView: (data) {
      final args = data.getArgs<ListingDetailViewArguments>(nullOk: false);
      return _i14.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i7.ListingDetailView(listingId: args.listingId, key: args.key),
        settings: data,
      );
    },
    _i8.CreateListingView: (data) {
      return _i14.MaterialPageRoute<dynamic>(
        builder: (context) => const _i8.CreateListingView(),
        settings: data,
      );
    },
    _i9.EditListingView: (data) {
      final args = data.getArgs<EditListingViewArguments>(nullOk: false);
      return _i14.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i9.EditListingView(listingId: args.listingId, key: args.key),
        settings: data,
      );
    },
    _i10.ProfileView: (data) {
      return _i14.MaterialPageRoute<dynamic>(
        builder: (context) => const _i10.ProfileView(),
        settings: data,
      );
    },
    _i11.EditProfileView: (data) {
      return _i14.MaterialPageRoute<dynamic>(
        builder: (context) => const _i11.EditProfileView(),
        settings: data,
      );
    },
    _i12.SearchView: (data) {
      return _i14.MaterialPageRoute<dynamic>(
        builder: (context) => const _i12.SearchView(),
        settings: data,
      );
    },
    _i13.MessagesView: (data) {
      return _i14.MaterialPageRoute<dynamic>(
        builder: (context) => const _i13.MessagesView(),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class ListingDetailViewArguments {
  const ListingDetailViewArguments({
    required this.listingId,
    this.key,
  });

  final String listingId;

  final _i14.Key? key;

  @override
  String toString() {
    return '{"listingId": "$listingId", "key": "$key"}';
  }

  @override
  bool operator ==(covariant ListingDetailViewArguments other) {
    if (identical(this, other)) return true;
    return other.listingId == listingId && other.key == key;
  }

  @override
  int get hashCode {
    return listingId.hashCode ^ key.hashCode;
  }
}

class EditListingViewArguments {
  const EditListingViewArguments({
    required this.listingId,
    this.key,
  });

  final String listingId;

  final _i14.Key? key;

  @override
  String toString() {
    return '{"listingId": "$listingId", "key": "$key"}';
  }

  @override
  bool operator ==(covariant EditListingViewArguments other) {
    if (identical(this, other)) return true;
    return other.listingId == listingId && other.key == key;
  }

  @override
  int get hashCode {
    return listingId.hashCode ^ key.hashCode;
  }
}

extension NavigatorStateExtension on _i15.NavigationService {
  Future<dynamic> navigateToStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLoginView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.loginView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToRegisterView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.registerView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToMainView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.mainView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToListingsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.listingsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToListingDetailView({
    required String listingId,
    _i14.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.listingDetailView,
        arguments: ListingDetailViewArguments(listingId: listingId, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCreateListingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.createListingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToEditListingView({
    required String listingId,
    _i14.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.editListingView,
        arguments: EditListingViewArguments(listingId: listingId, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToProfileView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.profileView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToEditProfileView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.editProfileView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSearchView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.searchView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToMessagesView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.messagesView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLoginView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.loginView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithRegisterView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.registerView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithMainView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.mainView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithListingsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.listingsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithListingDetailView({
    required String listingId,
    _i14.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.listingDetailView,
        arguments: ListingDetailViewArguments(listingId: listingId, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCreateListingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.createListingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithEditListingView({
    required String listingId,
    _i14.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.editListingView,
        arguments: EditListingViewArguments(listingId: listingId, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithProfileView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.profileView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithEditProfileView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.editProfileView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSearchView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.searchView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithMessagesView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.messagesView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}

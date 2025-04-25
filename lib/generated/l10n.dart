// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Innovate Your Move`
  String get logo_title {
    return Intl.message(
      'Innovate Your Move',
      name: 'logo_title',
      desc: '',
      args: [],
    );
  }

  /// `ThinkStep`
  String get title {
    return Intl.message('ThinkStep', name: 'title', desc: '', args: []);
  }

  /// `ahmed`
  String get text1 {
    return Intl.message('ahmed', name: 'text1', desc: '', args: []);
  }

  /// `ahmed`
  String get text2 {
    return Intl.message('ahmed', name: 'text2', desc: '', args: []);
  }

  /// `Welcome!`
  String get text3 {
    return Intl.message('Welcome!', name: 'text3', desc: '', args: []);
  }

  /// `to`
  String get text4 {
    return Intl.message('to', name: 'text4', desc: '', args: []);
  }

  /// `ThinkStep`
  String get text8 {
    return Intl.message('ThinkStep', name: 'text8', desc: '', args: []);
  }

  /// `Choose Your User Type To Get Started`
  String get text5 {
    return Intl.message(
      'Choose Your User Type To Get Started',
      name: 'text5',
      desc: '',
      args: [],
    );
  }

  /// `Patient`
  String get text6 {
    return Intl.message('Patient', name: 'text6', desc: '', args: []);
  }

  /// `Caregiver`
  String get text7 {
    return Intl.message('Caregiver', name: 'text7', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}

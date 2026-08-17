import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'VAG-DMP'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @phoneOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Phone Number or Email'**
  String get phoneOrEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to VAG-DMP'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Empowering Villages, Tracking Progress'**
  String get loginSubtitle;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navVillages.
  ///
  /// In en, this message translates to:
  /// **'Villages'**
  String get navVillages;

  /// No description provided for @navMeetings.
  ///
  /// In en, this message translates to:
  /// **'Meetings'**
  String get navMeetings;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @dashboardWelcome.
  ///
  /// In en, this message translates to:
  /// **'Namaste, {userName} 🙏'**
  String dashboardWelcome(String userName);

  /// No description provided for @upcomingMeetings.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Meetings'**
  String get upcomingMeetings;

  /// No description provided for @openIssues.
  ///
  /// In en, this message translates to:
  /// **'Open Issues'**
  String get openIssues;

  /// No description provided for @villagesAssigned.
  ///
  /// In en, this message translates to:
  /// **'Villages Assigned'**
  String get villagesAssigned;

  /// No description provided for @logNewIssue.
  ///
  /// In en, this message translates to:
  /// **'Log New Issue'**
  String get logNewIssue;

  /// No description provided for @startMeeting.
  ///
  /// In en, this message translates to:
  /// **'Start Meeting'**
  String get startMeeting;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @totalVillages.
  ///
  /// In en, this message translates to:
  /// **'Total Villages'**
  String get totalVillages;

  /// No description provided for @activeIssues.
  ///
  /// In en, this message translates to:
  /// **'Active Issues'**
  String get activeIssues;

  /// No description provided for @resolvedThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Resolved This Month'**
  String get resolvedThisMonth;

  /// No description provided for @meetingsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Meetings This Week'**
  String get meetingsThisWeek;

  /// No description provided for @villageList.
  ///
  /// In en, this message translates to:
  /// **'Villages'**
  String get villageList;

  /// No description provided for @searchVillages.
  ///
  /// In en, this message translates to:
  /// **'Search villages...'**
  String get searchVillages;

  /// No description provided for @villageMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get villageMembers;

  /// No description provided for @villageIssues.
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get villageIssues;

  /// No description provided for @villageMeetings.
  ///
  /// In en, this message translates to:
  /// **'Meetings'**
  String get villageMeetings;

  /// No description provided for @villageOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get villageOverview;

  /// No description provided for @createMeeting.
  ///
  /// In en, this message translates to:
  /// **'Create Meeting'**
  String get createMeeting;

  /// No description provided for @meetingDate.
  ///
  /// In en, this message translates to:
  /// **'Meeting Date'**
  String get meetingDate;

  /// No description provided for @villageName.
  ///
  /// In en, this message translates to:
  /// **'Village Name'**
  String get villageName;

  /// No description provided for @attendeesCount.
  ///
  /// In en, this message translates to:
  /// **'Number of Attendees'**
  String get attendeesCount;

  /// No description provided for @meetingNotes.
  ///
  /// In en, this message translates to:
  /// **'Meeting Notes'**
  String get meetingNotes;

  /// No description provided for @attachPhoto.
  ///
  /// In en, this message translates to:
  /// **'Attach Photo'**
  String get attachPhoto;

  /// No description provided for @saveMeeting.
  ///
  /// In en, this message translates to:
  /// **'Save Meeting'**
  String get saveMeeting;

  /// No description provided for @logIssue.
  ///
  /// In en, this message translates to:
  /// **'Log Issue'**
  String get logIssue;

  /// No description provided for @issueTitle.
  ///
  /// In en, this message translates to:
  /// **'Issue Title'**
  String get issueTitle;

  /// No description provided for @issueCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get issueCategory;

  /// No description provided for @issueSeverity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get issueSeverity;

  /// No description provided for @issueDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get issueDescription;

  /// No description provided for @submitIssue.
  ///
  /// In en, this message translates to:
  /// **'Submit Issue'**
  String get submitIssue;

  /// No description provided for @categoryWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get categoryWater;

  /// No description provided for @categorySanitation.
  ///
  /// In en, this message translates to:
  /// **'Sanitation'**
  String get categorySanitation;

  /// No description provided for @categoryRoads.
  ///
  /// In en, this message translates to:
  /// **'Roads'**
  String get categoryRoads;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @severityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get severityLow;

  /// No description provided for @severityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get severityMedium;

  /// No description provided for @severityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get severityHigh;

  /// No description provided for @statusReported.
  ///
  /// In en, this message translates to:
  /// **'Reported'**
  String get statusReported;

  /// No description provided for @statusEscalated.
  ///
  /// In en, this message translates to:
  /// **'Escalated to Govt'**
  String get statusEscalated;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// No description provided for @memberDirectory.
  ///
  /// In en, this message translates to:
  /// **'Member Directory'**
  String get memberDirectory;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get addMember;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

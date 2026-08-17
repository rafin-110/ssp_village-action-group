// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'वीएजी-डीएमपी';

  @override
  String get login => 'लॉगिन';

  @override
  String get phoneOrEmail => 'फ़ोन नंबर या ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get loginButton => 'लॉगिन करें';

  @override
  String get loginWelcome => 'वीएजी-डीएमपी में आपका स्वागत है';

  @override
  String get loginSubtitle => 'गाँवों को सशक्त बनाना, प्रगति को ट्रैक करना';

  @override
  String get navDashboard => 'डैशबोर्ड';

  @override
  String get navVillages => 'गाँव';

  @override
  String get navMeetings => 'बैठकें';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String dashboardWelcome(String userName) {
    return 'नमस्ते, $userName 🙏';
  }

  @override
  String get upcomingMeetings => 'आगामी बैठकें';

  @override
  String get openIssues => 'खुले मुद्दे';

  @override
  String get villagesAssigned => 'सौंपे गए गाँव';

  @override
  String get logNewIssue => 'नया मुद्दा दर्ज करें';

  @override
  String get startMeeting => 'बैठक शुरू करें';

  @override
  String get recentActivity => 'हालिया गतिविधि';

  @override
  String get totalVillages => 'कुल गाँव';

  @override
  String get activeIssues => 'सक्रिय मुद्दे';

  @override
  String get resolvedThisMonth => 'इस माह हल किए गए';

  @override
  String get meetingsThisWeek => 'इस सप्ताह की बैठकें';

  @override
  String get villageList => 'गाँव';

  @override
  String get searchVillages => 'गाँव खोजें...';

  @override
  String get villageMembers => 'सदस्य';

  @override
  String get villageIssues => 'मुद्दे';

  @override
  String get villageMeetings => 'बैठकें';

  @override
  String get villageOverview => 'अवलोकन';

  @override
  String get createMeeting => 'बैठक बनाएं';

  @override
  String get meetingDate => 'बैठक की तारीख';

  @override
  String get villageName => 'गाँव का नाम';

  @override
  String get attendeesCount => 'उपस्थित सदस्यों की संख्या';

  @override
  String get meetingNotes => 'बैठक नोट्स';

  @override
  String get attachPhoto => 'फोटो जोड़ें';

  @override
  String get saveMeeting => 'बैठक सहेजें';

  @override
  String get logIssue => 'मुद्दा दर्ज करें';

  @override
  String get issueTitle => 'मुद्दे का शीर्षक';

  @override
  String get issueCategory => 'श्रेणी';

  @override
  String get issueSeverity => 'गंभीरता';

  @override
  String get issueDescription => 'विवरण';

  @override
  String get submitIssue => 'मुद्दा जमा करें';

  @override
  String get categoryWater => 'पानी';

  @override
  String get categorySanitation => 'स्वच्छता';

  @override
  String get categoryRoads => 'सड़कें';

  @override
  String get categoryEducation => 'शिक्षा';

  @override
  String get categoryHealth => 'स्वास्थ्य';

  @override
  String get categoryOther => 'अन्य';

  @override
  String get severityLow => 'कम';

  @override
  String get severityMedium => 'मध्यम';

  @override
  String get severityHigh => 'उच्च';

  @override
  String get statusReported => 'रिपोर्ट किया गया';

  @override
  String get statusEscalated => 'सरकार को भेजा गया';

  @override
  String get statusInProgress => 'प्रगति में';

  @override
  String get statusResolved => 'हल किया गया';

  @override
  String get memberDirectory => 'सदस्य निर्देशिका';

  @override
  String get addMember => 'सदस्य जोड़ें';

  @override
  String get noData => 'कोई डेटा उपलब्ध नहीं';

  @override
  String get save => 'सहेजें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get edit => 'संपादित करें';

  @override
  String get viewAll => 'सभी देखें';
}

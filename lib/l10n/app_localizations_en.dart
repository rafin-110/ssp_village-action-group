// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'VAG-DMP';

  @override
  String get login => 'Login';

  @override
  String get phoneOrEmail => 'Phone Number or Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get loginButton => 'Login';

  @override
  String get loginWelcome => 'Welcome to VAG-DMP';

  @override
  String get loginSubtitle => 'Empowering Villages, Tracking Progress';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navVillages => 'Villages';

  @override
  String get navMeetings => 'Meetings';

  @override
  String get navProfile => 'Profile';

  @override
  String dashboardWelcome(String userName) {
    return 'Namaste, $userName 🙏';
  }

  @override
  String get upcomingMeetings => 'Upcoming Meetings';

  @override
  String get openIssues => 'Open Issues';

  @override
  String get villagesAssigned => 'Villages Assigned';

  @override
  String get logNewIssue => 'Log New Issue';

  @override
  String get startMeeting => 'Start Meeting';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get totalVillages => 'Total Villages';

  @override
  String get activeIssues => 'Active Issues';

  @override
  String get resolvedThisMonth => 'Resolved This Month';

  @override
  String get meetingsThisWeek => 'Meetings This Week';

  @override
  String get villageList => 'Villages';

  @override
  String get searchVillages => 'Search villages...';

  @override
  String get villageMembers => 'Members';

  @override
  String get villageIssues => 'Issues';

  @override
  String get villageMeetings => 'Meetings';

  @override
  String get villageOverview => 'Overview';

  @override
  String get createMeeting => 'Create Meeting';

  @override
  String get meetingDate => 'Meeting Date';

  @override
  String get villageName => 'Village Name';

  @override
  String get attendeesCount => 'Number of Attendees';

  @override
  String get meetingNotes => 'Meeting Notes';

  @override
  String get attachPhoto => 'Attach Photo';

  @override
  String get saveMeeting => 'Save Meeting';

  @override
  String get logIssue => 'Log Issue';

  @override
  String get issueTitle => 'Issue Title';

  @override
  String get issueCategory => 'Category';

  @override
  String get issueSeverity => 'Severity';

  @override
  String get issueDescription => 'Description';

  @override
  String get submitIssue => 'Submit Issue';

  @override
  String get categoryWater => 'Water';

  @override
  String get categorySanitation => 'Sanitation';

  @override
  String get categoryRoads => 'Roads';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryOther => 'Other';

  @override
  String get severityLow => 'Low';

  @override
  String get severityMedium => 'Medium';

  @override
  String get severityHigh => 'High';

  @override
  String get statusReported => 'Reported';

  @override
  String get statusEscalated => 'Escalated to Govt';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get memberDirectory => 'Member Directory';

  @override
  String get addMember => 'Add Member';

  @override
  String get noData => 'No data available';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get viewAll => 'View All';
}

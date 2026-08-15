import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Prime'**
  String get appTitle;

  /// No description provided for @startupFailureTitle.
  ///
  /// In en, this message translates to:
  /// **'Prime couldn\'t start'**
  String get startupFailureTitle;

  /// No description provided for @startupFailureBody.
  ///
  /// In en, this message translates to:
  /// **'Your data could not be loaded. Restarting the app usually fixes this.'**
  String get startupFailureBody;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navQuests.
  ///
  /// In en, this message translates to:
  /// **'Quests'**
  String get navQuests;

  /// No description provided for @navStory.
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get navStory;

  /// No description provided for @navJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get navJournal;

  /// No description provided for @navYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get navYou;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

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

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @noQuestsYet.
  ///
  /// In en, this message translates to:
  /// **'No quests yet. Quests you create will show up here.'**
  String get noQuestsYet;

  /// No description provided for @browseSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Browse Suggestions'**
  String get browseSuggestions;

  /// No description provided for @createQuestLabel.
  ///
  /// In en, this message translates to:
  /// **'Create Quest'**
  String get createQuestLabel;

  /// No description provided for @difficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficultyLabel;

  /// No description provided for @repeatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get repeatsLabel;

  /// No description provided for @attributeAllocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Attribute allocation'**
  String get attributeAllocationLabel;

  /// No description provided for @questNotFound.
  ///
  /// In en, this message translates to:
  /// **'This quest doesn\'t exist or was removed.'**
  String get questNotFound;

  /// No description provided for @couldntLoadQuest.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this quest.'**
  String get couldntLoadQuest;

  /// No description provided for @questLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong loading this quest. Please try again.'**
  String get questLoadErrorBody;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @greetingNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get greetingNight;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @playerLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String playerLevelLabel(int level);

  /// No description provided for @playerXpTotal.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP total'**
  String playerXpTotal(String xp);

  /// No description provided for @playerXpToNextLevel.
  ///
  /// In en, this message translates to:
  /// **'{current} / {needed} XP to next level'**
  String playerXpToNextLevel(int current, int needed);

  /// No description provided for @motivationalLine1.
  ///
  /// In en, this message translates to:
  /// **'Small consistent steps compound.'**
  String get motivationalLine1;

  /// No description provided for @motivationalLine2.
  ///
  /// In en, this message translates to:
  /// **'Momentum is built one quest at a time.'**
  String get motivationalLine2;

  /// No description provided for @motivationalLine3.
  ///
  /// In en, this message translates to:
  /// **'Discipline today, progress tomorrow.'**
  String get motivationalLine3;

  /// No description provided for @motivationalLine4.
  ///
  /// In en, this message translates to:
  /// **'Show up — the rest follows.'**
  String get motivationalLine4;

  /// No description provided for @motivationalLine5.
  ///
  /// In en, this message translates to:
  /// **'Every rep counts toward the next level.'**
  String get motivationalLine5;

  /// No description provided for @couldntLoadLevel.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your level.'**
  String get couldntLoadLevel;

  /// No description provided for @dailyMomentumTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily momentum'**
  String get dailyMomentumTitle;

  /// No description provided for @dailyMomentumNoQuests.
  ///
  /// In en, this message translates to:
  /// **'No quests yet'**
  String get dailyMomentumNoQuests;

  /// No description provided for @dailyMomentumProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} quests completed'**
  String dailyMomentumProgress(int completed, int total);

  /// No description provided for @dailyMomentumXpToday.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP today'**
  String dailyMomentumXpToday(String xp);

  /// No description provided for @couldntLoadTodayProgress.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load today\'s progress.'**
  String get couldntLoadTodayProgress;

  /// No description provided for @growthTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Growth today'**
  String get growthTodayTitle;

  /// No description provided for @growthTodayEmpty.
  ///
  /// In en, this message translates to:
  /// **'No XP earned today'**
  String get growthTodayEmpty;

  /// No description provided for @couldntLoadTodayXp.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load today\'s XP.'**
  String get couldntLoadTodayXp;

  /// No description provided for @couldntLoadTodayQuests.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load today\'s quests.'**
  String get couldntLoadTodayQuests;

  /// No description provided for @mainQuestLabel.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S MISSION'**
  String get mainQuestLabel;

  /// No description provided for @heroCtaBegin.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get heroCtaBegin;

  /// No description provided for @heroEmptyHeadline.
  ///
  /// In en, this message translates to:
  /// **'Ready for today\'s mission?'**
  String get heroEmptyHeadline;

  /// No description provided for @completedTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed today'**
  String get completedTodayLabel;

  /// No description provided for @ctaView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get ctaView;

  /// No description provided for @ctaComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get ctaComplete;

  /// No description provided for @ctaAddProgress.
  ///
  /// In en, this message translates to:
  /// **'Add Progress'**
  String get ctaAddProgress;

  /// No description provided for @ctaContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get ctaContinue;

  /// No description provided for @couldntLoadMainQuest.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your main quest.'**
  String get couldntLoadMainQuest;

  /// No description provided for @questsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quests'**
  String get questsTitle;

  /// No description provided for @suggestionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestionsTooltip;

  /// No description provided for @createQuestTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create Quest'**
  String get createQuestTooltip;

  /// No description provided for @couldntLoadQuests.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load quests.'**
  String get couldntLoadQuests;

  /// No description provided for @questsLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong loading your quests. Please try again.'**
  String get questsLoadErrorBody;

  /// No description provided for @questFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Quest'**
  String get questFallbackTitle;

  /// No description provided for @editQuestTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit Quest'**
  String get editQuestTooltip;

  /// No description provided for @deleteQuestTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete Quest'**
  String get deleteQuestTooltip;

  /// No description provided for @questCompletedXp.
  ///
  /// In en, this message translates to:
  /// **'Quest completed — +{xp} XP'**
  String questCompletedXp(int xp);

  /// No description provided for @deleteQuestDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete quest?'**
  String get deleteQuestDialogTitle;

  /// No description provided for @deleteQuestDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"? This removes the quest and its daily progress. XP you already earned from it is kept.'**
  String deleteQuestDialogBody(String title);

  /// No description provided for @questCompleteForToday.
  ///
  /// In en, this message translates to:
  /// **'Quest complete for today'**
  String get questCompleteForToday;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @baseXpLabel.
  ///
  /// In en, this message translates to:
  /// **'Base XP'**
  String get baseXpLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @couldntCompleteQuest.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t complete this quest'**
  String get couldntCompleteQuest;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @titleRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequiredError;

  /// No description provided for @titleTooLongError.
  ///
  /// In en, this message translates to:
  /// **'Title must be 100 characters or fewer'**
  String get titleTooLongError;

  /// No description provided for @descriptionTooLongError.
  ///
  /// In en, this message translates to:
  /// **'Description must be 500 characters or fewer'**
  String get descriptionTooLongError;

  /// No description provided for @questTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Quest type'**
  String get questTypeLabel;

  /// No description provided for @progressTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress type'**
  String get progressTypeLabel;

  /// No description provided for @targetProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Target progress'**
  String get targetProgressLabel;

  /// No description provided for @enterPositiveNumberError.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive number'**
  String get enterPositiveNumberError;

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesBody.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. If you leave now, they won\'t be saved.'**
  String get discardChangesBody;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep Editing'**
  String get keepEditing;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @newQuestTitle.
  ///
  /// In en, this message translates to:
  /// **'New Quest'**
  String get newQuestTitle;

  /// No description provided for @editQuestTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Quest'**
  String get editQuestTitle;

  /// No description provided for @addAttributeButton.
  ///
  /// In en, this message translates to:
  /// **'Add attribute'**
  String get addAttributeButton;

  /// No description provided for @totalXpLabel.
  ///
  /// In en, this message translates to:
  /// **'Total: {total} XP'**
  String totalXpLabel(int total);

  /// No description provided for @attributeLabel.
  ///
  /// In en, this message translates to:
  /// **'Attribute'**
  String get attributeLabel;

  /// No description provided for @xpWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'XP weight'**
  String get xpWeightLabel;

  /// No description provided for @enterWholeNumberError.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number'**
  String get enterWholeNumberError;

  /// No description provided for @mustNotBeNegativeError.
  ///
  /// In en, this message translates to:
  /// **'Must not be negative'**
  String get mustNotBeNegativeError;

  /// No description provided for @removeAttributeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove attribute'**
  String get removeAttributeTooltip;

  /// No description provided for @completeQuestButton.
  ///
  /// In en, this message translates to:
  /// **'Complete Quest'**
  String get completeQuestButton;

  /// No description provided for @progressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressLabel;

  /// No description provided for @decreaseBy1.
  ///
  /// In en, this message translates to:
  /// **'Decrease by 1'**
  String get decreaseBy1;

  /// No description provided for @increaseBy1.
  ///
  /// In en, this message translates to:
  /// **'Increase by 1'**
  String get increaseBy1;

  /// No description provided for @customAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom amount'**
  String get customAmountLabel;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @decrementMinutes.
  ///
  /// In en, this message translates to:
  /// **'-{minutes} min'**
  String decrementMinutes(int minutes);

  /// No description provided for @minutesValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesValue(String minutes);

  /// No description provided for @minutesUnit.
  ///
  /// In en, this message translates to:
  /// **' min'**
  String get minutesUnit;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @notYetLabel.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get notYetLabel;

  /// No description provided for @completionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 time} other{{count} times}}'**
  String completionsCount(int count);

  /// No description provided for @xpEarnedTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'XP earned today'**
  String get xpEarnedTodayLabel;

  /// No description provided for @xpAmount.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP'**
  String xpAmount(String xp);

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @unlockedSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlockedSectionHeader;

  /// No description provided for @lockedSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lockedSectionHeader;

  /// No description provided for @noneUnlockedYet.
  ///
  /// In en, this message translates to:
  /// **'None yet — complete quests to start unlocking.'**
  String get noneUnlockedYet;

  /// No description provided for @allUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Every achievement is unlocked.'**
  String get allUnlocked;

  /// No description provided for @achievementSummaryCount.
  ///
  /// In en, this message translates to:
  /// **'{unlocked} / {total}'**
  String achievementSummaryCount(int unlocked, int total);

  /// No description provided for @unlockedOn.
  ///
  /// In en, this message translates to:
  /// **'Unlocked {date}'**
  String unlockedOn(String date);

  /// No description provided for @hiddenAchievementTitle.
  ///
  /// In en, this message translates to:
  /// **'Hidden Achievement'**
  String get hiddenAchievementTitle;

  /// No description provided for @hiddenAchievementBody.
  ///
  /// In en, this message translates to:
  /// **'Keep playing to reveal this achievement.'**
  String get hiddenAchievementBody;

  /// No description provided for @couldntLoadAchievements.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your achievements.'**
  String get couldntLoadAchievements;

  /// No description provided for @achievementsLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong loading achievements. Please try again.'**
  String get achievementsLoadErrorBody;

  /// No description provided for @achievementUnlockedEyebrow.
  ///
  /// In en, this message translates to:
  /// **'ACHIEVEMENT UNLOCKED'**
  String get achievementUnlockedEyebrow;

  /// No description provided for @rewardXpLabel.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String rewardXpLabel(int xp);

  /// No description provided for @nice.
  ///
  /// In en, this message translates to:
  /// **'Nice'**
  String get nice;

  /// No description provided for @achievementFirstStepTitle.
  ///
  /// In en, this message translates to:
  /// **'First Step'**
  String get achievementFirstStepTitle;

  /// No description provided for @achievementFirstStepDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete your first quest.'**
  String get achievementFirstStepDesc;

  /// No description provided for @achievementGettingStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get achievementGettingStartedTitle;

  /// No description provided for @achievementGettingStartedDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 5 quests.'**
  String get achievementGettingStartedDesc;

  /// No description provided for @achievementConsistentTitle.
  ///
  /// In en, this message translates to:
  /// **'Consistent'**
  String get achievementConsistentTitle;

  /// No description provided for @achievementConsistentDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete a quest on 3 consecutive days.'**
  String get achievementConsistentDesc;

  /// No description provided for @achievementExperiencedTitle.
  ///
  /// In en, this message translates to:
  /// **'Experienced'**
  String get achievementExperiencedTitle;

  /// No description provided for @achievementExperiencedDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach player level 5.'**
  String get achievementExperiencedDesc;

  /// No description provided for @achievementXpHunterTitle.
  ///
  /// In en, this message translates to:
  /// **'XP Hunter'**
  String get achievementXpHunterTitle;

  /// No description provided for @achievementXpHunterDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach 1,000 lifetime XP.'**
  String get achievementXpHunterDesc;

  /// No description provided for @achievementSpecialistTitle.
  ///
  /// In en, this message translates to:
  /// **'Specialist'**
  String get achievementSpecialistTitle;

  /// No description provided for @achievementSpecialistDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach 500 XP in a single attribute.'**
  String get achievementSpecialistDesc;

  /// No description provided for @achievementChallengerTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenger'**
  String get achievementChallengerTitle;

  /// No description provided for @achievementChallengerDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete a Hard or Very Hard quest.'**
  String get achievementChallengerDesc;

  /// No description provided for @chainsTitle.
  ///
  /// In en, this message translates to:
  /// **'Chains'**
  String get chainsTitle;

  /// No description provided for @activeChainsHeader.
  ///
  /// In en, this message translates to:
  /// **'Active Chains'**
  String get activeChainsHeader;

  /// No description provided for @completedChainsHeader.
  ///
  /// In en, this message translates to:
  /// **'Completed Chains'**
  String get completedChainsHeader;

  /// No description provided for @noActiveChains.
  ///
  /// In en, this message translates to:
  /// **'No active chains yet.'**
  String get noActiveChains;

  /// No description provided for @noCompletedChains.
  ///
  /// In en, this message translates to:
  /// **'No chains completed yet.'**
  String get noCompletedChains;

  /// No description provided for @couldntLoadChains.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your chains.'**
  String get couldntLoadChains;

  /// No description provided for @chainsLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong loading chains. Please try again.'**
  String get chainsLoadErrorBody;

  /// No description provided for @chainFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Chain'**
  String get chainFallbackTitle;

  /// No description provided for @hiddenChainTitle.
  ///
  /// In en, this message translates to:
  /// **'Hidden Chain'**
  String get hiddenChainTitle;

  /// No description provided for @hiddenChainBody.
  ///
  /// In en, this message translates to:
  /// **'Keep playing to discover this chain.'**
  String get hiddenChainBody;

  /// No description provided for @chainCompletePercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String chainCompletePercent(int percent);

  /// No description provided for @chainFinishedSuffix.
  ///
  /// In en, this message translates to:
  /// **' — chain finished'**
  String get chainFinishedSuffix;

  /// No description provided for @stagesHeader.
  ///
  /// In en, this message translates to:
  /// **'Stages'**
  String get stagesHeader;

  /// No description provided for @chainNotFound.
  ///
  /// In en, this message translates to:
  /// **'This chain doesn\'t exist.'**
  String get chainNotFound;

  /// No description provided for @couldntLoadChain.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this chain.'**
  String get couldntLoadChain;

  /// No description provided for @chainCurrentQuestLabel.
  ///
  /// In en, this message translates to:
  /// **'Current: {title}'**
  String chainCurrentQuestLabel(String title);

  /// No description provided for @chainStageLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get chainStageLockedTitle;

  /// No description provided for @chainStageFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Stage {index}'**
  String chainStageFallbackTitle(int index);

  /// No description provided for @chainStageCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get chainStageCompleted;

  /// No description provided for @chainStageInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get chainStageInProgress;

  /// No description provided for @chainStageLockedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete the current stage first'**
  String get chainStageLockedSubtitle;

  /// No description provided for @identityTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get identityTitle;

  /// No description provided for @couldntLoadIdentity.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your identity profile.'**
  String get couldntLoadIdentity;

  /// No description provided for @attributesHeader.
  ///
  /// In en, this message translates to:
  /// **'Attributes'**
  String get attributesHeader;

  /// No description provided for @strongestBadge.
  ///
  /// In en, this message translates to:
  /// **'Strongest'**
  String get strongestBadge;

  /// No description provided for @weakestBadge.
  ///
  /// In en, this message translates to:
  /// **'Weakest'**
  String get weakestBadge;

  /// No description provided for @percentValue.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String percentValue(int percent);

  /// No description provided for @lifetimeHeader.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get lifetimeHeader;

  /// No description provided for @questsCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Quests completed'**
  String get questsCompletedLabel;

  /// No description provided for @chainsCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Chains completed'**
  String get chainsCompletedLabel;

  /// No description provided for @achievementsUnlockedLabel.
  ///
  /// In en, this message translates to:
  /// **'Achievements unlocked'**
  String get achievementsUnlockedLabel;

  /// No description provided for @totalXpEarnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Total XP earned'**
  String get totalXpEarnedLabel;

  /// No description provided for @recentMilestonesHeader.
  ///
  /// In en, this message translates to:
  /// **'Recent Milestones'**
  String get recentMilestonesHeader;

  /// No description provided for @noMilestonesYet.
  ///
  /// In en, this message translates to:
  /// **'No milestones yet — complete quests to start building your story.'**
  String get noMilestonesYet;

  /// No description provided for @milestoneUnlockedAchievement.
  ///
  /// In en, this message translates to:
  /// **'Unlocked \"{title}\"'**
  String milestoneUnlockedAchievement(String title);

  /// No description provided for @milestoneCompletedChain.
  ///
  /// In en, this message translates to:
  /// **'Completed \"{title}\"'**
  String milestoneCompletedChain(String title);

  /// No description provided for @milestoneReachedLevel.
  ///
  /// In en, this message translates to:
  /// **'Reached Level {level}'**
  String milestoneReachedLevel(int level);

  /// No description provided for @youTitle.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youTitle;

  /// No description provided for @xpByAttributeHeader.
  ///
  /// In en, this message translates to:
  /// **'XP by attribute'**
  String get xpByAttributeHeader;

  /// No description provided for @couldntLoadXp.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your XP.'**
  String get couldntLoadXp;

  /// No description provided for @xpLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong loading your XP. Please try again.'**
  String get xpLoadErrorBody;

  /// No description provided for @levelUpEyebrow.
  ///
  /// In en, this message translates to:
  /// **'LEVEL UP'**
  String get levelUpEyebrow;

  /// No description provided for @levelUpSingle.
  ///
  /// In en, this message translates to:
  /// **'You reached a new level'**
  String get levelUpSingle;

  /// No description provided for @levelUpMultiJump.
  ///
  /// In en, this message translates to:
  /// **'Level {previous} → Level {newLevel}'**
  String levelUpMultiJump(int previous, int newLevel);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @generalSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSectionHeader;

  /// No description provided for @restartOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart Onboarding'**
  String get restartOnboardingTitle;

  /// No description provided for @restartOnboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See the intro and starter quests again'**
  String get restartOnboardingSubtitle;

  /// No description provided for @suggestionPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggestion Preferences'**
  String get suggestionPreferencesTitle;

  /// No description provided for @suggestionPreferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Life stage, goals, time, and pace for Suggestions'**
  String get suggestionPreferencesSubtitle;

  /// No description provided for @aboutSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSectionHeader;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @localDataExplanation.
  ///
  /// In en, this message translates to:
  /// **'All your data is stored only on this device, using local storage (Hive). Nothing is sent to a server. Uninstalling the app, or clearing local data below, permanently erases it.'**
  String get localDataExplanation;

  /// No description provided for @licensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licensesTitle;

  /// No description provided for @licensesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open-source software used by Prime'**
  String get licensesSubtitle;

  /// No description provided for @dataSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataSectionHeader;

  /// No description provided for @clearAllDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all local data'**
  String get clearAllDataTitle;

  /// No description provided for @clearAllDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently erase every quest, XP, and unlock'**
  String get clearAllDataSubtitle;

  /// No description provided for @clearAllDataDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all local data?'**
  String get clearAllDataDialogTitle;

  /// No description provided for @clearAllDataDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes every quest, all progress, all XP, and every achievement and chain you have unlocked — on this device only. This cannot be undone.'**
  String get clearAllDataDialogBody;

  /// No description provided for @deleteEverything.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get deleteEverything;

  /// No description provided for @couldntClearData.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t clear local data. Please try again.'**
  String get couldntClearData;

  /// No description provided for @languageSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSectionHeader;

  /// No description provided for @languageSystemOption.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get languageSystemOption;

  /// No description provided for @languageTurkishOption.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get languageTurkishOption;

  /// No description provided for @languageEnglishOption.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglishOption;

  /// No description provided for @suggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestionsTitle;

  /// No description provided for @preferencesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesTooltip;

  /// No description provided for @pickedForYou.
  ///
  /// In en, this message translates to:
  /// **'Picked for you'**
  String get pickedForYou;

  /// No description provided for @popularQuestsToStart.
  ///
  /// In en, this message translates to:
  /// **'Popular quests to start with'**
  String get popularQuestsToStart;

  /// No description provided for @basedOnGoals.
  ///
  /// In en, this message translates to:
  /// **'Based on your goals, routine, and pace.'**
  String get basedOnGoals;

  /// No description provided for @setPreferencesForPicks.
  ///
  /// In en, this message translates to:
  /// **'Set your preferences for picks made just for you.'**
  String get setPreferencesForPicks;

  /// No description provided for @noSuggestionsLeft.
  ///
  /// In en, this message translates to:
  /// **'You\'ve added every suggestion — nice work. Create a custom quest for anything else.'**
  String get noSuggestionsLeft;

  /// No description provided for @couldntLoadSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load suggestions. Please try again.'**
  String get couldntLoadSuggestions;

  /// No description provided for @addedToQuests.
  ///
  /// In en, this message translates to:
  /// **'Added \"{title}\" to your quests'**
  String addedToQuests(String title);

  /// No description provided for @alreadyInQuests.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" is already in your quests'**
  String alreadyInQuests(String title);

  /// No description provided for @openLabel.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openLabel;

  /// No description provided for @addQuestButton.
  ///
  /// In en, this message translates to:
  /// **'Add Quest'**
  String get addQuestButton;

  /// No description provided for @couldntAddQuestShort.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add this quest. Try again.'**
  String get couldntAddQuestShort;

  /// No description provided for @suggestionNotFound.
  ///
  /// In en, this message translates to:
  /// **'This suggestion doesn\'t exist.'**
  String get suggestionNotFound;

  /// No description provided for @estimatedTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated time'**
  String get estimatedTimeLabel;

  /// No description provided for @progressTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress target'**
  String get progressTargetLabel;

  /// No description provided for @completeOnce.
  ///
  /// In en, this message translates to:
  /// **'Complete once'**
  String get completeOnce;

  /// No description provided for @addToMyQuestsButton.
  ///
  /// In en, this message translates to:
  /// **'Add to My Quests'**
  String get addToMyQuestsButton;

  /// No description provided for @couldntAddQuestLong.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add this quest. Please try again.'**
  String get couldntAddQuestLong;

  /// No description provided for @whyRecommendedHeader.
  ///
  /// In en, this message translates to:
  /// **'Why this was recommended'**
  String get whyRecommendedHeader;

  /// No description provided for @solidStartingPoint.
  ///
  /// In en, this message translates to:
  /// **'A solid starting point for anyone.'**
  String get solidStartingPoint;

  /// No description provided for @reasonFitsLifeStage.
  ///
  /// In en, this message translates to:
  /// **'Fits your life stage'**
  String get reasonFitsLifeStage;

  /// No description provided for @reasonMatchesGoal.
  ///
  /// In en, this message translates to:
  /// **'Matches your goal: {goal}'**
  String reasonMatchesGoal(String goal);

  /// No description provided for @reasonFitsAvailableTime.
  ///
  /// In en, this message translates to:
  /// **'Fits your available time'**
  String get reasonFitsAvailableTime;

  /// No description provided for @reasonMatchesIntensity.
  ///
  /// In en, this message translates to:
  /// **'Matches your preferred pace'**
  String get reasonMatchesIntensity;

  /// No description provided for @lifeStageSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Life stage'**
  String get lifeStageSectionLabel;

  /// No description provided for @workingOnSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'What are you working on?'**
  String get workingOnSectionLabel;

  /// No description provided for @availableTimeSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Available time per day'**
  String get availableTimeSectionLabel;

  /// No description provided for @preferredIntensitySectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Preferred intensity'**
  String get preferredIntensitySectionLabel;

  /// No description provided for @savePreferencesButton.
  ///
  /// In en, this message translates to:
  /// **'Save Preferences'**
  String get savePreferencesButton;

  /// No description provided for @preferencesSaved.
  ///
  /// In en, this message translates to:
  /// **'Preferences saved'**
  String get preferencesSaved;

  /// No description provided for @couldntLoadPreferences.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your preferences.'**
  String get couldntLoadPreferences;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @addSelectedGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Add Selected & Get Started'**
  String get addSelectedGetStarted;

  /// No description provided for @wantHeadStart.
  ///
  /// In en, this message translates to:
  /// **'Want a head start?'**
  String get wantHeadStart;

  /// No description provided for @pickQuestsOptional.
  ///
  /// In en, this message translates to:
  /// **'Pick any quests you want to start with — entirely optional. You can always add your own instead, or later.'**
  String get pickQuestsOptional;

  /// No description provided for @browseMoreSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Browse more suggestions'**
  String get browseMoreSuggestions;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Prime'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Body.
  ///
  /// In en, this message translates to:
  /// **'Prime turns your real habits into visible progress — no fantasy, no clutter, just your own effort tracked honestly.'**
  String get onboardingSlide1Body;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Quests are the things you do'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Body.
  ///
  /// In en, this message translates to:
  /// **'A daily habit, a one-off task, a bigger goal — each one is a Quest. Completing it makes progress.'**
  String get onboardingSlide2Body;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Progress earns XP'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Body.
  ///
  /// In en, this message translates to:
  /// **'Completing a quest earns XP toward the attribute it is about — Health, Discipline, Knowledge, and more.'**
  String get onboardingSlide3Body;

  /// No description provided for @onboardingSlide4Title.
  ///
  /// In en, this message translates to:
  /// **'Attributes build your level'**
  String get onboardingSlide4Title;

  /// No description provided for @onboardingSlide4Body.
  ///
  /// In en, this message translates to:
  /// **'XP adds up into a Level that only ever goes up — a simple, honest record of consistency over time.'**
  String get onboardingSlide4Body;

  /// No description provided for @onboardingSlide5Title.
  ///
  /// In en, this message translates to:
  /// **'Find your story in You'**
  String get onboardingSlide5Title;

  /// No description provided for @onboardingSlide5Body.
  ///
  /// In en, this message translates to:
  /// **'Achievements, Quest Chains, and your Identity Profile all live in the You tab — derived automatically from what you do. Nothing to set up.'**
  String get onboardingSlide5Body;

  /// No description provided for @starterDrinkWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Drink water'**
  String get starterDrinkWaterTitle;

  /// No description provided for @starterDrinkWaterDesc.
  ///
  /// In en, this message translates to:
  /// **'Stay hydrated through the day.'**
  String get starterDrinkWaterDesc;

  /// No description provided for @starterRead20Title.
  ///
  /// In en, this message translates to:
  /// **'Read for 20 minutes'**
  String get starterRead20Title;

  /// No description provided for @starterRead20Desc.
  ///
  /// In en, this message translates to:
  /// **'A short daily reading habit.'**
  String get starterRead20Desc;

  /// No description provided for @starterWalk15Title.
  ///
  /// In en, this message translates to:
  /// **'Walk for 15 minutes'**
  String get starterWalk15Title;

  /// No description provided for @starterWalk15Desc.
  ///
  /// In en, this message translates to:
  /// **'A short walk, any time of day.'**
  String get starterWalk15Desc;

  /// No description provided for @starterPlanTomorrowTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan tomorrow'**
  String get starterPlanTomorrowTitle;

  /// No description provided for @starterPlanTomorrowDesc.
  ///
  /// In en, this message translates to:
  /// **'A few minutes to set up tomorrow before today ends.'**
  String get starterPlanTomorrowDesc;

  /// No description provided for @starterWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete a workout'**
  String get starterWorkoutTitle;

  /// No description provided for @starterWorkoutDesc.
  ///
  /// In en, this message translates to:
  /// **'Any real physical effort counts.'**
  String get starterWorkoutDesc;

  /// No description provided for @journalComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Journaling is coming soon.'**
  String get journalComingSoon;

  /// No description provided for @storyComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Your story is still being written.\nCheck back soon.'**
  String get storyComingSoon;

  /// No description provided for @focusTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focusTitle;

  /// No description provided for @attributeHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get attributeHealth;

  /// No description provided for @attributeStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get attributeStrength;

  /// No description provided for @attributeDiscipline.
  ///
  /// In en, this message translates to:
  /// **'Discipline'**
  String get attributeDiscipline;

  /// No description provided for @attributeKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Knowledge'**
  String get attributeKnowledge;

  /// No description provided for @attributeCareer.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get attributeCareer;

  /// No description provided for @attributeFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get attributeFinance;

  /// No description provided for @attributeRelationships.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get attributeRelationships;

  /// No description provided for @attributeMindfulness.
  ///
  /// In en, this message translates to:
  /// **'Mindfulness'**
  String get attributeMindfulness;

  /// No description provided for @difficultyTrivial.
  ///
  /// In en, this message translates to:
  /// **'Trivial'**
  String get difficultyTrivial;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get difficultyNormal;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @difficultyVeryHard.
  ///
  /// In en, this message translates to:
  /// **'Very Hard'**
  String get difficultyVeryHard;

  /// No description provided for @questTypeDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily Quest'**
  String get questTypeDaily;

  /// No description provided for @questTypeWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly Quest'**
  String get questTypeWeekly;

  /// No description provided for @questTypeMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly Quest'**
  String get questTypeMonthly;

  /// No description provided for @questTypeSide.
  ///
  /// In en, this message translates to:
  /// **'Side Quest'**
  String get questTypeSide;

  /// No description provided for @questTypeEpic.
  ///
  /// In en, this message translates to:
  /// **'Epic Quest'**
  String get questTypeEpic;

  /// No description provided for @questTypeMainStory.
  ///
  /// In en, this message translates to:
  /// **'Main Story Quest'**
  String get questTypeMainStory;

  /// No description provided for @questTypeRepeatable.
  ///
  /// In en, this message translates to:
  /// **'Repeatable Quest'**
  String get questTypeRepeatable;

  /// No description provided for @questTypeRecovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery Quest'**
  String get questTypeRecovery;

  /// No description provided for @progressTypeBinary.
  ///
  /// In en, this message translates to:
  /// **'Binary (done / not done)'**
  String get progressTypeBinary;

  /// No description provided for @progressTypeQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get progressTypeQuantity;

  /// No description provided for @progressTypeDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get progressTypeDuration;

  /// No description provided for @repeatabilityNone.
  ///
  /// In en, this message translates to:
  /// **'One-time'**
  String get repeatabilityNone;

  /// No description provided for @repeatabilityDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeatabilityDaily;

  /// No description provided for @repeatabilityWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeatabilityWeekly;

  /// No description provided for @questStateNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get questStateNotStarted;

  /// No description provided for @questStateInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get questStateInProgress;

  /// No description provided for @questStateComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get questStateComplete;

  /// No description provided for @questStateExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get questStateExpired;

  /// No description provided for @questStateConverted.
  ///
  /// In en, this message translates to:
  /// **'Converted'**
  String get questStateConverted;

  /// No description provided for @lifeStageStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get lifeStageStudent;

  /// No description provided for @lifeStageWorkingProfessional.
  ///
  /// In en, this message translates to:
  /// **'Working professional'**
  String get lifeStageWorkingProfessional;

  /// No description provided for @lifeStageEntrepreneur.
  ///
  /// In en, this message translates to:
  /// **'Entrepreneur'**
  String get lifeStageEntrepreneur;

  /// No description provided for @lifeStageHomemaker.
  ///
  /// In en, this message translates to:
  /// **'Homemaker'**
  String get lifeStageHomemaker;

  /// No description provided for @lifeStageRetired.
  ///
  /// In en, this message translates to:
  /// **'Retired'**
  String get lifeStageRetired;

  /// No description provided for @lifeStageOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get lifeStageOther;

  /// No description provided for @goalAreaStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get goalAreaStudy;

  /// No description provided for @goalAreaCareer.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get goalAreaCareer;

  /// No description provided for @goalAreaFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get goalAreaFitness;

  /// No description provided for @goalAreaNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get goalAreaNutrition;

  /// No description provided for @goalAreaSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get goalAreaSleep;

  /// No description provided for @goalAreaReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get goalAreaReading;

  /// No description provided for @goalAreaMindfulness.
  ///
  /// In en, this message translates to:
  /// **'Mindfulness'**
  String get goalAreaMindfulness;

  /// No description provided for @goalAreaFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get goalAreaFinance;

  /// No description provided for @goalAreaRelationships.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get goalAreaRelationships;

  /// No description provided for @goalAreaOrganization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get goalAreaOrganization;

  /// No description provided for @goalAreaCreativity.
  ///
  /// In en, this message translates to:
  /// **'Creativity'**
  String get goalAreaCreativity;

  /// No description provided for @goalAreaSelfCare.
  ///
  /// In en, this message translates to:
  /// **'Self-care'**
  String get goalAreaSelfCare;

  /// No description provided for @availableTimeUnder15.
  ///
  /// In en, this message translates to:
  /// **'Under 15 minutes'**
  String get availableTimeUnder15;

  /// No description provided for @availableTime15to30.
  ///
  /// In en, this message translates to:
  /// **'15–30 minutes'**
  String get availableTime15to30;

  /// No description provided for @availableTime30to60.
  ///
  /// In en, this message translates to:
  /// **'30–60 minutes'**
  String get availableTime30to60;

  /// No description provided for @availableTimeOver60.
  ///
  /// In en, this message translates to:
  /// **'Over 60 minutes'**
  String get availableTimeOver60;

  /// No description provided for @intensityGentle.
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get intensityGentle;

  /// No description provided for @intensityBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get intensityBalanced;

  /// No description provided for @intensityChallenging.
  ///
  /// In en, this message translates to:
  /// **'Challenging'**
  String get intensityChallenging;

  /// No description provided for @suggestionStudyPomodoroTitle.
  ///
  /// In en, this message translates to:
  /// **'Study one focused Pomodoro'**
  String get suggestionStudyPomodoroTitle;

  /// No description provided for @suggestionStudyPomodoroDesc.
  ///
  /// In en, this message translates to:
  /// **'25 minutes of distraction-free study, one clean block.'**
  String get suggestionStudyPomodoroDesc;

  /// No description provided for @suggestionStudyPomodoroMotivation.
  ///
  /// In en, this message translates to:
  /// **'Small focused blocks beat long, unfocused sessions.'**
  String get suggestionStudyPomodoroMotivation;

  /// No description provided for @suggestionReviewLectureNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Review today\'s lecture notes'**
  String get suggestionReviewLectureNotesTitle;

  /// No description provided for @suggestionReviewLectureNotesDesc.
  ///
  /// In en, this message translates to:
  /// **'Go back over what you covered today while it\'s fresh.'**
  String get suggestionReviewLectureNotesDesc;

  /// No description provided for @suggestionSolvePracticeQuestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Solve 10 practice questions'**
  String get suggestionSolvePracticeQuestionsTitle;

  /// No description provided for @suggestionSolvePracticeQuestionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Active recall on 10 problems from your current subject.'**
  String get suggestionSolvePracticeQuestionsDesc;

  /// No description provided for @suggestionRead20PagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Read 20 pages'**
  String get suggestionRead20PagesTitle;

  /// No description provided for @suggestionRead20PagesDesc.
  ///
  /// In en, this message translates to:
  /// **'Textbook, novel, or anything worth finishing.'**
  String get suggestionRead20PagesDesc;

  /// No description provided for @suggestionPrepareTomorrowsTaskListTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare tomorrow\'s task list'**
  String get suggestionPrepareTomorrowsTaskListTitle;

  /// No description provided for @suggestionPrepareTomorrowsTaskListDesc.
  ///
  /// In en, this message translates to:
  /// **'A few minutes tonight to walk into tomorrow with a plan.'**
  String get suggestionPrepareTomorrowsTaskListDesc;

  /// No description provided for @suggestionPracticeEnglish15Title.
  ///
  /// In en, this message translates to:
  /// **'Practice English for 15 minutes'**
  String get suggestionPracticeEnglish15Title;

  /// No description provided for @suggestionPracticeEnglish15Desc.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary, listening, or conversation practice.'**
  String get suggestionPracticeEnglish15Desc;

  /// No description provided for @suggestionPlanTop3TasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan the top 3 tasks'**
  String get suggestionPlanTop3TasksTitle;

  /// No description provided for @suggestionPlanTop3TasksDesc.
  ///
  /// In en, this message translates to:
  /// **'Before the day gets noisy, decide what actually matters.'**
  String get suggestionPlanTop3TasksDesc;

  /// No description provided for @suggestionFinishDeepWorkBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish one deep-work block'**
  String get suggestionFinishDeepWorkBlockTitle;

  /// No description provided for @suggestionFinishDeepWorkBlockDesc.
  ///
  /// In en, this message translates to:
  /// **'60 minutes, one task, notifications off.'**
  String get suggestionFinishDeepWorkBlockDesc;

  /// No description provided for @suggestionClearImportantEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear the most important email'**
  String get suggestionClearImportantEmailTitle;

  /// No description provided for @suggestionClearImportantEmailDesc.
  ///
  /// In en, this message translates to:
  /// **'The one you\'ve been putting off — just that one.'**
  String get suggestionClearImportantEmailDesc;

  /// No description provided for @suggestionWalk15BreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a 15-minute walk'**
  String get suggestionWalk15BreakTitle;

  /// No description provided for @suggestionWalk15BreakDesc.
  ///
  /// In en, this message translates to:
  /// **'Step away from the desk and reset.'**
  String get suggestionWalk15BreakDesc;

  /// No description provided for @suggestionReviewWeeklyPrioritiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Review weekly priorities'**
  String get suggestionReviewWeeklyPrioritiesTitle;

  /// No description provided for @suggestionReviewWeeklyPrioritiesDesc.
  ///
  /// In en, this message translates to:
  /// **'A short check-in on whether this week is still on track.'**
  String get suggestionReviewWeeklyPrioritiesDesc;

  /// No description provided for @suggestionLearnJobConceptTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn one job-related concept'**
  String get suggestionLearnJobConceptTitle;

  /// No description provided for @suggestionLearnJobConceptDesc.
  ///
  /// In en, this message translates to:
  /// **'Read, watch, or practice one thing that improves your work.'**
  String get suggestionLearnJobConceptDesc;

  /// No description provided for @suggestionReviewWeeklyNumbersTitle.
  ///
  /// In en, this message translates to:
  /// **'Review this week\'s numbers'**
  String get suggestionReviewWeeklyNumbersTitle;

  /// No description provided for @suggestionReviewWeeklyNumbersDesc.
  ///
  /// In en, this message translates to:
  /// **'Revenue, costs, or usage — whatever tells you the truth.'**
  String get suggestionReviewWeeklyNumbersDesc;

  /// No description provided for @suggestionReachOutOneCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Reach out to one potential customer'**
  String get suggestionReachOutOneCustomerTitle;

  /// No description provided for @suggestionReachOutOneCustomerDesc.
  ///
  /// In en, this message translates to:
  /// **'One real conversation moves things more than a dozen plans.'**
  String get suggestionReachOutOneCustomerDesc;

  /// No description provided for @suggestionWriteTopPriorityTitle.
  ///
  /// In en, this message translates to:
  /// **'Write down today\'s top priority'**
  String get suggestionWriteTopPriorityTitle;

  /// No description provided for @suggestionWriteTopPriorityDesc.
  ///
  /// In en, this message translates to:
  /// **'One sentence: what actually matters today.'**
  String get suggestionWriteTopPriorityDesc;

  /// No description provided for @suggestionReviewCashRunwayTitle.
  ///
  /// In en, this message translates to:
  /// **'Review cash runway'**
  String get suggestionReviewCashRunwayTitle;

  /// No description provided for @suggestionReviewCashRunwayDesc.
  ///
  /// In en, this message translates to:
  /// **'A few minutes with the numbers avoids surprises later.'**
  String get suggestionReviewCashRunwayDesc;

  /// No description provided for @suggestionBatchProcessInvoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Batch process invoices'**
  String get suggestionBatchProcessInvoicesTitle;

  /// No description provided for @suggestionBatchProcessInvoicesDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear the paperwork in one sitting instead of piecemeal.'**
  String get suggestionBatchProcessInvoicesDesc;

  /// No description provided for @suggestionReadIndustryArticleTitle.
  ///
  /// In en, this message translates to:
  /// **'Read one industry article'**
  String get suggestionReadIndustryArticleTitle;

  /// No description provided for @suggestionReadIndustryArticleDesc.
  ///
  /// In en, this message translates to:
  /// **'Stay current on the space you\'re building in.'**
  String get suggestionReadIndustryArticleDesc;

  /// No description provided for @suggestionPlanWeeklyMealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan this week\'s meals'**
  String get suggestionPlanWeeklyMealsTitle;

  /// No description provided for @suggestionPlanWeeklyMealsDesc.
  ///
  /// In en, this message translates to:
  /// **'Decide once, cook without decision fatigue all week.'**
  String get suggestionPlanWeeklyMealsDesc;

  /// No description provided for @suggestionTidySprint10Title.
  ///
  /// In en, this message translates to:
  /// **'Do a 10-minute tidy sprint'**
  String get suggestionTidySprint10Title;

  /// No description provided for @suggestionTidySprint10Desc.
  ///
  /// In en, this message translates to:
  /// **'One timer, one room, no perfectionism.'**
  String get suggestionTidySprint10Desc;

  /// No description provided for @suggestionPrepTomorrowsLunchTitle.
  ///
  /// In en, this message translates to:
  /// **'Prep tomorrow\'s lunch'**
  String get suggestionPrepTomorrowsLunchTitle;

  /// No description provided for @suggestionPrepTomorrowsLunchDesc.
  ///
  /// In en, this message translates to:
  /// **'Future you will be grateful.'**
  String get suggestionPrepTomorrowsLunchDesc;

  /// No description provided for @suggestionCallFamilyMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Call a family member'**
  String get suggestionCallFamilyMemberTitle;

  /// No description provided for @suggestionCallFamilyMemberDesc.
  ///
  /// In en, this message translates to:
  /// **'A real conversation, not a text.'**
  String get suggestionCallFamilyMemberDesc;

  /// No description provided for @suggestionDeclutterOneDrawerTitle.
  ///
  /// In en, this message translates to:
  /// **'Declutter one drawer'**
  String get suggestionDeclutterOneDrawerTitle;

  /// No description provided for @suggestionDeclutterOneDrawerDesc.
  ///
  /// In en, this message translates to:
  /// **'Small scope, real progress.'**
  String get suggestionDeclutterOneDrawerDesc;

  /// No description provided for @suggestionBatchCookMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Batch-cook a meal'**
  String get suggestionBatchCookMealTitle;

  /// No description provided for @suggestionBatchCookMealDesc.
  ///
  /// In en, this message translates to:
  /// **'Cook once, eat well for days.'**
  String get suggestionBatchCookMealDesc;

  /// No description provided for @suggestionGentleWalk15Title.
  ///
  /// In en, this message translates to:
  /// **'Take a gentle 15-minute walk'**
  String get suggestionGentleWalk15Title;

  /// No description provided for @suggestionGentleWalk15Desc.
  ///
  /// In en, this message translates to:
  /// **'Easy pace, fresh air, no pressure.'**
  String get suggestionGentleWalk15Desc;

  /// No description provided for @suggestionCallOldFriendTitle.
  ///
  /// In en, this message translates to:
  /// **'Call an old friend'**
  String get suggestionCallOldFriendTitle;

  /// No description provided for @suggestionCallOldFriendDesc.
  ///
  /// In en, this message translates to:
  /// **'Reconnect with someone you haven\'t spoken to in a while.'**
  String get suggestionCallOldFriendDesc;

  /// No description provided for @suggestionReadChapterPleasureTitle.
  ///
  /// In en, this message translates to:
  /// **'Read a chapter for pleasure'**
  String get suggestionReadChapterPleasureTitle;

  /// No description provided for @suggestionReadChapterPleasureDesc.
  ///
  /// In en, this message translates to:
  /// **'No agenda — just a good book.'**
  String get suggestionReadChapterPleasureDesc;

  /// No description provided for @suggestionTryNewSimpleRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Try a new simple recipe'**
  String get suggestionTryNewSimpleRecipeTitle;

  /// No description provided for @suggestionTryNewSimpleRecipeDesc.
  ///
  /// In en, this message translates to:
  /// **'Cook something you\'ve never made before.'**
  String get suggestionTryNewSimpleRecipeDesc;

  /// No description provided for @suggestionJournalEveningTitle.
  ///
  /// In en, this message translates to:
  /// **'Write a journal entry about today'**
  String get suggestionJournalEveningTitle;

  /// No description provided for @suggestionJournalEveningDesc.
  ///
  /// In en, this message translates to:
  /// **'A few honest lines about how today went.'**
  String get suggestionJournalEveningDesc;

  /// No description provided for @suggestionLearnNewWordTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn one new word'**
  String get suggestionLearnNewWordTitle;

  /// No description provided for @suggestionLearnNewWordDesc.
  ///
  /// In en, this message translates to:
  /// **'Small, steady vocabulary growth.'**
  String get suggestionLearnNewWordDesc;

  /// No description provided for @suggestionWalk20Title.
  ///
  /// In en, this message translates to:
  /// **'Walk for 20 minutes'**
  String get suggestionWalk20Title;

  /// No description provided for @suggestionWalk20Desc.
  ///
  /// In en, this message translates to:
  /// **'Any pace, anywhere — just get moving.'**
  String get suggestionWalk20Desc;

  /// No description provided for @suggestionFullBodyWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete a full-body workout'**
  String get suggestionFullBodyWorkoutTitle;

  /// No description provided for @suggestionFullBodyWorkoutDesc.
  ///
  /// In en, this message translates to:
  /// **'One real session, whatever equipment you have.'**
  String get suggestionFullBodyWorkoutDesc;

  /// No description provided for @suggestionPushups20Title.
  ///
  /// In en, this message translates to:
  /// **'Do 20 push-ups'**
  String get suggestionPushups20Title;

  /// No description provided for @suggestionPushups20Desc.
  ///
  /// In en, this message translates to:
  /// **'Spread them across the day if you need to.'**
  String get suggestionPushups20Desc;

  /// No description provided for @suggestionStretch10Title.
  ///
  /// In en, this message translates to:
  /// **'Stretch for 10 minutes'**
  String get suggestionStretch10Title;

  /// No description provided for @suggestionStretch10Desc.
  ///
  /// In en, this message translates to:
  /// **'Loosen up, especially after sitting.'**
  String get suggestionStretch10Desc;

  /// No description provided for @suggestionDrinkWater8Title.
  ///
  /// In en, this message translates to:
  /// **'Drink 8 glasses of water'**
  String get suggestionDrinkWater8Title;

  /// No description provided for @suggestionDrinkWater8Desc.
  ///
  /// In en, this message translates to:
  /// **'Steady hydration through the day.'**
  String get suggestionDrinkWater8Desc;

  /// No description provided for @suggestionHighProteinMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare a high-protein meal'**
  String get suggestionHighProteinMealTitle;

  /// No description provided for @suggestionHighProteinMealDesc.
  ///
  /// In en, this message translates to:
  /// **'Fuel your training properly.'**
  String get suggestionHighProteinMealDesc;

  /// No description provided for @suggestionMobility5Title.
  ///
  /// In en, this message translates to:
  /// **'Do a 5-minute mobility routine'**
  String get suggestionMobility5Title;

  /// No description provided for @suggestionMobility5Desc.
  ///
  /// In en, this message translates to:
  /// **'Hips, shoulders, ankles — the joints that need it most.'**
  String get suggestionMobility5Desc;

  /// No description provided for @suggestionTakeTheStairsTitle.
  ///
  /// In en, this message translates to:
  /// **'Take the stairs today'**
  String get suggestionTakeTheStairsTitle;

  /// No description provided for @suggestionTakeTheStairsDesc.
  ///
  /// In en, this message translates to:
  /// **'A small, repeatable choice that adds up.'**
  String get suggestionTakeTheStairsDesc;

  /// No description provided for @suggestionExtraVegetableServingTitle.
  ///
  /// In en, this message translates to:
  /// **'Eat one extra serving of vegetables'**
  String get suggestionExtraVegetableServingTitle;

  /// No description provided for @suggestionExtraVegetableServingDesc.
  ///
  /// In en, this message translates to:
  /// **'Add, don\'t restrict — just one more serving today.'**
  String get suggestionExtraVegetableServingDesc;

  /// No description provided for @suggestionCookAtHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Cook a meal at home instead of ordering'**
  String get suggestionCookAtHomeTitle;

  /// No description provided for @suggestionCookAtHomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Control what goes in, save money too.'**
  String get suggestionCookAtHomeDesc;

  /// No description provided for @suggestionAvoidAddedSugarTitle.
  ///
  /// In en, this message translates to:
  /// **'Avoid added sugar for the day'**
  String get suggestionAvoidAddedSugarTitle;

  /// No description provided for @suggestionAvoidAddedSugarDesc.
  ///
  /// In en, this message translates to:
  /// **'One full day, no added sugar.'**
  String get suggestionAvoidAddedSugarDesc;

  /// No description provided for @suggestionMealPrepTomorrowTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal-prep for tomorrow'**
  String get suggestionMealPrepTomorrowTitle;

  /// No description provided for @suggestionMealPrepTomorrowDesc.
  ///
  /// In en, this message translates to:
  /// **'Set tomorrow\'s meals up tonight.'**
  String get suggestionMealPrepTomorrowDesc;

  /// No description provided for @suggestionTrackTodaysMealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Track today\'s meals'**
  String get suggestionTrackTodaysMealsTitle;

  /// No description provided for @suggestionTrackTodaysMealsDesc.
  ///
  /// In en, this message translates to:
  /// **'Just noticing what you eat changes how you eat.'**
  String get suggestionTrackTodaysMealsDesc;

  /// No description provided for @suggestionConsistentWakeupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a consistent wake-up time'**
  String get suggestionConsistentWakeupTitle;

  /// No description provided for @suggestionConsistentWakeupDesc.
  ///
  /// In en, this message translates to:
  /// **'Same time every day, weekends included.'**
  String get suggestionConsistentWakeupDesc;

  /// No description provided for @suggestionNoScreensBeforeBedTitle.
  ///
  /// In en, this message translates to:
  /// **'No screens 30 minutes before bed'**
  String get suggestionNoScreensBeforeBedTitle;

  /// No description provided for @suggestionNoScreensBeforeBedDesc.
  ///
  /// In en, this message translates to:
  /// **'Wind down without a backlit screen.'**
  String get suggestionNoScreensBeforeBedDesc;

  /// No description provided for @suggestionSleepBeforeTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep before a chosen time'**
  String get suggestionSleepBeforeTimeTitle;

  /// No description provided for @suggestionSleepBeforeTimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Pick a bedtime and actually hit it.'**
  String get suggestionSleepBeforeTimeDesc;

  /// No description provided for @suggestionNap20Title.
  ///
  /// In en, this message translates to:
  /// **'Take a 20-minute nap'**
  String get suggestionNap20Title;

  /// No description provided for @suggestionNap20Desc.
  ///
  /// In en, this message translates to:
  /// **'Short enough to stay refreshing, not groggy.'**
  String get suggestionNap20Desc;

  /// No description provided for @suggestionWindDownWithBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Wind down with a book instead of a screen'**
  String get suggestionWindDownWithBookTitle;

  /// No description provided for @suggestionWindDownWithBookDesc.
  ///
  /// In en, this message translates to:
  /// **'Trade the scroll for a few pages.'**
  String get suggestionWindDownWithBookDesc;

  /// No description provided for @suggestionReadOneArticleTitle.
  ///
  /// In en, this message translates to:
  /// **'Read one article on a new topic'**
  String get suggestionReadOneArticleTitle;

  /// No description provided for @suggestionReadOneArticleDesc.
  ///
  /// In en, this message translates to:
  /// **'Something outside your usual feed.'**
  String get suggestionReadOneArticleDesc;

  /// No description provided for @suggestionFinishOneChapterTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish one chapter'**
  String get suggestionFinishOneChapterTitle;

  /// No description provided for @suggestionFinishOneChapterDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep the book moving, one chapter at a time.'**
  String get suggestionFinishOneChapterDesc;

  /// No description provided for @suggestionReadBeforeBedTitle.
  ///
  /// In en, this message translates to:
  /// **'Read before bed instead of scrolling'**
  String get suggestionReadBeforeBedTitle;

  /// No description provided for @suggestionReadBeforeBedDesc.
  ///
  /// In en, this message translates to:
  /// **'Swap the phone for a book at bedtime.'**
  String get suggestionReadBeforeBedDesc;

  /// No description provided for @suggestionAudiobookChapterTitle.
  ///
  /// In en, this message translates to:
  /// **'Listen to one audiobook chapter'**
  String get suggestionAudiobookChapterTitle;

  /// No description provided for @suggestionAudiobookChapterDesc.
  ///
  /// In en, this message translates to:
  /// **'Reading counts even with your ears.'**
  String get suggestionAudiobookChapterDesc;

  /// No description provided for @suggestionMeditate10Title.
  ///
  /// In en, this message translates to:
  /// **'Meditate for 10 minutes'**
  String get suggestionMeditate10Title;

  /// No description provided for @suggestionMeditate10Desc.
  ///
  /// In en, this message translates to:
  /// **'Sit, breathe, and let the noise settle.'**
  String get suggestionMeditate10Desc;

  /// No description provided for @suggestionDeepBreathing5Title.
  ///
  /// In en, this message translates to:
  /// **'Practice 5 minutes of deep breathing'**
  String get suggestionDeepBreathing5Title;

  /// No description provided for @suggestionDeepBreathing5Desc.
  ///
  /// In en, this message translates to:
  /// **'Slow, deliberate breaths — nothing else.'**
  String get suggestionDeepBreathing5Desc;

  /// No description provided for @suggestionBodyScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Do a short body scan'**
  String get suggestionBodyScanTitle;

  /// No description provided for @suggestionBodyScanDesc.
  ///
  /// In en, this message translates to:
  /// **'Notice tension from head to toe and let it go.'**
  String get suggestionBodyScanDesc;

  /// No description provided for @suggestionSitInSilence5Title.
  ///
  /// In en, this message translates to:
  /// **'Sit in silence for 5 minutes'**
  String get suggestionSitInSilence5Title;

  /// No description provided for @suggestionSitInSilence5Desc.
  ///
  /// In en, this message translates to:
  /// **'No phone, no music — just quiet.'**
  String get suggestionSitInSilence5Desc;

  /// No description provided for @suggestionGratitudeThreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice gratitude — write 3 things down'**
  String get suggestionGratitudeThreeTitle;

  /// No description provided for @suggestionGratitudeThreeDesc.
  ///
  /// In en, this message translates to:
  /// **'Three specific things, however small.'**
  String get suggestionGratitudeThreeDesc;

  /// No description provided for @suggestionMindfulWalkNoPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Do a mindful walk without your phone'**
  String get suggestionMindfulWalkNoPhoneTitle;

  /// No description provided for @suggestionMindfulWalkNoPhoneDesc.
  ///
  /// In en, this message translates to:
  /// **'Just you, moving, paying attention.'**
  String get suggestionMindfulWalkNoPhoneDesc;

  /// No description provided for @suggestionLogTodaysSpendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Log today\'s spending'**
  String get suggestionLogTodaysSpendingTitle;

  /// No description provided for @suggestionLogTodaysSpendingDesc.
  ///
  /// In en, this message translates to:
  /// **'A quick, honest record of where money went.'**
  String get suggestionLogTodaysSpendingDesc;

  /// No description provided for @suggestionReviewSubscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Review one subscription for cancellation'**
  String get suggestionReviewSubscriptionTitle;

  /// No description provided for @suggestionReviewSubscriptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Is it still worth what you\'re paying?'**
  String get suggestionReviewSubscriptionDesc;

  /// No description provided for @suggestionMoveToSavingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Move a fixed amount into savings'**
  String get suggestionMoveToSavingsTitle;

  /// No description provided for @suggestionMoveToSavingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Even a small amount, moved consistently.'**
  String get suggestionMoveToSavingsDesc;

  /// No description provided for @suggestionCheckWeeklyBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your budget for the week'**
  String get suggestionCheckWeeklyBudgetTitle;

  /// No description provided for @suggestionCheckWeeklyBudgetDesc.
  ///
  /// In en, this message translates to:
  /// **'A short look before spending gets away from you.'**
  String get suggestionCheckWeeklyBudgetDesc;

  /// No description provided for @suggestionReadFinanceArticleTitle.
  ///
  /// In en, this message translates to:
  /// **'Read one article about personal finance'**
  String get suggestionReadFinanceArticleTitle;

  /// No description provided for @suggestionReadFinanceArticleDesc.
  ///
  /// In en, this message translates to:
  /// **'Build the knowledge, a little at a time.'**
  String get suggestionReadFinanceArticleDesc;

  /// No description provided for @suggestionThoughtfulMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a thoughtful message to a friend'**
  String get suggestionThoughtfulMessageTitle;

  /// No description provided for @suggestionThoughtfulMessageDesc.
  ///
  /// In en, this message translates to:
  /// **'Not a check-in — something real.'**
  String get suggestionThoughtfulMessageDesc;

  /// No description provided for @suggestionPhoneFreeMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Have a phone-free meal with someone'**
  String get suggestionPhoneFreeMealTitle;

  /// No description provided for @suggestionPhoneFreeMealDesc.
  ///
  /// In en, this message translates to:
  /// **'Full attention, one meal.'**
  String get suggestionPhoneFreeMealDesc;

  /// No description provided for @suggestionNoteOfAppreciationTitle.
  ///
  /// In en, this message translates to:
  /// **'Write a note of appreciation'**
  String get suggestionNoteOfAppreciationTitle;

  /// No description provided for @suggestionNoteOfAppreciationDesc.
  ///
  /// In en, this message translates to:
  /// **'Tell someone specifically what you appreciate about them.'**
  String get suggestionNoteOfAppreciationDesc;

  /// No description provided for @suggestionPlanGetTogetherTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan a get-together'**
  String get suggestionPlanGetTogetherTitle;

  /// No description provided for @suggestionPlanGetTogetherDesc.
  ///
  /// In en, this message translates to:
  /// **'Put something real on the calendar.'**
  String get suggestionPlanGetTogetherDesc;

  /// No description provided for @suggestionAskAboutTheirDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask a loved one about their day — and really listen'**
  String get suggestionAskAboutTheirDayTitle;

  /// No description provided for @suggestionAskAboutTheirDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Give someone your full attention for a few minutes.'**
  String get suggestionAskAboutTheirDayDesc;

  /// No description provided for @suggestionClearInboxZeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear your inbox to zero'**
  String get suggestionClearInboxZeroTitle;

  /// No description provided for @suggestionClearInboxZeroDesc.
  ///
  /// In en, this message translates to:
  /// **'Archive, reply, or delete — until it is empty.'**
  String get suggestionClearInboxZeroDesc;

  /// No description provided for @suggestionPlanTomorrowMorningTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan tomorrow morning'**
  String get suggestionPlanTomorrowMorningTitle;

  /// No description provided for @suggestionPlanTomorrowMorningDesc.
  ///
  /// In en, this message translates to:
  /// **'Decide your first task before the day starts.'**
  String get suggestionPlanTomorrowMorningDesc;

  /// No description provided for @suggestionOrganizeDesktopFilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Organize your desktop files'**
  String get suggestionOrganizeDesktopFilesTitle;

  /// No description provided for @suggestionOrganizeDesktopFilesDesc.
  ///
  /// In en, this message translates to:
  /// **'Fifteen minutes of digital tidying.'**
  String get suggestionOrganizeDesktopFilesDesc;

  /// No description provided for @suggestionSketch10Title.
  ///
  /// In en, this message translates to:
  /// **'Sketch for 10 minutes'**
  String get suggestionSketch10Title;

  /// No description provided for @suggestionSketch10Desc.
  ///
  /// In en, this message translates to:
  /// **'No pressure to be good — just make marks.'**
  String get suggestionSketch10Desc;

  /// No description provided for @suggestionWrite200WordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Write 200 words of anything'**
  String get suggestionWrite200WordsTitle;

  /// No description provided for @suggestionWrite200WordsDesc.
  ///
  /// In en, this message translates to:
  /// **'Fiction, a journal, an idea — just write.'**
  String get suggestionWrite200WordsDesc;

  /// No description provided for @suggestionLearn3ChordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn 3 chords on an instrument'**
  String get suggestionLearn3ChordsTitle;

  /// No description provided for @suggestionLearn3ChordsDesc.
  ///
  /// In en, this message translates to:
  /// **'Pick it up and make some noise.'**
  String get suggestionLearn3ChordsDesc;

  /// No description provided for @suggestionCreativePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Take one creative photo'**
  String get suggestionCreativePhotoTitle;

  /// No description provided for @suggestionCreativePhotoDesc.
  ///
  /// In en, this message translates to:
  /// **'Look at something ordinary differently.'**
  String get suggestionCreativePhotoDesc;

  /// No description provided for @suggestionBrainstorm10IdeasTitle.
  ///
  /// In en, this message translates to:
  /// **'Brainstorm 10 ideas for a project'**
  String get suggestionBrainstorm10IdeasTitle;

  /// No description provided for @suggestionBrainstorm10IdeasDesc.
  ///
  /// In en, this message translates to:
  /// **'Quantity first — the good ones show up eventually.'**
  String get suggestionBrainstorm10IdeasDesc;

  /// No description provided for @suggestionPhoneFree20Title.
  ///
  /// In en, this message translates to:
  /// **'Spend 20 minutes without the phone'**
  String get suggestionPhoneFree20Title;

  /// No description provided for @suggestionPhoneFree20Desc.
  ///
  /// In en, this message translates to:
  /// **'Just be, without checking anything.'**
  String get suggestionPhoneFree20Desc;

  /// No description provided for @suggestionRelaxingBathTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a relaxing bath or shower'**
  String get suggestionRelaxingBathTitle;

  /// No description provided for @suggestionRelaxingBathDesc.
  ///
  /// In en, this message translates to:
  /// **'Unhurried, just for you.'**
  String get suggestionRelaxingBathDesc;

  /// No description provided for @suggestionFreshAirBreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Step outside for fresh air'**
  String get suggestionFreshAirBreakTitle;

  /// No description provided for @suggestionFreshAirBreakDesc.
  ///
  /// In en, this message translates to:
  /// **'A few minutes outside, no destination needed.'**
  String get suggestionFreshAirBreakDesc;

  /// No description provided for @suggestionSayNoOnceTitle.
  ///
  /// In en, this message translates to:
  /// **'Say no to one thing that drains you'**
  String get suggestionSayNoOnceTitle;

  /// No description provided for @suggestionSayNoOnceDesc.
  ///
  /// In en, this message translates to:
  /// **'Protect your time on purpose.'**
  String get suggestionSayNoOnceDesc;

  /// No description provided for @suggestionSmallKindTreatTitle.
  ///
  /// In en, this message translates to:
  /// **'Treat yourself to something small and kind'**
  String get suggestionSmallKindTreatTitle;

  /// No description provided for @suggestionSmallKindTreatDesc.
  ///
  /// In en, this message translates to:
  /// **'A real, deliberate act of care for yourself.'**
  String get suggestionSmallKindTreatDesc;

  /// No description provided for @suggestionTidyOneAreaTitle.
  ///
  /// In en, this message translates to:
  /// **'Tidy one small area'**
  String get suggestionTidyOneAreaTitle;

  /// No description provided for @suggestionTidyOneAreaDesc.
  ///
  /// In en, this message translates to:
  /// **'One shelf, one corner — contained and doable.'**
  String get suggestionTidyOneAreaDesc;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

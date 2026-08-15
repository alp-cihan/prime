// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Prime';

  @override
  String get startupFailureTitle => 'Prime couldn\'t start';

  @override
  String get startupFailureBody =>
      'Your data could not be loaded. Restarting the app usually fixes this.';

  @override
  String get navToday => 'Today';

  @override
  String get navQuests => 'Quests';

  @override
  String get navStory => 'Story';

  @override
  String get navJournal => 'Journal';

  @override
  String get navYou => 'You';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get noQuestsYet =>
      'No quests yet. Quests you create will show up here.';

  @override
  String get browseSuggestions => 'Browse Suggestions';

  @override
  String get createQuestLabel => 'Create Quest';

  @override
  String get difficultyLabel => 'Difficulty';

  @override
  String get repeatsLabel => 'Repeats';

  @override
  String get attributeAllocationLabel => 'Attribute allocation';

  @override
  String get questNotFound => 'This quest doesn\'t exist or was removed.';

  @override
  String get couldntLoadQuest => 'Couldn\'t load this quest.';

  @override
  String get questLoadErrorBody =>
      'Something went wrong loading this quest. Please try again.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get greetingNight => 'Good night';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String playerLevelLabel(int level) {
    return 'Level $level';
  }

  @override
  String playerXpTotal(String xp) {
    return '$xp XP total';
  }

  @override
  String playerXpToNextLevel(int current, int needed) {
    return '$current / $needed XP to next level';
  }

  @override
  String get motivationalLine1 => 'Small consistent steps compound.';

  @override
  String get motivationalLine2 => 'Momentum is built one quest at a time.';

  @override
  String get motivationalLine3 => 'Discipline today, progress tomorrow.';

  @override
  String get motivationalLine4 => 'Show up — the rest follows.';

  @override
  String get motivationalLine5 => 'Every rep counts toward the next level.';

  @override
  String get couldntLoadLevel => 'Couldn\'t load your level.';

  @override
  String get dailyMomentumTitle => 'Daily momentum';

  @override
  String get dailyMomentumNoQuests => 'No quests yet';

  @override
  String dailyMomentumProgress(int completed, int total) {
    return '$completed of $total quests completed';
  }

  @override
  String dailyMomentumXpToday(String xp) {
    return '$xp XP today';
  }

  @override
  String get couldntLoadTodayProgress => 'Couldn\'t load today\'s progress.';

  @override
  String get growthTodayTitle => 'Growth today';

  @override
  String get growthTodayEmpty => 'No XP earned today';

  @override
  String get couldntLoadTodayXp => 'Couldn\'t load today\'s XP.';

  @override
  String get couldntLoadTodayQuests => 'Couldn\'t load today\'s quests.';

  @override
  String get mainQuestLabel => 'TODAY\'S MISSION';

  @override
  String get heroCtaBegin => 'Begin';

  @override
  String get heroEmptyHeadline => 'Ready for today\'s mission?';

  @override
  String get completedTodayLabel => 'Completed today';

  @override
  String get ctaView => 'View';

  @override
  String get ctaComplete => 'Complete';

  @override
  String get ctaAddProgress => 'Add Progress';

  @override
  String get ctaContinue => 'Continue';

  @override
  String get couldntLoadMainQuest => 'Couldn\'t load your main quest.';

  @override
  String get questsTitle => 'Quests';

  @override
  String get suggestionsTooltip => 'Suggestions';

  @override
  String get createQuestTooltip => 'Create Quest';

  @override
  String get couldntLoadQuests => 'Couldn\'t load quests.';

  @override
  String get questsLoadErrorBody =>
      'Something went wrong loading your quests. Please try again.';

  @override
  String get questFallbackTitle => 'Quest';

  @override
  String get editQuestTooltip => 'Edit Quest';

  @override
  String get deleteQuestTooltip => 'Delete Quest';

  @override
  String questCompletedXp(int xp) {
    return 'Quest completed — +$xp XP';
  }

  @override
  String get deleteQuestDialogTitle => 'Delete quest?';

  @override
  String deleteQuestDialogBody(String title) {
    return 'Delete \"$title\"? This removes the quest and its daily progress. XP you already earned from it is kept.';
  }

  @override
  String get questCompleteForToday => 'Quest complete for today';

  @override
  String get typeLabel => 'Type';

  @override
  String get baseXpLabel => 'Base XP';

  @override
  String get statusLabel => 'Status';

  @override
  String get couldntCompleteQuest => 'Couldn\'t complete this quest';

  @override
  String get rewardSectionHeader => 'Rewards';

  @override
  String get whyThisMattersHeader => 'Why this matters';

  @override
  String get titleLabel => 'Title';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get titleRequiredError => 'Title is required';

  @override
  String get titleTooLongError => 'Title must be 100 characters or fewer';

  @override
  String get descriptionTooLongError =>
      'Description must be 500 characters or fewer';

  @override
  String get questTypeLabel => 'Quest type';

  @override
  String get progressTypeLabel => 'Progress type';

  @override
  String get targetProgressLabel => 'Target progress';

  @override
  String get enterPositiveNumberError => 'Enter a positive number';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesBody =>
      'You have unsaved changes. If you leave now, they won\'t be saved.';

  @override
  String get keepEditing => 'Keep Editing';

  @override
  String get discard => 'Discard';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get newQuestTitle => 'New Quest';

  @override
  String get editQuestTitle => 'Edit Quest';

  @override
  String get addAttributeButton => 'Add attribute';

  @override
  String totalXpLabel(int total) {
    return 'Total: $total XP';
  }

  @override
  String get attributeLabel => 'Attribute';

  @override
  String get xpWeightLabel => 'XP weight';

  @override
  String get enterWholeNumberError => 'Enter a whole number';

  @override
  String get mustNotBeNegativeError => 'Must not be negative';

  @override
  String get removeAttributeTooltip => 'Remove attribute';

  @override
  String get completeQuestButton => 'Complete Quest';

  @override
  String get progressLabel => 'Progress';

  @override
  String get decreaseBy1 => 'Decrease by 1';

  @override
  String get increaseBy1 => 'Increase by 1';

  @override
  String get customAmountLabel => 'Custom amount';

  @override
  String get addButton => 'Add';

  @override
  String decrementMinutes(int minutes) {
    return '-$minutes min';
  }

  @override
  String minutesValue(String minutes) {
    return '$minutes min';
  }

  @override
  String get minutesUnit => ' min';

  @override
  String get todayLabel => 'Today';

  @override
  String get notYetLabel => 'Not yet';

  @override
  String completionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: '1 time',
    );
    return '$_temp0';
  }

  @override
  String get xpEarnedTodayLabel => 'XP earned today';

  @override
  String xpAmount(String xp) {
    return '$xp XP';
  }

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get unlockedSectionHeader => 'Unlocked';

  @override
  String get lockedSectionHeader => 'Locked';

  @override
  String get noneUnlockedYet =>
      'None yet — complete quests to start unlocking.';

  @override
  String get allUnlocked => 'Every achievement is unlocked.';

  @override
  String achievementSummaryCount(int unlocked, int total) {
    return '$unlocked / $total';
  }

  @override
  String unlockedOn(String date) {
    return 'Unlocked $date';
  }

  @override
  String get hiddenAchievementTitle => 'Hidden Achievement';

  @override
  String get hiddenAchievementBody =>
      'Keep playing to reveal this achievement.';

  @override
  String get couldntLoadAchievements => 'Couldn\'t load your achievements.';

  @override
  String get achievementsLoadErrorBody =>
      'Something went wrong loading achievements. Please try again.';

  @override
  String get achievementUnlockedEyebrow => 'ACHIEVEMENT UNLOCKED';

  @override
  String rewardXpLabel(int xp) {
    return '+$xp XP';
  }

  @override
  String get nice => 'Nice';

  @override
  String get achievementFirstStepTitle => 'First Step';

  @override
  String get achievementFirstStepDesc => 'Complete your first quest.';

  @override
  String get achievementGettingStartedTitle => 'Getting Started';

  @override
  String get achievementGettingStartedDesc => 'Complete 5 quests.';

  @override
  String get achievementConsistentTitle => 'Consistent';

  @override
  String get achievementConsistentDesc =>
      'Complete a quest on 3 consecutive days.';

  @override
  String get achievementExperiencedTitle => 'Experienced';

  @override
  String get achievementExperiencedDesc => 'Reach player level 5.';

  @override
  String get achievementXpHunterTitle => 'XP Hunter';

  @override
  String get achievementXpHunterDesc => 'Reach 1,000 lifetime XP.';

  @override
  String get achievementSpecialistTitle => 'Specialist';

  @override
  String get achievementSpecialistDesc => 'Reach 500 XP in a single attribute.';

  @override
  String get achievementChallengerTitle => 'Challenger';

  @override
  String get achievementChallengerDesc => 'Complete a Hard or Very Hard quest.';

  @override
  String get chainsTitle => 'Chains';

  @override
  String get activeChainsHeader => 'Active Chains';

  @override
  String get completedChainsHeader => 'Completed Chains';

  @override
  String get noActiveChains => 'No active chains yet.';

  @override
  String get noCompletedChains => 'No chains completed yet.';

  @override
  String get couldntLoadChains => 'Couldn\'t load your chains.';

  @override
  String get chainsLoadErrorBody =>
      'Something went wrong loading chains. Please try again.';

  @override
  String get chainFallbackTitle => 'Chain';

  @override
  String get hiddenChainTitle => 'Hidden Chain';

  @override
  String get hiddenChainBody => 'Keep playing to discover this chain.';

  @override
  String chainCompletePercent(int percent) {
    return '$percent% complete';
  }

  @override
  String get chainFinishedSuffix => ' — chain finished';

  @override
  String get stagesHeader => 'Stages';

  @override
  String get chainNotFound => 'This chain doesn\'t exist.';

  @override
  String get couldntLoadChain => 'Couldn\'t load this chain.';

  @override
  String chainCurrentQuestLabel(String title) {
    return 'Current: $title';
  }

  @override
  String get chainStageLockedTitle => 'Locked';

  @override
  String chainStageFallbackTitle(int index) {
    return 'Stage $index';
  }

  @override
  String get chainStageCompleted => 'Completed';

  @override
  String get chainStageInProgress => 'In progress';

  @override
  String get chainStageLockedSubtitle => 'Complete the current stage first';

  @override
  String get identityTitle => 'Identity';

  @override
  String get couldntLoadIdentity => 'Couldn\'t load your identity profile.';

  @override
  String get attributesHeader => 'Attributes';

  @override
  String get strongestBadge => 'Strongest';

  @override
  String get weakestBadge => 'Weakest';

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String get lifetimeHeader => 'Lifetime';

  @override
  String get questsCompletedLabel => 'Quests completed';

  @override
  String get chainsCompletedLabel => 'Chains completed';

  @override
  String get achievementsUnlockedLabel => 'Achievements unlocked';

  @override
  String get totalXpEarnedLabel => 'Total XP earned';

  @override
  String get recentMilestonesHeader => 'Recent Milestones';

  @override
  String get noMilestonesYet =>
      'No milestones yet — complete quests to start building your story.';

  @override
  String milestoneUnlockedAchievement(String title) {
    return 'Unlocked \"$title\"';
  }

  @override
  String milestoneCompletedChain(String title) {
    return 'Completed \"$title\"';
  }

  @override
  String milestoneReachedLevel(int level) {
    return 'Reached Level $level';
  }

  @override
  String get youTitle => 'You';

  @override
  String get xpByAttributeHeader => 'XP by attribute';

  @override
  String get couldntLoadXp => 'Couldn\'t load your XP.';

  @override
  String get xpLoadErrorBody =>
      'Something went wrong loading your XP. Please try again.';

  @override
  String get levelUpEyebrow => 'LEVEL UP';

  @override
  String get levelUpSingle => 'You reached a new level';

  @override
  String levelUpMultiJump(int previous, int newLevel) {
    return 'Level $previous → Level $newLevel';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get generalSectionHeader => 'General';

  @override
  String get restartOnboardingTitle => 'Restart Onboarding';

  @override
  String get restartOnboardingSubtitle =>
      'See the intro and starter quests again';

  @override
  String get suggestionPreferencesTitle => 'Suggestion Preferences';

  @override
  String get suggestionPreferencesSubtitle =>
      'Life stage, goals, time, and pace for Suggestions';

  @override
  String get aboutSectionHeader => 'About';

  @override
  String get versionLabel => 'Version';

  @override
  String get localDataExplanation =>
      'All your data is stored only on this device, using local storage (Hive). Nothing is sent to a server. Uninstalling the app, or clearing local data below, permanently erases it.';

  @override
  String get licensesTitle => 'Licenses';

  @override
  String get licensesSubtitle => 'Open-source software used by Prime';

  @override
  String get dataSectionHeader => 'Data';

  @override
  String get clearAllDataTitle => 'Clear all local data';

  @override
  String get clearAllDataSubtitle =>
      'Permanently erase every quest, XP, and unlock';

  @override
  String get clearAllDataDialogTitle => 'Clear all local data?';

  @override
  String get clearAllDataDialogBody =>
      'This permanently deletes every quest, all progress, all XP, and every achievement and chain you have unlocked — on this device only. This cannot be undone.';

  @override
  String get deleteEverything => 'Delete everything';

  @override
  String get couldntClearData =>
      'Couldn\'t clear local data. Please try again.';

  @override
  String get languageSectionHeader => 'Language';

  @override
  String get languageSystemOption => 'System language';

  @override
  String get languageTurkishOption => 'Türkçe';

  @override
  String get languageEnglishOption => 'English';

  @override
  String get suggestionsTitle => 'Suggestions';

  @override
  String get preferencesTooltip => 'Preferences';

  @override
  String get pickedForYou => 'Picked for you';

  @override
  String get popularQuestsToStart => 'Popular quests to start with';

  @override
  String get basedOnGoals => 'Based on your goals, routine, and pace.';

  @override
  String get setPreferencesForPicks =>
      'Set your preferences for picks made just for you.';

  @override
  String get noSuggestionsLeft =>
      'You\'ve added every suggestion — nice work. Create a custom quest for anything else.';

  @override
  String get couldntLoadSuggestions =>
      'Couldn\'t load suggestions. Please try again.';

  @override
  String addedToQuests(String title) {
    return 'Added \"$title\" to your quests';
  }

  @override
  String alreadyInQuests(String title) {
    return '\"$title\" is already in your quests';
  }

  @override
  String get openLabel => 'Open';

  @override
  String get addQuestButton => 'Add Quest';

  @override
  String get couldntAddQuestShort => 'Couldn\'t add this quest. Try again.';

  @override
  String get suggestionNotFound => 'This suggestion doesn\'t exist.';

  @override
  String get estimatedTimeLabel => 'Estimated time';

  @override
  String get progressTargetLabel => 'Progress target';

  @override
  String get completeOnce => 'Complete once';

  @override
  String get addToMyQuestsButton => 'Add to My Quests';

  @override
  String get couldntAddQuestLong =>
      'Couldn\'t add this quest. Please try again.';

  @override
  String get whyRecommendedHeader => 'Why this was recommended';

  @override
  String get solidStartingPoint => 'A solid starting point for anyone.';

  @override
  String get reasonFitsLifeStage => 'Fits your life stage';

  @override
  String reasonMatchesGoal(String goal) {
    return 'Matches your goal: $goal';
  }

  @override
  String get reasonFitsAvailableTime => 'Fits your available time';

  @override
  String get reasonMatchesIntensity => 'Matches your preferred pace';

  @override
  String get lifeStageSectionLabel => 'Life stage';

  @override
  String get workingOnSectionLabel => 'What are you working on?';

  @override
  String get availableTimeSectionLabel => 'Available time per day';

  @override
  String get preferredIntensitySectionLabel => 'Preferred intensity';

  @override
  String get savePreferencesButton => 'Save Preferences';

  @override
  String get preferencesSaved => 'Preferences saved';

  @override
  String get couldntLoadPreferences => 'Couldn\'t load your preferences.';

  @override
  String get skip => 'Skip';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get addSelectedGetStarted => 'Add Selected & Get Started';

  @override
  String get wantHeadStart => 'Want a head start?';

  @override
  String get pickQuestsOptional =>
      'Pick any quests you want to start with — entirely optional. You can always add your own instead, or later.';

  @override
  String get browseMoreSuggestions => 'Browse more suggestions';

  @override
  String get onboardingSlide1Title => 'Welcome to Prime';

  @override
  String get onboardingSlide1Body =>
      'Prime turns your real habits into visible progress — no fantasy, no clutter, just your own effort tracked honestly.';

  @override
  String get onboardingSlide2Title => 'Quests are the things you do';

  @override
  String get onboardingSlide2Body =>
      'A daily habit, a one-off task, a bigger goal — each one is a Quest. Completing it makes progress.';

  @override
  String get onboardingSlide3Title => 'Progress earns XP';

  @override
  String get onboardingSlide3Body =>
      'Completing a quest earns XP toward the attribute it is about — Health, Discipline, Knowledge, and more.';

  @override
  String get onboardingSlide4Title => 'Attributes build your level';

  @override
  String get onboardingSlide4Body =>
      'XP adds up into a Level that only ever goes up — a simple, honest record of consistency over time.';

  @override
  String get onboardingSlide5Title => 'Find your story in You';

  @override
  String get onboardingSlide5Body =>
      'Achievements, Quest Chains, and your Identity Profile all live in the You tab — derived automatically from what you do. Nothing to set up.';

  @override
  String get starterDrinkWaterTitle => 'Drink water';

  @override
  String get starterDrinkWaterDesc => 'Stay hydrated through the day.';

  @override
  String get starterRead20Title => 'Read for 20 minutes';

  @override
  String get starterRead20Desc => 'A short daily reading habit.';

  @override
  String get starterWalk15Title => 'Walk for 15 minutes';

  @override
  String get starterWalk15Desc => 'A short walk, any time of day.';

  @override
  String get starterPlanTomorrowTitle => 'Plan tomorrow';

  @override
  String get starterPlanTomorrowDesc =>
      'A few minutes to set up tomorrow before today ends.';

  @override
  String get starterWorkoutTitle => 'Complete a workout';

  @override
  String get starterWorkoutDesc => 'Any real physical effort counts.';

  @override
  String get journalComingSoon => 'Journaling is coming soon.';

  @override
  String get storyComingSoon =>
      'Your story is still being written.\nCheck back soon.';

  @override
  String get focusTitle => 'Focus';

  @override
  String get attributeHealth => 'Health';

  @override
  String get attributeStrength => 'Strength';

  @override
  String get attributeDiscipline => 'Discipline';

  @override
  String get attributeKnowledge => 'Knowledge';

  @override
  String get attributeCareer => 'Career';

  @override
  String get attributeFinance => 'Finance';

  @override
  String get attributeRelationships => 'Relationships';

  @override
  String get attributeMindfulness => 'Mindfulness';

  @override
  String get difficultyTrivial => 'Trivial';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyNormal => 'Normal';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get difficultyVeryHard => 'Very Hard';

  @override
  String get questTypeDaily => 'Daily Quest';

  @override
  String get questTypeWeekly => 'Weekly Quest';

  @override
  String get questTypeMonthly => 'Monthly Quest';

  @override
  String get questTypeSide => 'Side Quest';

  @override
  String get questTypeEpic => 'Epic Quest';

  @override
  String get questTypeMainStory => 'Main Story Quest';

  @override
  String get questTypeRepeatable => 'Repeatable Quest';

  @override
  String get questTypeRecovery => 'Recovery Quest';

  @override
  String get progressTypeBinary => 'Binary (done / not done)';

  @override
  String get progressTypeQuantity => 'Quantity';

  @override
  String get progressTypeDuration => 'Duration';

  @override
  String get repeatabilityNone => 'One-time';

  @override
  String get repeatabilityDaily => 'Daily';

  @override
  String get repeatabilityWeekly => 'Weekly';

  @override
  String get questStateNotStarted => 'Not started';

  @override
  String get questStateInProgress => 'In progress';

  @override
  String get questStateComplete => 'Complete';

  @override
  String get questStateExpired => 'Expired';

  @override
  String get questStateConverted => 'Converted';

  @override
  String get lifeStageStudent => 'Student';

  @override
  String get lifeStageWorkingProfessional => 'Working professional';

  @override
  String get lifeStageEntrepreneur => 'Entrepreneur';

  @override
  String get lifeStageHomemaker => 'Homemaker';

  @override
  String get lifeStageRetired => 'Retired';

  @override
  String get lifeStageOther => 'Other';

  @override
  String get goalAreaStudy => 'Study';

  @override
  String get goalAreaCareer => 'Career';

  @override
  String get goalAreaFitness => 'Fitness';

  @override
  String get goalAreaNutrition => 'Nutrition';

  @override
  String get goalAreaSleep => 'Sleep';

  @override
  String get goalAreaReading => 'Reading';

  @override
  String get goalAreaMindfulness => 'Mindfulness';

  @override
  String get goalAreaFinance => 'Finance';

  @override
  String get goalAreaRelationships => 'Relationships';

  @override
  String get goalAreaOrganization => 'Organization';

  @override
  String get goalAreaCreativity => 'Creativity';

  @override
  String get goalAreaSelfCare => 'Self-care';

  @override
  String get availableTimeUnder15 => 'Under 15 minutes';

  @override
  String get availableTime15to30 => '15–30 minutes';

  @override
  String get availableTime30to60 => '30–60 minutes';

  @override
  String get availableTimeOver60 => 'Over 60 minutes';

  @override
  String get intensityGentle => 'Gentle';

  @override
  String get intensityBalanced => 'Balanced';

  @override
  String get intensityChallenging => 'Challenging';

  @override
  String get suggestionStudyPomodoroTitle => 'Study one focused Pomodoro';

  @override
  String get suggestionStudyPomodoroDesc =>
      '25 minutes of distraction-free study, one clean block.';

  @override
  String get suggestionStudyPomodoroMotivation =>
      'Small focused blocks beat long, unfocused sessions.';

  @override
  String get suggestionReviewLectureNotesTitle =>
      'Review today\'s lecture notes';

  @override
  String get suggestionReviewLectureNotesDesc =>
      'Go back over what you covered today while it\'s fresh.';

  @override
  String get suggestionSolvePracticeQuestionsTitle =>
      'Solve 10 practice questions';

  @override
  String get suggestionSolvePracticeQuestionsDesc =>
      'Active recall on 10 problems from your current subject.';

  @override
  String get suggestionRead20PagesTitle => 'Read 20 pages';

  @override
  String get suggestionRead20PagesDesc =>
      'Textbook, novel, or anything worth finishing.';

  @override
  String get suggestionPrepareTomorrowsTaskListTitle =>
      'Prepare tomorrow\'s task list';

  @override
  String get suggestionPrepareTomorrowsTaskListDesc =>
      'A few minutes tonight to walk into tomorrow with a plan.';

  @override
  String get suggestionPracticeEnglish15Title =>
      'Practice English for 15 minutes';

  @override
  String get suggestionPracticeEnglish15Desc =>
      'Vocabulary, listening, or conversation practice.';

  @override
  String get suggestionPlanTop3TasksTitle => 'Plan the top 3 tasks';

  @override
  String get suggestionPlanTop3TasksDesc =>
      'Before the day gets noisy, decide what actually matters.';

  @override
  String get suggestionFinishDeepWorkBlockTitle => 'Finish one deep-work block';

  @override
  String get suggestionFinishDeepWorkBlockDesc =>
      '60 minutes, one task, notifications off.';

  @override
  String get suggestionClearImportantEmailTitle =>
      'Clear the most important email';

  @override
  String get suggestionClearImportantEmailDesc =>
      'The one you\'ve been putting off — just that one.';

  @override
  String get suggestionWalk15BreakTitle => 'Take a 15-minute walk';

  @override
  String get suggestionWalk15BreakDesc => 'Step away from the desk and reset.';

  @override
  String get suggestionReviewWeeklyPrioritiesTitle =>
      'Review weekly priorities';

  @override
  String get suggestionReviewWeeklyPrioritiesDesc =>
      'A short check-in on whether this week is still on track.';

  @override
  String get suggestionLearnJobConceptTitle => 'Learn one job-related concept';

  @override
  String get suggestionLearnJobConceptDesc =>
      'Read, watch, or practice one thing that improves your work.';

  @override
  String get suggestionReviewWeeklyNumbersTitle =>
      'Review this week\'s numbers';

  @override
  String get suggestionReviewWeeklyNumbersDesc =>
      'Revenue, costs, or usage — whatever tells you the truth.';

  @override
  String get suggestionReachOutOneCustomerTitle =>
      'Reach out to one potential customer';

  @override
  String get suggestionReachOutOneCustomerDesc =>
      'One real conversation moves things more than a dozen plans.';

  @override
  String get suggestionWriteTopPriorityTitle =>
      'Write down today\'s top priority';

  @override
  String get suggestionWriteTopPriorityDesc =>
      'One sentence: what actually matters today.';

  @override
  String get suggestionReviewCashRunwayTitle => 'Review cash runway';

  @override
  String get suggestionReviewCashRunwayDesc =>
      'A few minutes with the numbers avoids surprises later.';

  @override
  String get suggestionBatchProcessInvoicesTitle => 'Batch process invoices';

  @override
  String get suggestionBatchProcessInvoicesDesc =>
      'Clear the paperwork in one sitting instead of piecemeal.';

  @override
  String get suggestionReadIndustryArticleTitle => 'Read one industry article';

  @override
  String get suggestionReadIndustryArticleDesc =>
      'Stay current on the space you\'re building in.';

  @override
  String get suggestionPlanWeeklyMealsTitle => 'Plan this week\'s meals';

  @override
  String get suggestionPlanWeeklyMealsDesc =>
      'Decide once, cook without decision fatigue all week.';

  @override
  String get suggestionTidySprint10Title => 'Do a 10-minute tidy sprint';

  @override
  String get suggestionTidySprint10Desc =>
      'One timer, one room, no perfectionism.';

  @override
  String get suggestionPrepTomorrowsLunchTitle => 'Prep tomorrow\'s lunch';

  @override
  String get suggestionPrepTomorrowsLunchDesc => 'Future you will be grateful.';

  @override
  String get suggestionCallFamilyMemberTitle => 'Call a family member';

  @override
  String get suggestionCallFamilyMemberDesc =>
      'A real conversation, not a text.';

  @override
  String get suggestionDeclutterOneDrawerTitle => 'Declutter one drawer';

  @override
  String get suggestionDeclutterOneDrawerDesc => 'Small scope, real progress.';

  @override
  String get suggestionBatchCookMealTitle => 'Batch-cook a meal';

  @override
  String get suggestionBatchCookMealDesc => 'Cook once, eat well for days.';

  @override
  String get suggestionGentleWalk15Title => 'Take a gentle 15-minute walk';

  @override
  String get suggestionGentleWalk15Desc => 'Easy pace, fresh air, no pressure.';

  @override
  String get suggestionCallOldFriendTitle => 'Call an old friend';

  @override
  String get suggestionCallOldFriendDesc =>
      'Reconnect with someone you haven\'t spoken to in a while.';

  @override
  String get suggestionReadChapterPleasureTitle =>
      'Read a chapter for pleasure';

  @override
  String get suggestionReadChapterPleasureDesc =>
      'No agenda — just a good book.';

  @override
  String get suggestionTryNewSimpleRecipeTitle => 'Try a new simple recipe';

  @override
  String get suggestionTryNewSimpleRecipeDesc =>
      'Cook something you\'ve never made before.';

  @override
  String get suggestionJournalEveningTitle =>
      'Write a journal entry about today';

  @override
  String get suggestionJournalEveningDesc =>
      'A few honest lines about how today went.';

  @override
  String get suggestionLearnNewWordTitle => 'Learn one new word';

  @override
  String get suggestionLearnNewWordDesc => 'Small, steady vocabulary growth.';

  @override
  String get suggestionWalk20Title => 'Walk for 20 minutes';

  @override
  String get suggestionWalk20Desc => 'Any pace, anywhere — just get moving.';

  @override
  String get suggestionFullBodyWorkoutTitle => 'Complete a full-body workout';

  @override
  String get suggestionFullBodyWorkoutDesc =>
      'One real session, whatever equipment you have.';

  @override
  String get suggestionPushups20Title => 'Do 20 push-ups';

  @override
  String get suggestionPushups20Desc =>
      'Spread them across the day if you need to.';

  @override
  String get suggestionStretch10Title => 'Stretch for 10 minutes';

  @override
  String get suggestionStretch10Desc => 'Loosen up, especially after sitting.';

  @override
  String get suggestionDrinkWater8Title => 'Drink 8 glasses of water';

  @override
  String get suggestionDrinkWater8Desc => 'Steady hydration through the day.';

  @override
  String get suggestionHighProteinMealTitle => 'Prepare a high-protein meal';

  @override
  String get suggestionHighProteinMealDesc => 'Fuel your training properly.';

  @override
  String get suggestionMobility5Title => 'Do a 5-minute mobility routine';

  @override
  String get suggestionMobility5Desc =>
      'Hips, shoulders, ankles — the joints that need it most.';

  @override
  String get suggestionTakeTheStairsTitle => 'Take the stairs today';

  @override
  String get suggestionTakeTheStairsDesc =>
      'A small, repeatable choice that adds up.';

  @override
  String get suggestionExtraVegetableServingTitle =>
      'Eat one extra serving of vegetables';

  @override
  String get suggestionExtraVegetableServingDesc =>
      'Add, don\'t restrict — just one more serving today.';

  @override
  String get suggestionCookAtHomeTitle =>
      'Cook a meal at home instead of ordering';

  @override
  String get suggestionCookAtHomeDesc =>
      'Control what goes in, save money too.';

  @override
  String get suggestionAvoidAddedSugarTitle => 'Avoid added sugar for the day';

  @override
  String get suggestionAvoidAddedSugarDesc => 'One full day, no added sugar.';

  @override
  String get suggestionMealPrepTomorrowTitle => 'Meal-prep for tomorrow';

  @override
  String get suggestionMealPrepTomorrowDesc =>
      'Set tomorrow\'s meals up tonight.';

  @override
  String get suggestionTrackTodaysMealsTitle => 'Track today\'s meals';

  @override
  String get suggestionTrackTodaysMealsDesc =>
      'Just noticing what you eat changes how you eat.';

  @override
  String get suggestionConsistentWakeupTitle => 'Set a consistent wake-up time';

  @override
  String get suggestionConsistentWakeupDesc =>
      'Same time every day, weekends included.';

  @override
  String get suggestionNoScreensBeforeBedTitle =>
      'No screens 30 minutes before bed';

  @override
  String get suggestionNoScreensBeforeBedDesc =>
      'Wind down without a backlit screen.';

  @override
  String get suggestionSleepBeforeTimeTitle => 'Sleep before a chosen time';

  @override
  String get suggestionSleepBeforeTimeDesc =>
      'Pick a bedtime and actually hit it.';

  @override
  String get suggestionNap20Title => 'Take a 20-minute nap';

  @override
  String get suggestionNap20Desc =>
      'Short enough to stay refreshing, not groggy.';

  @override
  String get suggestionWindDownWithBookTitle =>
      'Wind down with a book instead of a screen';

  @override
  String get suggestionWindDownWithBookDesc =>
      'Trade the scroll for a few pages.';

  @override
  String get suggestionReadOneArticleTitle => 'Read one article on a new topic';

  @override
  String get suggestionReadOneArticleDesc =>
      'Something outside your usual feed.';

  @override
  String get suggestionFinishOneChapterTitle => 'Finish one chapter';

  @override
  String get suggestionFinishOneChapterDesc =>
      'Keep the book moving, one chapter at a time.';

  @override
  String get suggestionReadBeforeBedTitle =>
      'Read before bed instead of scrolling';

  @override
  String get suggestionReadBeforeBedDesc =>
      'Swap the phone for a book at bedtime.';

  @override
  String get suggestionAudiobookChapterTitle =>
      'Listen to one audiobook chapter';

  @override
  String get suggestionAudiobookChapterDesc =>
      'Reading counts even with your ears.';

  @override
  String get suggestionMeditate10Title => 'Meditate for 10 minutes';

  @override
  String get suggestionMeditate10Desc =>
      'Sit, breathe, and let the noise settle.';

  @override
  String get suggestionDeepBreathing5Title =>
      'Practice 5 minutes of deep breathing';

  @override
  String get suggestionDeepBreathing5Desc =>
      'Slow, deliberate breaths — nothing else.';

  @override
  String get suggestionBodyScanTitle => 'Do a short body scan';

  @override
  String get suggestionBodyScanDesc =>
      'Notice tension from head to toe and let it go.';

  @override
  String get suggestionSitInSilence5Title => 'Sit in silence for 5 minutes';

  @override
  String get suggestionSitInSilence5Desc => 'No phone, no music — just quiet.';

  @override
  String get suggestionGratitudeThreeTitle =>
      'Practice gratitude — write 3 things down';

  @override
  String get suggestionGratitudeThreeDesc =>
      'Three specific things, however small.';

  @override
  String get suggestionMindfulWalkNoPhoneTitle =>
      'Do a mindful walk without your phone';

  @override
  String get suggestionMindfulWalkNoPhoneDesc =>
      'Just you, moving, paying attention.';

  @override
  String get suggestionLogTodaysSpendingTitle => 'Log today\'s spending';

  @override
  String get suggestionLogTodaysSpendingDesc =>
      'A quick, honest record of where money went.';

  @override
  String get suggestionReviewSubscriptionTitle =>
      'Review one subscription for cancellation';

  @override
  String get suggestionReviewSubscriptionDesc =>
      'Is it still worth what you\'re paying?';

  @override
  String get suggestionMoveToSavingsTitle => 'Move a fixed amount into savings';

  @override
  String get suggestionMoveToSavingsDesc =>
      'Even a small amount, moved consistently.';

  @override
  String get suggestionCheckWeeklyBudgetTitle =>
      'Check your budget for the week';

  @override
  String get suggestionCheckWeeklyBudgetDesc =>
      'A short look before spending gets away from you.';

  @override
  String get suggestionReadFinanceArticleTitle =>
      'Read one article about personal finance';

  @override
  String get suggestionReadFinanceArticleDesc =>
      'Build the knowledge, a little at a time.';

  @override
  String get suggestionThoughtfulMessageTitle =>
      'Send a thoughtful message to a friend';

  @override
  String get suggestionThoughtfulMessageDesc =>
      'Not a check-in — something real.';

  @override
  String get suggestionPhoneFreeMealTitle =>
      'Have a phone-free meal with someone';

  @override
  String get suggestionPhoneFreeMealDesc => 'Full attention, one meal.';

  @override
  String get suggestionNoteOfAppreciationTitle =>
      'Write a note of appreciation';

  @override
  String get suggestionNoteOfAppreciationDesc =>
      'Tell someone specifically what you appreciate about them.';

  @override
  String get suggestionPlanGetTogetherTitle => 'Plan a get-together';

  @override
  String get suggestionPlanGetTogetherDesc =>
      'Put something real on the calendar.';

  @override
  String get suggestionAskAboutTheirDayTitle =>
      'Ask a loved one about their day — and really listen';

  @override
  String get suggestionAskAboutTheirDayDesc =>
      'Give someone your full attention for a few minutes.';

  @override
  String get suggestionClearInboxZeroTitle => 'Clear your inbox to zero';

  @override
  String get suggestionClearInboxZeroDesc =>
      'Archive, reply, or delete — until it is empty.';

  @override
  String get suggestionPlanTomorrowMorningTitle => 'Plan tomorrow morning';

  @override
  String get suggestionPlanTomorrowMorningDesc =>
      'Decide your first task before the day starts.';

  @override
  String get suggestionOrganizeDesktopFilesTitle =>
      'Organize your desktop files';

  @override
  String get suggestionOrganizeDesktopFilesDesc =>
      'Fifteen minutes of digital tidying.';

  @override
  String get suggestionSketch10Title => 'Sketch for 10 minutes';

  @override
  String get suggestionSketch10Desc =>
      'No pressure to be good — just make marks.';

  @override
  String get suggestionWrite200WordsTitle => 'Write 200 words of anything';

  @override
  String get suggestionWrite200WordsDesc =>
      'Fiction, a journal, an idea — just write.';

  @override
  String get suggestionLearn3ChordsTitle => 'Learn 3 chords on an instrument';

  @override
  String get suggestionLearn3ChordsDesc => 'Pick it up and make some noise.';

  @override
  String get suggestionCreativePhotoTitle => 'Take one creative photo';

  @override
  String get suggestionCreativePhotoDesc =>
      'Look at something ordinary differently.';

  @override
  String get suggestionBrainstorm10IdeasTitle =>
      'Brainstorm 10 ideas for a project';

  @override
  String get suggestionBrainstorm10IdeasDesc =>
      'Quantity first — the good ones show up eventually.';

  @override
  String get suggestionPhoneFree20Title => 'Spend 20 minutes without the phone';

  @override
  String get suggestionPhoneFree20Desc => 'Just be, without checking anything.';

  @override
  String get suggestionRelaxingBathTitle => 'Take a relaxing bath or shower';

  @override
  String get suggestionRelaxingBathDesc => 'Unhurried, just for you.';

  @override
  String get suggestionFreshAirBreakTitle => 'Step outside for fresh air';

  @override
  String get suggestionFreshAirBreakDesc =>
      'A few minutes outside, no destination needed.';

  @override
  String get suggestionSayNoOnceTitle => 'Say no to one thing that drains you';

  @override
  String get suggestionSayNoOnceDesc => 'Protect your time on purpose.';

  @override
  String get suggestionSmallKindTreatTitle =>
      'Treat yourself to something small and kind';

  @override
  String get suggestionSmallKindTreatDesc =>
      'A real, deliberate act of care for yourself.';

  @override
  String get suggestionTidyOneAreaTitle => 'Tidy one small area';

  @override
  String get suggestionTidyOneAreaDesc =>
      'One shelf, one corner — contained and doable.';
}

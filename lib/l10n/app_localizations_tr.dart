// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Prime';

  @override
  String get startupFailureTitle => 'Prime başlatılamadı';

  @override
  String get startupFailureBody =>
      'Verileriniz yüklenemedi. Uygulamayı yeniden başlatmak genellikle bu sorunu çözer.';

  @override
  String get navToday => 'Bugün';

  @override
  String get navQuests => 'Görevler';

  @override
  String get navStory => 'Hikaye';

  @override
  String get navJournal => 'Günlük';

  @override
  String get navYou => 'Sen';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get delete => 'Sil';

  @override
  String get dismiss => 'Kapat';

  @override
  String get somethingWentWrong =>
      'Bir şeyler ters gitti. Lütfen tekrar deneyin.';

  @override
  String get noQuestsYet =>
      'Henüz görev yok. Oluşturduğunuz görevler burada görünecek.';

  @override
  String get browseSuggestions => 'Önerilere Göz At';

  @override
  String get createQuestLabel => 'Görev Oluştur';

  @override
  String get difficultyLabel => 'Zorluk';

  @override
  String get repeatsLabel => 'Tekrar';

  @override
  String get attributeAllocationLabel => 'Nitelik dağılımı';

  @override
  String get questNotFound => 'Bu görev mevcut değil veya kaldırılmış.';

  @override
  String get couldntLoadQuest => 'Bu görev yüklenemedi.';

  @override
  String get questLoadErrorBody =>
      'Görev yüklenirken bir sorun oluştu. Lütfen tekrar deneyin.';

  @override
  String get continueLabel => 'Devam Et';

  @override
  String get greetingNight => 'İyi geceler';

  @override
  String get greetingMorning => 'Günaydın';

  @override
  String get greetingAfternoon => 'Tünaydın';

  @override
  String get greetingEvening => 'İyi akşamlar';

  @override
  String playerLevelLabel(int level) {
    return 'Seviye $level';
  }

  @override
  String playerXpTotal(String xp) {
    return 'Toplam $xp XP';
  }

  @override
  String playerXpToNextLevel(int current, int needed) {
    return 'Sonraki seviyeye $current / $needed XP';
  }

  @override
  String get motivationalLine1 => 'Küçük, tutarlı adımlar birikir.';

  @override
  String get motivationalLine2 =>
      'Momentum, bir seferde bir görevle inşa edilir.';

  @override
  String get motivationalLine3 => 'Bugün disiplin, yarın ilerleme.';

  @override
  String get motivationalLine4 => 'Sadece göster kendini — gerisi gelir.';

  @override
  String get motivationalLine5 =>
      'Her tekrar bir sonraki seviyeye katkı sağlar.';

  @override
  String get couldntLoadLevel => 'Seviyeniz yüklenemedi.';

  @override
  String get dailyMomentumTitle => 'Günlük ivme';

  @override
  String get dailyMomentumNoQuests => 'Henüz görev yok';

  @override
  String dailyMomentumProgress(int completed, int total) {
    return '$total görevden $completed tamamlandı';
  }

  @override
  String dailyMomentumXpToday(String xp) {
    return 'Bugün $xp XP';
  }

  @override
  String get couldntLoadTodayProgress => 'Bugünkü ilerleme yüklenemedi.';

  @override
  String get growthTodayTitle => 'Bugünkü gelişim';

  @override
  String get growthTodayEmpty => 'Bugün henüz XP kazanılmadı';

  @override
  String get couldntLoadTodayXp => 'Bugünkü XP yüklenemedi.';

  @override
  String get couldntLoadTodayQuests => 'Bugünkü görevler yüklenemedi.';

  @override
  String get mainQuestLabel => 'BUGÜNÜN GÖREVİ';

  @override
  String get heroCtaBegin => 'Başla';

  @override
  String get heroEmptyHeadline => 'Bugünün görevine hazır mısın?';

  @override
  String get completedTodayLabel => 'Bugün tamamlandı';

  @override
  String get ctaView => 'Görüntüle';

  @override
  String get ctaComplete => 'Tamamla';

  @override
  String get ctaAddProgress => 'İlerleme Ekle';

  @override
  String get ctaContinue => 'Devam Et';

  @override
  String get couldntLoadMainQuest => 'Ana göreviniz yüklenemedi.';

  @override
  String get questsTitle => 'Görevler';

  @override
  String get suggestionsTooltip => 'Öneriler';

  @override
  String get createQuestTooltip => 'Görev Oluştur';

  @override
  String get couldntLoadQuests => 'Görevler yüklenemedi.';

  @override
  String get questsLoadErrorBody =>
      'Görevleriniz yüklenirken bir sorun oluştu. Lütfen tekrar deneyin.';

  @override
  String get questFallbackTitle => 'Görev';

  @override
  String get editQuestTooltip => 'Görevi Düzenle';

  @override
  String get deleteQuestTooltip => 'Görevi Sil';

  @override
  String questCompletedXp(int xp) {
    return 'Görev tamamlandı — +$xp XP';
  }

  @override
  String get deleteQuestDialogTitle => 'Görev silinsin mi?';

  @override
  String deleteQuestDialogBody(String title) {
    return '\"$title\" silinsin mi? Bu, görevi ve günlük ilerlemesini kaldırır. Bu görevden şimdiye kadar kazandığınız XP korunur.';
  }

  @override
  String get questCompleteForToday => 'Görev bugün için tamamlandı';

  @override
  String get typeLabel => 'Tür';

  @override
  String get baseXpLabel => 'Temel XP';

  @override
  String get statusLabel => 'Durum';

  @override
  String get couldntCompleteQuest => 'Bu görev tamamlanamadı';

  @override
  String get rewardSectionHeader => 'Kazanımlar';

  @override
  String get whyThisMattersHeader => 'Neden önemli';

  @override
  String get titleLabel => 'Başlık';

  @override
  String get descriptionLabel => 'Açıklama';

  @override
  String get titleRequiredError => 'Başlık gereklidir';

  @override
  String get titleTooLongError => 'Başlık en fazla 100 karakter olmalı';

  @override
  String get descriptionTooLongError => 'Açıklama en fazla 500 karakter olmalı';

  @override
  String get questTypeLabel => 'Görev türü';

  @override
  String get progressTypeLabel => 'İlerleme türü';

  @override
  String get targetProgressLabel => 'Hedef ilerleme';

  @override
  String get enterPositiveNumberError => 'Pozitif bir sayı girin';

  @override
  String get discardChangesTitle => 'Değişiklikler silinsin mi?';

  @override
  String get discardChangesBody =>
      'Kaydedilmemiş değişiklikleriniz var. Şimdi çıkarsanız kaydedilmeyecekler.';

  @override
  String get keepEditing => 'Düzenlemeye Devam Et';

  @override
  String get discard => 'Vazgeç';

  @override
  String get saveChanges => 'Değişiklikleri Kaydet';

  @override
  String get newQuestTitle => 'Yeni Görev';

  @override
  String get editQuestTitle => 'Görevi Düzenle';

  @override
  String get addAttributeButton => 'Nitelik ekle';

  @override
  String totalXpLabel(int total) {
    return 'Toplam: $total XP';
  }

  @override
  String get attributeLabel => 'Nitelik';

  @override
  String get xpWeightLabel => 'XP ağırlığı';

  @override
  String get enterWholeNumberError => 'Tam sayı girin';

  @override
  String get mustNotBeNegativeError => 'Negatif olamaz';

  @override
  String get removeAttributeTooltip => 'Niteliği kaldır';

  @override
  String get completeQuestButton => 'Görevi Tamamla';

  @override
  String get progressLabel => 'İlerleme';

  @override
  String get decreaseBy1 => '1 azalt';

  @override
  String get increaseBy1 => '1 artır';

  @override
  String get customAmountLabel => 'Özel miktar';

  @override
  String get addButton => 'Ekle';

  @override
  String decrementMinutes(int minutes) {
    return '-$minutes dk';
  }

  @override
  String minutesValue(String minutes) {
    return '$minutes dk';
  }

  @override
  String get minutesUnit => ' dk';

  @override
  String get todayLabel => 'Bugün';

  @override
  String get notYetLabel => 'Henüz değil';

  @override
  String completionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kez',
      one: '1 kez',
    );
    return '$_temp0';
  }

  @override
  String get xpEarnedTodayLabel => 'Bugün kazanılan XP';

  @override
  String xpAmount(String xp) {
    return '$xp XP';
  }

  @override
  String get achievementsTitle => 'Başarımlar';

  @override
  String get unlockedSectionHeader => 'Açılanlar';

  @override
  String get lockedSectionHeader => 'Kilitli';

  @override
  String get noneUnlockedYet =>
      'Henüz yok — kilitleri açmaya başlamak için görev tamamlayın.';

  @override
  String get allUnlocked => 'Tüm başarımlar açıldı.';

  @override
  String achievementSummaryCount(int unlocked, int total) {
    return '$unlocked / $total';
  }

  @override
  String unlockedOn(String date) {
    return '$date tarihinde açıldı';
  }

  @override
  String get hiddenAchievementTitle => 'Gizli Başarım';

  @override
  String get hiddenAchievementBody =>
      'Bu başarımı ortaya çıkarmak için oynamaya devam edin.';

  @override
  String get couldntLoadAchievements => 'Başarımlarınız yüklenemedi.';

  @override
  String get achievementsLoadErrorBody =>
      'Başarımlar yüklenirken bir sorun oluştu. Lütfen tekrar deneyin.';

  @override
  String get achievementUnlockedEyebrow => 'BAŞARIM AÇILDI';

  @override
  String rewardXpLabel(int xp) {
    return '+$xp XP';
  }

  @override
  String get nice => 'Harika';

  @override
  String get achievementFirstStepTitle => 'İlk Adım';

  @override
  String get achievementFirstStepDesc => 'İlk görevinizi tamamlayın.';

  @override
  String get achievementGettingStartedTitle => 'Başlangıç';

  @override
  String get achievementGettingStartedDesc => '5 görev tamamlayın.';

  @override
  String get achievementConsistentTitle => 'Tutarlı';

  @override
  String get achievementConsistentDesc =>
      'Art arda 3 gün boyunca bir görev tamamlayın.';

  @override
  String get achievementExperiencedTitle => 'Deneyimli';

  @override
  String get achievementExperiencedDesc => 'Oyuncu seviyesi 5\'e ulaşın.';

  @override
  String get achievementXpHunterTitle => 'XP Avcısı';

  @override
  String get achievementXpHunterDesc => '1.000 kalıcı XP\'ye ulaşın.';

  @override
  String get achievementSpecialistTitle => 'Uzman';

  @override
  String get achievementSpecialistDesc =>
      'Tek bir nitelikte 500 XP\'ye ulaşın.';

  @override
  String get achievementChallengerTitle => 'Meydan Okuyan';

  @override
  String get achievementChallengerDesc =>
      'Zor veya Çok Zor bir görevi tamamlayın.';

  @override
  String get chainsTitle => 'Zincirler';

  @override
  String get activeChainsHeader => 'Aktif Zincirler';

  @override
  String get completedChainsHeader => 'Tamamlanan Zincirler';

  @override
  String get noActiveChains => 'Henüz aktif zincir yok.';

  @override
  String get noCompletedChains => 'Henüz tamamlanan zincir yok.';

  @override
  String get couldntLoadChains => 'Zincirleriniz yüklenemedi.';

  @override
  String get chainsLoadErrorBody =>
      'Zincirler yüklenirken bir sorun oluştu. Lütfen tekrar deneyin.';

  @override
  String get chainFallbackTitle => 'Zincir';

  @override
  String get hiddenChainTitle => 'Gizli Zincir';

  @override
  String get hiddenChainBody =>
      'Bu zinciri keşfetmek için oynamaya devam edin.';

  @override
  String chainCompletePercent(int percent) {
    return '%$percent tamamlandı';
  }

  @override
  String get chainFinishedSuffix => ' — zincir tamamlandı';

  @override
  String get stagesHeader => 'Aşamalar';

  @override
  String get chainNotFound => 'Bu zincir mevcut değil.';

  @override
  String get couldntLoadChain => 'Bu zincir yüklenemedi.';

  @override
  String chainCurrentQuestLabel(String title) {
    return 'Şu an: $title';
  }

  @override
  String get chainStageLockedTitle => 'Kilitli';

  @override
  String chainStageFallbackTitle(int index) {
    return 'Aşama $index';
  }

  @override
  String get chainStageCompleted => 'Tamamlandı';

  @override
  String get chainStageInProgress => 'Devam ediyor';

  @override
  String get chainStageLockedSubtitle => 'Önce mevcut aşamayı tamamlayın';

  @override
  String get identityTitle => 'Kimlik';

  @override
  String get couldntLoadIdentity => 'Kimlik profiliniz yüklenemedi.';

  @override
  String get attributesHeader => 'Nitelikler';

  @override
  String get strongestBadge => 'En Güçlü';

  @override
  String get weakestBadge => 'En Zayıf';

  @override
  String percentValue(int percent) {
    return '%$percent';
  }

  @override
  String get lifetimeHeader => 'Kalıcı';

  @override
  String get questsCompletedLabel => 'Tamamlanan görevler';

  @override
  String get chainsCompletedLabel => 'Tamamlanan zincirler';

  @override
  String get achievementsUnlockedLabel => 'Açılan başarımlar';

  @override
  String get totalXpEarnedLabel => 'Kazanılan toplam XP';

  @override
  String get recentMilestonesHeader => 'Son Kilometre Taşları';

  @override
  String get noMilestonesYet =>
      'Henüz kilometre taşı yok — hikayenizi oluşturmaya başlamak için görev tamamlayın.';

  @override
  String milestoneUnlockedAchievement(String title) {
    return '\"$title\" açıldı';
  }

  @override
  String milestoneCompletedChain(String title) {
    return '\"$title\" tamamlandı';
  }

  @override
  String milestoneReachedLevel(int level) {
    return 'Seviye $level\'e ulaşıldı';
  }

  @override
  String get youTitle => 'Sen';

  @override
  String get xpByAttributeHeader => 'Niteliklere göre XP';

  @override
  String get couldntLoadXp => 'XP\'niz yüklenemedi.';

  @override
  String get xpLoadErrorBody =>
      'XP\'niz yüklenirken bir sorun oluştu. Lütfen tekrar deneyin.';

  @override
  String get levelUpEyebrow => 'SEVİYE ATLADI';

  @override
  String get levelUpSingle => 'Yeni bir seviyeye ulaştınız';

  @override
  String levelUpMultiJump(int previous, int newLevel) {
    return 'Seviye $previous → Seviye $newLevel';
  }

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get generalSectionHeader => 'Genel';

  @override
  String get restartOnboardingTitle => 'Tanıtımı Yeniden Başlat';

  @override
  String get restartOnboardingSubtitle =>
      'Tanıtımı ve başlangıç görevlerini tekrar görün';

  @override
  String get suggestionPreferencesTitle => 'Öneri Tercihleri';

  @override
  String get suggestionPreferencesSubtitle =>
      'Öneriler için yaşam evresi, hedefler, süre ve tempo';

  @override
  String get aboutSectionHeader => 'Hakkında';

  @override
  String get versionLabel => 'Sürüm';

  @override
  String get localDataExplanation =>
      'Tüm verileriniz yalnızca bu cihazda, yerel depolama (Hive) kullanılarak saklanır. Hiçbir şey bir sunucuya gönderilmez. Uygulamayı kaldırmak veya aşağıdan yerel verileri temizlemek, verilerinizi kalıcı olarak siler.';

  @override
  String get licensesTitle => 'Lisanslar';

  @override
  String get licensesSubtitle =>
      'Prime tarafından kullanılan açık kaynak yazılımlar';

  @override
  String get dataSectionHeader => 'Veri';

  @override
  String get clearAllDataTitle => 'Tüm yerel verileri temizle';

  @override
  String get clearAllDataSubtitle =>
      'Her görevi, XP\'yi ve kilidi kalıcı olarak sil';

  @override
  String get clearAllDataDialogTitle => 'Tüm yerel veriler temizlensin mi?';

  @override
  String get clearAllDataDialogBody =>
      'Bu işlem yalnızca bu cihazdaki her görevi, tüm ilerlemeyi, tüm XP\'yi ve kilidini açtığınız her başarım ve zinciri kalıcı olarak siler. Bu işlem geri alınamaz.';

  @override
  String get deleteEverything => 'Her şeyi sil';

  @override
  String get couldntClearData =>
      'Yerel veriler temizlenemedi. Lütfen tekrar deneyin.';

  @override
  String get languageSectionHeader => 'Dil';

  @override
  String get languageSystemOption => 'Sistem dili';

  @override
  String get languageTurkishOption => 'Türkçe';

  @override
  String get languageEnglishOption => 'English';

  @override
  String get suggestionsTitle => 'Öneriler';

  @override
  String get preferencesTooltip => 'Tercihler';

  @override
  String get pickedForYou => 'Sizin için seçildi';

  @override
  String get popularQuestsToStart => 'Başlamak için popüler görevler';

  @override
  String get basedOnGoals => 'Hedeflerinize, rutininize ve temponuza göre.';

  @override
  String get setPreferencesForPicks =>
      'Size özel seçimler için tercihlerinizi ayarlayın.';

  @override
  String get noSuggestionsLeft =>
      'Tüm önerileri eklediniz — harika iş. Başka bir şey için özel bir görev oluşturabilirsiniz.';

  @override
  String get couldntLoadSuggestions =>
      'Öneriler yüklenemedi. Lütfen tekrar deneyin.';

  @override
  String addedToQuests(String title) {
    return '\"$title\" görevlerinize eklendi';
  }

  @override
  String alreadyInQuests(String title) {
    return '\"$title\" zaten görevlerinizde';
  }

  @override
  String get openLabel => 'Aç';

  @override
  String get addQuestButton => 'Görevi Ekle';

  @override
  String get couldntAddQuestShort => 'Bu görev eklenemedi. Tekrar deneyin.';

  @override
  String get suggestionNotFound => 'Bu öneri mevcut değil.';

  @override
  String get estimatedTimeLabel => 'Tahmini süre';

  @override
  String get progressTargetLabel => 'İlerleme hedefi';

  @override
  String get completeOnce => 'Bir kez tamamla';

  @override
  String get addToMyQuestsButton => 'Görevlerime Ekle';

  @override
  String get couldntAddQuestLong =>
      'Bu görev eklenemedi. Lütfen tekrar deneyin.';

  @override
  String get whyRecommendedHeader => 'Neden önerildi';

  @override
  String get solidStartingPoint => 'Herkes için sağlam bir başlangıç noktası.';

  @override
  String get reasonFitsLifeStage => 'Yaşam evrenize uyuyor';

  @override
  String reasonMatchesGoal(String goal) {
    return 'Hedefinizle eşleşiyor: $goal';
  }

  @override
  String get reasonFitsAvailableTime => 'Uygun sürenize uyuyor';

  @override
  String get reasonMatchesIntensity => 'Tercih ettiğiniz tempoyla eşleşiyor';

  @override
  String get lifeStageSectionLabel => 'Yaşam evresi';

  @override
  String get workingOnSectionLabel => 'Ne üzerinde çalışıyorsunuz?';

  @override
  String get availableTimeSectionLabel => 'Günlük uygun süre';

  @override
  String get preferredIntensitySectionLabel => 'Tercih edilen tempo';

  @override
  String get savePreferencesButton => 'Tercihleri Kaydet';

  @override
  String get preferencesSaved => 'Tercihler kaydedildi';

  @override
  String get couldntLoadPreferences => 'Tercihleriniz yüklenemedi.';

  @override
  String get skip => 'Atla';

  @override
  String get back => 'Geri';

  @override
  String get next => 'İleri';

  @override
  String get getStarted => 'Başla';

  @override
  String get addSelectedGetStarted => 'Seçilenleri Ekle ve Başla';

  @override
  String get wantHeadStart => 'Öne geçmek ister misiniz?';

  @override
  String get pickQuestsOptional =>
      'Başlamak istediğiniz görevleri seçin — tamamen isteğe bağlı. İsterseniz kendi görevlerinizi de ekleyebilir ya da bunu daha sonra yapabilirsiniz.';

  @override
  String get browseMoreSuggestions => 'Daha fazla öneriye göz at';

  @override
  String get onboardingSlide1Title => 'Prime\'a Hoş Geldiniz';

  @override
  String get onboardingSlide1Body =>
      'Prime, gerçek alışkanlıklarınızı görünür ilerlemeye dönüştürür — fantastik öğeler yok, karmaşa yok, sadece dürüstçe takip edilen kendi çabanız.';

  @override
  String get onboardingSlide2Title => 'Görevler yaptığınız şeylerdir';

  @override
  String get onboardingSlide2Body =>
      'Günlük bir alışkanlık, tek seferlik bir görev, daha büyük bir hedef — her biri bir Görevdir. Onu tamamlamak ilerleme sağlar.';

  @override
  String get onboardingSlide3Title => 'İlerleme XP kazandırır';

  @override
  String get onboardingSlide3Body =>
      'Bir görevi tamamlamak, ilgili olduğu nitelik için XP kazandırır — Sağlık, Disiplin, Bilgi ve daha fazlası.';

  @override
  String get onboardingSlide4Title => 'Nitelikler seviyenizi oluşturur';

  @override
  String get onboardingSlide4Body =>
      'XP birikerek yalnızca yükselen bir Seviye oluşturur — zaman içindeki tutarlılığınızın basit, dürüst bir kaydı.';

  @override
  String get onboardingSlide5Title => 'Hikayenizi Sen\'de bulun';

  @override
  String get onboardingSlide5Body =>
      'Başarımlar, Görev Zincirleri ve Kimlik Profiliniz Sen sekmesinde yer alır — yaptıklarınızdan otomatik olarak türetilir. Kurulacak hiçbir şey yok.';

  @override
  String get starterDrinkWaterTitle => 'Su iç';

  @override
  String get starterDrinkWaterDesc => 'Gün boyunca sıvı alımınızı sürdürün.';

  @override
  String get starterRead20Title => '20 dakika oku';

  @override
  String get starterRead20Desc => 'Kısa bir günlük okuma alışkanlığı.';

  @override
  String get starterWalk15Title => '15 dakika yürü';

  @override
  String get starterWalk15Desc =>
      'Günün herhangi bir saatinde kısa bir yürüyüş.';

  @override
  String get starterPlanTomorrowTitle => 'Yarını planla';

  @override
  String get starterPlanTomorrowDesc =>
      'Bugün bitmeden yarını hazırlamak için birkaç dakika.';

  @override
  String get starterWorkoutTitle => 'Antrenman yap';

  @override
  String get starterWorkoutDesc => 'Gerçek bir fiziksel çaba sayılır.';

  @override
  String get journalComingSoon => 'Günlük tutma yakında geliyor.';

  @override
  String get storyComingSoon =>
      'Hikayeniz hâlâ yazılıyor.\nYakında tekrar bakın.';

  @override
  String get focusTitle => 'Odak';

  @override
  String get attributeHealth => 'Sağlık';

  @override
  String get attributeStrength => 'Güç';

  @override
  String get attributeDiscipline => 'Disiplin';

  @override
  String get attributeKnowledge => 'Bilgi';

  @override
  String get attributeCareer => 'Kariyer';

  @override
  String get attributeFinance => 'Finans';

  @override
  String get attributeRelationships => 'İlişkiler';

  @override
  String get attributeMindfulness => 'Farkındalık';

  @override
  String get difficultyTrivial => 'Çok Kolay';

  @override
  String get difficultyEasy => 'Kolay';

  @override
  String get difficultyNormal => 'Normal';

  @override
  String get difficultyHard => 'Zor';

  @override
  String get difficultyVeryHard => 'Çok Zor';

  @override
  String get questTypeDaily => 'Günlük Görev';

  @override
  String get questTypeWeekly => 'Haftalık Görev';

  @override
  String get questTypeMonthly => 'Aylık Görev';

  @override
  String get questTypeSide => 'Yan Görev';

  @override
  String get questTypeEpic => 'Epik Görev';

  @override
  String get questTypeMainStory => 'Ana Hikaye Görevi';

  @override
  String get questTypeRepeatable => 'Tekrarlanan Görev';

  @override
  String get questTypeRecovery => 'Toparlanma Görevi';

  @override
  String get progressTypeBinary => 'İkili (yapıldı / yapılmadı)';

  @override
  String get progressTypeQuantity => 'Miktar';

  @override
  String get progressTypeDuration => 'Süre';

  @override
  String get repeatabilityNone => 'Tek seferlik';

  @override
  String get repeatabilityDaily => 'Günlük';

  @override
  String get repeatabilityWeekly => 'Haftalık';

  @override
  String get questStateNotStarted => 'Başlamadı';

  @override
  String get questStateInProgress => 'Devam ediyor';

  @override
  String get questStateComplete => 'Tamamlandı';

  @override
  String get questStateExpired => 'Süresi doldu';

  @override
  String get questStateConverted => 'Dönüştürüldü';

  @override
  String get lifeStageStudent => 'Öğrenci';

  @override
  String get lifeStageWorkingProfessional => 'Çalışan profesyonel';

  @override
  String get lifeStageEntrepreneur => 'Girişimci';

  @override
  String get lifeStageHomemaker => 'Ev hanımı/beyi';

  @override
  String get lifeStageRetired => 'Emekli';

  @override
  String get lifeStageOther => 'Diğer';

  @override
  String get goalAreaStudy => 'Ders çalışma';

  @override
  String get goalAreaCareer => 'Kariyer';

  @override
  String get goalAreaFitness => 'Fitness';

  @override
  String get goalAreaNutrition => 'Beslenme';

  @override
  String get goalAreaSleep => 'Uyku';

  @override
  String get goalAreaReading => 'Okuma';

  @override
  String get goalAreaMindfulness => 'Farkındalık';

  @override
  String get goalAreaFinance => 'Finans';

  @override
  String get goalAreaRelationships => 'İlişkiler';

  @override
  String get goalAreaOrganization => 'Düzen';

  @override
  String get goalAreaCreativity => 'Yaratıcılık';

  @override
  String get goalAreaSelfCare => 'Öz bakım';

  @override
  String get availableTimeUnder15 => '15 dakikadan az';

  @override
  String get availableTime15to30 => '15–30 dakika';

  @override
  String get availableTime30to60 => '30–60 dakika';

  @override
  String get availableTimeOver60 => '60 dakikadan fazla';

  @override
  String get intensityGentle => 'Hafif';

  @override
  String get intensityBalanced => 'Dengeli';

  @override
  String get intensityChallenging => 'Zorlayıcı';

  @override
  String get suggestionStudyPomodoroTitle => 'Odaklanmış bir Pomodoro çalış';

  @override
  String get suggestionStudyPomodoroDesc =>
      'Dikkat dağıtmadan 25 dakika, tek bir temiz blok.';

  @override
  String get suggestionStudyPomodoroMotivation =>
      'Küçük, odaklı bloklar uzun, dağınık oturumlardan daha iyidir.';

  @override
  String get suggestionReviewLectureNotesTitle =>
      'Bugünkü ders notlarını gözden geçir';

  @override
  String get suggestionReviewLectureNotesDesc =>
      'Bugün işlediklerinizi taze aklınızdayken tekrar gözden geçirin.';

  @override
  String get suggestionSolvePracticeQuestionsTitle => '10 alıştırma sorusu çöz';

  @override
  String get suggestionSolvePracticeQuestionsDesc =>
      'Mevcut konunuzdan 10 soru üzerinde aktif hatırlama pratiği yapın.';

  @override
  String get suggestionRead20PagesTitle => '20 sayfa oku';

  @override
  String get suggestionRead20PagesDesc =>
      'Ders kitabı, roman veya bitirmeye değer herhangi bir şey.';

  @override
  String get suggestionPrepareTomorrowsTaskListTitle =>
      'Yarının görev listesini hazırla';

  @override
  String get suggestionPrepareTomorrowsTaskListDesc =>
      'Yarına bir planla girmek için bu akşam birkaç dakika ayırın.';

  @override
  String get suggestionPracticeEnglish15Title =>
      '15 dakika İngilizce pratiği yap';

  @override
  String get suggestionPracticeEnglish15Desc =>
      'Kelime, dinleme veya konuşma pratiği.';

  @override
  String get suggestionPlanTop3TasksTitle => 'En önemli 3 görevi planla';

  @override
  String get suggestionPlanTop3TasksDesc =>
      'Gün yoğunlaşmadan önce gerçekten neyin önemli olduğuna karar verin.';

  @override
  String get suggestionFinishDeepWorkBlockTitle =>
      'Bir derin çalışma bloğunu tamamla';

  @override
  String get suggestionFinishDeepWorkBlockDesc =>
      '60 dakika, tek bir görev, bildirimler kapalı.';

  @override
  String get suggestionClearImportantEmailTitle => 'En önemli e-postayı hallet';

  @override
  String get suggestionClearImportantEmailDesc =>
      'Ertelediğiniz o e-posta — sadece o bir tanesi.';

  @override
  String get suggestionWalk15BreakTitle => '15 dakikalık bir yürüyüşe çık';

  @override
  String get suggestionWalk15BreakDesc =>
      'Masadan uzaklaşın ve kendinizi yenileyin.';

  @override
  String get suggestionReviewWeeklyPrioritiesTitle =>
      'Haftalık öncelikleri gözden geçir';

  @override
  String get suggestionReviewWeeklyPrioritiesDesc =>
      'Bu haftanın hâlâ yolunda olup olmadığına kısa bir bakış.';

  @override
  String get suggestionLearnJobConceptTitle =>
      'İşinizle ilgili bir kavram öğrenin';

  @override
  String get suggestionLearnJobConceptDesc =>
      'İşinizi geliştirecek bir şeyi okuyun, izleyin veya uygulayın.';

  @override
  String get suggestionReviewWeeklyNumbersTitle =>
      'Bu haftanın rakamlarını gözden geçir';

  @override
  String get suggestionReviewWeeklyNumbersDesc =>
      'Gelir, maliyetler veya kullanım — size gerçeği söyleyen her ne ise.';

  @override
  String get suggestionReachOutOneCustomerTitle =>
      'Potansiyel bir müşteriyle iletişime geç';

  @override
  String get suggestionReachOutOneCustomerDesc =>
      'Gerçek bir konuşma, bir düzine plandan daha fazla şeyi ilerletir.';

  @override
  String get suggestionWriteTopPriorityTitle =>
      'Bugünün en önemli önceliğini yaz';

  @override
  String get suggestionWriteTopPriorityDesc =>
      'Tek cümle: bugün gerçekten neyin önemli olduğu.';

  @override
  String get suggestionReviewCashRunwayTitle =>
      'Nakit dayanıklılığını gözden geçir';

  @override
  String get suggestionReviewCashRunwayDesc =>
      'Rakamlara birkaç dakika ayırmak sonradan sürprizlerin önüne geçer.';

  @override
  String get suggestionBatchProcessInvoicesTitle =>
      'Faturaları toplu olarak işle';

  @override
  String get suggestionBatchProcessInvoicesDesc =>
      'Evrak işlerini parça parça yerine tek seferde halledin.';

  @override
  String get suggestionReadIndustryArticleTitle => 'Bir sektör makalesi oku';

  @override
  String get suggestionReadIndustryArticleDesc =>
      'İçinde bulunduğunuz alandaki gelişmeleri takip edin.';

  @override
  String get suggestionPlanWeeklyMealsTitle => 'Bu haftanın yemeklerini planla';

  @override
  String get suggestionPlanWeeklyMealsDesc =>
      'Bir kez karar verin, hafta boyunca karar yorgunluğu yaşamadan pişirin.';

  @override
  String get suggestionTidySprint10Title =>
      '10 dakikalık bir toparlama sprinti yap';

  @override
  String get suggestionTidySprint10Desc =>
      'Tek bir zamanlayıcı, tek bir oda, mükemmeliyetçilik yok.';

  @override
  String get suggestionPrepTomorrowsLunchTitle =>
      'Yarının öğle yemeğini hazırla';

  @override
  String get suggestionPrepTomorrowsLunchDesc =>
      'Yarınki siz buna minnettar olacak.';

  @override
  String get suggestionCallFamilyMemberTitle => 'Bir aile üyenizi arayın';

  @override
  String get suggestionCallFamilyMemberDesc =>
      'Mesaj değil, gerçek bir konuşma.';

  @override
  String get suggestionDeclutterOneDrawerTitle => 'Bir çekmeceyi düzenle';

  @override
  String get suggestionDeclutterOneDrawerDesc =>
      'Küçük kapsam, gerçek ilerleme.';

  @override
  String get suggestionBatchCookMealTitle => 'Toplu yemek pişir';

  @override
  String get suggestionBatchCookMealDesc =>
      'Bir kez pişirin, günlerce iyi yiyin.';

  @override
  String get suggestionGentleWalk15Title =>
      'Hafif tempoda 15 dakika yürüyüş yap';

  @override
  String get suggestionGentleWalk15Desc =>
      'Rahat bir tempo, temiz hava, baskı yok.';

  @override
  String get suggestionCallOldFriendTitle => 'Eski bir arkadaşınızı arayın';

  @override
  String get suggestionCallOldFriendDesc =>
      'Uzun süredir konuşmadığınız biriyle yeniden bağlantı kurun.';

  @override
  String get suggestionReadChapterPleasureTitle => 'Keyif için bir bölüm oku';

  @override
  String get suggestionReadChapterPleasureDesc =>
      'Amaç yok — sadece güzel bir kitap.';

  @override
  String get suggestionTryNewSimpleRecipeTitle =>
      'Yeni ve basit bir tarif dene';

  @override
  String get suggestionTryNewSimpleRecipeDesc =>
      'Daha önce hiç yapmadığınız bir şey pişirin.';

  @override
  String get suggestionJournalEveningTitle =>
      'Bugün hakkında bir günlük yazısı yaz';

  @override
  String get suggestionJournalEveningDesc =>
      'Bugünün nasıl geçtiğine dair birkaç dürüst satır.';

  @override
  String get suggestionLearnNewWordTitle => 'Yeni bir kelime öğren';

  @override
  String get suggestionLearnNewWordDesc =>
      'Küçük, istikrarlı kelime dağarcığı gelişimi.';

  @override
  String get suggestionWalk20Title => '20 dakika yürü';

  @override
  String get suggestionWalk20Desc =>
      'Herhangi bir tempo, herhangi bir yer — sadece hareket edin.';

  @override
  String get suggestionFullBodyWorkoutTitle => 'Tüm vücut antrenmanı tamamla';

  @override
  String get suggestionFullBodyWorkoutDesc =>
      'Elinizdeki ekipmanla gerçek bir seans.';

  @override
  String get suggestionPushups20Title => '20 şınav çek';

  @override
  String get suggestionPushups20Desc => 'Gerekirse gün boyuna yayabilirsiniz.';

  @override
  String get suggestionStretch10Title => '10 dakika esne';

  @override
  String get suggestionStretch10Desc => 'Özellikle oturduktan sonra gevşeyin.';

  @override
  String get suggestionDrinkWater8Title => '8 bardak su iç';

  @override
  String get suggestionDrinkWater8Desc => 'Gün boyunca düzenli sıvı alımı.';

  @override
  String get suggestionHighProteinMealTitle =>
      'Yüksek proteinli bir öğün hazırla';

  @override
  String get suggestionHighProteinMealDesc =>
      'Antrenmanınızı doğru şekilde besleyin.';

  @override
  String get suggestionMobility5Title => '5 dakikalık bir mobilite rutini yap';

  @override
  String get suggestionMobility5Desc =>
      'Kalçalar, omuzlar, ayak bilekleri — en çok ihtiyaç duyan eklemler.';

  @override
  String get suggestionTakeTheStairsTitle => 'Bugün merdivenleri kullan';

  @override
  String get suggestionTakeTheStairsDesc =>
      'Küçük ama tekrarlanabilir bir seçim, zamanla birikir.';

  @override
  String get suggestionExtraVegetableServingTitle =>
      'Bir porsiyon fazladan sebze ye';

  @override
  String get suggestionExtraVegetableServingDesc =>
      'Kısıtlamayın, ekleyin — bugün sadece bir porsiyon daha.';

  @override
  String get suggestionCookAtHomeTitle => 'Sipariş yerine evde yemek pişir';

  @override
  String get suggestionCookAtHomeDesc =>
      'İçindekileri kontrol edin, üstelik para da biriktirin.';

  @override
  String get suggestionAvoidAddedSugarTitle => 'Bugün ilave şekerden kaçının';

  @override
  String get suggestionAvoidAddedSugarDesc =>
      'Tam bir gün, hiç ilave şeker yok.';

  @override
  String get suggestionMealPrepTomorrowTitle =>
      'Yarın için yemek hazırlığı yap';

  @override
  String get suggestionMealPrepTomorrowDesc =>
      'Yarının öğünlerini bu akşamdan hazırlayın.';

  @override
  String get suggestionTrackTodaysMealsTitle => 'Bugünkü öğünlerinizi kaydedin';

  @override
  String get suggestionTrackTodaysMealsDesc =>
      'Ne yediğinizi fark etmek bile yeme şeklinizi değiştirir.';

  @override
  String get suggestionConsistentWakeupTitle =>
      'Sabit bir uyanma saati belirle';

  @override
  String get suggestionConsistentWakeupDesc =>
      'Hafta sonları dahil her gün aynı saat.';

  @override
  String get suggestionNoScreensBeforeBedTitle =>
      'Yatmadan 30 dakika önce ekran kullanma';

  @override
  String get suggestionNoScreensBeforeBedDesc =>
      'Aydınlatmalı bir ekran olmadan sakinleşin.';

  @override
  String get suggestionSleepBeforeTimeTitle =>
      'Belirlediğiniz bir saatten önce uyu';

  @override
  String get suggestionSleepBeforeTimeDesc =>
      'Bir yatma saati seçin ve gerçekten ona uyun.';

  @override
  String get suggestionNap20Title => '20 dakikalık bir şekerleme yap';

  @override
  String get suggestionNap20Desc =>
      'Sizi dinç tutacak kadar kısa, sersemletmeyecek kadar.';

  @override
  String get suggestionWindDownWithBookTitle =>
      'Ekran yerine bir kitapla sakinleş';

  @override
  String get suggestionWindDownWithBookDesc =>
      'Kaydırmayı bırakın, birkaç sayfa okuyun.';

  @override
  String get suggestionReadOneArticleTitle => 'Yeni bir konuda bir makale oku';

  @override
  String get suggestionReadOneArticleDesc =>
      'Her zamanki akışınızın dışında bir şey.';

  @override
  String get suggestionFinishOneChapterTitle => 'Bir bölümü bitir';

  @override
  String get suggestionFinishOneChapterDesc =>
      'Kitabı bir seferde bir bölüm ilerletin.';

  @override
  String get suggestionReadBeforeBedTitle =>
      'Yatmadan önce kaydırmak yerine oku';

  @override
  String get suggestionReadBeforeBedDesc =>
      'Yatma vaktinde telefonu bir kitapla değiştirin.';

  @override
  String get suggestionAudiobookChapterTitle => 'Bir sesli kitap bölümü dinle';

  @override
  String get suggestionAudiobookChapterDesc =>
      'Kulaklarınızla da okumuş sayılırsınız.';

  @override
  String get suggestionMeditate10Title => '10 dakika meditasyon yap';

  @override
  String get suggestionMeditate10Desc =>
      'Oturun, nefes alın ve gürültünün dinmesine izin verin.';

  @override
  String get suggestionDeepBreathing5Title =>
      '5 dakika derin nefes egzersizi yap';

  @override
  String get suggestionDeepBreathing5Desc =>
      'Yavaş, bilinçli nefesler — başka bir şey değil.';

  @override
  String get suggestionBodyScanTitle => 'Kısa bir vücut taraması yap';

  @override
  String get suggestionBodyScanDesc =>
      'Baştan ayağa gerginliği fark edin ve bırakın.';

  @override
  String get suggestionSitInSilence5Title => '5 dakika sessizce otur';

  @override
  String get suggestionSitInSilence5Desc =>
      'Telefon yok, müzik yok — sadece sessizlik.';

  @override
  String get suggestionGratitudeThreeTitle =>
      'Minnettarlık pratiği yap — 3 şey yaz';

  @override
  String get suggestionGratitudeThreeDesc =>
      'Ne kadar küçük olursa olsun, üç somut şey.';

  @override
  String get suggestionMindfulWalkNoPhoneTitle =>
      'Telefonsuz bilinçli bir yürüyüş yap';

  @override
  String get suggestionMindfulWalkNoPhoneDesc =>
      'Sadece siz, hareket halinde, dikkatinizi vererek.';

  @override
  String get suggestionLogTodaysSpendingTitle =>
      'Bugünkü harcamalarınızı kaydedin';

  @override
  String get suggestionLogTodaysSpendingDesc =>
      'Paranızın nereye gittiğine dair hızlı, dürüst bir kayıt.';

  @override
  String get suggestionReviewSubscriptionTitle =>
      'Bir aboneliği iptal için gözden geçir';

  @override
  String get suggestionReviewSubscriptionDesc => 'Ödediğinize hâlâ değiyor mu?';

  @override
  String get suggestionMoveToSavingsTitle =>
      'Sabit bir miktarı birikime aktarın';

  @override
  String get suggestionMoveToSavingsDesc =>
      'Küçük bir miktar bile olsa, düzenli olarak aktarılsın.';

  @override
  String get suggestionCheckWeeklyBudgetTitle =>
      'Haftalık bütçenizi kontrol edin';

  @override
  String get suggestionCheckWeeklyBudgetDesc =>
      'Harcamalar elinizden kaçmadan kısa bir bakış.';

  @override
  String get suggestionReadFinanceArticleTitle =>
      'Kişisel finans hakkında bir makale oku';

  @override
  String get suggestionReadFinanceArticleDesc =>
      'Bilginizi azar azar geliştirin.';

  @override
  String get suggestionThoughtfulMessageTitle =>
      'Bir arkadaşınıza içten bir mesaj gönderin';

  @override
  String get suggestionThoughtfulMessageDesc =>
      'Sıradan bir kontrol değil — gerçek bir şey.';

  @override
  String get suggestionPhoneFreeMealTitle =>
      'Biriyle telefonsuz bir öğün yiyin';

  @override
  String get suggestionPhoneFreeMealDesc => 'Tam dikkat, tek bir öğün.';

  @override
  String get suggestionNoteOfAppreciationTitle => 'Bir takdir notu yazın';

  @override
  String get suggestionNoteOfAppreciationDesc =>
      'Birine onda özellikle neyi takdir ettiğinizi söyleyin.';

  @override
  String get suggestionPlanGetTogetherTitle => 'Bir buluşma planlayın';

  @override
  String get suggestionPlanGetTogetherDesc => 'Takvime gerçek bir şey koyun.';

  @override
  String get suggestionAskAboutTheirDayTitle =>
      'Sevdiğinize gününü sorun — ve gerçekten dinleyin';

  @override
  String get suggestionAskAboutTheirDayDesc =>
      'Birkaç dakikalığına birine tüm dikkatinizi verin.';

  @override
  String get suggestionClearInboxZeroTitle => 'Gelen kutunuzu sıfırlayın';

  @override
  String get suggestionClearInboxZeroDesc =>
      'Arşivleyin, yanıtlayın veya silin — boşalana kadar.';

  @override
  String get suggestionPlanTomorrowMorningTitle => 'Yarın sabahı planla';

  @override
  String get suggestionPlanTomorrowMorningDesc =>
      'Gün başlamadan ilk görevinize karar verin.';

  @override
  String get suggestionOrganizeDesktopFilesTitle =>
      'Masaüstü dosyalarınızı düzenleyin';

  @override
  String get suggestionOrganizeDesktopFilesDesc =>
      'On beş dakikalık dijital düzenleme.';

  @override
  String get suggestionSketch10Title => '10 dakika eskiz çiz';

  @override
  String get suggestionSketch10Desc =>
      'İyi olma baskısı yok — sadece çizgiler atın.';

  @override
  String get suggestionWrite200WordsTitle =>
      'Herhangi bir şey hakkında 200 kelime yaz';

  @override
  String get suggestionWrite200WordsDesc =>
      'Kurgu, günlük, bir fikir — sadece yazın.';

  @override
  String get suggestionLearn3ChordsTitle => 'Bir enstrümanda 3 akor öğren';

  @override
  String get suggestionLearn3ChordsDesc => 'Elinize alın ve biraz ses çıkarın.';

  @override
  String get suggestionCreativePhotoTitle => 'Yaratıcı bir fotoğraf çek';

  @override
  String get suggestionCreativePhotoDesc => 'Sıradan bir şeye farklı bakın.';

  @override
  String get suggestionBrainstorm10IdeasTitle => 'Bir proje için 10 fikir üret';

  @override
  String get suggestionBrainstorm10IdeasDesc =>
      'Önce miktar — iyi olanlar zamanla ortaya çıkar.';

  @override
  String get suggestionPhoneFree20Title => 'Telefonsuz 20 dakika geçirin';

  @override
  String get suggestionPhoneFree20Desc =>
      'Hiçbir şeyi kontrol etmeden, sadece orada olun.';

  @override
  String get suggestionRelaxingBathTitle =>
      'Rahatlatıcı bir banyo veya duş alın';

  @override
  String get suggestionRelaxingBathDesc =>
      'Aceleye gerek yok, sadece kendiniz için.';

  @override
  String get suggestionFreshAirBreakTitle =>
      'Temiz hava almak için dışarı çıkın';

  @override
  String get suggestionFreshAirBreakDesc =>
      'Belirli bir varış noktası olmadan, dışarıda birkaç dakika.';

  @override
  String get suggestionSayNoOnceTitle => 'Sizi yoran bir şeye hayır deyin';

  @override
  String get suggestionSayNoOnceDesc => 'Zamanınızı bilerek koruyun.';

  @override
  String get suggestionSmallKindTreatTitle =>
      'Kendinize küçük ve nazik bir ödül verin';

  @override
  String get suggestionSmallKindTreatDesc =>
      'Kendiniz için gerçek, bilinçli bir özen eylemi.';

  @override
  String get suggestionTidyOneAreaTitle => 'Küçük bir alanı toparlayın';

  @override
  String get suggestionTidyOneAreaDesc =>
      'Bir raf, bir köşe — sınırlı ve yapılabilir.';
}

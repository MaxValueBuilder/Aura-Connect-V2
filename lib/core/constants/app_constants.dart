/// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Aura Connect';
  static const String appVersion = '1.0.0';

  // API Configuration (base URL is read from .env BACKEND_URL for security)
  static const Duration apiTimeout = Duration(seconds: 40);
  static const Duration cacheTimeout = Duration(minutes: 3);

  // Google AI Configuration
  static const String geminiApiKey = 'your-gemini-api-key';
  static const String googleSpeechApiKey = 'your-google-speech-api-key';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String consultationCheckpointKey = 'consultation_checkpoint_';

  // Audio Recording
  static const int audioSampleRate = 44100;
  static const String audioFileExtension = '.m4a';
  static const Duration maxRecordingDuration = Duration(hours: 2);

  // Pagination
  static const int defaultPageSize = 50;
  static const int patientsPageSize = 50;

  // UI
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;

  // Landing feature cards (iconName maps to Icons.* in UI)
  static const List<FeatureCardItem> featureCards = [
    FeatureCardItem(
      iconName: 'mic',
      title: 'Real-Time Co-Pilot',
      description:
          'AI listens to your consultations and captures key information automatically.',
      colorValue: 0xFF3B82F6, // primaryLight
      tag: 'AI-POWERED',
    ),
    FeatureCardItem(
      iconName: 'description',
      title: 'Instant SOAP Notes',
      description:
          'Generate complete, professional SOAP notes in seconds after each consultation.',
      colorValue: 0xFF10B981, // success
      tag: 'AUTOMATION',
    ),
    FeatureCardItem(
      iconName: 'group',
      title: 'Client Handouts',
      description:
          'Automatically create clear, personalized handouts for pet owners.',
      colorValue: 0xFF3B82F6, // info
      tag: 'SMART',
    ),
    FeatureCardItem(
      iconName: 'access_time',
      title: 'Save 2+ Hours Daily',
      description:
          'Reduce documentation time and get home to your family faster.',
      colorValue: 0xFF1E40AF, // primaryDark
      tag: 'SECURE',
    ),
    FeatureCardItem(
      iconName: 'check_circle_outlined',
      title: 'SOAP Compliant',
      description: 'All notes structured according to standards.',
      colorValue: 0xFFF59E0B, // warning
      tag: 'EFFICIENT',
    ),
    FeatureCardItem(
      iconName: 'security',
      title: 'HIPAA Compliant',
      description: 'Your data is secure and complies with all regulations.',
      colorValue: 0xFF94A3B8, // secondaryLight
      tag: 'COMPLIANT',
    ),
  ];

  static const String howItWorksSectionSubtitle =
      'Get started in minutes with our simple three-step process.';
  static const List<HowItWorksStepItem> howItWorksSteps = [
    HowItWorksStepItem(
      number: '01',
      title: 'Create Your Account',
      description:
          'Simple first-time setup, fully HIPAA compliant, ready in minutes.',
    ),
    HowItWorksStepItem(
      number: '02',
      title: 'Start Your First Consultation',
      description:
          'Begin your appointment as usual. Aura captures details in real-time.',
    ),
    HowItWorksStepItem(
      number: '03',
      title: 'Review & Approve',
      description:
          'Get instant SOAP notes, client handouts, and more—all ready to use.',
    ),
  ];

  // Landing testimonials (rating, quote, author name, title; optional image path)
  static const List<TestimonialItem> testimonials = [
    TestimonialItem(
      rating: 5,
      quote:
          'Aura Connect has completely transformed my practice. I\'m finishing my notes faster than I thought possible, and I actually enjoy using it!',
      authorName: 'Dr. Sarah Chen',
      authorTitle: 'Small Animal Veterinarian',
      imagePath: 'assets/images/Veterian1.png',
    ),
    TestimonialItem(
      rating: 5,
      quote:
          'We bought this for my entire team (5 DVMs). Now we all love it. Easy to use. No one ever asks me "How do I do X" after onboarding.',
      authorName: 'Dr. Michael Chen',
      authorTitle: 'Emergency Veterinarian',
      imagePath: 'assets/images/Veterian2.png',
    ),
    TestimonialItem(
      rating: 5,
      quote:
          'Finally—a vet SOAP tool that actually understands the workflow. My notes are clearer, faster, and my clients love the handouts!',
      authorName: 'Dr. Emily Rodriguez',
      authorTitle: 'Mixed Animal Practice',
      imagePath: 'assets/images/Veterian3.png',
    ),
  ];

  // Landing stat overview cards (icon + value + label)
  static const List<StatOverviewItem> statOverviewCards = [
    StatOverviewItem(
      iconName: 'trending_up',
      value: '5,000+',
      label: 'Active Clinics',
    ),
    StatOverviewItem(
      iconName: 'description',
      value: '50k+',
      label: 'Notes Generated',
    ),
    StatOverviewItem(
      iconName: 'psychology',
      value: '98%',
      label: 'Accuracy Rate',
    ),
    StatOverviewItem(
      iconName: 'gps_fixed',
      value: '2hrs',
      label: 'Saved Daily',
    ),
  ];

  // Landing pricing plan feature list (checkmarks under "Perfect for veterinary practices")
  static const List<String> pricingPlanFeatures = [
    'Unlimited consultations',
    'Real-time AI transcription',
    'SOAP note generation',
    'Client handout creation',
    'Task management',
    'HIPAA compliance',
    '24/7 support',
  ];

  // Medical flags for patient Medical Information card
  static const List<String> medicalFlagOptions = [
    'Allergies',
    'Special Diet',
    'Senior Care',
    'Indoor Only',
    'Aggressive',
    'Anxious',
    'Exotic',
    'Microchipped',
    'Spayed/Neutered',
  ];
}

/// Data for a single "How it works" step (number, title, description).
class HowItWorksStepItem {
  final String number;
  final String title;
  final String description;

  const HowItWorksStepItem({
    required this.number,
    required this.title,
    required this.description,
  });
}

/// Data for a single landing feature card.
class FeatureCardItem {
  final String iconName;
  final String title;
  final String description;
  final int colorValue;
  final String tag;

  const FeatureCardItem({
    required this.iconName,
    required this.title,
    required this.description,
    required this.colorValue,
    required this.tag,
  });
}

/// Data for a single testimonial card (rating, quote, author, optional image).
class TestimonialItem {
  final int rating;
  final String quote;
  final String authorName;
  final String authorTitle;
  final String? imagePath;

  const TestimonialItem({
    required this.rating,
    required this.quote,
    required this.authorName,
    required this.authorTitle,
    this.imagePath,
  });
}

/// Data for a single landing stat overview card (value + label + icon).
class StatOverviewItem {
  final String iconName;
  final String value;
  final String label;

  const StatOverviewItem({
    required this.iconName,
    required this.value,
    required this.label,
  });
}

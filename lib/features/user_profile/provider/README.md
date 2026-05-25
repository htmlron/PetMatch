# User Profile Provider - Quick Reference Guide

## 📁 Files Created

1. **`user_profile_state.dart`** - State class with all profile fields
2. **`user_profile_provider.dart`** - Riverpod provider with methods
3. **`USAGE_EXAMPLES.dart`** - Complete usage examples

---

## 🚀 Quick Start

### Import the Provider

```dart
import 'package:petmatch/features/user_profile/provider/user_profile_provider.dart';
```

---

## ✅ Available Methods

### 1. **setPetPreference(BuildContext context, String preference)**

Save selected pet: 'Cat', 'Dog', or 'No Preference'

```dart
ref.read(userProfileProvider.notifier).setPetPreference(context, 'Dog');
```

### 2. **Lifestyle Preferences (string options)**

These replace the old numeric 0–5 ratings:

```dart
ref.read(userProfileProvider.notifier).setLivingEnvironment(context, 'Apartment');
ref.read(userProfileProvider.notifier).setDailyAvailability(context, 'Mostly Home');
ref.read(userProfileProvider.notifier).setPetOwnershipExperience(context, 'First-time Owner');
ref.read(userProfileProvider.notifier).setLifestylePace(context, 'Balanced');
ref.read(userProfileProvider.notifier).setBudgetForPetCare(context, 'Moderate');
```

### 5. **submitProfile()**

Submit all data to backend (returns Future<bool>)

```dart
final success = await ref.read(userProfileProvider.notifier).submitProfile();
if (success) {
  // Navigate to home
}
```

### 6. **clearProfile()**

Reset all profile data

```dart
ref.read(userProfileProvider.notifier).clearProfile();
```

---

## 📊 Reading State

### Watch State (rebuilds on change)

```dart
final profile = ref.watch(userProfileProvider);
print(profile.petPreference); // 'Dog'
print(profile.livingEnvironment); // 'Apartment'
print(profile.completionPercentage); // 75%
```

### Read State Once (no rebuild)

```dart
final profile = ref.read(userProfileProvider);
```

---

## 🎯 Common Use Cases

### In Continue Button

```dart
GestureDetector(
  onTap: () {
    // Save data
    ref.read(userProfileProvider.notifier).setPetPreference('Dog');

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved: Dog')),
    );

    // Navigate to next screen
    context.push('/activity-level');
  },
  child: Container(
    child: Text('Continue'),
  ),
)
```

### Display Progress

```dart
final profile = ref.watch(userProfileProvider);

LinearProgressIndicator(
  value: profile.completionPercentage / 100,
)
```

### Validation

```dart
final profile = ref.watch(userProfileProvider);

if (profile.isValid) {
  // All required fields filled
  // Show submit button
} else {
  // Show incomplete message
}
```

---

## 🐛 Debugging

All methods log to console:

```
📝 Pet preference saved: Dog
Current completion: 25%
Profile state: {pet_preference: Dog, ...}
──────────────────────────────────────────────────────
```

Get full summary:

```dart
final summary = ref.read(userProfileProvider.notifier).getProfileSummary();
print(summary);
```

---

## 🔄 Integration with Supabase

Update `submitProfile()` method in `user_profile_provider.dart`:

```dart
Future<bool> submitProfile() async {
  try {
    state = state.copyWith(isSubmitting: true);

    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    await supabase.from('user_profiles').upsert({
      'user_id': userId,
      ...state.toJson(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    state = state.copyWith(isSubmitting: false, isComplete: true);
    return true;
  } catch (e) {
    state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
    return false;
  }
}
```

---

## 📱 State Fields

### Required Fields

- `petPreference` - String? ('Cat', 'Dog', 'No Preference')
- `livingEnvironment` - String? (e.g. 'Apartment', 'TownHouse')
- `dailyAvailability` - String? (e.g. 'Mostly Home', 'Out During Day')
- `petOwnershipExperience` - String? (e.g. 'First-time Owner', 'Experienced')
- `lifestylePace` - String? (e.g. 'Relaxed', 'Balanced', 'Active')
- `budgetForPetCare` - String? (e.g. 'Low', 'Moderate', 'High')

### Optional Fields

- `livingSpace` - String?
- `experience` - String?
- `preferredBreeds` - List<String>?
- `agePreference` - String?
- `sizePreference` - String?

### Metadata

- `isComplete` - bool
- `isSubmitting` - bool
- `errorMessage` - String?

---

## 💡 Tips

1. **Always use `ref.read()` when calling methods** (in callbacks)
2. **Use `ref.watch()` when displaying data** (rebuilds UI)
3. **Check `isValid` before submitting**
4. **Use `completionPercentage` for progress bars**
5. **Console logs help with debugging**

---

## 🎉 Done!

Your User Profile Provider is ready to use across all onboarding screens!

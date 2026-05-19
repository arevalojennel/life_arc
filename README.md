# LifeArc 🎮

LifeArc is a Flutter-based life simulation game inspired by BitLife, where players make life choices, experience random events, and shape their character’s future over time.

The game uses Google's Gemini AI model (`gemini-2.5-flash`) to dynamically generate intelligent life events, outcomes, and scenarios.

## ✨ Features

- AI-generated life events using Gemini 2.5 Flash
- Choice-based outcomes
- Character stats progression
- Net worth tracking
- Life timeline/history
- Animated stat graphs
- Passive random events
- Modern mobile UI inspired by BitLife

---

# 🤖 AI-Powered Gameplay

LifeArc integrates:

- `gemini-2.5-flash`

for generating:
- dynamic life events
- realistic choices
- random scenarios
- passive world events
- personalized outcomes

This allows gameplay to feel:
- unique
- unpredictable
- replayable
- human-like

---

# 👤 Character System

Players start by creating a character with:
- Name
- Personality trait

![Character Creation](assets/gif/Character_Creation.gif)

Each character has:
- Age
- Health
- Happiness
- Wealth
- Relationships
- Money / Net Worth

---

# 📈 Dynamic Stats

Stats Included:
- ❤️ Health
- 😊 Happiness
- 💰 Wealth
- 👥 Relationships

Features:
- Real-time updates
- Historical tracking
- Animated line graphs
- Values clamped from 0–100

---

# 💵 Net Worth System

Features:
- Animated money transitions
- Green when increasing
- Red when decreasing
- Supports negative balances
- Directional trend icons

Example:

```dart
NetWorthContainer(value: ch.money)
```

---

# 🌎 Passive Events

Examples:
- sickness
- inheritance
- meeting someone
- lottery win
- accidents

Passive events automatically:
- apply stat changes
- update history
- continue gameplay

---

# 📜 Life Timeline

Example:

```text
Age 18: Graduated High School — Studied hard
Age 22: Got First Job — Accepted the offer
```

---

# 📊 Animated Stat Graphs

Tracked histories:

```dart
healthHistory
happinessHistory
wealthHistory
relationshipHistory
```

Graph Features:
- auto scaling
- smooth curves
- border-safe rendering
- responsive width

---

# 🏗 Project Structure

```text
lib/
│
├── models/
├── screens/
├── services/
├── widgets/
└── main.dart
```

---

# ⚙️ State Management

Uses:
- Provider
- ChangeNotifier

Main controller:

```dart
GameState extends ChangeNotifier
```

---

# 🚀 Getting Started

Install dependencies:

```bash
flutter pub get
```

Run app:

```bash
flutter run
```

---

# 📦 Dependencies

```yaml
provider:
google_fonts:
http:
```

---

# 🎨 UI Style

Inspired by:
- BitLife
- modern mobile UI
- gradients
- rounded cards
- animated transitions

---

# 🔮 Planned Features

- careers
- education
- marriage
- properties
- vehicles
- achievements
- save/load system

---

# 🛠 Built With

- Flutter
- Dart
- Provider
- Gemini 2.5 Flash API

---

# 👨‍💻 Developer

Created by Jennel Arevalo.

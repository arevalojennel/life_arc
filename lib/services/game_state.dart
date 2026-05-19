import 'package:flutter/foundation.dart';
import '../models/character.dart';
import '../services/ai_service.dart';

enum GamePhase { idle, event, choosing, outcome, dead }

class GameState extends ChangeNotifier {
  Character? character;
  LifeEvent? currentEvent;
  Choice? lastChoice;
  GamePhase phase = GamePhase.event;
  bool isLoading = false;
  String? error;

  void startNewGame(String name, String trait) {
    character = Character(name: name, trait: trait);
    currentEvent = null;
    lastChoice = null;
    phase = GamePhase.idle;
    isLoading = false;
    error = null;
    AIService.resetFallbackEvents();
    character!.healthHistory.add(character!.health);
    character!.happinessHistory.add(character!.happiness);
    character!.wealthHistory.add(character!.wealth);
    character!.relationshipHistory.add(character!.relationships);
    notifyListeners();
  }

  // Called when user taps "Age Up" on the main screen
  void ageUp() {
    if (character == null) return;
    _loadNextEvent();
  }

  Future<void> _loadNextEvent() async {
    if (character == null) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      currentEvent = await AIService.generateLifeEvent(character!);

      if (currentEvent!.isPassiveEvent) {
        final event = currentEvent!;

        final syntheticChoice = Choice(
          text: event.title,
          outcome: event.description,
          deltas: event.passiveDeltas!,
        );

        // IMPORTANT: set lastChoice FIRST
        lastChoice = syntheticChoice;

        _applyChoice(syntheticChoice);

        phase = GamePhase.outcome;

        notifyListeners(); // 🔥 REQUIRED HERE
        return;
      }

      phase = GamePhase.event;
    } catch (e) {
      error = 'Failed to load event';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _applyChoice(Choice choice) {
    lastChoice = choice;

    final c = character!;
    final e = currentEvent;

    c.health += choice.deltas.health;
    c.happiness += choice.deltas.happiness;
    c.wealth += choice.deltas.wealth;
    c.relationships += choice.deltas.relationships;
    c.money += choice.deltas.moneyDelta;

    _addHistory(c);

    // if (c.money < 0) c.money = 0;
    c.clampStats();

    c.age += _ageIncrement();

    // FIX: prevent null crash / missing history
    if (e != null) {
      c.lifeEvents.add(
        'Age ${c.age}: ${e.title} — ${choice.text}',
      );
    }

    if (c.isDead) {
      c.isAlive = false;
      phase = GamePhase.dead;
    }
  }

  void makeChoice(Choice choice) {
    if (character == null || currentEvent == null) return;

    _applyChoice(choice);

    if (character!.isDead) {
      notifyListeners();
      return;
    }

    phase = GamePhase.outcome;
    notifyListeners();
  }

  void continueLife() {
    currentEvent = null;
    lastChoice = null;
    phase = GamePhase.idle;
    notifyListeners();
  }

  int _ageIncrement() {
    final c = character!;
    if (c.age < 5) return 2;
    if (c.age < 13) return 2;
    if (c.age < 18) return 1;
    if (c.age < 30) return 2;
    return 3;
  }

  String get lifeRating {
    if (character == null) return '';
    final avg = (character!.health +
            character!.happiness +
            character!.wealth +
            character!.relationships) /
        4;
    if (avg >= 80) return 'Extraordinary ✨';
    if (avg >= 65) return 'Wonderful 🌟';
    if (avg >= 50) return 'Good 😊';
    if (avg >= 35) return 'Turbulent 🌊';
    return 'Difficult 🌧️';
  }

  void _addHistory(Character c) {
    c.healthHistory.add(c.health);
    c.happinessHistory.add(c.happiness);
    c.wealthHistory.add(c.wealth);
    c.relationshipHistory.add(c.relationships);
  }
}

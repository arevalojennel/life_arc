class Character {
  String name;
  String trait;

  int age;
  int health;
  int happiness;
  int wealth;
  int relationships;
  int money;

  List<String> lifeEvents;

  bool isAlive;

  List<int> healthHistory = [];
  List<int> happinessHistory = [];
  List<int> wealthHistory = [];
  List<int> relationshipHistory = [];

  Character({
    required this.name,
    required this.trait,
    this.age = 0,
    this.health = 80,
    this.happiness = 70,
    this.wealth = 50,
    this.relationships = 60,
    this.money = 0,
    List<String>? lifeEvents,
    this.isAlive = true,
  })  : lifeEvents = lifeEvents ?? [],
        healthHistory = [],
        happinessHistory = [],
        wealthHistory = [],
        relationshipHistory = [];

  void clampStats() {
    health = health.clamp(0, 100);
    happiness = happiness.clamp(0, 100);
    wealth = wealth.clamp(0, 100);
    relationships = relationships.clamp(0, 100);
  }

  bool get isDead => !isAlive || health <= 0 || age >= 90;

  String get lifeStage {
    if (age <= 2) return 'Infant';
    if (age <= 5) return 'Toddler';
    if (age <= 12) return 'Childhood';
    if (age <= 17) return 'Teenage Years';
    if (age <= 25) return 'Young Adult';
    if (age <= 39) return 'Adult';
    if (age <= 59) return 'Middle Age';
    return 'Senior Years';
  }

  void applyDeltas(StatDeltas deltas) {
    health += deltas.health;
    happiness += deltas.happiness;
    wealth += deltas.wealth;
    relationships += deltas.relationships;
    money += deltas.moneyDelta;

    clampStats();

    if (health <= 0) {
      health = 0;
      isAlive = false;
    }
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'trait': trait,
        'age': age,
        'health': health,
        'happiness': happiness,
        'wealth': wealth,
        'relationships': relationships,
        'money': money,
        'lifeEvents': lifeEvents,
        'isAlive': isAlive,
      };

  factory Character.fromJson(Map<String, dynamic> json) => Character(
        name: json['name'],
        trait: json['trait'],
        age: json['age'],
        health: json['health'],
        happiness: json['happiness'],
        wealth: json['wealth'],
        relationships: json['relationships'],
        money: json['money'] ?? 0,
        lifeEvents: List<String>.from(json['lifeEvents'] ?? []),
        isAlive: json['isAlive'] ?? true,
      )
        ..healthHistory = List<int>.from(json['healthHistory'] ?? [])
        ..happinessHistory = List<int>.from(json['happinessHistory'] ?? [])
        ..wealthHistory = List<int>.from(json['wealthHistory'] ?? [])
        ..relationshipHistory =
            List<int>.from(json['relationshipHistory'] ?? []);
}

enum EventType {
  choice,
  passive,
  death,
}

class LifeEvent {
  final EventType type;

  final String title;
  final String description;

  final List<Choice> choices;

  // Used only for passive/death events
  final StatDeltas? passiveDeltas;

  LifeEvent({
    required this.type,
    required this.title,
    required this.description,
    this.choices = const [],
    this.passiveDeltas,
  });

  bool get isChoiceEvent => type == EventType.choice;

  bool get isPassiveEvent => type == EventType.passive;

  bool get isDeathEvent => type == EventType.death;
}

class Choice {
  final String text;
  final StatDeltas deltas;
  final String outcome;

  Choice({
    required this.text,
    required this.deltas,
    required this.outcome,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      text: json['text'],
      outcome: json['outcome'],
      deltas: StatDeltas.fromJson(json),
    );
  }
}

class StatDeltas {
  final int health;
  final int happiness;
  final int wealth;
  final int relationships;
  final int moneyDelta;

  StatDeltas({
    this.health = 0,
    this.happiness = 0,
    this.wealth = 0,
    this.relationships = 0,
    this.moneyDelta = 0,
  });

  factory StatDeltas.fromJson(Map<String, dynamic> json) {
    return StatDeltas(
      health: (json['health'] ?? 0).toInt(),
      happiness: (json['happiness'] ?? 0).toInt(),
      wealth: (json['wealth'] ?? 0).toInt(),
      relationships: (json['relationships'] ?? 0).toInt(),
      moneyDelta: (json['money_delta'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'health': health,
        'happiness': happiness,
        'wealth': wealth,
        'relationships': relationships,
        'money_delta': moneyDelta,
      };
}

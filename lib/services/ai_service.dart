import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';

class AIService {
  static const String _apiKey = 'AIzaSyAE2jFYR5NfpuMiTXx1IaARMkj5l2xuZsc';
  static const String _model = 'gemini-2.5-flash';
  static String get _baseUrl =>
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey';
  static final Map<String, Set<String>> _usedFallbackEvents = {};

  static void resetFallbackEvents() {
    _usedFallbackEvents.clear();
  }

  static Future<LifeEvent> generateLifeEvent(Character character) async {
    final recentEvents = character.lifeEvents.length > 3
        ? character.lifeEvents.sublist(character.lifeEvents.length - 3)
        : character.lifeEvents;

    final ageContext = _ageContext(character.age);

    final prompt = '''
You are a life simulator game engine. Generate a realistic, age-appropriate life event for this character.

CHARACTER
- Name: ${character.name}
- Age: ${character.age}
- Life Stage: ${character.lifeStage}
- Personality: ${character.trait}
- Stats: Health=${character.health}/100, Happiness=${character.happiness}/100, Wealth=${character.wealth}/100, Relationships=${character.relationships}/100
- Current Money: \$${character.money}
- Recent history: ${recentEvents.isEmpty ? "Just starting life" : recentEvents.join("; ")}

AGE GUIDANCE (age ${character.age})
$ageContext

EVENT TYPES
There are TWO possible event types:

1. CHOICE EVENT
- Normal life situations where the player chooses between 2-3 actions.

2. PASSIVE EVENT
- Random unavoidable life events, accidents, tragedies, illnesses, lucky encounters, or unexpected situations.
- The player CANNOT choose anything.
- These events directly apply stat changes automatically.
- Examples:
  - Falling from a bike as a child
  - Car accident as an adult
  - Sudden illness
  - Losing a job unexpectedly
  - Winning a raffle
  - House flooding
  - Being hospitalized
  - Natural disasters
  - Unexpected inheritance
  - Accidental death (VERY rare)
- Passive events MUST still be age-appropriate and realistic.

IMPORTANT RANDOMIZATION
- Most events should still be CHOICE EVENTS.
- Around 15-20% of generated events should be PASSIVE EVENTS.
- Accidental death should be EXTREMELY RARE and mostly possible only for older characters or severe accidents.
- Severe events should not happen too frequently.

RULES
- The event MUST feel realistic for someone exactly ${character.age} years old.
- Do NOT generate events from the wrong life stage.
- Choices should reflect what a ${character.age}-old actually controls.
- Stat deltas between -25 and +25 normally.
- Extreme events may go beyond this slightly if justified.
- money_delta must be realistic for the age and life stage.
- Keep descriptions vivid but concise.
- Avoid repetitive events.

RETURN FORMAT

For CHOICE EVENTS:
{
  "type": "choice",
  "title": "Short event title",
  "description": "Event description",
  "choices": [
    {
      "text": "Choice text",
      "outcome": "Outcome text",
      "health": 5,
      "happiness": -10,
      "wealth": 15,
      "relationships": 0,
      "money_delta": 500
    }
  ]
}

For PASSIVE EVENTS:
{
  "type": "passive",
  "title": "Unexpected Car Crash",
  "description": "${character.name} was involved in a serious car accident during a rainy evening commute.",
  "effect": {
    "health": -25,
    "happiness": -15,
    "wealth": -10,
    "relationships": 5,
    "money_delta": -4000
  }
}

For accidental death:
{
  "type": "death",
  "title": "Fatal Accident",
  "description": "${character.name} suffered a fatal accident that abruptly ended their life.",
  "effect": {
    "health": -100,
    "happiness": 0,
    "wealth": 0,
    "relationships": 0,
    "money_delta": 0
  }
}

Return ONLY valid JSON.
''';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'maxOutputTokens': 2048,
            'temperature': 0.9,
            'thinkingConfig': {
              'thinkingBudget': 0,
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
            data['candidates'][0]['content']['parts'][0]['text'] as String;
        // Strip any markdown fences just in case
        final clean = text.replaceAll(RegExp(r'```json|```'), '').trim();
        final json = jsonDecode(clean);
        return _parseEvent(json);
      } else {
        // Fallback to hardcoded event on API error
        return _fallbackEvent(character);
      }
    } catch (e) {
      return _fallbackEvent(character);
    }
  }

  static String _ageContext(int age) {
    if (age <= 4) {
      return '''Life stage: Toddler / Early Childhood (ages 0-4)
- Events: learning to walk/talk, playing with toys, family outings, getting a pet, a new sibling, a scary dream, a scraped knee.
- Choices involve simple childhood instincts: hide, cry, ask a parent, share, explore.
- No school, no money, no adult concepts. Pure family and play world.''';
    } else if (age <= 12) {
      return '''Life stage: Childhood (ages 5-12)
- Events: school friendships, bullying, sports tryouts, a crush, a bad grade, a school play, a family trip, losing a pet, a birthday party falling apart.
- Choices are kid-level: tell a parent, stand up to someone, practice harder, make a new friend.
- No jobs, no romance beyond a simple crush, no financial decisions.''';
    } else if (age <= 17) {
      return '''Life stage: Teenage Years (ages 13-17)
- Events: first relationship, peer pressure, exam stress, part-time job offer, a fight with parents, discovering a passion, social media drama, sports championship, skipping class.
- Choices reflect teen independence: rebel, comply, seek advice, pursue a passion.
- Can include first jobs, school clubs, dating, identity questions. No adult finances or career decisions.''';
    } else if (age <= 25) {
      return '''Life stage: Young Adult (ages 18-25)
- Events: college/university decisions, first real job, moving out, a serious relationship, heartbreak, student debt, a gap year, a party gone wrong, finding a mentor, first apartment.
- Choices reflect new adult freedom with limited experience: take the risk, play it safe, ask for help, prioritize fun vs. future.
- Money matters but is tight. Career is just starting. Relationships are intense.''';
    } else if (age <= 39) {
      return '''Life stage: Adult (ages 26-39)
- Events: career promotion or setback, marriage proposal, pregnancy/parenthood, buying a home, starting a business, a friend group dissolving, a health wake-up call, traveling abroad, a creative project.
- Choices involve real trade-offs between ambition, relationships, money, and health.
- Established career, adult relationships, financial decisions have real weight.''';
    } else if (age <= 59) {
      return '''Life stage: Middle Age (ages 40-59)
- Events: mid-life career change, kids leaving home (empty nest), aging parents needing care, a health diagnosis, marriage trouble or renewal, a big financial decision, reconnecting with an old passion, a friend's death.
- Choices reflect experience and the weight of responsibility: stability vs. reinvention, self vs. family.
- Wealth and health become central themes. Legacy starts to matter.''';
    } else {
      return '''Life stage: Senior Years (ages 60+)
- Events: retirement, grandchildren, health decline, loss of a spouse or close friend, downsizing the home, a bucket list trip, reconciling with estranged family, a serious illness, rediscovering a hobby, writing memoirs.
- Choices reflect wisdom, mortality, and legacy: make peace, stay active, lean on family, pursue one last dream.
- No career ambitions. Focus on health, relationships, meaning, and end-of-life themes.''';
    }
  }

  static LifeEvent _parseEvent(Map<String, dynamic> json) {
    final typeString = json['type'] ?? 'choice';

    final EventType type;

    switch (typeString) {
      case 'passive':
        type = EventType.passive;
        break;

      case 'death':
        type = EventType.death;
        break;

      default:
        type = EventType.choice;
    }

    // PASSIVE / DEATH EVENTS
    if (type != EventType.choice) {
      return LifeEvent(
        type: type,
        title: json['title'],
        description: json['description'],
        passiveDeltas: StatDeltas.fromJson(json['effect'] ?? {}),
      );
    }

    // CHOICE EVENTS
    final choices = (json['choices'] as List<dynamic>)
        .map((c) => Choice.fromJson(c))
        .toList();

    return LifeEvent(
      type: EventType.choice,
      title: json['title'],
      description: json['description'],
      choices: choices,
    );
  }

  static LifeEvent _getUniqueFallbackEvent(String stage) {
    final events = _fallbackEvents(stage);

    // initialize set for this stage
    _usedFallbackEvents.putIfAbsent(stage, () => <String>{});

    final used = _usedFallbackEvents[stage]!;

    // filter unused events
    final available = events.where((e) => !used.contains(e.title)).toList();

    // if everything used, reset (or you can keep it strict)
    if (available.isEmpty) {
      used.clear();
      available.addAll(events);
    }

    available.shuffle();
    final selected = available.first;

    // mark as used
    used.add(selected.title);

    return selected;
  }

  static LifeEvent _fallbackEvent(Character character) {
    return _getUniqueFallbackEvent(character.lifeStage);
  }

  static List<LifeEvent> _fallbackEvents(String stage) {
    switch (stage) {
      // =====================================================
      // INFANT (0-2)
      // =====================================================

      case 'Infant':
        return [
          LifeEvent(
            type: EventType.choice,
            title: 'First Steps',
            description:
                'Your parents encourage you to take your very first steps.',
            choices: [
              Choice(
                text: 'Walk toward them',
                outcome: 'Everyone cheers proudly.',
                deltas: StatDeltas(
                  happiness: 8,
                  relationships: 6,
                  health: 2,
                ),
              ),
              Choice(
                text: 'Crawl instead',
                outcome: 'You play it safe for now.',
                deltas: StatDeltas(
                  health: 3,
                ),
              ),
            ],
          ),
          LifeEvent(
            type: EventType.choice,
            title: 'Favorite Cartoon',
            description: 'You become obsessed with a colorful cartoon show.',
            choices: [
              Choice(
                text: 'Watch all day',
                outcome: 'You laugh nonstop at the silly characters.',
                deltas: StatDeltas(
                  happiness: 10,
                  health: -2,
                ),
              ),
              Choice(
                text: 'Play with toys instead',
                outcome: 'You stay active and curious.',
                deltas: StatDeltas(
                  health: 5,
                  happiness: 4,
                ),
              ),
            ],
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'High Fever',
            description:
                'You develop a dangerous fever and spend days recovering.',
            passiveDeltas: StatDeltas(
              health: -15,
              happiness: -5,
            ),
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Grandparents Visit',
            description:
                'Your grandparents shower you with love and attention.',
            passiveDeltas: StatDeltas(
              happiness: 10,
              relationships: 8,
            ),
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Fell From Crib',
            description: 'You tumble out of your crib during the night.',
            passiveDeltas: StatDeltas(
              health: -8,
            ),
          ),
        ];

      // =====================================================
      // TODDLER (3-5)
      // =====================================================

      case 'Toddler':
        return [
          LifeEvent(
            type: EventType.choice,
            title: 'Playground Adventure',
            description: 'You climb the tallest slide at the playground.',
            choices: [
              Choice(
                text: 'Slide down fast',
                outcome: 'You scream with excitement.',
                deltas: StatDeltas(
                  happiness: 10,
                  health: 2,
                ),
              ),
              Choice(
                text: 'Climb down carefully',
                outcome: 'You avoid getting hurt.',
                deltas: StatDeltas(
                  health: 5,
                ),
              ),
            ],
          ),
          LifeEvent(
            type: EventType.choice,
            title: 'Birthday Tantrum',
            description: 'Another child grabs your birthday balloon.',
            choices: [
              Choice(
                text: 'Cry loudly',
                outcome: 'Your parents comfort you immediately.',
                deltas: StatDeltas(
                  happiness: 4,
                  relationships: -3,
                ),
              ),
              Choice(
                text: 'Share politely',
                outcome: 'Everyone praises your kindness.',
                deltas: StatDeltas(
                  happiness: 8,
                  relationships: 6,
                ),
              ),
            ],
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Scraped Knee',
            description: 'You trip while running around the house.',
            passiveDeltas: StatDeltas(
              health: -5,
            ),
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Family Vacation',
            description: 'Your family takes you on a beach vacation.',
            passiveDeltas: StatDeltas(
              happiness: 12,
              relationships: 8,
            ),
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Lost Favorite Toy',
            description: 'Your favorite stuffed toy disappears.',
            passiveDeltas: StatDeltas(
              happiness: -10,
            ),
          ),
        ];

      // =====================================================
      // CHILDHOOD (6-12)
      // =====================================================

      case 'Childhood':
        return [
          LifeEvent(
            type: EventType.choice,
            title: 'School Talent Show',
            description: 'Your teacher asks if you want to perform.',
            choices: [
              Choice(
                text: 'Perform confidently',
                outcome: 'The crowd applauds loudly.',
                deltas: StatDeltas(
                  happiness: 12,
                  relationships: 8,
                ),
              ),
              Choice(
                text: 'Stay backstage',
                outcome: 'You avoid embarrassment.',
                deltas: StatDeltas(
                  happiness: -2,
                ),
              ),
            ],
          ),
          LifeEvent(
            type: EventType.choice,
            title: 'School Bully',
            description: 'An older student keeps teasing you during recess.',
            choices: [
              Choice(
                text: 'Tell a teacher',
                outcome: 'The bullying eventually stops.',
                deltas: StatDeltas(
                  happiness: 5,
                  relationships: 4,
                ),
              ),
              Choice(
                text: 'Stand up yourself',
                outcome: 'You gain confidence but risk conflict.',
                deltas: StatDeltas(
                  happiness: 8,
                  health: -3,
                ),
              ),
            ],
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Bike Crash',
            description: 'You crash your bike while racing friends downhill.',
            passiveDeltas: StatDeltas(
              health: -10,
              happiness: -3,
            ),
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Won Art Contest',
            description: 'Your drawing wins first place at school.',
            passiveDeltas: StatDeltas(
              happiness: 15,
              wealth: 5,
            ),
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Pet Dies',
            description: 'Your beloved pet passes away peacefully.',
            passiveDeltas: StatDeltas(
              happiness: -15,
            ),
          ),
        ];

      // =====================================================
      // TEENAGE YEARS (13-17)
      // =====================================================

      case 'Teenage Years':
        return [
          LifeEvent(
            type: EventType.choice,
            title: 'First Crush',
            description: 'You develop feelings for someone in class.',
            choices: [
              Choice(
                text: 'Confess your feelings',
                outcome: 'Your heart races with excitement.',
                deltas: StatDeltas(
                  happiness: 15,
                  relationships: 10,
                ),
              ),
              Choice(
                text: 'Keep it secret',
                outcome: 'You quietly admire them from afar.',
                deltas: StatDeltas(
                  happiness: -2,
                ),
              ),
            ],
          ),
          LifeEvent(
            type: EventType.choice,
            title: 'Exam Stress',
            description: 'Final exams are approaching quickly.',
            choices: [
              Choice(
                text: 'Study intensely',
                outcome: 'Your grades improve significantly.',
                deltas: StatDeltas(
                  wealth: 10,
                  happiness: -5,
                  health: -2,
                ),
              ),
              Choice(
                text: 'Relax with friends',
                outcome: 'You enjoy life but risk poor grades.',
                deltas: StatDeltas(
                  happiness: 10,
                  relationships: 8,
                  wealth: -5,
                ),
              ),
            ],
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Sports Injury',
            description: 'You twist your ankle badly during a game.',
            passiveDeltas: StatDeltas(
              health: -15,
            ),
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Phone Stolen',
            description: 'Your phone disappears during a crowded event.',
            passiveDeltas: StatDeltas(
              happiness: -8,
              moneyDelta: -800,
            ),
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Scholarship Award',
            description: 'You receive an academic scholarship.',
            passiveDeltas: StatDeltas(
              wealth: 15,
              happiness: 10,
              moneyDelta: 5000,
            ),
          ),
        ];

      // =====================================================
      // YOUNG ADULT (18-25)
      // =====================================================

      case 'Young Adult':
        return [
          LifeEvent(
            type: EventType.choice,
            title: 'Job Interview',
            description: 'You land an important interview for your dream job.',
            choices: [
              Choice(
                text: 'Prepare extensively',
                outcome: 'Your confidence impresses the interviewer.',
                deltas: StatDeltas(
                  wealth: 12,
                  happiness: 6,
                  moneyDelta: 3000,
                ),
              ),
              Choice(
                text: 'Wing it casually',
                outcome: 'The interview feels inconsistent.',
                deltas: StatDeltas(
                  happiness: -3,
                ),
              ),
            ],
          ),
          LifeEvent(
            type: EventType.choice,
            title: 'Apartment Hunting',
            description: 'Rent prices suddenly rise across the city.',
            choices: [
              Choice(
                text: 'Move somewhere cheaper',
                outcome: 'You save money but lose comfort.',
                deltas: StatDeltas(
                  wealth: 10,
                  happiness: -4,
                  moneyDelta: 4000,
                ),
              ),
              Choice(
                text: 'Keep current apartment',
                outcome: 'Your finances become tighter.',
                deltas: StatDeltas(
                  happiness: 5,
                  wealth: -8,
                  moneyDelta: -3000,
                ),
              ),
            ],
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Minor Car Accident',
            description: 'Another driver crashes into your vehicle.',
            passiveDeltas: StatDeltas(
              health: -8,
              happiness: -5,
              moneyDelta: -2500,
            ),
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Unexpected Bonus',
            description: 'Your employer rewards your performance generously.',
            passiveDeltas: StatDeltas(
              wealth: 10,
              happiness: 10,
              moneyDelta: 5000,
            ),
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Food Poisoning',
            description: 'You become seriously ill after eating spoiled food.',
            passiveDeltas: StatDeltas(
              health: -12,
              happiness: -4,
            ),
          ),
        ];

      // =====================================================
      // ADULT (26-39)
      // =====================================================

      case 'Adult':
        return [
          LifeEvent(
            type: EventType.choice,
            title: 'Promotion Offer',
            description: 'Your boss offers you a demanding promotion.',
            choices: [
              Choice(
                text: 'Accept promotion',
                outcome: 'Your income increases dramatically.',
                deltas: StatDeltas(
                  wealth: 18,
                  health: -5,
                  moneyDelta: 12000,
                ),
              ),
              Choice(
                text: 'Maintain balance',
                outcome: 'You preserve your free time.',
                deltas: StatDeltas(
                  happiness: 10,
                  health: 5,
                ),
              ),
            ],
          ),
          LifeEvent(
            type: EventType.choice,
            title: 'Marriage Proposal',
            description: 'Your partner asks you to spend forever together.',
            choices: [
              Choice(
                text: 'Say yes',
                outcome: 'A new chapter begins.',
                deltas: StatDeltas(
                  happiness: 20,
                  relationships: 20,
                ),
              ),
              Choice(
                text: 'Wait longer',
                outcome: 'Things become slightly awkward.',
                deltas: StatDeltas(
                  relationships: -8,
                ),
              ),
            ],
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'House Flood',
            description: 'Heavy rain floods part of your home.',
            passiveDeltas: StatDeltas(
              happiness: -10,
              wealth: -12,
              moneyDelta: -15000,
            ),
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Work Burnout',
            description: 'Years of nonstop work begin affecting your health.',
            passiveDeltas: StatDeltas(
              health: -15,
              happiness: -10,
            ),
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Lottery Win',
            description: 'You win a surprisingly large lottery prize.',
            passiveDeltas: StatDeltas(
              wealth: 20,
              happiness: 15,
              moneyDelta: 100000,
            ),
          ),
        ];

      // =====================================================
      // MIDDLE AGE (40-59)
      // =====================================================

      case 'Middle Age':
        return [
          LifeEvent(
            type: EventType.choice,
            title: 'Career Change',
            description: 'You consider leaving your long-time career behind.',
            choices: [
              Choice(
                text: 'Start fresh',
                outcome: 'The new challenge excites you.',
                deltas: StatDeltas(
                  happiness: 15,
                  wealth: -5,
                ),
              ),
              Choice(
                text: 'Stay stable',
                outcome: 'You avoid uncertainty.',
                deltas: StatDeltas(
                  wealth: 8,
                ),
              ),
            ],
          ),
          LifeEvent(
            type: EventType.choice,
            title: 'Health Wake-Up Call',
            description: 'Doctors warn you about unhealthy habits.',
            choices: [
              Choice(
                text: 'Commit to exercise',
                outcome: 'Your energy improves noticeably.',
                deltas: StatDeltas(
                  health: 18,
                  happiness: 6,
                  moneyDelta: -2000,
                ),
              ),
              Choice(
                text: 'Ignore warning',
                outcome: 'Your condition slowly worsens.',
                deltas: StatDeltas(
                  health: -10,
                ),
              ),
            ],
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Unexpected Surgery',
            description: 'A medical emergency requires immediate surgery.',
            passiveDeltas: StatDeltas(
              health: -20,
              happiness: -8,
              moneyDelta: -20000,
            ),
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Child Moves Away',
            description: 'Your child relocates far from home.',
            passiveDeltas: StatDeltas(
              happiness: -5,
              relationships: -8,
            ),
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Paid Off Mortgage',
            description: 'You finally finish paying off your home.',
            passiveDeltas: StatDeltas(
              wealth: 15,
              happiness: 10,
              moneyDelta: 30000,
            ),
          ),
        ];

      // =====================================================
      // SENIOR YEARS (60+)
      // =====================================================

      default:
        return [
          LifeEvent(
            type: EventType.choice,
            title: 'Retirement Plans',
            description: 'You decide how to spend your retirement years.',
            choices: [
              Choice(
                text: 'Travel the world',
                outcome: 'You create unforgettable memories.',
                deltas: StatDeltas(
                  happiness: 18,
                  moneyDelta: -15000,
                ),
              ),
              Choice(
                text: 'Stay with family',
                outcome: 'You cherish meaningful moments.',
                deltas: StatDeltas(
                  relationships: 15,
                  happiness: 10,
                ),
              ),
            ],
          ),
          LifeEvent(
            type: EventType.choice,
            title: 'Write Memoirs',
            description: 'You consider documenting your life story.',
            choices: [
              Choice(
                text: 'Write the book',
                outcome: 'You reflect deeply on your life.',
                deltas: StatDeltas(
                  happiness: 10,
                  relationships: 5,
                ),
              ),
              Choice(
                text: 'Keep memories private',
                outcome: 'You enjoy peaceful solitude.',
                deltas: StatDeltas(
                  health: 3,
                ),
              ),
            ],
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Peaceful Passing',
            description:
                'Surrounded by loved ones, your life quietly comes to an end.',
            passiveDeltas: StatDeltas(
              health: -100,
            ),
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Hospital Stay',
            description: 'You spend several weeks recovering in the hospital.',
            passiveDeltas: StatDeltas(
              health: -18,
              happiness: -6,
              moneyDelta: -12000,
            ),
          ),
          LifeEvent(
            type: EventType.passive,
            title: 'Grandchild Born',
            description: 'A new grandchild brings joy to your family.',
            passiveDeltas: StatDeltas(
              happiness: 18,
              relationships: 12,
            ),
          ),
        ];
    }
  }
}

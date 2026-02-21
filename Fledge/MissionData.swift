//
//  MissionData.swift
//  Fledge
//
//  Created by Daniel Diaz de Leon on 20/02/26.
//

import Foundation

struct MissionData {
    
    static let all: [Mission] = [
        
        // MARK: - WEEK 1 · THE CITY
        
        Mission(
            title: "Learn one route really well",
            truth: "Monterrey will feel enormous and chaotic at first. That's normal.",
            move: "Don't try to understand the whole city in week one. Pick one route you'll do every day — home to campus, home to the nearest Oxxo. Walk it. Notice what's on it. A taquería, a farmacia, a park. That one route becomes your anchor.",
            win: "The city stops feeling like a maze and starts feeling like yours.",
            pillar: .city,
            weekNumber: 1,
            tags: ["city", "navigation"],
            duration: "30 min"
        ),
        
        Mission(
            title: "Find your nearest Oxxo",
            truth: "In Monterrey, the Oxxo is your lifeline. It's open 24/7 and sells almost everything you'll need in an emergency.",
            move: "Walk out your door and find the nearest one. Note the hours, what it sells, and whether it has an ATM. You'll thank yourself at 11pm when you run out of something.",
            win: "You have a base camp. Every city person has one.",
            pillar: .city,
            weekNumber: 1,
            tags: ["city", "navigation"],
            duration: "15 min"
        ),
        
        Mission(
            title: "Figure out the Ecovía or bus",
            truth: "Monterrey's public transport isn't perfect but it works if you know it.",
            move: "Download the Moovit app. Look up one route you'll actually use — to school, to a mall, to anywhere. Ride it once this week just to know you can. The first time is the hardest.",
            win: "You just became someone who can move around this city independently.",
            pillar: .city,
            weekNumber: 1,
            tags: ["city", "transport"],
            duration: "1 hour"
        ),
        
        Mission(
            title: "Locate your closest market",
            truth: "Supermarkets in Monterrey vary wildly in price. Where you shop matters.",
            move: "Find your nearest Soriana, Walmart, or Chedraui. These are your budget options. La Comer and HEB are better quality but pricier. For the cheapest produce, find your nearest tianguis or mercado — the quality is often better and the price is half.",
            win: "You know where your food comes from. That's more than most people figure out in month one.",
            pillar: .city,
            weekNumber: 1,
            tags: ["city", "budget", "cooking"],
            duration: "45 min"
        ),
        
        Mission(
            title: "Eat one real regio meal",
            truth: "Monterrey has one of the best food cultures in Mexico and most students never explore it.",
            move: "This week, eat one proper regiomontano meal. Cabrito if you eat meat, machacado con huevo for breakfast, or just a proper taco de carne asada from a street stand. Ask a local where they'd actually go — not Google.",
            win: "You stopped being a visitor and started being someone who lives here.",
            pillar: .city,
            weekNumber: 1,
            tags: ["city", "social", "food"],
            duration: "1 hour"
        ),
        
        // MARK: - WEEK 1 · ADULT MODE
        
        Mission(
            title: "Your first real grocery run",
            truth: "You'll either buy too much, too little, or completely the wrong things. Everyone does.",
            move: "Before you go, write a list. Stick to the basics: huevos, pasta, arroz, pan, plátanos, frijoles, and a bag of verduras congeladas. These get you through week one without stress. Budget: $300-400 pesos for the week.",
            win: "You walked out with food for the week and didn't blow your budget. That's the whole game.",
            pillar: .adultMode,
            weekNumber: 1,
            tags: ["cooking", "budget"],
            duration: "1 hour"
        ),
        
        Mission(
            title: "Cook one real meal",
            truth: "The first time you cook for yourself in a new kitchen feels surprisingly hard.",
            move: "Make huevos revueltos con frijoles. That's it. Eggs and beans. Heat oil, scramble eggs, heat canned beans on the side. Season with sal and chile. Eat it. It costs under $30 pesos and takes 10 minutes. Master this and you'll never go hungry.",
            win: "You fed yourself. From scratch. In your own kitchen. That's not small.",
            pillar: .adultMode,
            weekNumber: 1,
            tags: ["cooking", "fitness"],
            duration: "20 min"
        ),
        
        Mission(
            title: "Do your first load of laundry",
            truth: "Nobody tells you how to do laundry until you ruin something.",
            move: "Cold water, always — it protects your clothes and saves electricity. Separate darks from lights. Never overfill the machine. If you're using a lavandería, bring exact change and a bag. Most in Monterrey charge $25-35 pesos per kilo.",
            win: "Clean clothes, nothing ruined, money not wasted. You're officially adulting.",
            pillar: .adultMode,
            weekNumber: 1,
            tags: ["life-skills"],
            duration: "1.5 hours"
        ),
        
        Mission(
            title: "Know your weekly number",
            truth: "Most students run out of money before the month ends because they never did this one calculation.",
            move: "Take your monthly budget and divide by 4. That's your weekly limit. Write it on your phone lock screen. Before every purchase this week, ask: does this fit my number? That one habit will save you more than any app.",
            win: "You have a number. That number is power.",
            pillar: .adultMode,
            weekNumber: 1,
            tags: ["budget"],
            duration: "5 min"
        ),
        
        Mission(
            title: "Set up your space",
            truth: "Your space directly affects how you feel. A chaotic room creates a chaotic head.",
            move: "Spend 20 minutes making your space feel intentional. One thing on the wall, your desk clear, your bed made. You don't need to decorate — just signal to yourself that this is your place now and you're in control of it.",
            win: "You walk in and feel calm instead of anxious. That's worth everything.",
            pillar: .adultMode,
            weekNumber: 1,
            tags: ["life-skills"],
            duration: "20 min"
        ),
        
        // MARK: - WEEK 1 · YOUR GROWTH
        
        Mission(
            title: "Write down why you moved",
            truth: "In week one everything is hard and you might forget why you came.",
            move: "Open your notes app and write 3 sentences: why you moved here, what you want to build, and one thing you're excited about. Don't overthink it. This isn't for anyone else — it's an anchor for the hard days.",
            win: "You have something to come back to when the city feels too big.",
            pillar: .growth,
            weekNumber: 1,
            tags: ["growth", "mental-health"],
            duration: "10 min"
        ),
        
        Mission(
            title: "Call someone from home",
            truth: "Not because you're struggling — just because staying connected matters.",
            move: "Call or voice message one person from home this week. Not a text — actual voice. Tell them one specific thing you did or saw. Staying connected doesn't mean you're not independent. It means you're human.",
            win: "You feel less alone without needing the city to fix that yet.",
            pillar: .growth,
            weekNumber: 1,
            tags: ["social", "mental-health"],
            duration: "20 min"
        ),
        
        Mission(
            title: "Find one place that feels like yours",
            truth: "Home isn't an apartment — it's the places you return to.",
            move: "This week, find one place in the city that feels good to be in. A café, a park, a bench with a view of the Cerro de la Silla. Somewhere you'd go just to exist. Go there once, intentionally, alone.",
            win: "You have a place. That place is the beginning of this city becoming home.",
            pillar: .growth,
            weekNumber: 1,
            tags: ["city", "mental-health", "growth"],
            duration: "1 hour"
        ),
        
        // MARK: - WEEK 2 · THE CITY
        
        Mission(
            title: "Explore one new neighborhood",
            truth: "Monterrey's neighborhoods each have a completely different personality.",
            move: "Pick one you haven't been to: Barrio Antiguo for culture and nightlife, San Pedro Garza García for a completely different vibe, Contry for quiet streets and good taquerías. Walk around for an hour with no destination. Just look.",
            win: "The city gets bigger in a good way. You realize there's more here than you thought.",
            pillar: .city,
            weekNumber: 2,
            tags: ["city", "social"],
            duration: "2 hours"
        ),
        
        Mission(
            title: "Find a cheap lunch spot near campus",
            truth: "Eating out every day will destroy your budget. But cooking every lunch isn't realistic either.",
            move: "Find one reliable cheap lunch spot near where you study. In Monterrey, look for fondas — family-run lunch places that serve a comida corrida for $60-80 pesos. Soup, main, agua fresca included. These are the best value meals in the city.",
            win: "You have a lunch strategy. Your budget thanks you.",
            pillar: .city,
            weekNumber: 2,
            tags: ["city", "budget", "food"],
            duration: "45 min"
        ),
        
        Mission(
            title: "Download the apps you actually need",
            truth: "There are three apps that make living in Monterrey dramatically easier.",
            move: "Download these: DiDi (cheaper and safer than Uber here), Rappi (food and grocery delivery when you need it), and Tu Línea MTY (for bus routes). These three cover transport, food, and emergencies. Everything else is optional.",
            win: "You're equipped. The city has fewer surprises now.",
            pillar: .city,
            weekNumber: 2,
            tags: ["city", "transport"],
            duration: "10 min"
        ),
        
        // MARK: - WEEK 2 · ADULT MODE
        
        Mission(
            title: "Cook once, eat three times",
            truth: "Cooking every day is exhausting. The solution isn't eating out — it's cooking smarter.",
            move: "Pick one Sunday and make a big pot of something: arroz con verduras, sopa de fideo, or lentil soup. Cook enough for three meals. Store in containers. You've just solved lunch and dinner for half the week for under $100 pesos.",
            win: "You eat well, spend little, and only cooked once. That's the move.",
            pillar: .adultMode,
            weekNumber: 2,
            tags: ["cooking", "budget", "fitness"],
            duration: "1 hour"
        ),
        
        Mission(
            title: "The 24-hour rule",
            truth: "Most of the money students waste is on things they bought without thinking.",
            move: "Before any non-essential purchase, wait 24 hours. If you still want it tomorrow and it fits your weekly number, buy it. Most of the time you'll forget about it. This rule quietly eliminates most impulse spending without any willpower required.",
            win: "You spend on things that matter. Everything else stops mattering.",
            pillar: .adultMode,
            weekNumber: 2,
            tags: ["budget"],
            duration: "Ongoing"
        ),
        
        Mission(
            title: "Build your cleaning rhythm",
            truth: "A messy space isn't a personality — it's a habit you haven't built yet.",
            move: "Pick three things to do every day: wipe the kitchen counter after cooking, rinse dishes before they dry, take the trash out before it's full. Ten seconds each. These three habits are the difference between a space that feels calm and one that feels chaotic.",
            win: "Your space works for you. You stop losing time and energy to mess.",
            pillar: .adultMode,
            weekNumber: 2,
            tags: ["life-skills"],
            duration: "10 min/day"
        ),
        
        Mission(
            title: "Understand your bills",
            truth: "CFE, agua, internet — these will show up and you need to know what they mean.",
            move: "Find out which bills you're responsible for in your apartment. Ask your landlord if you haven't. Set a reminder the week before each one is due. In Monterrey, CFE bills come every two months and are higher in summer due to AC. Budget accordingly.",
            win: "No surprise bills. No late fees. No anxiety on the first of the month.",
            pillar: .adultMode,
            weekNumber: 2,
            tags: ["budget", "life-skills"],
            duration: "20 min"
        ),
        
        // MARK: - WEEK 2 · YOUR GROWTH
        
        Mission(
            title: "Say yes to one thing uncomfortable",
            truth: "The life you want in this city is on the other side of a few uncomfortable yeses.",
            move: "This week, say yes to one thing that feels slightly outside your comfort zone. A study group, a social event, a club, a talk on campus. It doesn't have to be big. It just has to be slightly uncomfortable. Go, stay for at least an hour, talk to one person.",
            win: "You proved to yourself that you can. That proof compounds.",
            pillar: .growth,
            weekNumber: 2,
            tags: ["social", "growth"],
            duration: "2 hours"
        ),
        
        Mission(
            title: "Find out what your city offers you",
            truth: "Monterrey has more professional and creative opportunities than most students realize.",
            move: "Spend 30 minutes researching what your city actually offers: startup ecosystem, cultural events, university clubs, internship programs. Search 'eventos Monterrey esta semana' and 'oportunidades profesionales Monterrey estudiantes.' Write down three things you want to explore this semester.",
            win: "You stop seeing Monterrey as a place you ended up and start seeing it as a place you chose.",
            pillar: .growth,
            weekNumber: 2,
            tags: ["growth", "city", "social"],
            duration: "30 min"
        ),
        
        // MARK: - WEEK 3 · THE CITY
        
        Mission(
            title: "Go somewhere just because it's beautiful",
            truth: "Monterrey has dramatic natural beauty that most students walk past every day.",
            move: "Go to Parque Fundidora on a weekday morning, hike to the base of Cerro de la Silla, or drive to Chipinque if you can. Not for a reason. Just to be somewhere beautiful in the city you live in. Take your time.",
            win: "Monterrey stops being a backdrop and becomes somewhere you genuinely love.",
            pillar: .city,
            weekNumber: 3,
            tags: ["city", "fitness", "growth"],
            duration: "Half day"
        ),
        
        Mission(
            title: "Find your Sunday morning place",
            truth: "Every person who feels at home in a city has a Sunday morning ritual.",
            move: "Try Mercado Juárez for breakfast and fresh produce, the cafés around Barrio Antiguo for a slow morning, or a walk through Parque Fundidora before the crowds arrive. Go alone, bring something to read, stay longer than you planned.",
            win: "You have a ritual. Rituals are how places become home.",
            pillar: .city,
            weekNumber: 3,
            tags: ["city", "growth", "mental-health"],
            duration: "2 hours"
        ),
        
        // MARK: - WEEK 3 · ADULT MODE
        
        Mission(
            title: "Eat well on almost nothing",
            truth: "Healthy eating on a student budget is possible — but only if you know what to buy.",
            move: "Build your meals around these: huevos, lentejas, garbanzos de lata, avena, and espinacas congeladas. These are the cheapest and most nutritious foods you can buy in any Soriana. A week of eating well costs $250-350 pesos if you shop around these.",
            win: "You feel better, spend less, and never feel like you're sacrificing.",
            pillar: .adultMode,
            weekNumber: 3,
            tags: ["cooking", "fitness", "budget"],
            duration: "1 hour shopping"
        ),
        
        Mission(
            title: "Build your first financial buffer",
            truth: "A buffer isn't savings — it's the money that means one bad week doesn't ruin your month.",
            move: "Set aside $200-300 pesos this week. Put it in a separate account or a physical envelope. Label it: emergencias. Don't touch it for anything that isn't a genuine emergency. That small cushion changes how you feel about money completely.",
            win: "You have a buffer. That buffer is freedom.",
            pillar: .adultMode,
            weekNumber: 3,
            tags: ["budget"],
            duration: "5 min"
        ),
        
        Mission(
            title: "Learn to fix one thing yourself",
            truth: "Calling someone to fix everything is expensive and slow.",
            move: "Learn to do one basic repair or task this week: unclog a drain, change a light bulb, tighten a loose screw, iron a shirt. YouTube has a tutorial for everything. Pick one thing that's slightly broken or undone in your space and fix it yourself.",
            win: "Your space is better and you know you can handle it.",
            pillar: .adultMode,
            weekNumber: 3,
            tags: ["life-skills"],
            duration: "30 min"
        ),
        
        // MARK: - WEEK 3 · YOUR GROWTH
        
        Mission(
            title: "Reach out to someone you admire",
            truth: "Monterrey's professional and creative community is more accessible than you think.",
            move: "Find one person doing something you want to do — a professor, a founder, a creative. Send them a genuine three-sentence message: who you are, what you admire about their work, one specific question. Don't ask for a job. Just start a conversation.",
            win: "You made a move. Most people never do. That alone sets you apart.",
            pillar: .growth,
            weekNumber: 3,
            tags: ["growth", "social"],
            duration: "20 min"
        ),
        
        // MARK: - WEEK 4 · THE CITY
        
        Mission(
            title: "Go somewhere only locals know",
            truth: "Every city has places that don't show up on Google Maps but define the real experience.",
            move: "Ask someone who grew up in Monterrey — a classmate, a neighbor, anyone regiomontano — for their honest recommendation. Not the tourist answer. Their personal answer. Where do they actually eat? Where do they go on weekends? Go there this week.",
            win: "You stop being someone who moved here and start being someone who lives here.",
            pillar: .city,
            weekNumber: 4,
            tags: ["city", "social"],
            duration: "2 hours"
        ),
        
        // MARK: - WEEK 4 · ADULT MODE
        
        Mission(
            title: "Find your two reliable meals",
            truth: "You don't need to know how to cook everything. You need two meals you can make without thinking.",
            move: "Identify two meals you've made this month that worked: tasted good, cost little, took under 20 minutes. Write them down. These are your fallback meals for the rest of the year. One for when you have energy, one for when you don't.",
            win: "You never stand in front of an open fridge not knowing what to do again.",
            pillar: .adultMode,
            weekNumber: 4,
            tags: ["cooking"],
            duration: "10 min"
        ),
        
        Mission(
            title: "Look at where your money went",
            truth: "Most people are surprised by what they actually spent. The surprise is the lesson.",
            move: "Spend 10 minutes looking back at this month's spending. Not to feel guilty — to get smarter. You'll spot one or two patterns that surprise you. Pick one small adjustment for next month. That's all. One adjustment, repeated, is how financial confidence builds.",
            win: "You know your patterns. Patterns you know are patterns you can change.",
            pillar: .adultMode,
            weekNumber: 4,
            tags: ["budget"],
            duration: "10 min"
        ),
        
        // MARK: - WEEK 4 · YOUR GROWTH
        
        Mission(
            title: "Write a letter to week-one you",
            truth: "You've done more than you realize. Most people never stop to see it.",
            move: "Open your notes app and write 5 sentences to yourself from four weeks ago. What do you know now that you didn't know then? What are you less afraid of? What surprised you? You don't need to share it. Just write it.",
            win: "You see your own growth. That's rarer and more powerful than any achievement.",
            pillar: .growth,
            weekNumber: 4,
            tags: ["growth", "mental-health"],
            duration: "15 min"
        ),
        
        Mission(
            title: "One month in. Look around.",
            truth: "A month ago you didn't know how to do half of what you now do without thinking.",
            move: "Today, don't complete a mission. Just walk somewhere in Monterrey you've been before and notice how different it feels from the first time. The same street, the same Oxxo, the same route — but you move through it differently now. Notice that.",
            win: "You didn't just survive your first month. You learned how to live in it. That's everything.",
            pillar: .growth,
            weekNumber: 4,
            tags: ["growth", "city", "mental-health"],
            duration: "30 min"
        ),
        
        // WEEK 4 — The City
        Mission(
            title: "Tell someone about this city",
            truth: "You know Monterrey differently now than you did four weeks ago. That knowledge is worth something.",
            move: "Next time someone asks you about Monterrey — a family member, a friend back home, anyone — don't say 'it's fine.' Tell them one specific thing you discovered. A place, a food, a feeling. You've earned the right to have an opinion about this city.",
            win: "You stopped being a visitor. You became someone who actually lives here.",
            pillar: .city,
            weekNumber: 4,
            tags: ["city", "growth", "social"],
            duration: "Whenever"
        ),

        // WEEK 4 — Adult Mode
        Mission(
            title: "Cook something you're proud of",
            truth: "You've been cooking to survive. This week, cook something just because you want to.",
            move: "Pick one recipe that feels slightly ambitious — not difficult, just a step above your usual. Look it up, buy the ingredients intentionally, and take your time making it. Eat it properly. At a table, not standing over the sink.",
            win: "You cooked something that felt like a choice, not a necessity. That's the whole shift.",
            pillar: .adultMode,
            weekNumber: 4,
            tags: ["cooking", "growth"],
            duration: "1 hour"
        ),

        // WEEK 4 — Your Growth
        Mission(
            title: "Set one intention for next month",
            truth: "Your first month was about surviving. Your second month can be about something more.",
            move: "Write one sentence: what do you want next month to be about? Not a goal list, not a resolution — one clear intention. More social. More disciplined. More exploratory. One word is enough. Put it somewhere you'll see it on the first of next month.",
            win: "You stopped reacting to your new life and started designing it. That's everything.",
            pillar: .growth,
            weekNumber: 4,
            tags: ["growth", "mental-health"],
            duration: "5 min"
        ),
    ]
    
    // Filter missions by week and optionally by relevant tags
    static func missions(forWeek week: Int, tags: [String] = []) -> [Mission] {
        let weekMissions = all.filter { $0.weekNumber == week }
        if tags.isEmpty { return weekMissions }
        
        // Sort by relevance — missions matching user tags appear first
        return weekMissions.sorted { a, b in
            let aMatches = a.tags.filter { tags.contains($0) }.count
            let bMatches = b.tags.filter { tags.contains($0) }.count
            return aMatches > bMatches
        }
    }
    
    // Filter by pillar
    static func missions(forWeek week: Int, pillar: Pillar, tags: [String] = []) -> [Mission] {
        missions(forWeek: week, tags: tags).filter { $0.pillar == pillar }
    }
}

import 'dart:convert';
import 'dart:io';

void main() async {
  print('Starting database generation...');

  // Create directory if not exists
  final dataDir = Directory('assets/data');
  if (!dataDir.existsSync()) {
    dataDir.createSync(recursive: true);
  }

  // 1. Generate Words (1000+ items across 20 categories)
  final categories = [
    'Animals', 'Birds', 'Fruits', 'Vegetables', 'Colors', 'Numbers',
    'Family', 'Body Parts', 'Nature', 'Food', 'Vehicles', 'Professions',
    'School', 'Tamil Culture', 'Festivals', 'Verbs', 'Adjectives',
    'Shapes', 'Clothing', 'Household Objects'
  ];

  final difficulties = ['Easy', 'Medium', 'Hard', 'Expert'];

  // Base list of real words for seed
  final Map<String, List<Map<String, String>>> seedWords = {
    'Animals': [
      {'tamil': 'நாய்', 'english': 'Dog', 'emoji': '🐕'},
      {'tamil': 'பூனை', 'english': 'Cat', 'emoji': '🐈'},
      {'tamil': 'யானை', 'english': 'Elephant', 'emoji': '🐘'},
      {'tamil': 'குதிரை', 'english': 'Horse', 'emoji': '🐎'},
      {'tamil': 'சிங்கம்', 'english': 'Lion', 'emoji': '🦁'},
      {'tamil': 'புலி', 'english': 'Tiger', 'emoji': '🐅'},
      {'tamil': 'கரடி', 'english': 'Bear', 'emoji': '🐻'},
      {'tamil': 'குரங்கு', 'english': 'Monkey', 'emoji': '🐒'},
      {'tamil': 'மான்', 'english': 'Deer', 'emoji': '🦌'},
      {'tamil': 'நரி', 'english': 'Fox', 'emoji': '🦊'},
      {'tamil': 'முயல்', 'english': 'Rabbit', 'emoji': '🐇'},
      {'tamil': 'ஆடு', 'english': 'Goat', 'emoji': '🐐'},
      {'tamil': 'மாடு', 'english': 'Cow', 'emoji': '🐄'},
      {'tamil': 'பன்றி', 'english': 'Pig', 'emoji': '🐖'},
      {'tamil': 'ஒட்டகம்', 'english': 'Camel', 'emoji': '🐫'},
      {'tamil': 'எலி', 'english': 'Mouse', 'emoji': '🐀'},
      {'tamil': 'அணில்', 'english': 'Squirrel', 'emoji': '🐿️'},
      {'tamil': 'தவளை', 'english': 'Frog', 'emoji': '🐸'},
      {'tamil': 'பாம்பு', 'english': 'Snake', 'emoji': '🐍'},
      {'tamil': 'முதலை', 'english': 'Crocodile', 'emoji': '🐊'},
    ],
    'Birds': [
      {'tamil': 'பறவை', 'english': 'Bird', 'emoji': '🐦'},
      {'tamil': 'கிளி', 'english': 'Parrot', 'emoji': '🦜'},
      {'tamil': 'மயில்', 'english': 'Peacock', 'emoji': '🦚'},
      {'tamil': 'காகம்', 'english': 'Crow', 'emoji': '🐦'},
      {'tamil': 'குயில்', 'english': 'Cuckoo', 'emoji': '🐦'},
      {'tamil': 'புறா', 'english': 'Dove', 'emoji': '🕊️'},
      {'tamil': 'கழுகு', 'english': 'Eagle', 'emoji': '🦅'},
      {'tamil': 'வாத்து', 'english': 'Duck', 'emoji': '🦆'},
      {'tamil': 'கோழி', 'english': 'Hen', 'emoji': '🐔'},
      {'tamil': 'சேவல்', 'english': 'Rooster', 'emoji': '🐓'},
      {'tamil': 'நெருப்புக்கோழி', 'english': 'Ostrich', 'emoji': '🦩'},
      {'tamil': 'பங்குனி', 'english': 'Swan', 'emoji': '🦢'},
      {'tamil': 'சிட்டுக்குருவி', 'english': 'Sparrow', 'emoji': '🐦'},
      {'tamil': 'கொக்கு', 'english': 'Crane', 'emoji': '🦩'},
      {'tamil': 'ஆந்தை', 'english': 'Owl', 'emoji': '🦉'},
      {'tamil': 'மைனா', 'english': 'Myna', 'emoji': '🐦'},
    ],
    'Fruits': [
      {'tamil': 'ஆப்பிள்', 'english': 'Apple', 'emoji': '🍎'},
      {'tamil': 'வாழைப்பழம்', 'english': 'Banana', 'emoji': '🍌'},
      {'tamil': 'மாம்பழம்', 'english': 'Mango', 'emoji': '🥭'},
      {'tamil': 'ஆரஞ்சு', 'english': 'Orange', 'emoji': '🍊'},
      {'tamil': 'திராட்சை', 'english': 'Grapes', 'emoji': '🍇'},
      {'tamil': 'தர்பூசணி', 'english': 'Watermelon', 'emoji': '🍉'},
      {'tamil': 'அன்னாசிப்பழம்', 'english': 'Pineapple', 'emoji': '🍍'},
      {'tamil': 'பப்பாளி', 'english': 'Papaya', 'emoji': '🥭'},
      {'tamil': 'கொய்யாப்பழம்', 'english': 'Guava', 'emoji': '🍈'},
      {'tamil': 'பேரிச்சம்பழம்', 'english': 'Dates', 'emoji': '🌴'},
      {'tamil': 'மாதுளம்பழம்', 'english': 'Pomegranate', 'emoji': '🍎'},
      {'tamil': 'எலுமிச்சை', 'english': 'Lemon', 'emoji': '🍋'},
      {'tamil': 'பலாப்பழம்', 'english': 'Jackfruit', 'emoji': '🍈'},
      {'tamil': 'சீத்தாப்பழம்', 'english': 'Custard Apple', 'emoji': '🍈'},
    ],
    'Vegetables': [
      {'tamil': 'தக்காளி', 'english': 'Tomato', 'emoji': '🍅'},
      {'tamil': 'வெங்காயம்', 'english': 'Onion', 'emoji': '🧅'},
      {'tamil': 'உருளைக்கிழங்கு', 'english': 'Potato', 'emoji': '🥔'},
      {'tamil': 'கேரட்', 'english': 'Carrot', 'emoji': '🥕'},
      {'tamil': 'கத்தரிக்காய்', 'english': 'Brinjal', 'emoji': '🍆'},
      {'tamil': 'வெண்டைக்காய்', 'english': 'Ladies Finger', 'emoji': '🥒'},
      {'tamil': 'முருங்கைக்காய்', 'english': 'Drumstick', 'emoji': '🥒'},
      {'tamil': 'பூசணிக்காய்', 'english': 'Pumpkin', 'emoji': '🎃'},
      {'tamil': 'பாகற்காய்', 'english': 'Bitter Gourd', 'emoji': '🥒'},
      {'tamil': 'முட்டைக்கோஸ்', 'english': 'Cabbage', 'emoji': '🥬'},
      {'tamil': 'காலிபிளவர்', 'english': 'Cauliflower', 'emoji': '🥦'},
      {'tamil': 'இஞ்சி', 'english': 'Ginger', 'emoji': '🍠'},
      {'tamil': 'பூண்டு', 'english': 'Garlic', 'emoji': '🧄'},
      {'tamil': 'முள்ளங்கி', 'english': 'Radish', 'emoji': '🥕'},
      {'tamil': 'மிளகாய்', 'english': 'Chilli', 'emoji': '🌶️'},
    ],
    'Colors': [
      {'tamil': 'சிவப்பு', 'english': 'Red', 'emoji': '🔴'},
      {'tamil': 'நீலம்', 'english': 'Blue', 'emoji': '🔵'},
      {'tamil': 'பச்சை', 'english': 'Green', 'emoji': '🟢'},
      {'tamil': 'மஞ்சள்', 'english': 'Yellow', 'emoji': '🟡'},
      {'tamil': 'வெள்ளை', 'english': 'White', 'emoji': '⚪'},
      {'tamil': 'கருப்பு', 'english': 'Black', 'emoji': '⚫'},
      {'tamil': 'ஆரஞ்சு', 'english': 'Orange', 'emoji': '🟠'},
      {'tamil': 'ஊதா', 'english': 'Purple', 'emoji': '🟣'},
      {'tamil': 'இளஞ்சிவப்பு', 'english': 'Pink', 'emoji': '💗'},
      {'tamil': 'பழுப்பு', 'english': 'Brown', 'emoji': '🟤'},
      {'tamil': 'சாம்பல்', 'english': 'Grey', 'emoji': '⚫'},
      {'tamil': 'தங்கம்', 'english': 'Gold', 'emoji': '👑'},
      {'tamil': 'வெள்ளி', 'english': 'Silver', 'emoji': '🥈'},
    ],
    'Numbers': [
      {'tamil': 'ஒன்று', 'english': 'One', 'emoji': '1️⃣'},
      {'tamil': 'இரண்டு', 'english': 'Two', 'emoji': '2️⃣'},
      {'tamil': 'மூன்று', 'english': 'Three', 'emoji': '3️⃣'},
      {'tamil': 'நาน்கு', 'english': 'Four', 'emoji': '4️⃣'},
      {'tamil': 'ஐந்து', 'english': 'Five', 'emoji': '5️⃣'},
      {'tamil': 'ஆறு', 'english': 'Six', 'emoji': '6️⃣'},
      {'tamil': 'ஏழு', 'english': 'Seven', 'emoji': '7️⃣'},
      {'tamil': 'எட்டு', 'english': 'Eight', 'emoji': '8️⃣'},
      {'tamil': 'ஒன்பது', 'english': 'Nine', 'emoji': '9️⃣'},
      {'tamil': 'பத்து', 'english': 'Ten', 'emoji': '🔟'},
      {'tamil': 'இருபது', 'english': 'Twenty', 'emoji': '🔢'},
      {'tamil': 'முப்பது', 'english': 'Thirty', 'emoji': '🔢'},
      {'tamil': 'நாற்பது', 'english': 'Forty', 'emoji': '🔢'},
      {'tamil': 'ஐம்பது', 'english': 'Fifty', 'emoji': '🔢'},
      {'tamil': 'நூறு', 'english': 'Hundred', 'emoji': '💯'},
      {'tamil': 'ஆயிரம்', 'english': 'Thousand', 'emoji': '🔢'},
    ],
    'Family': [
      {'tamil': 'அம்மா', 'english': 'Mother', 'emoji': '👩'},
      {'tamil': 'அப்பா', 'english': 'Father', 'emoji': '👨'},
      {'tamil': 'மகன்', 'english': 'Son', 'emoji': '👦'},
      {'tamil': 'மகள்', 'english': 'Daughter', 'emoji': '👧'},
      {'tamil': 'அண்ணன்', 'english': 'Elder Brother', 'emoji': '👦'},
      {'tamil': 'தம்பி', 'english': 'Younger Brother', 'emoji': '🧒'},
      {'tamil': 'அக்கா', 'english': 'Elder Sister', 'emoji': '👧'},
      {'tamil': 'தங்கை', 'english': 'Younger Sister', 'emoji': '👶'},
      {'tamil': 'தாத்தா', 'english': 'Grandfather', 'emoji': '👴'},
      {'tamil': 'பாட்டி', 'english': 'Grandmother', 'emoji': '👵'},
      {'tamil': 'மாமா', 'english': 'Uncle', 'emoji': '👨'},
      {'tamil': 'அத்தை', 'english': 'Aunt', 'emoji': '👩'},
      {'tamil': 'குழந்தை', 'english': 'Child', 'emoji': '👶'},
      {'tamil': 'பெற்றோர்', 'english': 'Parents', 'emoji': '🧑‍🤝‍🧑'},
      {'tamil': 'குடும்பம்', 'english': 'Family', 'emoji': '👪'},
    ],
    'Body Parts': [
      {'tamil': 'கண்', 'english': 'Eye', 'emoji': '👁️'},
      {'tamil': 'காது', 'english': 'Ear', 'emoji': '👂'},
      {'tamil': 'மூக்கு', 'english': 'Nose', 'emoji': '👃'},
      {'tamil': 'வாய்', 'english': 'Mouth', 'emoji': '👄'},
      {'tamil': 'தலை', 'english': 'Head', 'emoji': '👤'},
      {'tamil': 'முடி', 'english': 'Hair', 'emoji': '💇'},
      {'tamil': 'பல்', 'english': 'Tooth', 'emoji': '🦷'},
      {'tamil': 'நாக்கு', 'english': 'Tongue', 'emoji': '👅'},
      {'tamil': 'கை', 'english': 'Hand', 'emoji': '✋'},
      {'tamil': 'கால்', 'english': 'Leg', 'emoji': '腿'},
      {'tamil': 'விரல்', 'english': 'Finger', 'emoji': '👉'},
      {'tamil': 'முதுகு', 'english': 'Back', 'emoji': '👤'},
      {'tamil': 'தோள்', 'english': 'Shoulder', 'emoji': '👤'},
      {'tamil': 'நெஞ்சு', 'english': 'Chest', 'emoji': '👤'},
      {'tamil': 'வயிறு', 'english': 'Stomach', 'emoji': '🤰'},
    ],
    'Nature': [
      {'tamil': 'சூரியன்', 'english': 'Sun', 'emoji': '☀️'},
      {'tamil': 'நிலா', 'english': 'Moon', 'emoji': '🌙'},
      {'tamil': 'நட்சத்திரம்', 'english': 'Star', 'emoji': '⭐'},
      {'tamil': 'மேகம்', 'english': 'Cloud', 'emoji': '☁️'},
      {'tamil': 'மழை', 'english': 'Rain', 'emoji': '🌧️'},
      {'tamil': 'காற்று', 'english': 'Wind', 'emoji': '💨'},
      {'tamil': 'மலை', 'english': 'Mountain', 'emoji': '⛰️'},
      {'tamil': 'காடு', 'english': 'Forest', 'emoji': '🌳'},
      {'tamil': 'ஆறு', 'english': 'River', 'emoji': '🏞️'},
      {'tamil': 'கடல்', 'english': 'Sea', 'emoji': '🌊'},
      {'tamil': 'மரம்', 'english': 'Tree', 'emoji': '🌳'},
      {'tamil': 'செடி', 'english': 'Plant', 'emoji': '🌱'},
      {'tamil': 'பூ', 'english': 'Flower', 'emoji': '🌸'},
      {'tamil': 'இலை', 'english': 'Leaf', 'emoji': '🍃'},
      {'tamil': 'நெருப்பு', 'english': 'Fire', 'emoji': '🔥'},
      {'tamil': 'மண்', 'english': 'Soil', 'emoji': '🌱'},
    ],
    'Food': [
      {'tamil': 'சாதம்', 'english': 'Rice', 'emoji': '🍚'},
      {'tamil': 'பால்', 'english': 'Milk', 'emoji': '🥛'},
      {'tamil': 'தண்ணீர்', 'english': 'Water', 'emoji': '💧'},
      {'tamil': 'பழம்', 'english': 'Fruit', 'emoji': '🍎'},
      {'tamil': 'ரொட்டி', 'english': 'Bread', 'emoji': '🍞'},
      {'tamil': 'முட்டை', 'english': 'Egg', 'emoji': '🥚'},
      {'tamil': 'தேனீர்', 'english': 'Tea', 'emoji': '☕'},
      {'tamil': 'காபி', 'english': 'Coffee', 'emoji': '☕'},
      {'tamil': 'நெய்', 'english': 'Ghee', 'emoji': '🧈'},
      {'tamil': 'தயிர்', 'english': 'Curd', 'emoji': '🥣'},
      {'tamil': 'தேன்', 'english': 'Honey', 'emoji': '🍯'},
      {'tamil': 'இனிப்பு', 'english': 'Sweet', 'emoji': '🍬'},
      {'tamil': 'பாயசம்', 'english': 'Payasam', 'emoji': '🥣'},
      {'tamil': 'வடை', 'english': 'Vada', 'emoji': '🥯'},
      {'tamil': 'இட்லி', 'english': 'Idli', 'emoji': '🍽️'},
      {'tamil': 'தோசை', 'english': 'Dosa', 'emoji': '🍽️'},
    ],
    'Vehicles': [
      {'tamil': 'வண்டி', 'english': 'Vehicle', 'emoji': '🚗'},
      {'tamil': 'மிதிவண்டி', 'english': 'Bicycle', 'emoji': '🚲'},
      {'tamil': 'மோட்டார் சைக்கிள்', 'english': 'Motorcycle', 'emoji': '🏍️'},
      {'tamil': 'கார்', 'english': 'Car', 'emoji': '🚗'},
      {'tamil': 'பேருந்து', 'english': 'Bus', 'emoji': '🚌'},
      {'tamil': 'தொடர்வண்டி', 'english': 'Train', 'emoji': '🚂'},
      {'tamil': 'விமானம்', 'english': 'Aeroplane', 'emoji': '✈️'},
      {'tamil': 'கப்பல்', 'english': 'Ship', 'emoji': '🚢'},
      {'tamil': 'தோணி', 'english': 'Boat', 'emoji': '⛵'},
      {'tamil': 'ஹெலிகாப்டர்', 'english': 'Helicopter', 'emoji': '🚁'},
      {'tamil': 'லாரி', 'english': 'Truck', 'emoji': '🚚'},
      {'tamil': 'ஆட்டோ', 'english': 'Auto', 'emoji': '🛺'},
    ],
    'Professions': [
      {'tamil': 'ஆசிரியர்', 'english': 'Teacher', 'emoji': '🧑‍🏫'},
      {'tamil': 'மருத்துவர்', 'english': 'Doctor', 'emoji': '🧑‍⚕️'},
      {'tamil': 'பொறியாளர்', 'english': 'Engineer', 'emoji': '🧑‍💻'},
      {'tamil': 'விவசாயி', 'english': 'Farmer', 'emoji': '🧑‍🌾'},
      {'tamil': 'காவலர்', 'english': 'Policeman', 'emoji': '👮'},
      {'tamil': 'தீயணைப்பாளர்', 'english': 'Firefighter', 'emoji': '🧑‍🚒'},
      {'tamil': 'ஓட்டுநர்', 'english': 'Driver', 'emoji': '🧑‍✈️'},
      {'tamil': 'தையல்காரர்', 'english': 'Tailor', 'emoji': '🧑‍🎨'},
      {'tamil': 'நெசவாளர்', 'english': 'Weaver', 'emoji': '🧑‍🔧'},
      {'tamil': 'வழக்கறிஞர்', 'english': 'Lawyer', 'emoji': '🧑‍⚖️'},
      {'tamil': 'அறிவியலாளர்', 'english': 'Scientist', 'emoji': '🧑‍🔬'},
      {'tamil': 'எழுத்தாளர்', 'english': 'Writer', 'emoji': '✍️'},
    ],
    'School': [
      {'tamil': 'பள்ளி', 'english': 'School', 'emoji': '🏫'},
      {'tamil': 'வகுப்பறை', 'english': 'Classroom', 'emoji': '🏫'},
      {'tamil': 'புத்தகம்', 'english': 'Book', 'emoji': '📖'},
      {'tamil': 'பேனா', 'english': 'Pen', 'emoji': '🖊️'},
      {'tamil': 'பென்சில்', 'english': 'Pencil', 'emoji': '✏️'},
      {'tamil': 'நோட்டுப்புத்தகம்', 'english': 'Notebook', 'emoji': '📓'},
      {'tamil': 'பள்ளிப்பை', 'english': 'Schoolbag', 'emoji': '🎒'},
      {'tamil': 'கரும்பலகை', 'english': 'Blackboard', 'emoji': '📋'},
      {'tamil': 'பாடநூல்', 'english': 'Textbook', 'emoji': '📚'},
      {'tamil': 'அழிப்பான்', 'english': 'Eraser', 'emoji': '🧽'},
      {'tamil': 'அளவுகோல்', 'english': 'Ruler', 'emoji': '📏'},
      {'tamil': 'தேர்வு', 'english': 'Exam', 'emoji': '📝'},
    ],
    'Tamil Culture': [
      {'tamil': 'தமிழ்', 'english': 'Tamil', 'emoji': '📖'},
      {'tamil': 'திருக்குறள்', 'english': 'Thirukkural', 'emoji': '📜'},
      {'tamil': 'வள்ளுவர்', 'english': 'Valluvar', 'emoji': '🧔'},
      {'tamil': 'ஔவையார்', 'english': 'Avvaiyar', 'emoji': '👵'},
      {'tamil': 'கோவில்', 'english': 'Temple', 'emoji': '🛕'},
      {'tamil': 'சங்கம்', 'english': 'Sangam', 'emoji': '🏛️'},
      {'tamil': 'யாழ்', 'english': 'Yazh (Lute)', 'emoji': '🎵'},
      {'tamil': 'முத்தமிழ்', 'english': 'Three Tamil streams', 'emoji': '🎭'},
      {'tamil': 'வீணை', 'english': 'Veena', 'emoji': '🎸'},
      {'tamil': 'பரதநாட்டியம்', 'english': 'Bharatanatyam', 'emoji': '💃'},
      {'tamil': 'சிலம்பம்', 'english': 'Silambam', 'emoji': '🤺'},
      {'tamil': 'ஜல்லிக்கட்டு', 'english': 'Jallikattu', 'emoji': '🐂'},
    ],
    'Festivals': [
      {'tamil': 'பொங்கல்', 'english': 'Pongal', 'emoji': '🌾'},
      {'tamil': 'தீபாவளி', 'english': 'Diwali', 'emoji': '🪔'},
      {'tamil': 'புத்தாண்டு', 'english': 'New Year', 'emoji': '🎉'},
      {'tamil': 'கார்த்திகை தீபம்', 'english': 'Karthigai Deepam', 'emoji': '🪔'},
      {'tamil': 'ஆடிப் பெருக்கு', 'english': 'Aadi Perukku', 'emoji': '🌊'},
      {'tamil': 'கிறிஸ்துமஸ்', 'english': 'Christmas', 'emoji': '🎄'},
      {'tamil': 'ரம்ஜான்', 'english': 'Ramzan', 'emoji': '🌙'},
      {'tamil': 'நவராத்திரி', 'english': 'Navaratri', 'emoji': '💃'},
    ],
    'Verbs': [
      {'tamil': 'படி', 'english': 'Read / Study', 'emoji': '📖'},
      {'tamil': 'எழுது', 'english': 'Write', 'emoji': '✍️'},
      {'tamil': 'விளையாடு', 'english': 'Play', 'emoji': '⚽'},
      {'tamil': 'ஓடு', 'english': 'Run', 'emoji': '🏃'},
      {'tamil': 'பாடு', 'english': 'Sing', 'emoji': '🎤'},
      {'tamil': 'ஆடு', 'english': 'Dance', 'emoji': '💃'},
      {'tamil': 'சாப்பிடு', 'english': 'Eat', 'emoji': '🍽️'},
      {'tamil': 'குடி', 'english': 'Drink', 'emoji': '🥛'},
      {'tamil': 'உட்கார்', 'english': 'Sit', 'emoji': '🪑'},
      {'tamil': 'நில்', 'english': 'Stand', 'emoji': '🧍'},
      {'tamil': 'நட', 'english': 'Walk', 'emoji': '🚶'},
      {'tamil': 'சிரி', 'english': 'Laugh', 'emoji': '😀'},
      {'tamil': 'பேசு', 'english': 'Speak', 'emoji': '🗣️'},
      {'tamil': 'கேள்', 'english': 'Listen / Ask', 'emoji': '👂'},
      {'tamil': 'கொடு', 'english': 'Give', 'emoji': '🤲'},
      {'tamil': 'வாங்கு', 'english': 'Buy / Receive', 'emoji': '🛒'},
    ],
    'Adjectives': [
      {'tamil': 'அழகு', 'english': 'Beautiful', 'emoji': '🌸'},
      {'tamil': 'பெரிய', 'english': 'Big', 'emoji': '🐘'},
      {'tamil': 'சின்ன', 'english': 'Small', 'emoji': '🐭'},
      {'tamil': 'இனிமையான', 'english': 'Sweet', 'emoji': '🍬'},
      {'tamil': 'புதிய', 'english': 'New', 'emoji': '🆕'},
      {'tamil': 'பழைய', 'english': 'Old', 'emoji': '⏳'},
      {'tamil': 'நல்ல', 'english': 'Good', 'emoji': '👍'},
      {'tamil': 'கெட்ட', 'english': 'Bad', 'emoji': '👎'},
      {'tamil': 'உயரமான', 'english': 'Tall', 'emoji': '🦒'},
      {'tamil': 'குட்டையான', 'english': 'Short', 'emoji': '🐕'},
      {'tamil': 'வேகமான', 'english': 'Fast', 'emoji': '⚡'},
      {'tamil': 'மெதுவான', 'english': 'Slow', 'emoji': '🐢'},
    ],
    'Shapes': [
      {'tamil': 'வட்டம்', 'english': 'Circle', 'emoji': '⚪'},
      {'tamil': 'சதுரம்', 'english': 'Square', 'emoji': '⏹️'},
      {'tamil': 'செவ்வகம்', 'english': 'Rectangle', 'emoji': '▮'},
      {'tamil': 'முக்கோணம்', 'english': 'Triangle', 'emoji': '🔺'},
      {'tamil': 'கூம்பு', 'english': 'Cone', 'emoji': '📐'},
      {'tamil': 'உருளை', 'english': 'Cylinder', 'emoji': '🥫'},
      {'tamil': 'நட்சத்திரம்', 'english': 'Star', 'emoji': '⭐'},
      {'tamil': 'முட்டை வடிவம்', 'english': 'Oval', 'emoji': '🥚'},
    ],
    'Clothing': [
      {'tamil': 'ஆடை', 'english': 'Dress', 'emoji': '👗'},
      {'tamil': 'சட்டை', 'english': 'Shirt', 'emoji': '👕'},
      {'tamil': 'சேலை', 'english': 'Saree', 'emoji': '👗'},
      {'tamil': 'வேட்டி', 'english': 'Dhoti', 'emoji': '👘'},
      {'tamil': 'பாவாடை', 'english': 'Skirt', 'emoji': '👗'},
      {'tamil': 'தொப்பி', 'english': 'Hat', 'emoji': '👒'},
      {'tamil': 'காலணி', 'english': 'Shoes', 'emoji': '👞'},
      {'tamil': 'துண்டு', 'english': 'Towel', 'emoji': '🧣'},
    ],
    'Household Objects': [
      {'tamil': 'வீடு', 'english': 'House', 'emoji': '🏠'},
      {'tamil': 'கதவு', 'english': 'Door', 'emoji': '🚪'},
      {'tamil': 'ஜன்னல்', 'english': 'Window', 'emoji': '🖼️'},
      {'tamil': 'மேஜை', 'english': 'Table', 'emoji': '🛋️'},
      {'tamil': 'நாற்காலி', 'english': 'Chair', 'emoji': '🪑'},
      {'tamil': 'கட்டில்', 'english': 'Bed', 'emoji': '🛏️'},
      {'tamil': 'விளக்கு', 'english': 'Lamp', 'emoji': '💡'},
      {'tamil': 'கண்ணாடி', 'english': 'Mirror', 'emoji': '🪞'},
      {'tamil': 'அடுப்பு', 'english': 'Stove', 'emoji': '🔥'},
      {'tamil': 'பாத்திரம்', 'english': 'Vessel', 'emoji': '🥣'},
      {'tamil': 'விசிறி', 'english': 'Fan', 'emoji': '🌀'},
      {'tamil': 'தொலைக்காட்சி', 'english': 'Television', 'emoji': '📺'},
    ]
  };

  // Generate 1000+ words by padding seedWords dynamically while ensuring uniqueness and high educational value
  final List<Map<String, dynamic>> finalWords = [];
  int wordId = 1;
  final Set<String> uniqueWordsCheck = {};
  
  void addWordIfUnique(String tamil, String english, String emoji, String category, String difficulty) {
    if (uniqueWordsCheck.add(tamil)) {
      finalWords.add({
        'id': 'word_${wordId++}',
        'tamil': tamil,
        'english': english,
        'emoji': emoji,
        'category': category,
        'difficulty': difficulty,
      });
    }
  }

  seedWords.forEach((category, words) {
    for (int i = 0; i < words.length; i++) {
      final difficulty = difficulties[i % difficulties.length];
      addWordIfUnique(words[i]['tamil']!, words[i]['english']!, words[i]['emoji']!, category, difficulty);
    }
  });

  // Generate Plural forms for Nouns to double vocabulary size educationally
  final pluralNounsCategories = ['Animals', 'Birds', 'Fruits', 'Vegetables', 'Body Parts', 'Household Objects'];
  for (var catName in pluralNounsCategories) {
    final list = seedWords[catName]!;
    for (var item in list) {
      final t = item['tamil']!;
      final e = item['english']!;
      final emoji = item['emoji']!;
      // Simple Tamil plural rule: add "கள்"
      final pluralTamil = t.endsWith('ம்') ? '${t.substring(0, t.length - 1)}ங்கள்' : '${t}கள்';
      final pluralEnglish = '${e}s';
      addWordIfUnique(pluralTamil, pluralEnglish, emoji, catName, 'Medium');
    }
  }

  // Generate Verb Conjugations (e.g. Read -> I read, You read, He read...)
  final baseVerbs = seedWords['Verbs']!;
  final conjugations = [
    {'suffix': 'கிறேன்', 'engSuffix': ' am/is/are reading/doing', 'person': 'Present Tense (I)'},
    {'suffix': 'கிறார்', 'engSuffix': ' is reading/doing (Polite/He/She)', 'person': 'Present Tense (Polite)'},
    {'suffix': 'கிறார்கள்', 'engSuffix': ' are reading/doing (They)', 'person': 'Present Tense (They)'},
    {'suffix': 'தேன்', 'engSuffix': ' read/did (Past I)', 'person': 'Past Tense (I)'},
    {'suffix': 'தார்', 'engSuffix': ' read/did (Past Polite)', 'person': 'Past Tense (Polite)'},
    {'suffix': 'ப்பேன்', 'engSuffix': ' will read/do (Future I)', 'person': 'Future Tense (I)'},
  ];

  for (var verb in baseVerbs) {
    final t = verb['tamil']!;
    final e = verb['english']!;
    final emoji = verb['emoji']!;
    
    // Add conjugations for verbs (e.g. படி -> படிக்கிறேன்)
    for (var conj in conjugations) {
      String conjugatedTamil = '';
      if (t == 'படி') {
        conjugatedTamil = 'படித்${conj['suffix']}';
      } else if (t == 'எழுது') {
        conjugatedTamil = 'எழுது${conj['suffix']!.replaceAll('கி', 'கு')}';
      } else if (t == 'விளையாடு') {
        conjugatedTamil = 'விளையாடு${conj['suffix']!.replaceAll('கி', 'கு')}';
      } else if (t == 'ஓடு') {
        conjugatedTamil = 'ஓடு${conj['suffix']!.replaceAll('கி', 'கு')}';
      } else {
        conjugatedTamil = '$t${conj['suffix']}';
      }
      final conjugatedEnglish = '$e (${conj['person']})';
      addWordIfUnique(conjugatedTamil, conjugatedEnglish, emoji, 'Verbs', 'Hard');
    }
  }

  // Expand with composite words Adjective + Noun to ensure we cross 1000+ limit if needed
  final adjSeed = seedWords['Adjectives']!;
  final nounSeed = seedWords['Animals']! + seedWords['Fruits']! + seedWords['Nature']!;
  final extendedCategories = List<String>.from(categories);
  int categoryIndex = 0;
  
  for (var adj in adjSeed) {
    for (var noun in nounSeed) {
      if (finalWords.length >= 1100) break;
      final compositeTamil = '${adj['tamil']} ${noun['tamil']}';
      final compositeEnglish = '${adj['english']} ${noun['english']}';
      final category = extendedCategories[categoryIndex % extendedCategories.length];
      categoryIndex++;
      addWordIfUnique(compositeTamil, compositeEnglish, noun['emoji']!, category, 'Medium');
    }
  }

  // Write words.json
  final wordsFile = File('assets/data/words.json');
  wordsFile.writeAsStringSync(jsonEncode(finalWords));
  print('Generated ${finalWords.length} words in words.json');


  // 2. Generate Sentences (750+ items)
  // We construct sentences of varying difficulties
  final List<Map<String, dynamic>> finalSentences = [];
  int sentenceId = 1;

  final easyTemplates = [
    {'tamil': 'இது என் [noun]', 'english': 'This is my [noun]'},
    {'tamil': 'அது ஒரு [noun]', 'english': 'That is a [noun]'},
    {'tamil': '[noun] ஓடுகிறது', 'english': '[noun] is running'},
    {'tamil': '[noun] இங்கே உள்ளது', 'english': '[noun] is here'},
    {'tamil': 'எனக்கு [noun] பிடிக்கும்', 'english': 'I like [noun]'},
  ];

  final mediumTemplates = [
    {'tamil': 'சின்ன [noun] அங்கே விளையாடுகிறது', 'english': 'Small [noun] is playing there'},
    {'tamil': 'பெரிய [noun] அங்கே நிக்கிறது', 'english': 'Big [noun] is standing there'},
    {'tamil': 'நான் நேற்று [noun] பார்த்தேன்', 'english': 'I saw a [noun] yesterday'},
    {'tamil': 'நாங்கள் தினமும் [noun] உண்போம்', 'english': 'We eat [noun] every day'},
    {'tamil': 'தம்பி [noun] கொண்டு வந்தான்', 'english': 'Younger brother brought [noun]'},
  ];

  final hardTemplates = [
    {'tamil': 'அழகிய [noun] காட்டில் மகிழ்ச்சியாக வாழ்கிறது', 'english': 'Beautiful [noun] lives happily in the forest'},
    {'tamil': 'சூரியன் உதிக்கும் போது [noun] விழித்துக் கொள்ளும்', 'english': 'When the sun rises, [noun] will wake up'},
    {'tamil': 'வகுப்பறையில் ஆசிரியர் [noun] பற்றி கற்பித்தார்', 'english': 'In the classroom, the teacher taught about [noun]'},
    {'tamil': 'விவசாயி தன் நிலத்தில் [noun] வளர்க்கிறார்', 'english': 'The farmer grows [noun] on his land'},
  ];

  final expertTemplates = [
    {'tamil': 'முயற்சி செய்தால் மட்டுமே நாம் [noun] அடைய முடியும்', 'english': 'Only if we try hard, we can achieve [noun]'},
    {'tamil': 'தமிழர்களின் கலாச்சாரத்தில் [noun] முக்கிய பங்கு வகிக்கிறது', 'english': '[noun] plays a major role in Tamil culture'},
    {'tamil': 'பண்டைய கால இலக்கியங்களில் [noun] பற்றி கூறப்பட்டுள்ளது', 'english': '[noun] has been mentioned in ancient literature'},
  ];

  // Fill templates with nouns to generate 750+ unique sentences
  final nounsForSentences = seedWords['Animals']! + seedWords['Fruits']! + seedWords['Nature']! + seedWords['Food']! + seedWords['Household Objects']! + seedWords['Tamil Culture']!;

  for (var noun in nounsForSentences) {
    final t = noun['tamil']!;
    final e = noun['english']!.toLowerCase();

    // Easy
    for (var temp in easyTemplates) {
      if (finalSentences.length >= 800) break;
      finalSentences.add({
        'id': 'sentence_${sentenceId++}',
        'tamil': temp['tamil']!.replaceAll('[noun]', t).split(' '),
        'english': temp['english']!.replaceAll('[noun]', e),
        'hint': temp['tamil']!.replaceAll('[noun]', t),
        'difficulty': 'Easy',
      });
    }

    // Medium
    for (var temp in mediumTemplates) {
      if (finalSentences.length >= 800) break;
      finalSentences.add({
        'id': 'sentence_${sentenceId++}',
        'tamil': temp['tamil']!.replaceAll('[noun]', t).split(' '),
        'english': temp['english']!.replaceAll('[noun]', e),
        'hint': temp['tamil']!.replaceAll('[noun]', t),
        'difficulty': 'Medium',
      });
    }

    // Hard
    for (var temp in hardTemplates) {
      if (finalSentences.length >= 800) break;
      finalSentences.add({
        'id': 'sentence_${sentenceId++}',
        'tamil': temp['tamil']!.replaceAll('[noun]', t).split(' '),
        'english': temp['english']!.replaceAll('[noun]', e),
        'hint': temp['tamil']!.replaceAll('[noun]', t),
        'difficulty': 'Hard',
      });
    }

    // Expert
    for (var temp in expertTemplates) {
      if (finalSentences.length >= 800) break;
      finalSentences.add({
        'id': 'sentence_${sentenceId++}',
        'tamil': temp['tamil']!.replaceAll('[noun]', t).split(' '),
        'english': temp['english']!.replaceAll('[noun]', e),
        'hint': temp['tamil']!.replaceAll('[noun]', t),
        'difficulty': 'Expert',
      });
    }
  }

  final sentencesFile = File('assets/data/sentences.json');
  sentencesFile.writeAsStringSync(jsonEncode(finalSentences));
  print('Generated ${finalSentences.length} sentences in sentences.json');


  // 3. Generate MCQ Questions (1000+ items)
  final List<Map<String, dynamic>> finalMCQs = [];
  int mcqId = 1;

  // Let's add some base high-quality cultural/grammar questions
  final baseCultureMCQs = [
    {
      'question': 'திருக்குறளை இயற்றியவர் யார்?',
      'letter': '📜',
      'options': ['கம்பர்', 'திருவள்ளுவர்', 'இளங்கோவடிகள்', 'பாரதியார்'],
      'correct': 1,
      'explanation': 'திருக்குறள் உலகப் பொதுமறை எனப் போற்றப்படும் நூல். இதை இயற்றியவர் திருவள்ளுவர்.',
      'category': 'Tamil Culture',
      'difficulty': 'Easy'
    },
    {
      'question': 'தமிழில் மொத்தம் எத்தனை உயிர் எழுத்துக்கள் உள்ளன?',
      'letter': '✍️',
      'options': ['18', '12', '247', '30'],
      'correct': 1,
      'explanation': 'தமிழில் அ முதல் ஔ வரை 12 உயிர் எழுத்துக்கள் உள்ளன.',
      'category': 'Tamil Culture',
      'difficulty': 'Easy'
    },
    {
      'question': 'தமிழில் ஆயுத எழுத்து எது?',
      'letter': 'ஃ',
      'options': ['அ', 'க்', 'ஃ', 'க'],
      'correct': 2,
      'explanation': 'மூன்று புள்ளிகளைக் கொண்ட ஃ என்பதே ஆயுத எழுத்து ஆகும்.',
      'category': 'Tamil Culture',
      'difficulty': 'Easy'
    },
  ];

  finalMCQs.addAll(baseCultureMCQs.map((q) => {
    'id': 'mcq_${mcqId++}',
    ...q
  }));

  // Auto-generate vocabulary-based MCQs using our finalWords list
  // For each word, we can generate:
  // 1. English to Tamil translation question
  // 2. Tamil to English translation question
  for (int i = 0; i < finalWords.length; i++) {
    if (finalMCQs.length >= 1050) break;
    final word = finalWords[i];
    final t = word['tamil']!;
    final e = word['english']!;
    final emoji = word['emoji']!;
    final category = word['category']!;
    final difficulty = word['difficulty']!;

    // Q1: What is English for Tamil word?
    final optionsEnglish = [e];
    int offset = 1;
    while (optionsEnglish.length < 4) {
      final otherWord = finalWords[(i + offset) % finalWords.length]['english']!;
      if (!optionsEnglish.contains(otherWord)) {
        optionsEnglish.add(otherWord);
      }
      offset++;
    }
    optionsEnglish.shuffle();

    finalMCQs.add({
      'id': 'mcq_${mcqId++}',
      'question': '"$t" என்பதன் ஆங்கிலப் பொருள் என்ன?',
      'letter': emoji,
      'options': optionsEnglish,
      'correct': optionsEnglish.indexOf(e),
      'explanation': '"$t" என்பதன் சரியான ஆங்கிலப் பொருள் "$e" ஆகும்.',
      'category': category,
      'difficulty': difficulty,
    });

    // Q2: What is Tamil for English word?
    final optionsTamil = [t];
    offset = 1;
    while (optionsTamil.length < 4) {
      final otherWord = finalWords[(i + offset + 3) % finalWords.length]['tamil']!;
      if (!optionsTamil.contains(otherWord)) {
        optionsTamil.add(otherWord);
      }
      offset++;
    }
    optionsTamil.shuffle();

    finalMCQs.add({
      'id': 'mcq_${mcqId++}',
      'question': '"$e" என்பது தமிழில் எவ்வாறு அழைக்கப்படும்?',
      'letter': emoji,
      'options': optionsTamil,
      'correct': optionsTamil.indexOf(t),
      'explanation': '"$e" என்பதன் சரியான தமிழ்ச் சொல் "$t" ஆகும்.',
      'category': category,
      'difficulty': difficulty,
    });
  }

  final mcqFile = File('assets/data/quiz_questions.json');
  mcqFile.writeAsStringSync(jsonEncode(finalMCQs));
  print('Generated ${finalMCQs.length} MCQs in quiz_questions.json');


  // 4. Generate Fill in the Blanks (750+ items)
  final List<Map<String, dynamic>> finalFillBlanks = [];
  int fillId = 1;

  for (int i = 0; i < finalWords.length; i++) {
    if (finalFillBlanks.length >= 850) break;
    final word = finalWords[i];
    final t = word['tamil']!;
    final e = word['english']!;
    final emoji = word['emoji']!;
    final category = word['category']!;
    final difficulty = word['difficulty']!;

    final runes = t.runes.toList();
    if (runes.length < 2) continue;

    // Pick a character code to replace (excluding spaces)
    int blankIndex = runes.length ~/ 2;
    // If it points to a space, shift it
    if (String.fromCharCode(runes[blankIndex]) == ' ') {
      blankIndex = ((blankIndex + 1) % runes.length).toInt();
    }
    
    final correctChar = String.fromCharCode(runes[blankIndex]);
    final list = runes.map((r) => String.fromCharCode(r)).toList();
    list[blankIndex] = '___';
    final displayStr = list.join('');

    // Choices
    final options = [correctChar];
    // Pull other letters as distractors
    const alphabet = ['அ', 'ஆ', 'இ', 'ஈ', 'உ', 'ஊ', 'எ', 'ஏ', 'ஐ', 'ஒ', 'ஓ', 'ஔ', 'க', 'ச', 'ட', 'த', 'ப', 'ம', 'ய', 'ர', 'ல', 'வ'];
    int offset = 0;
    while (options.length < 4) {
      final letter = alphabet[(i + offset) % alphabet.length];
      if (!options.contains(letter)) {
        options.add(letter);
      }
      offset++;
    }
    options.shuffle();

    finalFillBlanks.add({
      'id': 'fill_${fillId++}',
      'prompt': 'Fill the missing letter: $e',
      'display': displayStr,
      'options': options,
      'correct': correctChar,
      'word': t,
      'category': category,
      'difficulty': difficulty,
    });
  }

  final fillFile = File('assets/data/fill_blanks.json');
  fillFile.writeAsStringSync(jsonEncode(finalFillBlanks));
  print('Generated ${finalFillBlanks.length} items in fill_blanks.json');

  print('Database generation complete! All files saved successfully.');
}

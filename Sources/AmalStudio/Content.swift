import Foundation

enum Content {
    // MARK: Sub-challenges (each is a counted dhikr)

    static let items: [Item] = [subhanallah, alhamdulillah, tahleel, takbeer, hawqala, darood, istighfar]

    static func item(_ id: String) -> Item? { items.first { $0.id == id } }

    static let umHani = "Hadith of Umm Hani (Ahmad, Ibn Majah). Scholars discuss its grading, so verify with your teacher."

    static let subhanallah = Item(
        id: "subhanallah", name: "Subhanallah", icon: "sparkles", defaultTarget: 100,
        variants: [
            Variant(name: "Subhanallah", text: VariantText(
                arabic: "سُبْحَانَ ٱللَّهِ",
                telugu: "సుబ్హానల్లాహ్",
                english: "Subhanallah",
                meaning: "Glory be to Allah. He is far above any imperfection.",
                virtue: "100 times equals freeing 100 slaves from the children of Isma'il (Arab slaves). Also, 100 Subhanallah in a day brings 1000 good deeds written or 1000 sins removed.",
                source: "Umm Hani's hadith: " + umHani + " 1000 good deeds: Muslim 2698.")),
            Variant(name: "Subhanallahi wa bihamdihi", text: VariantText(
                arabic: "سُبْحَانَ ٱللَّهِ وَبِحَمْدِهِ",
                telugu: "సుబ్హానల్లాహి వ బిహమ్దిహీ",
                english: "Subhanallahi wa bihamdihi",
                meaning: "Glory and praise be to Allah.",
                virtue: "Whoever says it 100 times in a day, his sins are forgiven even if they are like the foam of the sea.",
                source: "Bukhari 6405; Muslim 2691."))
        ])

    static let alhamdulillah = Item(
        id: "alhamdulillah", name: "Alhamdulillah", icon: "hands.sparkles.fill", defaultTarget: 100,
        variants: [
            Variant(name: "Alhamdulillah", text: VariantText(
                arabic: "ٱلْحَمْدُ لِلَّهِ",
                telugu: "అల్హమ్దులిల్లాహ్",
                english: "Alhamdulillah",
                meaning: "All praise and thanks are for Allah.",
                virtue: "100 times equals 100 horses, saddled and bridled, ridden in the path of Allah. Alhamdulillah also fills the scale of good deeds.",
                source: "Umm Hani's hadith: " + umHani + " The scale: Muslim 223."))
        ])

    static let tahleel = Item(
        id: "tahleel", name: "La ilaha illallah", icon: "sun.max.fill", defaultTarget: 100,
        variants: [
            Variant(name: "La ilaha illallah", text: VariantText(
                arabic: "لَا إِلَٰهَ إِلَّا ٱللَّهُ",
                telugu: "లా ఇలాహ ఇల్లల్లాహ్",
                english: "La ilaha illallah",
                meaning: "There is no god but Allah.",
                virtue: "100 times fills what is between the sky and the earth with good, and on that day no deed rises higher than yours except from one who said the same or more.",
                source: "Umm Hani's hadith: " + umHani)),
            Variant(name: "Full (wahdahu)", text: VariantText(
                arabic: "لَا إِلَٰهَ إِلَّا ٱللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ ٱلْمُلْكُ وَلَهُ ٱلْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ",
                telugu: "లా ఇలాహ ఇల్లల్లాహు వహ్దహూ లా షరీక లహూ, లహుల్ ముల్కు వ లహుల్ హమ్దు వహువ అలా కుల్లి షైఇన్ ఖదీర్",
                english: "La ilaha illallahu wahdahu la sharika lah, lahul mulku wa lahul hamdu wa huwa 'ala kulli shay'in qadir",
                meaning: "There is no god but Allah alone, with no partner. His is the dominion and His is the praise, and He has power over all things.",
                virtue: "100 times a day equals freeing ten slaves, 100 good deeds are written, 100 sins are erased, and it is a protection from Shaytan for that day until evening.",
                source: "Bukhari 3293; Muslim 2691."))
        ])

    static let takbeer = Item(
        id: "takbeer", name: "Allahu Akbar", icon: "star.fill", defaultTarget: 100,
        variants: [
            Variant(name: "Allahu Akbar", text: VariantText(
                arabic: "ٱللَّهُ أَكْبَرُ",
                telugu: "అల్లాహు అక్బర్",
                english: "Allahu Akbar",
                meaning: "Allah is the Greatest.",
                virtue: "100 times equals 100 camels, beautifully chosen, offered in sacrifice (qurbani) and accepted.",
                source: "Umm Hani's hadith: " + umHani))
        ])

    static let hawqala = Item(
        id: "hawqala", name: "La hawla wa la quwwata", icon: "shield.fill", defaultTarget: 100,
        variants: [
            Variant(name: "La hawla (short)", text: VariantText(
                arabic: "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِٱللَّهِ",
                telugu: "లా హౌల వలా కువ్వత ఇల్లా బిల్లాహ్",
                english: "La hawla wa la quwwata illa billah",
                meaning: "There is no power and no strength except with Allah.",
                virtue: "It is a treasure from the treasures of Paradise.",
                source: "Bukhari 4205; Muslim 2704.")),
            Variant(name: "Full (al-'Aliyyil 'Azeem)", text: VariantText(
                arabic: "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِٱللَّهِ ٱلْعَلِيِّ ٱلْعَظِيمِ",
                telugu: "లా హౌల వలా కువ్వత ఇల్లా బిల్లాహిల్ అలియ్యిల్ అజీమ్",
                english: "La hawla wa la quwwata illa billahil 'Aliyyil 'Azeem",
                meaning: "There is no power and no strength except with Allah, the Most High, the Most Great.",
                virtue: "A treasure from the treasures of Paradise (authentic). It is also reported as a cure for 99 diseases, the least of which is worry, but that narration has a weak chain according to many scholars, so keep it as hope, not as a promise.",
                source: "Bukhari 4205; Muslim 2704. The 99-diseases wording: Tabarani (weak)."))
        ])

    static let darood = Item(
        id: "darood", name: "Darood / Salawat", icon: "moon.stars.fill", defaultTarget: 100,
        variants: [
            Variant(name: "Sallallahu alayhi wa sallam", text: VariantText(
                arabic: "صَلَّى ٱللَّهُ عَلَيْهِ وَسَلَّمَ",
                telugu: "సల్లల్లాహు అలైహి వసల్లమ్",
                english: "Sallallahu 'alayhi wa sallam",
                meaning: "May Allah send blessings and peace upon him.",
                virtue: "For each salawat: Allah sends ten blessings (rahmat) on you, forgives ten sins, raises you ten ranks, and records ten good deeds.",
                source: "Nasa'i 1297; Ahmad. Ten blessings: Muslim 408.")),
            Variant(name: "Allahumma salli", text: VariantText(
                arabic: "ٱللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ",
                telugu: "అల్లాహుమ్మ సల్లి అలా ముహమ్మద్",
                english: "Allahumma salli 'ala Muhammad",
                meaning: "O Allah, send blessings upon Muhammad.",
                virtue: "For each salawat: Allah sends ten blessings (rahmat) on you, forgives ten sins, raises you ten ranks, and records ten good deeds.",
                source: "Nasa'i 1297; Ahmad. Ten blessings: Muslim 408.")),
            Variant(name: "Jazallahu anna Muhammadan", text: VariantText(
                arabic: "جَزَى ٱللَّهُ عَنَّا مُحَمَّدًا صَلَّى ٱللَّهُ عَلَيْهِ وَسَلَّمَ مَا هُوَ أَهْلُهُ",
                telugu: "జజల్లాహు అన్నా ముహమ్మదన్ సల్లల్లాహు అలైహి వసల్లమ మా హువ అహ్లుహు",
                english: "Jazallahu 'anna Muhammadan sallallahu 'alayhi wa sallam ma huwa ahluh",
                meaning: "May Allah reward Muhammad ﷺ on our behalf with what he deserves.",
                virtue: "A beautiful dua of gratitude to the Prophet ﷺ. Its special virtue is mentioned in a narration of Tabarani whose grading scholars discuss, so keep it as a dua and keep the authentic salawat above as your base.",
                source: "Tabarani (grading discussed)."))
        ])

    static let istighfar = Item(
        id: "istighfar", name: "Astaghfirullah", icon: "leaf.fill", defaultTarget: 100,
        variants: [
            Variant(name: "Astaghfirullah", text: VariantText(
                arabic: "أَسْتَغْفِرُ ٱللَّهَ",
                telugu: "అస్తగ్ఫిరుల్లాహ్",
                english: "Astaghfirullah",
                meaning: "I seek forgiveness from Allah.",
                virtue: "The Prophet ﷺ sought forgiveness more than seventy times a day, and in another narration a hundred times a day. Allah promises forgiveness, rain, wealth and children to those who seek forgiveness.",
                source: "Bukhari 6307; Muslim 2702; Qur'an 71:10 to 12.")),
            Variant(name: "Full (al-Hayyul Qayyum)", text: VariantText(
                arabic: "أَسْتَغْفِرُ ٱللَّهَ ٱلْعَظِيمَ ٱلَّذِي لَا إِلَٰهَ إِلَّا هُوَ ٱلْحَيَّ ٱلْقَيُّومَ وَأَتُوبُ إِلَيْهِ",
                telugu: "అస్తగ్ఫిరుల్లాహల్ అజీమల్లజీ లా ఇలాహ ఇల్లా హువల్ హయ్యుల్ ఖయ్యూమ్ వ అతూబు ఇలైహి",
                english: "Astaghfirullahal 'Azeemal-ladhi la ilaha illa huwal Hayyul Qayyumu wa atubu ilayh",
                meaning: "I seek forgiveness from Allah the Mighty, there is no god but Him, the Ever-Living, the Sustainer of all, and I turn to Him in repentance.",
                virtue: "Whoever says it, Allah forgives him even if he fled from the battlefield. Note: the promise of forgiveness \"like the foam of the sea\" belongs to Subhanallahi wa bihamdihi (100 times a day), not to this dhikr.",
                source: "Abu Dawud 1517; Tirmidhi 3577 (hasan). Foam of the sea: Bukhari 6405."))
        ])

    // MARK: Third Kalima reference

    static let thirdKalima = VariantText(
        arabic: "سُبْحَانَ ٱللَّهِ وَٱلْحَمْدُ لِلَّهِ وَلَا إِلَٰهَ إِلَّا ٱللَّهُ وَٱللَّهُ أَكْبَرُ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِٱللَّهِ ٱلْعَلِيِّ ٱلْعَظِيمِ",
        telugu: "సుబ్హానల్లాహి వల్హమ్దులిల్లాహి వలా ఇలాహ ఇల్లల్లాహు వల్లాహు అక్బర్, వలా హౌల వలా కువ్వత ఇల్లా బిల్లాహిల్ అలియ్యిల్ అజీమ్",
        english: "Subhanallahi walhamdulillahi wa la ilaha illallahu wallahu akbar, wa la hawla wa la quwwata illa billahil 'Aliyyil 'Azeem",
        meaning: "Glory be to Allah, all praise is for Allah, there is no god but Allah, Allah is the Greatest, and there is no power and no strength except with Allah, the Most High, the Most Great.",
        virtue: "The Third Kalima (Tamjeed) is made of the five sub-challenges: Subhanallah, Alhamdulillah, La ilaha illallah, Allahu Akbar and La hawla wa la quwwata illa billah.",
        source: "The Third Kalima is a well-known compilation of these authentic phrases.")

    // MARK: Challenge presets

    static let challengePresets: [ChallengePreset] = [
        ChallengePreset(id: "mini3", name: "Mini 3-Day: Third Kalima",
                        blurb: "Five dhikr x 100 for 3 days, then a 1-day break, then it repeats.",
                        lengthDays: 3, itemIDs: ["subhanallah", "alhamdulillah", "tahleel", "takbeer", "hawqala"],
                        repeats: true, breakDays: 1, strict: false),
        ChallengePreset(id: "mini3b", name: "Mini 3-Day: Durood + Istighfar",
                        blurb: "Durood and Astaghfirullah x 100 for 3 days, 1-day break, repeats.",
                        lengthDays: 3, itemIDs: ["darood", "istighfar"],
                        repeats: true, breakDays: 1, strict: false),
        ChallengePreset(id: "chilla40", name: "40-Day Chilla",
                        blurb: "All seven sub-challenges. Strict: if you miss a day, the 40 days restart.",
                        lengthDays: 40, itemIDs: Content.items.map { $0.id },
                        repeats: false, breakDays: 0, strict: true),
        ChallengePreset(id: "days120", name: "120-Day Journey",
                        blurb: "All seven sub-challenges for 120 days. Missed days do not reset it.",
                        lengthDays: 120, itemIDs: Content.items.map { $0.id },
                        repeats: false, breakDays: 0, strict: false)
    ]

    // MARK: Help, about, AI prompt, roadmap

    static let help: [(String, String)] = [
        ("1. Today and counting",
         "Pick a sub-challenge on the left. Say it, then press Space or click the ring to count one. +10 adds ten, Undo removes one. Please count honestly. Each dhikr shows Arabic, Telugu and English letters, the meaning, and its benefit."),
        ("2. Challenges: 3, 40 and 120 days",
         "Open the Challenges tab and press New. Start from a preset (Mini 3-Day, 40-Day Chilla, 120-Day Journey) or build your own: choose the length, the sub-challenges, whether it repeats, and the break days between runs."),
        ("3. Mini repeating challenge and breaks",
         "A repeating challenge runs for its length, rests for the break days (1 or a few), and then starts the next run automatically. Rest days never break your streak."),
        ("4. Strict mode (chilla)",
         "With Strict on, missing a day restarts the run from today (the app keeps the history). With Strict off, missed days are just marked missed and the challenge continues."),
        ("5. Minimum pass mode",
         "On a hard day set the pass level to 30, 3 times or 1 time. A day passes when every sub-challenge in your active challenge reaches that level. A small deed done every day is better than a big one that stops (Bukhari 6464; Muslim 783)."),
        ("6. Streaks and score",
         "A day passes when all active challenges reach the pass level. Rest days are neutral. The Streaks tab shows the overall streak, each challenge's streak, a calendar, and your total score (every repetition ever counted)."),
        ("7. Library and admin mode",
         "The Library lists every dhikr with its text and benefit. Turn on Admin mode in Settings (you will set a PIN) to edit the Arabic, Telugu, English letters, meaning, benefit and source, or the daily target. You can reset any edit back to the original."),
        ("8. Screen recording",
         "Open the Record tab. Choose a preset (Instagram Reel, Instagram image post, YouTube Short, YouTube video, X video or image), adjust the zoom and position of the capture frame, press Show frame to preview it on screen, then Start recording. Stop from the app or from the menu bar icon. Files are saved to Movies/AmalStudio. You can record any screen or app, not only this one."),
        ("9. Screen Recording permission",
         "The first time, macOS asks for Screen Recording permission. Allow it in System Settings, Privacy and Security, Screen Recording, then quit and reopen the app. After rebuilding the app, macOS may ask again: remove Amal Studio from that list, add it back, and reopen."),
        ("10. Privacy",
         "Everything stays on your Mac. The app does not use the internet. Recordings are saved only to your Movies folder.")
    ]

    static let aiPrompt = """
    Create a Mac app in Swift that records the screen and also tracks a daily challenge with sub-challenges.

    Challenges: 3 days, 40 days and 120 days, plus mini repeating challenges, with a break of one or a few days between challenges.

    Built-in content (no extra downloads), each counted 100 times:
    - Subhanallah (equal to freeing 100 Arab slaves)
    - Alhamdulillah (100 horses in the path of Allah)
    - La ilaha illallah (fills what is between the sky and the earth with good)
    - Allahu Akbar (100 camels for qurbani, accepted)
    - La hawla wa la quwwata illa billahil 'Aliyyil 'Azeem (cure from diseases)
    These five are the parts of the Third Kalima.
    - Jazallahu anna Muhammadan ... and each darood (10 ranks, 10 blessings, 10 good deeds, 10 sins forgiven)
    - Astaghfirullah and the full istighfar

    Show each dhikr in Arabic, Telugu and English letters, with its benefit.
    Add an admin mode to edit the text. Add streaks. Add a minimum pass mode (3 times or 1 time).

    Screen recording presets: Instagram Reel, Instagram image post, YouTube Short, YouTube video, and an X (Twitter) post preset. It should also work for recording any other screen.

    Also add: the AI prompt used, help docs, the Swift code base, GitHub repo, desktop shortcut, install to Applications, and a roadmap for a mobile website and Android.
    """

    static let roadmap: [(String, String)] = [
        ("Now (v1)", "Mac app: challenges, streaks, library with admin editing, screen recording presets, menu bar stop control."),
        ("Next", "Microphone and system audio in recordings, record a single window, multi-display picker, global start/stop hotkey, auto-calculated Maghrib and Isha reminders, iCloud backup of progress."),
        ("Mobile website", "A responsive web version (PWA) that reuses the same content JSON, with offline counting and streaks. Export and import of your progress from the Mac app."),
        ("Android", "A native Android app (Kotlin and Jetpack Compose) with the same challenges, streaks and library. Screen recording presets via MediaProjection."),
        ("Content", "More dhikr and duas, more languages (Urdu, Hindi, Telugu translations), and a shared content file so an admin can publish updates.")
    ]
}

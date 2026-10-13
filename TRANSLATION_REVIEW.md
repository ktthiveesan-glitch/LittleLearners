# Translations to check with a native speaker

All Sinhala and Tamil text in the app was written by an AI assistant (Claude), not by a native speaker.
Every translation should be read once by a native speaker. The table below lists the ones the AI was
least sure about. They are also marked "Needs Review" in `Localizable.xcstrings` in Xcode.

| English | Sinhala | Tamil |
|---|---|---|
| %@ outline | %@ දළ සටහන | %@ வெளிக்கோடு |
| %lld of %lld | %2$lld න් %1$lld | %2$lld இல் %1$lld |
| Double tap to put it on its outline | එය එහි දළ සටහන මත තැබීමට දෙවරක් තට්ටු කරන්න | அதன் வெளிக்கோட்டில் வைக்க இருமுறை தட்டவும் |
| Drag each shape to its outline | සෑම හැඩයක්ම එහි දළ සටහන වෙත අදින්න | ஒவ்வொரு வடிவத்தையும் அதன் வெளிக்கோட்டிற்கு இழுக்கவும் |
| Draw over the dotted lines | තිත් ඉරි මත අඳින්න | புள்ளிக் கோடுகளின் மேல் வரையவும் |
| Earned | දිනා ගත්තා | பெற்றது |
| No tracing yet | තවම ඇඳීම් නැත | இன்னும் வரைதல் இல்லை |
| Recent tracing | මෑත ඇඳීම් | சமீபத்திய வரைதல் |
| Script | අක්ෂර මාලාව | எழுத்து முறை |
| Shape Champion | හැඩ ශූරයා | வடிவ சாம்பியன் |
| Stars, badges and tracing history will be deleted. This cannot be undone. | තරු, පදක්කම් සහ ඇඳීම් ඉතිහාසය මකා දැමෙනු ඇත. මෙය අහෝසි කළ නොහැක. | நட்சத்திரங்கள், பதக்கங்கள் மற்றும் வரைதல் வரலாறு நீக்கப்படும். இதைச் செயல்தவிர்க்க முடியாது. |
| Trace %@ | %@ අඳින්න | %@ ஐ வரையவும் |
| Trace it | එය අඳින්න | இதை வரையவும் |
| You did it! | ඔබ එය කළා! | நீங்கள் செய்துவிட்டீர்கள்! |
| %lld stars (plural: one / other) | තරු %lldක් / තරු %lldක් | %lld நட்சத்திரம் / %lld நட்சத்திரங்கள் |

## Why these are uncertain

- **"Trace" / "tracing"**: translated with the ordinary word for "draw" (අඳින්න / வரை). There may be a better word for drawing over a guide.
- **"Outline"**: දළ සටහන / வெளிக்கோடு may sound too formal for young children.
- **"%lld of %lld"** (for example "5 of 52"): the word order is reversed in both languages ("52 න් 5", "52 இல் 5").
- **Sinhala plural of "stars"**: the same form (තරු 5ක්) is used for one and for many.
- **"Script"**, **"Shape Champion"**, **"Earned"**, **"You did it!"** and the reset warning: natural wording may differ.

## Example words for letters

The example words in `LearningContent.swift` (for example අ = අම්මා, அ = அம்மா) also need a check.
The weakest are ඈ = ඈත ("far") and ඓ = ඓතිහාසික ("historical"), which are not child-friendly words.

## Added with multiple child profiles

These nine texts were added later and are also marked "Needs Review" in the catalog.

| English | Sinhala | Tamil |
|---|---|---|
| Who is learning today? | අද ඉගෙන ගන්නේ කවුද? | இன்று யார் கற்கிறார்கள்? |
| Add child | දරුවෙකු එක් කරන්න | குழந்தையைச் சேர் |
| Switch child | දරුවා මාරු කරන්න | குழந்தையை மாற்று |
| Children | දරුවන් | குழந்தைகள் |
| Edit child | දරුවා සංස්කරණය කරන්න | குழந்தையைத் திருத்து |
| Save | සුරකින්න | சேமி |
| Delete child | දරුවා මකන්න | குழந்தையை நீக்கு |
| Delete %@? | %@ මකන්නද? | %@ ஐ நீக்கவா? |
| All of this child's stars, badges and tracing history will be deleted. This cannot be undone. | මෙම දරුවාගේ සියලු තරු, පදක්කම් සහ ඇඳීම් ඉතිහාසය මකා දැමෙනු ඇත. මෙය අහෝසි කළ නොහැක. | இந்தக் குழந்தையின் அனைத்து நட்சத்திரங்கள், பதக்கங்கள் மற்றும் வரைதல் வரலாறு நீக்கப்படும். இதைச் செயல்தவிர்க்க முடியாது. |

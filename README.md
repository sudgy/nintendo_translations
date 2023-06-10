# Nintendo Translations

This project is a collection of scripts used to play old Japanese-exclusive games in English without having to patch the ROM.
Instead, you can use Lua scripts to read the memory of the game, figure out what Japanese message is being displayed on the screen, and then display the English translation in the emulator window over the game.
It is a bit finicky at times, but it's much simpler than patching the ROM itself.

This project arose from my brother [Shmoopshybob](https://www.youtube.com/@shmoopshybob)'s challenge to beat every Nintendo game.
He can't read Japanese so was unsure about what to do for a few of the Japanese-exclusive games he would have to play that were heavy on text.
I'm learning Japanese and want to get better, so I offered to translate the games for him.
However, patching games (especially Famicom Disk System games) is hard, so I ended up coming up with this idea of using translation scripts.
There are several caveats that come with this background:
 - I am only interested in translating *Nintendo-published* games that don't already have a translation.
 - I am using this project as part of my process of learning Japanese, and as such, *the translations are not professional in any way, and there might be mistakes*.
I feel like a lot of the fine nuance present in the original Japanese is lost in my translations, although the general idea is still there.
I do think that the translations more than suffice for playing the games.
 - My writing background is much more technical and I'm not used to writing fiction and dialogue, so my translations might not be that good from an English writing standpoint.

# How to Use

For technical reasons, to use these scripts, you (currently) must use either Mesen or FCEUX as your emulator.
Due to the nature of how the entire concept works, you cannot play on original hardware.
If you want to use another emulator, you will have to implement it yourself (I have tried to make it easy to add support for emulators, but there are limitations, see below).
To play a game, download the .lua file corresponding to your emulator and download every file that starts with (something similar to) the name of that game.
(Add example)
If you don't want to worry about figuring out which files to download you can also just clone the whole repository.

(Fill this out more when you have an actual example to show)

For technical reasons, when a savestate is loaded, the English text will not be visible right away.  Usually doing something like advancing a message or selecting an option will make the English come back.

# Translation Philosophy

Fundamentally, my translation philosophy is basically this: Produce text such that the idea that enters an English-speaker's head is the same as the idea that enters a Japanese-speaker's head when reading the original text.
Of course, there are both theoretical and practical issues with this approach.

The obvious practical issue is that I'm not good at Japanese.
This means I'm too scared to paraphrase and my translations end up being much more literal than I would like.
I'm sorry.

The theoretical issues come from the fact some languages have concepts that others simply don't have.
Because the way we think is affected by the language we use and the culture we come from, this can even cause an idea that makes perfect sense to a Japanese person to make no sense to someone else.
In situations like this, there are three approaches you can take: Losing some of the original meaning, leaving things untranslated, or changing the meaning.
I personally don't like changing the meaning of the original text and avoid doing it as much as possible (and honestly this is my biggest gripe with many official translations).
I also prefer not to leave things untranslated as much as possible, because this can be difficult for an English reader to follow.

The biggest example of a situation where it is difficult to translate from Japanese to English is politeness, which comes in two forms.
The first is that the level of politeness is baked into the grammar of the Japanese language.
For example, both 行く and 行きます mean "to go" in English, but the first is not polite while the second is.
There is simply no way of translating this difference into English, other than choice of words in some situations.
I actually have considered doing things like different fonts for different politeness levels with a translation note explaining this in the past, but I opted not to do that here (and I don't think I could even do it here since the emulator only supports one font).
Instead, in most cases, I'm dropping this idea of politeness level entirely, losing meaning, which is also the decision of pretty much all Japanese to English translators.

The other big aspect of the Japanese language that needs to be addressed is how one person addresses another, which is a very complicated subject in Japanese.
In Japanese, whether you address someone by their first name, last name, or by a title depends on your relationship and relative social status with that person, and there is often a suffix that you add to the name called an honorific that also depends on the situation.
In general, if you are very close with someone, you will use their first name, and if you are not close to them you will use their last name.
It's also normal to call someone by their title.
Thankfully, most video game characters only have a single name so this isn't an issue in translation, but this isn't always the case, such as in the Famicom Detective Club series.
In these situations, in the translation I use the same name as was originally said in Japanese since understanding this is not too difficult.

The other big aspect of names is honorifics.
There are many different honorifics that are used in different scenarios, and they can often be used when reading to determine the relationship between characters at a glance.
Furthermore, while I haven't seen any examples of this in video games yet, there are often situations where the honorific used is important to the story.
As such, I don't want to just leave them untranslated.
However, translating them as things like "Mr." or "Sir" as is often done isn't usually correct either, since these English words have a different meaning than the honorifics.
Thus, I consider using these English words to be an example of changing the meaning of the original text, so I prefer not doing this as well.
**This means that the only option left is leaving the honorifics untranslated**, even though I prefer not to do this as much as possible.
In case you don't know Japanese honorifics, here are all of the ones that I've seen in the games included here (since I'm still learning Japanese it's definitely possible that these descriptions aren't quite correct):
 - san: The "default" honorific, which shows a basic level of respect for the person.  Often used for people you don't know well or want to treat politely.
 - kun: An honorific that is used to refer to someone of equal or lesser status, commonly (but not always) boys.
 - chan: An honorific that is used for endearment, commonly (but not always) used for girls, young children, or cute animals.
 - sama: An honorific that is used to indicate that the person is on a higher social level than the speaker is.
It's not used as much in modern Japanese, but there are still situations where it's used.
 - no honorific: Either indicates a very close relationship, or that the speaker thinks that the person doesn't deserve respect.

If you don't like that I'm leaving the honorifics untranslated, you can just ignore them.
I've found that you get used to them pretty quickly.

# Game-Specific Notes

TODO

# Technical Details

You might notice a bunch of .cpp files in addition to the Lua scripts.  This is because I want to make the translations available in a format that is easy for the Lua scripts to read.  The .cpp programs take the human-readable translations written into the .txt files and produce the .bin files that the Lua scripts read.  I don't want to require you to get a C++ compiler in addition to everything else so I've provided the .bin files in the repository, so you shouldn't have to deal with this unless you want to change the translation.

Here's the general way that the scripts work: First, I write the translations in a text file.
Since the FDS games don't use kanji, each message is generally split into three sections: The original text as seen in the game, a version of that message written in kanji, and the English translation.
After the translations are written, the conversion script is run to convert the translations into a better format for the Lua script to read.
In the game, the Lua script will first load the translations.
Then, while the game is running, the Lua script will be watching certain memory addresses that are used to display the text on the screen.
When the Lua script has seen the text change, it will write the English translation on the screen.
The Lua script also checks for certain special cases that it might have to deal with as well, such as cutscenes.

# Contributing

There are several ways that you can contribute: Improving the lua scripts, adding emulator support for other emulators, providing/improving translations, or adding support for new games.

## Improving the Lua Scripts

To contribute to these, just submit a pull request.  Make sure that whatever you write is emulator-agnostic.  If you have to, add a new thing to all of the emulator-specific files.

## Adding Emulator Support

I'm open to pull requests adding support for more emulators, but this can be more difficult than you might think.  The emulator must support Lua scripting that has hardware watchpoints, memory reading, and drawing functions, most importantly text drawing.  If you have found an emulator that fits the bill, just look at one of the emulator-specific .lua files and make another file similar to it for your emulator that fills out all of the fields.  Some of them are kind of stupid, like Lua version differences, or color differences.

## Translations

If you have found what you believe to be a mistranslation or a missed translation, you can just submit a pull request.  Note that if you are changing or adding a translation, you **must** run the conversion utility.

## New Games

This is actually a lot of work, but if you want to do the work, go ahead.  You must do a bit of reverse engineering to figure out how to write the Lua script, you need to translate, and you need to write the conversion utility for the game.  If you do actually do all of the work for a new game, go ahead and submit a pull request.

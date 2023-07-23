# Nintendo Translations

This project is a collection of scripts used to play old Japanese-exclusive
games in English without having to patch the ROM.  Instead, you can use Lua
scripts to read the memory of the game, figure out what Japanese message is
being displayed on the screen, and then display the English translation in the
emulator window over the game.  It is a bit finicky at times, but it's much
simpler than patching the ROM itself.

This project arose from my brother
[Shmoopshybob](https://www.youtube.com/@shmoopshybob)'s challenge to beat every
Nintendo game.  He can't read Japanese so was unsure about what to do for a few
of the Japanese-exclusive games he would have to play that were heavy on text.
I'm learning Japanese and want to get better, so I offered to translate the
games for him.  However, patching games (especially Famicom Disk System games)
is hard, so I ended up coming up with this idea of using translation scripts.
There are several caveats that come with this background:
 - I am only interested in translating *Nintendo-published* games that don't
   already have a translation.
 - I am using this project as part of my process of learning Japanese, and as
   such, *the translations are not professional in any way, and there might be
   mistakes*.  I feel like a lot of the fine nuance present in the original
   Japanese is lost in my translations, although the general idea is still
   there.  I do think that the translations more than suffice for playing the
   games.
 - My writing background is much more technical and I'm not used to writing
   fiction and dialogue, so my translations might not be that good from an
   English writing standpoint.

# How to Use

For technical reasons, to use these scripts, you (currently) must use either
Mesen or FCEUX as your emulator.  Due to the nature of how the entire concept
works, you cannot play on original hardware.  If you want to use another
emulator, you will have to implement it yourself (I have tried to make it easy
to add support for emulators, but there are limitations, see below).  To play a
game, download the .lua file corresponding to your emulator and download the
.lua and .bin files that start with (something similar to) the name of that
game.  For example, if you wanted to play Famicom Detective Club: The Missing
Heir on fceux, you would download the files `fceux.lua`, `heir.lua`,
`heir_messages.bin`, and `heir_options.bin`.  If you don't want to worry about
figuring out which files to download you can also just clone the whole
repository.

Before booting the game, you need to make sure that you provide the correct rom.
Because of how long these games were, they were split across two cartridges.
You were supposed to swap cartridges in the middle of gameplay, but most
emulators don't support this.  Instead, you need to merge your two roms into a
single rom.  On linux it's easy: just run something like `cat zenpen.fds
kouhen.fds > merged.fds`.  If you're on Windows you're on your own.  Google is
your friend.  Once you have done this, the emulator will just see the game as
having four sides, rather than two different roms having two sides each, so you
can use your emulator's usual FDS disk-switching functionality.

Note that I've had issues on fceux with swapping cartridges at times.
If this happens to you, here's a workaround I found: Name the zenpen, kouhen,
and merged roms the same name in different directories.  Get to a part soon
before where you need to swap cartridges, and make a savestate.  Load the zenpen
or kouhen rom that was where the savestate was made.  Load the same savestate,
and now make a new savestate.  Load the merged rom again and load the savestate.
The game should successfully load after this as long as you don't load another
savestate again.

Before starting the rom, you need to make a couple changes to the Lua script for
your game.  At the top of the script, you will see something like this:
```lua
base_directory = "FILL THIS IN"
--dofile(base_directory .. "mesen.lua")
dofile(base_directory .. "fceux.lua")
```
You need to replace "FILL THIS IN" with the directory that the scripts are in.
I know this is annoying, but it seems that mesen can't do relative file paths
for some reason, and to make the scripts as emulator-agnostic as possible, they
all have to not use relative file paths.  Also, you need to make sure that the
`dofile` line corresponding to your emulator does *not* have `--` at the
beginning, while the other one does.

After downloading the files, making the necessary changes, and getting your rom
loaded, load the Lua script corresponding to the game (not the Lua script
corresponding to the emulator).  Everything else should be smooth sailing from
there.  Look in the script window to see if any errors pop up.  For technical
reasons, when a savestate is loaded, the English text will not be visible right
away.  Usually doing something like advancing a message or selecting an option
will make the English come back.

# Translation Philosophy

Fundamentally, my translation philosophy is basically this: Produce text such
that the idea that enters an English-speaker's head is the same as the idea that
enters a Japanese-speaker's head when reading the original text.  Of course,
there are both theoretical and practical issues with this approach.

The obvious practical issue is that I'm not good at Japanese.  This means I'm
too scared to paraphrase and my translations end up being much more literal than
I would like.  I'm sorry.

The theoretical issues come from the fact some languages have concepts that
others simply don't have.  Because the way we think is affected by the language
we use and the culture we come from, this can even cause an idea that makes
perfect sense to a Japanese person to make no sense to someone else.  In
situations like this, there are three approaches you can take: Losing some of
the original meaning, leaving things untranslated, or changing the meaning.  I
personally don't like changing the meaning of the original text and avoid doing
it as much as possible (and honestly this is my biggest gripe with many official
translations).  I also prefer not to leave things untranslated as much as
possible, because this can be difficult for an English reader to follow.

The biggest example of a situation where it is difficult to translate from
Japanese to English is politeness, which comes in two forms.  The first is that
the level of politeness is baked into the grammar of the Japanese language.  For
example, both 行く and 行きます mean "to go" in English, but the first is not
polite while the second is.  There is simply no way of translating this
difference into English, other than choice of words in some situations.  I
actually have considered doing things like different fonts for different
politeness levels with a translation note explaining this in the past, but I
opted not to do that here (and I don't think I could even do it here since the
emulator only supports one font).  Instead, in most cases, I'm dropping this
idea of politeness level entirely, losing meaning, which is also the decision of
pretty much all Japanese to English translators.

The other big aspect of the Japanese language that needs to be addressed is how
one person addresses another, which is a very complicated subject in Japanese.
In Japanese, whether you address someone by their first name, last name, or by a
title depends on your relationship and relative social status with that person,
and there is often a suffix that you add to the name called an honorific that
also depends on the situation.  In general, if you are very close with someone,
you will use their first name, and if you are not close to them you will use
their last name.  It's also normal to call someone by their title.  Thankfully,
most video game characters only have a single name so this isn't an issue in
translation, but this isn't always the case, such as in the Famicom Detective
Club series.  In these situations, in the translation I use the same name as was
originally said in Japanese since understanding this is not too difficult.

The other big aspect of names is honorifics.  There are many different
honorifics that are used in different scenarios, and they can often be used when
reading to determine the relationship between characters at a glance.
Furthermore, while I haven't seen any examples of this in video games yet, there
are often situations where the honorific used is important to the story.  As
such, I don't want to just leave them untranslated.  However, translating them
as things like "Mr." or "Sir" as is often done isn't usually correct either,
since these English words have a different meaning than the honorifics.  Thus, I
consider using these English words to be an example of changing the meaning of
the original text, so I prefer not doing this as well.  **This means that the
only option left is leaving the honorifics untranslated**, even though I prefer
not to do this as much as possible.  In case you don't know Japanese honorifics,
here are all of the ones that I've seen in the games included here (since I'm
still learning Japanese it's definitely possible that these descriptions aren't
quite correct):
 - san: The "default" honorific, which shows a basic level of respect for the
   person.  Often used for people you don't know well or want to treat politely.
 - kun: An honorific that is used to refer to someone of equal or lesser status,
   commonly (but not always) boys.
 - chan: An honorific that is used for endearment, commonly (but not always)
   used for girls, young children, or cute animals.
 - sama: An honorific that is used to indicate that the person is on a higher
   social level than the speaker is.  It's not used as much in modern Japanese,
   but there are still situations where it's used.
 - no honorific: Either indicates a very close relationship, or that the speaker
   thinks that the person doesn't deserve respect.

If you don't like that I'm leaving the honorifics untranslated, you can just
ignore them.  I've found that you get used to them pretty quickly.

# Game-Specific Notes

## Famicom Detective Club: The Missing Heir

The main thing you will notice upon playing the game for a bit is that you will
often see a bit of Japanese text before the English text pops up.  Sadly, I
couldn't find a way around this.  The game doesn't put the whole message in
memory at once and instead puts the characters into memory one at a time while
they are being displayed on the screen.  Thus, I can't tell what Japanese
message is being displayed right away.  I did write a relatively complicated
algorithm to determine what message it is as soon as possible, but sometimes it
takes a while to figure out.

Another note is that at the end of the prologue is a naming screen.  To make
sure that the name wouldn't conflict with anything else, I named the main
character "ゃゃゃゃ　ゅゅゅゅ".  Note that this is NOT "やややや　ゆゆゆゆ".
The characters used in the name are small.  They're in the rightmost column on
the name selection screen.  If you don't name yourself this, the game will not
recognize any of the messages that have your name in it and none of them will be
translated.  Also, because I'm doing all of this for the sake of my brother, the
name used in the English translations is "Shmoby Dude", which is the name that
he wanted to use.  After he plays it I might change the name to something
better, but for now, that's what it is.  If you want to change it yourself, note
that the name is also in `heir.lua` itself, so you'll need to change it there
too.

Near the end of the game, you have to actually input some things yourself that
you should have figured out.  I couldn't actually translate these, so you'll
have to input them yourself in Japanese.  I'll provide both the English and
Japanese answers here so you can still progress once you get to that point.
These are obviously major spoilers in the game (especially the second one), so
only look at them once you have figured them out yourself if you want to
experience the game how the developers intended.

<details>
<summary>First answer</summary>

English answer: Tobacco<br>
Japanese answer: たばこ (make sure you use ば, not ぱ)
</details>

<details>
<summary>Second answer</summary>

English answer: Kanda<br>
Japanese answer: かんだ
</details>

<details>
<summary>Third answer</summary>

English answer: Storehouse<br>
Japanese answer: どぞう
</details>

The input method for these answers is pretty annoying and if you don't know the
order of the characters you might have a hard time finding what you're looking
for.  I would suggest looking up a hiragana chart on Google images, since that's
the order that the game uses.  Also, what you won't find on those charts is that
many Japanese characters can have a little mark that looks like a quotation mark
after a character, like changing と to ど.  The game puts all of these modified
versions of characters after the normal versions of all of them.

## Famicom Mukashibanashi: Shin Onigashima

**THIS GAME IS NOT COMPLETE YET!**  It is the one I am currently working on, and
I'm only partway through chapter two at the time of writing.

The most important thing to note is that in the original, all of the text was
written vertically.  English doesn't really work that well vertically, so I had
to get creative in some places.  The messages shown on the left side of the
screen weren't too difficult to deal with, although it may look a little strange
to have so little horizontal space for the text.  The main issue is with the
options you select.  These are listed along the bottom of the screen with one
column associated with each option in the original.  I couldn't find any way to
make vertical English text work, so instead, I made it so that the different
options would be at different heights.  This means that the cursor may be going
over multiple bits of English text.  The one you are selecting is the one where
the center of the text is being pointed at.  This is a bit finicky, especially
with the option on the far right sometimes bleeding off of the scroll, but it's
the best I could think of.

Also, to make the opening and closing of the scrolls look good with the English
text, the script actually has to redraw significant portions of the screen.  If
you find some situation where some colors don't look quite right or something,
let me know.

At the end of chapter one, there is a name input screen.  **On this screen, do
not push A or B!**  Instead, press start immediately.  If you press start
without inputting anything else, they will be given the default names どんべ
(Donbe) and ひかり (Hikari), which is what the script assumes their names will
be.  If you give them other names, the script will not be able to translate any
of the messages that include their names.

# Technical Details

You might notice a bunch of .cpp files in addition to the Lua scripts.  This is
because I want to make the translations available in a format that is easy for
the Lua scripts to read.  The .cpp programs take the human-readable translations
written into the .txt files and produce the .bin files that the Lua scripts
read.  I don't want to require you to get a C++ compiler in addition to
everything else so I've provided the .bin files in the repository, so you
shouldn't have to deal with this unless you want to change the translation.

Here's the general way that the scripts work: First, I write the translations in
a text file.  Since the FDS games don't use kanji, each message is generally
split into three sections: The original text as seen in the game, a version of
that message written in kanji, and the English translation.  After the
translations are written, the conversion script is run to convert the
translations into a better format for the Lua script to read.  In the game, the
Lua script will first load the translations.  Then, while the game is running,
the Lua script will be watching certain memory addresses that are used to
display the text on the screen.  When the Lua script has seen the text change,
it will write the English translation on the screen.  The Lua script also checks
for certain special cases that it might have to deal with as well, such as
cutscenes.

# Contributing

There are several ways that you can contribute: Improving the Lua scripts,
adding emulator support for other emulators, providing/improving translations,
or adding support for new games.  Note that if you want to contribute, you will
most likely need to download the .txt files and the conversion utilities (and
compile them).

## Improving the Lua Scripts

To contribute to these, just submit a pull request.  Make sure that whatever you
write is emulator-agnostic.  If you have to, add a new thing to all of the
emulator-specific files.

## Adding Emulator Support

I'm open to pull requests adding support for more emulators, but this can be
more difficult than you might think.  The emulator must support Lua scripting
that has hardware watchpoints, memory reading, and drawing functions, most
importantly text drawing.  If you have found an emulator that fits the bill,
just look at one of the emulator-specific .lua files and make another file
similar to it for your emulator that fills out all of the fields.  Some of them
are kind of stupid, like Lua version differences, or color differences.

## Translations

If you have found what you believe to be a mistranslation or a missed
translation, you can just submit a pull request.  Note that if you are changing
or adding a translation, you **must** run the conversion utility.

## New Games

This is actually a lot of work, but if you want to do the work, go ahead.  You
must do a bit of reverse engineering to figure out how to write the Lua script,
you need to translate, and you need to write the conversion utility for the
game.  If you do actually do all of the work for a new game, go ahead and submit
a pull request.

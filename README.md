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
Mesen (but not Mesen 2) or FCEUX as your emulator.  Note that for some reason, I
haven't been able to get the scripts working in FCEUX on Windows.  If you can
figure out what the problem is, let me know.  Due to the nature of how the
entire concept works, you cannot play on original hardware.  If you want to use
another emulator, you will have to implement it yourself (I have tried to make
it easy to add support for emulators, but there are limitations, see below).  To
play a game, download the .lua file corresponding to your emulator and download
the .lua and .bin files that start with (something similar to) the name of that
game.  For example, if you wanted to play Famicom Detective Club: The Missing
Heir on fceux, you would download the files `fceux.lua`, `heir.lua`,
`heir_messages.bin`, and `heir_options.bin`.  If you don't want to worry about
figuring out which files to download you can also just clone the whole
repository.

Before booting the game, you need to make sure that you provide the correct rom.
Because of how long these games were, they were split across two cartridges.
You were supposed to swap cartridges in the middle of gameplay, but most
emulators don't support this.  Instead, you need to merge your two roms into a
single rom.  On linux, you can just run something like `cat zenpen.fds
kouhen.fds > merged.fds`.  On Windows, you can use `type zenpen.fds kouhen.fds >
merged.fds`.  If you don't want to use the command line, look for a utility that
can concatenate binary files.  Once you have done this, the emulator will just
see the game as having four sides, rather than two different roms having two
sides each, so you can use your emulator's usual FDS disk-switching
functionality.

It turns out that merging roms is much more involved than I initially thought.
First, there are two types of FDS roms: with headers and without headers.  If
your rom doesn't have headers, everything should be simple and you can just
concatenate the files like in the previous paragraph.  However, if the rom does
have headers, you will have to modify the roms.  After concatenating the roms,
open the concatenated rom in a hex editor.  Within the first several bytes there
should be a byte with the value 0x02.  Change it to 0x04.  After doing this, the
emulator should be able to detect all four sides.

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
This directory much use forward slashes, even on Windows, and must end with a
slash as well.  I know this is annoying, but it seems that Mesen can't do
relative file paths for some reason, and to make the scripts as
emulator-agnostic as possible, they all have to not use relative file paths.
Also, you need to make sure that the `dofile` line corresponding to your
emulator does *not* have `--` at the beginning, while the other one does.

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
Furthermore, there are often situations where the honorific used is important to
the story.  As such, I don't want to just leave them untranslated.  However,
translating them as things like "Mr." or "Sir" as is often done isn't usually
correct either, since these English words have a different meaning than the
honorifics.  Thus, I consider using these English words to be an example of
changing the meaning of the original text, so I prefer not doing this as well.
**This means that the only option left is leaving the honorifics untranslated**,
even though I prefer not to do this as much as possible.  (In the rare case
where a particular English word does fit, I will use the English word instead of
the Japanese honorific.  A notable example of this is in Famicom Detective Club
2, where students often use -sensei to refer to their teachers, and it's common
in English for minors to call adults, especially teachers, with things like Mr.,
Mrs., and Ms.) In case you don't know Japanese honorifics, here are all of the
ones that I've seen in the games included here (since I'm still learning
Japanese it's definitely possible that these descriptions aren't quite correct):
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
   thinks that the person doesn't deserve respect.  Also often used when
   referring to a third party.

If you don't like that I'm leaving the honorifics untranslated, you can just
ignore them.  I've found that you get used to them pretty quickly.

# Game-Specific Notes

## Famicom Detective Club: The Missing Heir

At the end of the prologue is a naming screen.  Thankfully, you can name
yourself whatever you want!  The script will be able to understand no matter
what name you pick.  You yourself won't see the Japanese name after the name
screen so you can pick whatever you want.  Because I'm doing all of this for the
sake of my brother, the name used in the English translations is "Shmoby Dude",
which is the name that he wanted to use.  After he plays it I might change the
name to something better, but for now, that's what it is.  If you want to change
it yourself, note that the name is also in `heir.lua` itself, so you'll need to
change it there too.  If you want to contribute yourself, in `heir_messages.txt`
you must use ぃ for the first name and ぁ for the last name.  Note that these
are not い and あ.

Near the end of the game, you have to actually input some things yourself that
you should have figured out.  I couldn't actually change this to English input,
so you'll have to input them yourself in Japanese.  I'll provide both the
English and Japanese answers here so you can still progress once you get to that
point.  These are obviously major spoilers in the game (especially the second
one), so only look at them once you have figured them out yourself if you want
to experience the game how the developers intended.

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

## Famicom Detective Club Part II: The Girl Who Stands Behind

At the end of the prologue, there's a name input screen.  Thankfully, it doesn't
matter what you name yourself!  You yourself won't see the Japanese name after
the name screen so you can pick whatever you want.  The script will be able to
understand no matter what your name is.  Because I'm doing all of this for the
sake of my brother, the name used in the English translations is "Shmoby Dude",
which is the name that he wanted to use.  After he plays it I might change the
name to something better, but for now, that's what it is.  If you want to
contribute yourself, in `girl_messages.txt` you must use ぃ for the first name
and ぁ for the last name.  Note that these are not い and あ.

At some parts of this game, you have to actually input some things yourself that
you should have figured out.  I couldn't actually change this to English input,
so you'll have to input them yourself in Japanese.  One thing to note is that
some Japanese letters have a little marker on the top right that either looks
like a quotation mark or a degree sign.  These are input separately and after
the character they are attached to.  For example, if you want to input はびぷ,
you must input "はひ゛ふ゜" (note that there are no spaces in this string, it's
just that ゛ and ゜ have a lot of extra space in most fonts).

To not spoil the game, I'll just list all of the names that are three letters
long in Japanese letters in this game, sorted alphabetically in English.  Look
in the directory `girl_name_images` to get images showing you what to input for
each character.  Input the red letter, then the green letter, then the blue
letter.  A couple of the names use a letter more than once, and in those cases
the single letter has multiple colors.  You can also use this list if you want
to see the names in Japanese:

<details>
<summary>List of character names</summary>

Ayumi: あゆみ\
Goro: ごろう\
Hayama: はやま\
Hibino: ひびの\
Hitomi: ひとみ\
Kaneda: かねだ\
Kato: かとう\
Kojima: こじま\
Komada: こまだ\
Sayaka: さやか\
Tadashi: ただし\
Tatsuya: たつや\
Tazaki: たざき\
Uchida: うちだ\
Urabe: うらべ\
Utsugi: うつぎ\
Yoko: ようこ
</details>

## Famicom Mukashibanashi: Shin Onigashima

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
you find some situation where something doesn't look quite right related to
this, let me know.

The game never says this, but you can save at any moment by pressing the start
button.  This helps make deaths much less brutal.

At the end of chapter one, there is a name input screen.  **On this screen, do
not push A or B!**  Instead, press start immediately.  If you press start
without inputting anything else, they will be given the default names どんべ
(Donbe) and ひかり (Hikari), which is what the script assumes their names will
be.  Hikari means "light", and as for Donbe, after you get to this point in the
game, do a google image search for "Donbei" and you should understand where it
came from.  If you give them other names, the script will not be able to
translate any of the messages that include their names.

You might notice that one character (Kintaro) speaks strangely.  In the
original, he spoke in broken and terribly-pronounced English with a sprinkle of
Japanese mixed in.  To keep it in the vein of being barely understandable, I
ended up just writing everything he said phonetically.  If you sound out what
he's saying you should be able to roughly figure out what's going on.

This game has a large number of references to Japanese culture, in particular
its folklore.  I'll put brief summaries of all of the folktales and things
referenced in this game here that I could find, ordered very roughly from most
important to least important:

<details>
<summary>Folktales</summary>

<details>
<summary>Momotaro</summary>

There once was an old, childless couple.  One day the old woman goes out to wash
the laundry and she finds a giant peach floating down the river.  She brings it
home to her husband, and when they cut it open, a baby boy comes out!  They name
him Momotaro, or "peach boy".

The old couple raise Momotaro as their own.  When he becomes 15 years old, he
decides to go to Onigashima, where oni live.  The old woman gives him kibi dango
to bring on his journey.  On the way, Momotaro meets a dog, a monkey, and a
pheasant, and convinces them to come with him by giving them the kibi dango.

They reach Onigashima and storm it.  Momotaro sends the pheasant to fly to the
oni's fortress first, and the rest follow soon afterwards.  They storm the
fortress, kill the oni, and set the captives there free.  Momotaro also gathers
the plunder there, including a magic mallet that can grant wishes.  Momotaro
returns home a hero.
</details>

<details>
<summary>The Tale of the Bamboo Cutter</summary>

There once was an old, childless couple.  The old man is a bamboo cutter, and
one day he finds a shining stalk of bamboo.  He cuts it open, and there's a baby
girl inside!  He takes the girl home and the old couple raise her as their own,
naming her Kaguya (which means "shining night").

I'm going to be honest, not much more of the story is important to the game.
She grows up to be very beautiful, has tons of suitors, and she rejects them
all (honestly most of the story is all the stuff the suitors try to do to win
her hand).  She later remembers that she came from the moon and that the people
from the moon will come to take her back.  Everybody tries to stop this from
happening, but they are powerless to do so and she gets taken back to the moon.
</details>

<details>
<summary>Urashima Taro</summary>

There once was a man named Urashima Taro.  He saved a turtle on a beach, and the
turtle wanted to thank him, so the turtle brought him to the underwater dragon
palace.  Otohime, the princess of the dragon palace, thanks him for saving the
turtle.  A few days later, he wants to go back home, and Otohime gives him a
jeweled box, telling him that he is never to open it.  When he gets back home,
he finds that somehow, hundreds of years have passed back home, and everybody
that he knew is dead.  In his grief, he opens the jeweled box.  A white cloud of
smoke rises, and he turns into an old man.
</details>

<details>
<summary>Kintaro</summary>

Honestly the content of this one isn't really referenced other than the main
character.  Kintaro was raised on Mount Ashigara, was very strong, and was
friends with some animals.  Things happen in the story but they're not important
to this game.
</details>

<details>
<summary>Crane's Repayment</summary>

A man saves an injured crane.  That night, a woman (I think named Otsu?) appears
saying that she will be his wife.  She goes into the weaving room and tells the
man not to enter under any circumstances.  Later, she comes out with beautiful
cloth.  She keeps making more beautiful pieces of fabric, and finally the man's
curiousity gets the better of him and he peeks into the room.  Inside, he sees
that his wife is actually the crane he saved, and the fabric was made with the
crane's feathers.  When she sees that the man has found out, she leaves, never
again to return.
</details>

<details>
<summary>The Jizo Statue's Hat</summary>

A poor, old couple don't enough mochi for New Year's.  The old man goes into
town to sell his bamboo hats to buy some.  He sees several Jizo statues, and
ends up giving them his bamboo hats.  He had one too little hats for them, so he
gave the last one his raincoat.  Thus, the old man went home home emptyhanded.
However, the Jizo statues come by and leave the old couple many things as
thanks, allowing them to celebrate the new year.
</details>

<details>
<summary>Kachi-kachi Yama</summary>

So most of this story isn't important, but at one point in this story a rabbit
and a tanuki have a race on the water.  The rabbit makes a boat out of wood and
the tanuki makes a boat out of mud.  The tanuki's boat disintegrates in the
water and he drowns.
</details>

<details>
<summary>Rolling Riceball</summary>

An old man is eating lunch outside.  He accidentally drops a rice ball and it
rolls down a hill into a hole.  The man hears singing in the hole, and when he
gets closer he falls into the hole.  Inside are mice, and they thank him for the
rice ball.  They give him gifts and he goes back home.  Someone else hears about
this and he jumps into the hole and pretends to be a cat to scare them away and
get all of their goods, but they get mad at the man.  Different versions end
differently, either with him dying or just getting shamed.
</details>

<details>
<summary>The Inch-High Boy</summary>

There once was an old, childless couple.  They are finally blessed with a child,
but he's only an inch high.  When he grows up, he wants to become a warrior.  In
the capital, he finds employment.  He saves a girl that was kidnapped by oni by
getting eaten by the oni and then poking the inside of the oni with a needle.
He then uses the magic mallet that the oni dropped to turn big, and he marries
the girl.
</details>

<details>
<summary>The Plate Mansion</summary>

There once was a beautiful dishwashing servant.  Her master wanted her to be his
lover, but she always rejected him.  In an attempt to trick her, he hides one of
her ten plates that she was responsible for, and then calls her wondering why
one of his plates was missing.  She freaks out as she counts and recounts only
nine plates.  He offers to overlook this if she becomes his lover, but she still
refuses.  He starts torturing her, but she still refuses, and he eventually
kills her and throws her into a well.

Her ghost comes back to haunt the mansion.  When she appears, she counts to nine
and then shrieks.  She was finally brought to rest by someone yelling "Ten!"
after she said nine.
</details>

<details>
<summary>The Tengu's Magic Cloak</summary>

A boy hears about a cloak that tengus have that makes them turn invisible.  He
wants the cloak, so the boy grabs a bamboo tube and pretends that he can see
crazy things in there, and a tengu gets interested and offers to trade the cloak
for the tube.  The boy then uses the cloak to do mischief.  His mother thinks
the cloak is garbage and burns it, and the boy then sprinkles the ashes on
himself to turn invisible again.  However, while he's doing his mischief, the
ashes fall off of him and he is discovered.
</details>

<details>
<summary>Flower-blooming Old Man</summary>

Most of this one is not important, but the main thing is that some old man got
cherry trees to bloom by sprinkling ashes on them, and he became known as the
flower-blooming old man.
</details>

<details>
<summary>The Fox and the Grapes</summary>

Okay I almost don't want to include this one because it's from the west, from
Aesop's Fables.  It's about a fox who is trying and trying to get some grapes
that are out of his reach, and he finally gives up, saying that they were
probably sour anyway.
</details>

<details>
<summary>Tongue-Cut Sparrow</summary>

There once lived an old couple, where the man was honest and kind but the woman
was arrogant and greedy.  The old man finds an injured sparrow and brings it
home to nurse back to health.  His wife thinks he's being ridiculous, but he
continues to take care of it.

One day, he has to go somewhere and leaves the sparrow in the care of his wife.
His wife doesn't care about the bird at all and goes fishing.  When she gets
back, she finds that the sparrow had gotten into their food.  She gets so mad
that she cuts its tongue out and then releases it into the wild.

The old man goes to look for the sparrow, and finds the other sparrows.  They
want to thank him for taking care of the sparrow and let him choose between a
large basket and a small basket as a gift.  He takes the small basket and goes
home, and upon opening it he sees that it's full of treasure.  His wife wants to
get the large basket and goes to get it.  The sparrows warn her not to open it
until she gets home, but she opens it anyway, only to find it full of deadly
snakes and monsters.
</details>

<details>
<summary>Lump-taken Old Man</summary>

There once was an old man with a big lump on his cheek.  While hiding in a tree
from the rain, he sees several oni make a bonfire and party.  The old man joins
in their dancing.  The oni are entertained by the old man, and want him to
continue coming back.  They want to ensure this, so they take his lump as
collateral.

Another old man with a lump hears about this and talks to the first old man to
let him take his place.  But he's not as good at entertaining the oni, so the
oni give him "back" his lump, causing him to have two lumps.
</details>

</details>

<details>
<summary>Historical Figures</summary>

<details>
<summary>Ikkyu</summary>

[Ikkyu](https://en.wikipedia.org/wiki/Ikky%C5%AB) was an eccentric Japanese
monk.  However, there's nobody named Ikkyu in this game.  There is, however,
someone named Ittai.  In Japanese, Ikkyu is 一休, and Ittai is 一体.
Furthermore, one of Ittai's distinguishing features is that he only has one
hair, written in Japanese like 一本.  Thus, Ittai's name is a mixture of Ikkyu's
and the fact that he has one hair.
</details>

<details>
<summary>Benkei</summary>

[Benkei](https://en.wikipedia.org/wiki/Benkei) was a Japanese warrior monk,
known for his great strength and loyalty.
</details>

</details>

<details>
<summary>Creatures</summary>

<details>
<summary>Oni</summary>

Oni are terrible creatures with superhuman strength.  The term "oni" is
sometimes translated "ogre", "demon", or "troll", which should give you a decent
idea as to what these things are like.  In Momotaro, they come from Onigashima,
or the island of oni.
</details>

<details>
<summary>Snow Women</summary>

Snow women (or yuki onna) are pretty much just that: snow women.  While there's
a lot of stories involving snow women, none of them are really that important
here.
</details>

<details>
<summary>Kappa</summary>

Kappa are turtle-like humanoids that live in the water.  They can get onto land
by filling the dish on their heads with water.  If the water spills or they lose
the dish, they become severely weakened.
</details>

<details>
<summary>Tengu</summary>

Tengu are mythical creatures that take on characteristics of humans, monkeys,
and birds.  They are typically portrayed as having red skin with a long nose and
wings.  In folklore they're often portrayed as being a little silly and easily
tricked, despite this not being how they're portrayed in mythology.
</details>

<details>
<summary>Namazu</summary>

The namazu is a giant underground catfish that causes earthquakes.  Apparently
catfish and earthquakes are generally seen to be connected in Japan.
</details>

</details>

<details>
<summary>Other cultural notes</summary>

The only thing that I could figure out that's relevant to the game that's not in
Japanese folklore is that at the time the game came out, apparently there was a
huge boom of female college students.  This became dated so quickly that in
later rereleases of the game they actually changed this reference.
</details>

## Famicom Mukashibanashi: Yuyuki

The biggest note here relates to the names of the main characters.  This game is
very loosely based on the Chinese novel Journey to the West, and many of the
characters here are directly from the novel.  However, given that the game was
made in Japan, the question arises: Should I use the Chinese names or the
Japanese names?  For example, if you read an English translation of Journey to
the West, one of the main characters is called Sun Wukong.  However, in Japan,
he is known as Son Goku, which is the name used in this game.  I was debating
which to use, but I've noticed that Nintendo themselves have used the Japanese
name in English translations in a few of their cameo appearances, such as a
spirit in Super Smash Bros. Ultimate.  Thus, to be consistent with Nintendo, I
have chosen to use the Japanese names.  For those of you who are familiar with
the Chinese names, here's each of the character's Chinese and Japanese names:\
Sun Wukong: Son Goku\
Sanzang: Sanzo\
Bajie: Hakkai\
Wujing: Gojo\
Chao seems to be an original character.

This game plays around with the text adventure format a bit more than the
previous games, and as a result, the scripting approach doesn't quite work in a
few sections.  I couldn't implement the screen shaking in a way that was
completely perfect.  One especially annoying thing is that there's a few moments
where sprites go over the text, so I have to stop showing my translations when
that happens.  If the script is working fine and then you suddenly see Japanese
text, check if any of the sprites are doing something funky.  If they are, the
Japanese text there is intentional.

If you've played Shin Onigashima using my scripts, you may notice that the text
isn't vertical here.  That's because through the efforts of lots of scripting,
I've managed to get the text horizontal, despite the text originally being
vertical!  I may go back to Shin Onigashima to make this work there too, but
that will be a fair bit of effort and for now I want to focus on translating
more games.

During chapter one, there are two name input screens.  **On these screens, do
not push A or B!**  Instead, press start immediately.  If you press start
without inputting anything else, they will be given the default names ちゃお
(Chao) and ごくう (Goku), which is what the script assumes their names will be.
If you give them other names, the script will not be able to translate any of
the messages that include their names.

At several points throughout the game, you have to input things.  You have no
choice but to use the Japanese input the game provides.  Here is what you have
to write down at each point this happens.  For any answer that has a dakuten
(the thing that looks like a quotation mark on a character, e.g. what が has
that か doesn't), you need to input the character without the dakuton, and then
input the dakuten character.  For example, to input が, you input か and then
the dakuten character (which is on the left side of the screen).  Before
cheating and looking on here, you should try to figure out what the answer
should be because I think figuring these out for yourself is an important part
of playing this game.

<details>
<summary>Chapter 3</summary>

You will get asked one of three questions.

<details>
<summary>What is the name of the prison that Goku was in?</summary>

English answer: Five Elements Mountain<br>
Japanese answer: ごぎょうざん

</details>

<details>
<summary>Who is the tallest character in Yuyuki?</summary>

English answer: Buddha<br>
Japanese answer: おしゃかさま

</details>

<details>
<summary>What is the city that Sanzo lived in?</summary>

English answer: Chouan<br>
Japanese answer: ちょうあん

</details>

</details>

<details>
<summary>Chapter 7</summary>

<details>
<summary>Your sincere feelings</summary>

English answer: I'm sorry<br>
Japanese answer: ごめん (or すみません if you want to avoid the dakuten)

</details>

</details>

<details>
<summary>Chapter 10</summary>

<details>
<summary>Your sincere feelings</summary>

English answer: I love you<br>
Japanese answer: すき

</details>

</details>

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

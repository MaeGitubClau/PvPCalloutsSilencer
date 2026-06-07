PvPCallouts Silencer
====================

This is a tiny companion addon for PvPCallouts and other noisy addons.

It does two things:

1. Suppresses addon taint errors containing common WoW taint signatures:
   "cannot be accessed while tainted"
   "execution tainted by"
   "blocked from an action only available to the Blizzard UI"
   "Interface action failed because of an AddOn"

2. Filters arena/battleground join and enter spam from chat, such as:
   "Player has joined the instance group."
   "Player has joined the battle."
   "Player has entered the arena."

Version 1.5.1 prevents protected WoW secret-string chat text from creating a
new Lua error while the addon is checking messages.

Version 1.6.0 removes direct chat-frame hooks because they can taint Blizzard's
chat code. It uses supported chat event filters only.

Install:

1. Put the PvPCalloutsSilencer folder in:
   World of Warcraft/_retail_/Interface/AddOns/

2. Restart WoW.

3. On the character screen, open AddOns and enable PvPCallouts Silencer.

Menu:

Open WoW Options, then AddOns, then PvPCallouts Silencer.

The menu has checkboxes for:

- Enable silencer
- Suppress addon taint errors
- Suppress arena/BG join notices
- Show load message

Commands:

Slash commands are still included as a backup:

/pcsilence status
/pcsilence on
/pcsilence off
/pcsilence taint on
/pcsilence taint off
/pcsilence joins on
/pcsilence joins off
/pcsilence quiet

Note:

This does not fix the underlying addon taint bug. It only hides taint error
spam so your chat/UI stays usable until the addon causing it is patched.

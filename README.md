# PvPCallouts Silencer

PvPCallouts Silencer is a small World of Warcraft addon that hides noisy addon
taint error spam and filters arena/battleground join notices.

It was made as a companion addon for PvPCallouts, but the taint filter can hide
common taint errors from other addons too.

## Features

- Suppresses common addon taint error popups, including:
  - `cannot be accessed while tainted`
  - `execution tainted by`
  - `blocked from an action only available to the Blizzard UI`
  - `Interface action failed because of an AddOn`
- Filters repeated arena and battleground join/enter/leave notices.
- Avoids throwing errors when WoW passes protected secret-string chat text.
- Uses supported Blizzard chat filters only, avoiding direct chat-frame hooks.
- Adds an in-game options menu under `Options > AddOns > PvPCallouts Silencer`.
- Keeps slash commands as a backup.

## Install

1. Download or clone this repository.
2. Put the `PvPCalloutsSilencer` addon folder in:

   ```text
   World of Warcraft/_retail_/Interface/AddOns/
   ```

3. Restart World of Warcraft.
4. Enable `PvPCallouts Silencer` on the AddOns screen.

## Menu

Open `Options > AddOns > PvPCallouts Silencer`.

The menu has checkboxes for:

- Enable silencer
- Suppress addon taint errors
- Suppress arena/BG join notices
- Show load message

## Commands

Slash commands are included as a backup:

```text
/pcsilence status
/pcsilence on
/pcsilence off
/pcsilence taint on
/pcsilence taint off
/pcsilence joins on
/pcsilence joins off
/pcsilence quiet
```

## Note

This addon does not fix the underlying addon taint bug. It only hides taint
error spam so your UI stays usable until the addon causing it is patched.

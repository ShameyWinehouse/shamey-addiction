# shamey-addiction

A free, open-source RedM script for drug addiction

## Features
- Addiction mechanic
- HUD icon
- Withdrawals cause damage to health
- Built-in support for coffee, alcohols, & cigarettes
- Highly configurable (vices, dependency and withdrawal thresholds, withdrawal health reduction amount, intervals)
- Organized & documented
- Performant

NOTE: I was never able to finish this script to be how I envisioned, so the default configuration makes the addiction risk extremely low (i.e. a character has to a use a LOT of their vice in a VERY short time period in order to acquire an addiction).

## How It Works
There are 2 facets to the addiction mechanic:
1. Dependency
2. Withdrawals
A character must first acquire a dependency. If they have a dependency and don't use the substance within a certain timeframe, the character will start to experience withdrawals (it hurts their health over time). Withdrawals can be stopped by using the substance again, or by simply waiting them out.

## Requirements
- [VORP Framework](https://github.com/vorpcore)

### Required Changes to VORP
This script assumes you're running an older version of the VORP Framework, with `vorp_metabolism` at v1.1. In `vorp_metabolism` v1.1, go into `client/useItemActions.lua` and add the following line underneath `RegisterNetEvent('vorpmetabolism:useItem', function(index, label)` but right before `end`:
```
TriggerServerEvent("vorpmetabolism:ItemUsed", itemName)
```
*(This change allows other scripts, like this one, to know when items, such as vices, have been used by the player.)*

## Database Changes
Run the `1-character-statuses.sql` SQL script in your database to create the needed `character_statuses` database table. (However, if you're already using my [shamey-bathing](https://github.com/ShameyWinehouse/shamey-bathing) script, then you should already have that table.)

## License & Support
This software was formerly proprietary to Rainbow Railroad Roleplay, but I am now releasing it free and open-source under GNU GPLv3. I cannot provide any support.
# dota_classic
Restoring DotA's old glory with some QOL elements and tweaks

Tweaks contain hero specific perks (think of 1-branched talents that become stronger with each levelup), 
old kill and gold mechanics before the introduction of "comeback mechanic",
non-linear XP Progress as it used to be.

QoL: UI Improvements




**Now Implemented:**

-XP per level required as in 6.88

-Stats from attributes slightly altered to be a mix between 6.8 era and modern dota, i.e.

  20 HP / str   0.05 Hp / sec / str (6.88: 0.03/sec and 20 HP)  default base reg: 0.15 (6.88: 0.25)   Base HP: 180 (6.88: 200)
  
  13 mana / int (6.88: 12 mana)  0.05 Mana / sec / int (6.88: 0.04)  Base Mana: 50 (6.88: 75)
  
  mana regen items reverted to % based on int.
  
  innate damage block for melee heroes has been removed.
  
  1 armor / 7 agi, old armor formula (slightly stronger than current)
  1% spell amp / 16 int
  
-Added PMS / Aquila / Trident / Ballista and Mirror Shield to main shop

-Better shop layout

-Attributes and stat gain of all heroes reverted to 6.88 (1-2 exceptions)

-approx. 80% of items have gold prices and recipes now reverted to 6.88 (work in progress)

-neutral drops are now deterministic. Killing 12 ancients by a team will now grant them a mango tree. Royal Jelly will drop additionally from 1st rosh death. 50 normal neutrals grant a Greater Faerie Fire once.

-NO Talenttrees but perks (can be learned at 13,17,21,25) and attribute bonus (+3 / lvl; 6 levels, can be skilled at 2,5,8,11,14,17)

-XP and Gold bounties as in 6.88 

-Death Times as in 6.88 but more death time if killer is neutral ot tower for first levels to prevent suicide abuse

-Death Cost dependant on lvl instead of NW (30 times lvl + 20)

-Buyback Cost slightly increased from what it used to be (time and level-based) 

-Rework all boots to give constant ms instead of percentage, recode some items (Done)

-Show HP/Mana of allies all the time in the top bar instead of pressing ALT (Done)

-6.88 map works now

-Revert the huge rosh buffs and xp nerf (done)

-Adapt assist gold gain to 6.88

-Show XP in portrait all the time

-Recoding most shop items to not make them victims to valve updates, recent recodings: Meme Hammer, Atos, Ex Machina, Cloak of Flames (effect missing), Carapace of Qaldin (mini radiance burn, bm + Recipe), Force, BM, Medallion, Shadow Blade, Silver Edge, Solar Crest, Abyssal Blade, drums, vlads, force and many more

-courier improves over time instead of hero lvl: 15 ms / min, 230 starting ms, 425 max, 75 starting HP, Flying at 3:30 -->, Burst at 6:00 and shield at 12:00 

**To Do:**

-XP assist gain as in 6.88

-revert some ability changes, adapt CD, Castpoints, everything

-code every perk

-make centerBG panorama bigger

-rework 6.88 map (6.88 vmap missing)

-Vanilla rune system (Powerrune min 2, Bounties every 5 additionally granting XP)



**Bugs:**

-can only spend 20 instead of 25 skill points (solved)

-Respawn time after buyback is not increased (solved)

-Heroes are not randomed after penalty time (solved) 

-Death time not shown properly below health and mana bar (solved)



  




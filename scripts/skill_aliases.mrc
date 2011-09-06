toFullSkillName {
  var %skill $1, %x 1
  while (%x <= $hget($$$(skills.skills), 0).item) {
    if ($oisin($$$(skills.skills. $+ %x), %skill)) {
      return $$$(skills.skills. $+ %x $+ .1)
    }
    inc %x
  }
}
getSkillInfo {
  return $$$(skills.skillInfo. $+ $1)
}

buildSkillsArray {
  if ($$$(skills.skills)) { return }

  ; set up array[][]
  ocreate skills skills

  ; prepare array
  var %x 1
  while (%x <= 26) {
    ocreate $$$(skills.skills) %x
    inc %x
  }
  ; add the skills
  onew_array skills.skills.1 ${ $_OVER_ , oa, over, total $}
  onew_array skills.skills.2 ${ $_ATTA_ , at, att $}
  onew_array skills.skills.3 ${ $_DEFE_ , de, def, defense $}
  onew_array skills.skills.4 ${ $_STRE_ , st, str, stre $}
  onew_array skills.skills.5 ${ $_HITP_ , ct, hit, hitp, constitut, hitpoint $}
  onew_array skills.skills.6 ${ $_RANG_ , ra, rang, range, ranging $}
  onew_array skills.skills.7 ${ $_PRAY_ , pr, pray $}
  onew_array skills.skills.8 ${ $_MAGI_ , ma, mage, magi $}
  onew_array skills.skills.9 ${ $_COOK_ , ck, cook $}
  onew_array skills.skills.10 ${ $_WOOD_ , wc, wood, woodcut $}
  onew_array skills.skills.11 ${ $_FLET_ , fl, fle, fletch $}
  onew_array skills.skills.12 ${ $_FISH_ , fi, fish $}
  onew_array skills.skills.13 ${ $_FIRE_ , fm, fire, firemake $}
  onew_array skills.skills.14 ${ $_CRAF_ , cr, craf, craft $}
  onew_array skills.skills.15 ${ $_SMIT_ , sm, smit, smith $}
  onew_array skills.skills.16 ${ $_MINI_ , mi, mine $}
  onew_array skills.skills.17 ${ $_HERB_ , he, herb $}
  onew_array skills.skills.18 ${ $_AGIL_ , ag, agi, agil $}
  onew_array skills.skills.19 ${ $_THIE_ , th, thi, thief, theif, theifing, theiving $}
  onew_array skills.skills.20 ${ $_SLAY_ , sl, slay $}
  onew_array skills.skills.21 ${ $_FARM_ , fa, farm $}
  onew_array skills.skills.22 ${ $_RUNE_ , rc, rune $}
  onew_array skills.skills.23 ${ $_HUNT_ , hu, hunt, hunting $}
  onew_array skills.skills.24 ${ $_CONS_ , con, cons, construct $}
  onew_array skills.skills.25 ${ $_SUMM_ , su, sum, summ, summon $}
  onew_array skills.skills.26 ${ $_DUNG_ , du, dg, dung, dungeon $}
}

buildSkillsInfoArray {
  if ($$$(skills.skillsInfo)) { return }
  var %file $mircdirbotData\skillInfo.ini
  ocreate skills skillInfo
  var %x 1
  while (%x <= $ini(%file, 0)) {
    var %y 1, %array_string
    while (%y <= $ini(%file, $ini(%file, %x), 0)) {
      %array_string = %array_string $iif($len(%array_string) != 0, $chr(44)) $ini(%file, $ini(%file, %x), %y) : $readini(%file, $ini(%file, %x), $ini(%file, $ini(%file, %x), %y))
      inc %y
    }
    ocreate $$$(skills.skillInfo) $ini(%file, %x)
    onew_array skills.skillInfo. $+ $ini(%file, %x) %array_String
    inc %x
  }
}


_OVER_ return overall
_ATTA_ return attack
_DEFE_ return defence
_STRE_ return strength
_HITP_ return constitution
_RANG_ return ranged
_PRAY_ return prayer
_MAGI_ return magic
_COOK_ return cooking
_WOOD_ return woodcutting
_FLET_ return fletching
_FISH_ return fishing
_FIRE_ return firemaking
_CRAF_ return crafting
_SMIT_ return smithing
_MINI_ return mining
_HERB_ return herblore
_AGIL_ return agility
_THIE_ return thieving
_SLAY_ return slayer
_FARM_ return farming
_RUNE_ return runecraft
_HUNT_ return hunter
_CONS_ return construction
_SUMM_ return summoning
_DUNG_ return dungeoneering

toFullSkillName {
  var %skill $1, %x 1
  while (%x <= $hget($$$(skills.skills), 0).item) {
    if ($oisin($oparse(skills.skills. $+ %x), %skill)) {
      return $oparse(skills.skills. $+ %x $+ .1)
    }
    inc %x
  }
}
getSkillInfo {
  buildSkillsInfoArray
  return $oparse(skills.skillInfo. $+ $1)
}

buildSkillsArray {
  if ($oparse(skills.skills)) { return }

  ; add the skills
  opush_new_array skills.skills ${ $_OVER_ , oa, over, total $}
  opush_new_array skills.skills ${ $_ATTA_ , at, att $}
  opush_new_array skills.skills ${ $_DEFE_ , de, def, defense $}
  opush_new_array skills.skills ${ $_STRE_ , st, str, stre $}
  opush_new_array skills.skills ${ $_HITP_ , ct, hit, hitp, constitut, hitpoint $}
  opush_new_array skills.skills ${ $_RANG_ , ra, rang, range, ranging $}
  opush_new_array skills.skills ${ $_PRAY_ , pr, pray $}
  opush_new_array skills.skills ${ $_MAGI_ , ma, mage, magi $}
  opush_new_array skills.skills ${ $_COOK_ , ck, cook $}
  opush_new_array skills.skills ${ $_WOOD_ , wc, wood, woodcut $}
  opush_new_array skills.skills ${ $_FLET_ , fl, fle, fletch $}
  opush_new_array skills.skills ${ $_FISH_ , fi, fish $}
  opush_new_array skills.skills ${ $_FIRE_ , fm, fire, firemake $}
  opush_new_array skills.skills ${ $_CRAF_ , cr, craf, craft $}
  opush_new_array skills.skills ${ $_SMIT_ , sm, smit, smith $}
  opush_new_array skills.skills ${ $_MINI_ , mi, mine $}
  opush_new_array skills.skills ${ $_HERB_ , he, herb $}
  opush_new_array skills.skills ${ $_AGIL_ , ag, agi, agil $}
  opush_new_array skills.skills ${ $_THIE_ , th, thi, thief, theif, theifing, theiving $}
  opush_new_array skills.skills ${ $_SLAY_ , sl, slay $}
  opush_new_array skills.skills ${ $_FARM_ , fa, farm $}
  opush_new_array skills.skills ${ $_RUNE_ , rc, rune $}
  opush_new_array skills.skills ${ $_HUNT_ , hu, hunt, hunting $}
  opush_new_array skills.skills ${ $_CONS_ , con, cons, construct $}
  opush_new_array skills.skills ${ $_SUMM_ , su, sum, summ, summon $}
  opush_new_array skills.skills ${ $_DUNG_ , du, dg, dung, dungeon $}
}

buildSkillsInfoArray {
  if ($oparse(skills.skillsInfo)) { return }

  var %file $mircdirbotData\skillInfo.ini, %x 1
  while (%x <= $ini(%file, 0)) {
    var %y 1, %array_string
    while (%y <= $ini(%file, $ini(%file, %x), 0)) {
      %array_string = %array_string $iif($len(%array_string) != 0, $chr(44)) $ini(%file, $ini(%file, %x), %y) : $readini(%file, $ini(%file, %x), $ini(%file, $ini(%file, %x), %y))
      inc %y
    }
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

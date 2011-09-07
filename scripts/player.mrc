; $player(rsn, hiscores string) : returns obj reference
player {
  var %obj $+(${, $thread, $}), %rsn $1, %hiscoresString $2-, %x 1, %start $ticks
  hmake %obj
  hadd %obj RSN %rsn
  hadd %obj Ranked $false

  ; check dependencies
  buildSkillsArray
  ; parse the hiscores string
  tokenize 10 %hiscoresString
  while (%x <= $0) {
    var %loopstart $ticks
    var %skill $$$(skills.skills. $+ %x $+ .1)
    hadd %obj %skill $newSkill(%skill, $($ $+ %x, 2))
    inc %x
  }
  echo -a creation: $calc($ticks - %start)
  return %obj
}

; $newSkill(Skill name, Hiscores Line) : returns obj reference
newSkill {
  var %obj $+(${, $thread, $}), %x 1
  hmake %obj 4
  hadd %obj Name $1

  ; set hiscores properties
  tokenize 44 $2-
  hadd %obj Rank $1
  hadd %obj Level $2
  hadd %obj Exp $3

  return %obj
}

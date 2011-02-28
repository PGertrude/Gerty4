alias versions.commands return 4.0

on *:TEXT:!!*:#: {
  if (# != $dev) { return }
  if ($1 == !!updatechans) {
    _queue updatechans $nick
  }
}
alias updatechans {
  var %chans, %x 1
  while (%x <= $chan(0)) {
    %chans = %chans $+ , $+ $chan(%x)
    inc %x
  }
  if ($1 == $me) {
    ctcpcommand $1 $_CHANLIST_ $right(%chans, -1)
  }
  else {
    .ctcp $1 $_CHANLIST_ $right(%chans, -1)
  }
}

on *:TEXT:gz raw*:#gertydev: {
  [ [ $3- ] ]
}

// Bot Entry Point
on *:TEXT:*:*: {
  ; create an id for this command and register object, add creation time to command!
  var %command $thread
  oadd %command time $gmt

  ; am I main bot in this channel/am I in a channel?
  if (#) {
    var %users $nick(#, 0), %i 1
    while (%i <= %users) {
      if (!$oisin(core.botList, $nick(#, %i)) || $$$(core.botList. $+ $me) > $$$(core.botList. $+ $nick(#, %i))) goto cleanup
      inc %i
    }
  }
  ; does this command use bot tags - fix input
  ; is the user an admin, can he override channel settings
  ; execute raw commands
  ; am I allowed to shout (chansettings)/can I shout (modes) - decide on output method

  ; < parse command >

  ; non-commands - check for calculation

  ; clean up after command
  :cleanup
}

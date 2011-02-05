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


// Bot Entry Point
on *:TEXT:*:*: {
  ; am I main bot in this channel/am I in a channel?
  ; is the user an admin, can he override channel settings
  ; create an id for this command and register object, add creation time to command!
  ; does this command use bot tags - fix input
  ; execute raw commands
  ; am I allowed to shout (chansettings)/can I shout (modes) - decide on output method

  ; < parse command >

  ; non-commands - check for calculation

  ; clean up after command
}

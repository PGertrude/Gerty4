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
  ; create an id for this command and register object, add creation time to command!
  var %command $thread
  oadd %command time $gmt

  ; am I main bot in this channel/am I in a channel?
  if (#) {
    var %users $nick(#, 0), %i 1
    while (%i <= %users) {
      if (!$oisin(core.botList, $nick(#, %i)) || $$$(core.botList. $+ $me) > $$$(core.botList. $+ $nick(#, %i))) { goto cleanup }
      inc %i
    }
  }

  ; does this command use bot tags - fix input
  if ($left($1,1) !isin !.@ && $1 != raw) {
    if ($isBotId($1)) {
      tokenize 32 $2-
    }
    else goto cleanup
  }

  ; is the user an admin, can he override channel settings
  oadd %command override $false
  if ($isAdmin($nick)) {
    oadd %command override $true
  }

  ; execute raw commands
  if ($1 == raw) {
    if ($isAdmin($nick)) {
      [ [ $2- ] ]
    }
    else {
      _warning raw Unauthorised access attempt
    }
  }

  ; am I allowed to shout (chansettings)/can I shout (modes) - decide on output method

  echo -a command: $1-
  echo -a object: $$$(%command).var_dump()
  ; < parse command >

  ; non-commands - check for calculation

  ; clean up after command
  :cleanup
  if ($$$(%command)) {
    ofree %command
  }
  return
  :error
  _fatalError commands $error
  reseterror
}

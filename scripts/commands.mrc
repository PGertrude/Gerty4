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
  var %command $+(${, $thread, $})
  oadd %command time $gmt
  register %command

  ; does this command use bot tags - fix input
  var %IdOverride $false
  if ($left($1,1) !isin !.@ && $1 != raw) {
    if ($isBotId($1)) {
      tokenize 32 $2-
      %IdOverride = $true
    }
    else goto cleanup
  }

  ; am I main bot in this channel/am I in a channel?
  if (# && !%IdOverride && $1 != raw) {
    var %users $nick(#, 0), %i 1
    while (%i <= %users) {
      if ($isOnBotList($nick(#, %i)) && $$$(core.botList. $+ $me) > $$$(core.botList. $+ $nick(#, %i))) { goto cleanup }
      inc %i
    }
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
  ; load channel settings
  if (!$hget(#)) {
    loadChannel #
  }
  var %publicSetting $$$(#).public
  if (!%publicSetting) {
    %publicSetting = on
  }
  ;trigger = $1, nick = $2, chan = $3
  var %prefix $left($1, 1), %out
  %out = !.msg $nick
  if (%publicSetting == on && #) { %out = $iif(%prefix == @,!.msg #,!.notice $nick) }
  if (%publicSetting == off) { %out = !.notice $nick }
  if (%publicSetting == voice) { %out = $iif($nick isvoice # || $nick ishop # || $nick isop #,$iif(%prefix == @,!.msg #,!.notice $nick),!.notice $nick) }
  if (%publicSetting == half) { %out = $iif($nick ishop # || $nick isop #,$iif(%prefix == @,!.msg #,.notice $nick),!.notice $nick) }
  hadd $$$(%command) out %out

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

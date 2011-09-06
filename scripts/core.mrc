alias versions.core return 4.0

on *:START:         core $_START_
on *:CONNECT:       core $_CONNECT_
on *:QUIT:          core $_QUIT_ $nick
on *:DISCONNECT:    core $_DISCONNECT_
on *:JOIN:*:        if (# == $dev && $nick == $me) ofree $$$(core).channels
on *:PART:*:        core $_PART_ # $nick
on *:KICK:*:        core $_PART_ # $me
on *:MODE:*:        core $_MODE_ #
on *:SERVERMODE:*:  core $_SERVERMODE_ #
on *:INVITE:*:      core $_INVITE_ # $nick
ctcp *:*:*:         if ($isAdmin($nick)) ctcpcommand $nick $1-
raw 433:*:          core $_NICKINUSE_ $2
raw 366:*:          core $_JOIN_ $2
raw 471:*:          core $_NOJOIN_ $2-
raw 473:*:          core $_NOJOIN_ $2-
raw 474:*:          core $_NOJOIN_ $2-
raw 475:*:          core $_NOJOIN_ $2-
raw 477:*:          core $_NOJOIN_ $2-
raw 352:*:          haltdef
raw 315:*:          haltdef


alias core {
  if $1 {
    goto $1

    :1 _START_
    ; initialize timer
    if (!$timer(Core)) {
      .timerCore 0 1 timerCall
    }
    var %bots $config(data, botNicks), %i 1
    while (%i <= $numtok(%bots, 59)) {
      oadd core botList $gettok(%bots, %i, 59) %i
      inc %i
    }
    _queue core
    return

    :2 _CONNECT_
    if (swiftirc isin $server) {
      noop $regex($me,/(\[.{2}\])|)/i)
      oadd core id $iif($regml(1),$v1,[00])
      ns id $config(conn, ircpass)
      join $config(conn, channel)
    }
    _queue core
    return

    :3 _QUIT_
    return

    :4 _DISCONNECT_
    return

    :5 _JOIN_
    if ($2 == $dev) {
      .msg $2 !!updatechans
      updatechans $me
    }
    if ($2 == $dev || $2 == #gerty) {
      ctcpcommand $me $_JOIN_ $2
      _queue .ctcp $!dev(%) $_JOIN_ $2 $nick($2, 0)
      opush core.jobs who $2
      haltdef
      return
    }

    var %min $iif($hget($2, users), $v1, 5)
    if ($userCount($2) >= %min) {
      ctcpcommand $me $_JOIN_ $2
      _queue .ctcp $!dev(%) $_JOIN_ $2 $userCount($2)
    }
    else {
      .msg $2 You do not have enough users to invite me. (07 $+ $userCount($2) $+ / $+ %min users.).
      part $2 Contact an admin in #gerty with any questions.
      _warning join channel $2 below user req
    }
    ; add who chan to jobs
    opush core.jobs who $2
    haltdef
    return

    :6 _PART_
    if ($3 == $me) {
      .ctcp $dev(%) $_PART_ $2
      var %index $oisin(core.channels. $+ $me, $2)
      if (%index) {
        hdel $oparse(core.channels. $+ $me) %index
        oreindex core.channels. $+ $me
      }
    }
    return

    :8 _SERVERMODE_
    return

    :9 _INVITE_
    ; register invite
    hadd -m $2 invitee $3

    ; is this channel allowed us?
    loadChannel $2
    if ($$$($2).blacklist == 1) {
      _queue core $_NOJOIN_ $2 Cannot join channel (blacklisted)
      if ($hget($2)) { hfree $2 }
      return
    }

    ; Find bot with least users.
    var %botlist $$$(core).channels
    var %bots $hget(%botlist, 0).item
    var %x 1, %bot, %channels, %EmptyBot $me, %EmptyChannels $chan(0)
    while (%x <= %bots) {
      %bot = $oparse(core.channels. $+ $hget(%botlist, %x).item)
      %channels = $hget(%bot, 0).item
      if (%channels < %EmptyChannels) {
        %EmptyChannels = %channels
        %EmptyBot = $hget(%botlist, %x).item
      }
      inc %x
    }
    if (%EmptyChannels < 30) {
      if (%EmptyBot == $me) join $2
      else .ctcp %EmptyBot $_RAW_ join $2
    }

    return

    :10 _NICKINUSE_
    var %nicks $config(data, botNicks)
    if ($numtok(%nicks, 59) < 2) _fatalError core out of nicks
    else nick $gettok(%nicks, $calc($findtok(%nicks, $2, 59) +1), 59)
    return

    :11 _NOJOIN_
    if ($hget($2)) {
      if ($hget($2, invitee)) {
        .msg $v1 Unable to join $2 $+ : $3-
      }
    }
    _warning join $2-
    halt

    :newserver
    if ($2) server -m $2
    else server -m irc.swiftirc.net
    return
  }
  echo -s {{CORE}}

  echo -s checking main local bot status
  var %mainBot $false, %x 1
  if ($server) {
    while (%x <= $scon(0)) {
      if ($scon(%x).server && $scon(%x) != $cid) break
      if ($scon(%x) == $cid) {
        %mainBot = $true
        break
      }
      inc %x
    }
  }
  echo -s - bot status verified ( $+ %mainBot $+ )

  if (%mainBot) {
    if (!$sock(findupdate)) {
      echo -s checking for updates
      if ($versions.updater >= 4) _queue _findUpdate
      else _fatalError core updater not initialized.
      echo -s - updater initialized, waiting for response.
    }

    echo -s checking database
    _queue $!iif($hget(row),hfree row)
    if (!$sqlite_is_valid_conn(1)) {
      var %db $sqlite_open(gerty.db)
      ; check connection to database opened
      if (!%db) _fatalError core Database not connected.
      ; check database is readable
      if ($sqlite_fetch_row($sqlite_query(1, SELECT rsn FROM users WHERE rsn='P_Gertrude';), row, $SQLITE_ASSOC)) if ($hget(row, rsn) != P_Gertrude) _fatalError core Database not readable
      ;else _fatalError core Database not readable
      echo -s - database OK
    }
    else {
      ; check database is readable
      if ($sqlite_fetch_row($sqlite_query(1, SELECT rsn FROM users WHERE rsn='P_Gertrude';), row, $SQLITE_ASSOC)) if ($hget(row, rsn) != P_Gertrude) _fatalError core Database not readable
      ;else _fatalError core Database not readable
      echo -s - database OK
    }

    echo -s checking price date
    if ($versions.aliases >= 4 && $versions.callbacks >= 4) {
      _queue noop $!getSource(checkForOfflineGeUpdate, $thread , $parser $+ lastupdate)
      echo -s - retrieving last update time.
    }
    else _fatalError core missing components: aliases.mrc and/or callbacks.mrc out of date.
  }

  echo -s loading admins
  tokenize 59 $admins
  var %x 1, %cond, %admins
  while (%x <= $0) {
    %cond = %cond OR rsn LIKE ' $+ $($ $+ %x, 2) $+ '
    inc %x
  }
  var %query $sqlite_query(1, SELECT rsn, fingerprint FROM users WHERE $right(%cond, -3) $+ ;)
  while ($sqlite_fetch_row(%query, row, $SQLITE_ASSOC)) {
    %admins = %admins $+ , $+ $hget(row, rsn) $+ ; $+ $hget(row, fingerprint)
  }
  if (%admins) _fatalError core no admins!
  else echo -s - admins Loaded

  linesep

  ; Connect to a server (specified by host.)
  if (!$server && $scon(0) == 1) {
    var %servers $config(conn, servers), %x 1
    if (!%servers) server irc.swiftirc.net
    if (%servers) {
      while (%x <= $numtok(%servers, 59)) {
        server $iif(swiftirc isin $gettok(%servers, %x, 59), $null, -m) $gettok(%servers, %x, 59)
        inc %x
      }
    }
  }

  if (%mainBot) oadd core main $cid
  oadd core admins $right(%admins, -1)

  while ($com(0)) .comclose $com(1)

  return
  :error
  _fatalError core unknown - $error
}

alias ctcpcommand {
  if ($2) {
    goto $2
    :5 _JOIN_
    if (!$oisin(core.channels. $+ $1, $3)) opush core.channels. $+ $1 $3
    return
    :6 _PART_
    return
    :9 _INVITE_
    return
    :12 _RAW_
    [ [ $2- ] ]
    return
    :13 _CHANLIST_
    var %chans $numtok($3, 44), %x 1
    while (%x <= %chans) {
      _queue ctcpcommand  $1 $_JOIN_ $gettok($3, %x, 44)
      inc %x
    }
    return
    :PING
    :VERSION
    :FINGER
    return
    :error
    _fatalError ctcpcommand $error
  }
}

alias _queue .timer 1 0 $1-
alias _fatalError {
  writeini $errFile $1 err $+ $calc($ini($errFile, $1, 0) +1) $time $date $2-
  if ($me ison $dev) .msg $dev err07 $1 issue: $2-
  linesep
  echo 4 -s err07 $1 issue: $2-
  linesep
  if ($error) reseterror
  halt
}
alias _warning if ($me ison $dev) .msg $dev err07 $1 issue: $2-

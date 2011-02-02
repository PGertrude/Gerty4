versions.aliases return 4.0

// constants
[             return $([,)
]             return $(],)
{             return $({,)
}             return $(},)
|             return $(|,)
%             return $(%,)
#             return $(#,)

_START_       return 1
_CONNECT_     return 2
_QUIT_        return 3
_DISCONNECT_  return 4
_JOIN_        return 5
_PART_        return 6
_MODE_        return 7
_SERVERMODE_  return 8
_INVITE_      return 9

_NICKINUSE_   return 10

_NOJOIN_      return 11

_RAW_         return 12
_CHANLIST_    return 13

// macros
dev           return $iif($1,$1) $+ #gertyDev
errFile       return $mircdirbotData\errors.ini
geFile        return $mircdirbotData\geupdate.txt
parser        return http://sselessar.net/Gerty/parser.php?type=


config        return $readini($mircdirbotData\config.ini, $1, $2)
admins        return P_Gertrude;Tiedemanns; $+ $config(data, admins)
main          return $iif($hget(core, main) == $cid, $true, $false)
thread        return $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))

// job handling - common to all servers!
timerCall {
  var %time $gmt
  if ($calc(%time % 10) == 0) { // get job from core.
    if ($isObj($oparse(core.jobs))) {
      if ($oshift(core.jobs)) [ [ $v1 ] ]
    }
    var %x 0
    while (%x <= $scon(0)) {
      if (!$scid($scon(%x)).server) {
        ; scon %x server ; commented out for session limit kills!
      }
      inc %x
    }
  }
}

// aliases
$ {
  return $oparse($1 $+ . $+ $prop)
}
isAdmin {
  if ( $1 isop $dev || $1 ishop $dev ) { return $true }
  if ($fingerprint($1) isin $hget(core, admins)) { return $true }
  return $false
}
isObj return $iif($left($1, 1) == ${ && $right($1, 1) == $}, $true, $false)
fingerprint {
  var %address $address($1, 3)
  var %ident $right($gettok(%address, 1, 64), -3)
  var %host $gettok($gettok(%address, 2, 64), $calc($numtok($gettok(%address, 2, 64), 46) - 1) $+ -, 46)
  return %ident $+ @ $+ %host
}
getSource {
  .comopen $2 msxml2.xmlhttp
  var %url = $3 $+ $iif($numtok($gettok($3, $numtok($3,47), 47), 63) == 1, ?, &) $+ DontCachePlease= $+ $ctime
  noop $com($2, open, 1, bstr, get, bstr, %url, bool, 0)
  noop $comcall($2, noop $!com($1, responseText, 2) $(|,) $1 $!com($1).result $(|,) .comclose $!1, send, 1)
}
loadChannel {
  var %sql SELECT * FROM channel WHERE `channel`LIKE" $+ $1 $+ ";
  var %query $sqlite_query(1, %sql)
  while ($sqlite_fetch_row(%query, row, $SQLITE_ASSOC)) {
    hadd -m $hget(row, channel) users $hget(row, users)
    hadd -m $hget(row, channel) blacklist $hget(row, blacklist)
    hadd -m $hget(row, channel) public $hget(row, public)
    hadd -m $hget(row, channel) site $hget(row, site)
    hadd -m $hget(row, channel) event $hget(row, event)
    var %objName $hget(row, channel), %values $hget(row, setting), %x 1
    tokenize 59 %values
    while (%x <= $0) {
      hadd -m %objName $gettok($($ $+ %x,2),1,58) $gettok($($ $+ %x,2),2,58)
      inc %x
    }
  }
  if ($hget(row)) { hfree row }
}
isBot {
  if ($istok(BanHammer Captain_Falcon ClanWars Client Coder Machine milk Minibar mIRC Noobs Q RSHelp RuneScape snoozles Spam SwiftIRC Unknown W Warcraft X Y ChanServ,$1,32)) { return $true }
  if ($regex($1,/^(\[..\]BigSister|(\[..\])?Gerty|(\[..\])?RuneScript|Vectra(\[..\])?|Impact(\[..\])?|(\[..\])?Carbon|iKick|Miley-Cyrus)$/Si)) { return $true }
  if ($regex($1,/^(Noobwegian|Onzichtbaar(\[..\])?|ChanStat(\-..)?|ChaosTrivia(\[..\])?|Overflow|PokemonBot(\[..\])?)$/Si)) { return $true }
  return $false
}
userCount {
  if ($left($1, 1) == $#) {
    var %x $nick($1, 0), %i 1, %n 0
    while (%i <= %x) {
      if (!$isBot($nick($1, %i))) inc %n
      inc %i
    }
    return %n
  }
}


// object references
oadd {
  if ($0 <= 1) { _fatalError oadd Insufficient Parameters. }
  if ($0 == 2) { tokenize 32 $1- $false }
  var %x 2, %p $1, %c
  while (%x < $calc($0 - 1)) {
    if ($isObj($hget(%p, $($ $+ %x, 2)))) %c = $hget(%p, $($ $+ %x, 2))
    else %c = $+(${, $thread, $})
    hadd -m %p $($ $+ %x, 2) %c
    %p = %c
    inc %x
  }
  hadd -m %p $($ $+ $calc($0 -1), 2) $($ $+ $0, 2) 
}
oget {
  if ($0 <= 1) { _fatalError oget Insufficient Parameters. }
  var %x 2, %p $1, %c $2
  while (%x <= $0) {
    %p = $hget(%p, %c)
    if ($isObj(%p)) {
      %c = $($ $+ $calc(%x + 1), 2)
      if (%x == $0) return %p
    }
    else return %p
    inc %x
  }
  return %c
}
ofree {
  if (!$hget($1)) { return }
  var %table $1, %x 1
  while ($hget($1, 0).item > 0) {
    if ($isObj($hget($1, $hget($1, 1).item))) _queue ofree $hget($1, $hget($1, 1).item)
    hdel $1 $hget($1, %x).item
  }
  hfree $1
}
odel {
  var %obj $oparse($1), %child $2
  ofree $hget(%obj, %child)
  hdel %obj %child
}
opush {
  var %val $2-
  var %obj $oparse($1)
  if (!%obj) {
    oadd $replace($1, $chr(46), $chr(32)) 1 1
    %obj = $oparse($1)
    ofree %obj 1
  }
  if (!$isObj(%obj)) _fatalError opush Object operation on non-object
  hadd -m %obj $calc($hget(%obj, 0).item +1) $2-
}
oreindex {
  var %obj $oparse($1)
  if (!$isObj(%obj)) return
  var %temp $+(${, $thread, $}), %x 1, %y 1, %count $hget(%obj, 0).item
  while (%x <= %count) {
    if ($hget(%obj, %y) != $null) {
      hadd -m %temp %x $v1
      hdel %obj %y
      inc %x
    }
    inc %y
    if (%y == 1000) break
  }
  var %x 1, %y 1
  while (%x <= $hget(%temp, 0).item) {
    hadd -m %obj %x $hget(%temp, %x)
    inc %x
  }
  if ($hget(%temp)) hfree %temp
}
oparse {
  if ($isObj($1) || $numtok($1, 46) == 1) { return $1 }
  tokenize 46 $1
  var %x 1, %string
  while (%x <= $0) {
    %string = %string , $($ $+ %x, 2)
    inc %x
  }
  %string = $right(%string, -2)
  return $oget( [ %string ] )
}
oshift {
  var %obj $oparse($1)
  if (!$isObj(%obj)) _fatalError oshift Object operation on non-object.
  if ($hget(%obj, 0).item == 0) return
  var %value $hget(%obj, 1)
  hdel %obj 1
  oreindex %obj
  return %value
}
oisin {
  var %obj $oparse($1)
  if (!$isObj(%obj)) return $false
  var %x 1
  while (%x <= $hget(%obj, 0).item) {
    if ($2 == $hget(%obj, $hget(%obj, %x).item)) return $hget(%obj, %x).item
    inc %x
  }
  return $false
}
ocreate {
  if ($0 == 1) hmake $1
  if ($0 == 2) {
    if ($hget($1, $2)) { return }
    var %thread $+(${, $thread, $})
    hadd -m $1 $2 %thread
    hmake %thread
  }
}

// databases
db_query {
  var %resultId $thread
  var %query $sqlite_query(1, $1)
  oadd %resultId rows $sqlite_num_rows(%query)
  ocreate %resultId results
  var %y 1
  while ($sqlite_fetch_row(%query, row, $SQLITE_ASSOC)) {
    var %x 1
    while (%x <= $hget(row, 0).item) {
      ocreate $$$(%resultId).results %y
      hadd $$$(%resultId).results. [ $+ [ %y ] ] $hget(row, %x).item $hget(row, $hget(row, %x).item)
      inc %x
    }
    inc %y
  }
  hfree row
  return %resultId
}

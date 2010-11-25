alias versions.updater return 4.0

alias _findUpdate !sockopen findupdate gerty.rsportugal.org 80
on *:sockopen:findupdate: {
  !if ($sockerr) {
    !echo -t [Update Connection Error]
    !halt
  }
  !sockwrite -n $sockname GET /updater/versions.mrc HTTP/1.1
  !sockwrite -n $sockname Host: gerty.rsportugal.org $+ $crlf $+ $crlf
}
on *:sockread:findupdate: {
  var %file temp $+ $r(0,99999) $+ .txt
  !if ($sockerr) {
    !echo -t [Update Connection Error]
    !halt
  }
  while ($sock($sockname).rq) {
    !sockread &versions
    !var %a $calc($bfind(&versions, 0, 13 10 13 10) + 4)
    !bwrite %file -1 -1 $bvar(&versions, %a, $bvar(&versions,0)).text
  }
  !.load -rs %file
  checkVersions
  _queue !.unload -rs %file
  _queue !.remove %file
}

alias _update {
  var %sock update $+ $r(0,99999)
  if ($exists($2)) .remove $2
  !sockopen %sock gerty.rsportugal.org 80
  !sockmark %sock $1-
}
on *:sockopen:update*: {
  !if ($sockerr) {
    !echo -t [Update Connection Error]
    !halt
  }
  !sockwrite -n $sockname GET /updater/ $+ $gettok($sock($sockname).mark, 2, 32) HTTP/1.1
  !sockwrite -n $sockname Host: gerty.rsportugal.org $+ $crlf $+ $crlf
}
on *:sockread:update*: {
  !if ($sockerr) {
    !echo -t [Update Connection Error]
    !halt
  }
  while ($sock($sockname).rq) {
    !sockread &file
    !bwrite $gettok($sock($sockname).mark, 2, 32) -1 -1 &file
  }
}
on *:sockclose:update*: {
  var %x 1
  while (%x <= 10) {
    write -dl1 $gettok($sock($sockname).mark, 2, 32)
    inc %x
  }
  .load $sock($sockname).mark
  echo -s $gettok($sock($sockname).mark, 2, 32) updated.
}

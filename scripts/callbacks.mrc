alias versions.callbacks return 4.0

alias checkForOfflineGeUpdate {
  if ($gettok($read($geFile,1),2,124) < $calc($1 - 1600)) {
    write -il1 $geFile $asctime($calc($1 - 1600), HH:nn:ss) $+ $| $+ $calc($1 - 1600) $+ $| $+ $ord($asctime($calc($1 - 1600), dd)) $asctime($calc($1 - 1600), mmm)
    ;downloadSitePrices
  }
  return
  :error
  _fatalError checkForOfflineGeUpdate unknown - $error
}

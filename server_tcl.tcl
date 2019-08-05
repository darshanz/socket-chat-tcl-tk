namespace eval ns1 {
        global connected_clients
}

set svcPort 9999

proc sendToAllConnectedClients {sock msg client} {
      #send message to all  connected_clients
      foreach item [dict keys $ns1::connected_clients] {
        set connected_socket [dict get $ns1::connected_clients $item]
        puts $connected_socket "$client : $msg"
      }
}

proc  svcHandler {sock client} {
  set msg [gets $sock]
    if {[eof $sock]} {
      #Notify all clients when a client is disconnected
       dict unset ns1::connected_clients "$client"
       sendToAllConnectedClients $sock "\n$client Disconnected." $client
       close $sock
    } else {
      if { [string length $msg] > 0} {
        sendToAllConnectedClients $sock $msg $client
      }
    }
}


proc accept {sock addr port} {
  set client "${addr}:$port"
  fileevent $sock readable [list svcHandler $sock $client]
  dict set ns1::connected_clients "$addr:$port" $sock
  puts "Accept from [fconfigure $sock -peername]"
  fconfigure $sock -buffering line -blocking 0
  #connected clients

  puts $sock "$addr:$port"
  #Notify all clients about the connection of this client
  foreach item [dict keys $ns1::connected_clients] {
    if { $item != "$addr:$port" } {
       set connected_socket [dict get $ns1::connected_clients $item]
       puts $connected_socket "\n$item Connected."

    }
  }
  puts "Accepted connection from $addr at [exec date]"
}

set ns1:connected_clients [dict create]
socket -server accept $svcPort
vwait events

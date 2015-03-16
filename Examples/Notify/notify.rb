#!/bin/ruby

require 'socket'

# Send notification
UDPSock = UDPSocket.new
UDPSock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
UDPSock.send 'ping', 0, '<broadcast>', 50001
UDPSock.close
puts 'ping'

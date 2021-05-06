# lua rtpengine client 
[rtpengine](https://github.com/sipwise/rtpengine) since version 9.1 can handle requests made to it via HTTP, HTTPS, or WebSocket (WS or WSS) connections. 

This has an advantages over UDP with his possible packet loss or MTU issues especially for ennormously big SDP coming from WebRTC compatible browsers. 

This script is a simple lua rtpengine client. Currently works over websocket, but could be easily swtiched to utilise http as a transport protocol. [lua-http](https://github.com/daurnimator/lua-http) lib provides underlying transport layer.

The basic functionality (offer/answer/delete) is tested with [Kamailio](https://github.com/kamailio/kamailio) sip proxy.

## Update

Since Kamailio 5.5.0 (released in May 2021) rtpengine mod can use websockets as a transport by using mod [LWSC](https://kamailio.org/docs/modules/5.5.x/modules/lwsc.html)

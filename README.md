# WebSocket-Echo-Client-iOS
A demonstration of an echo client using a websocket in Objective-C with a Swift WebSocket class from [SocketIO](https://github.com/socketio/socket.io-client-swift).

In UTF-8 mode, if the text field is empty you send a PING-PONG, otherwise you sned the text you specify. If you switch to binary mode the app will send the grayscale intensity values of frames of the famous [The Horse in Motion](https://en.wikipedia.org/wiki/Eadweard_Muybridge). You need the included python echo server because the websocket.org server doesn't handle binary messages. 


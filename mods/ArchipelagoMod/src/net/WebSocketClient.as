package net {
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.SecureSocket;
    import flash.net.Socket;
    import flash.utils.ByteArray;
    import flash.utils.Endian;

    import Bezel.Logger;

    /**
     * Minimal WebSocket client (RFC 6455) on top of flash.net.Socket.
     *
     * Usage:
     *   var ws:WebSocketClient = new WebSocketClient(logger);
     *   ws.onOpen    = function():void { ... }
     *   ws.onMessage = function(text:String):void { ... }
     *   ws.onError   = function(msg:String):void { ... }
     *   ws.onClose   = function():void { ... }
     *   ws.connect("archipelago.gg", 56730);
     */
    public class WebSocketClient {

        private static const LOG:String = "WebSocket";

        private static const STATE_TCP:int       = 0; // TCP connecting
        private static const STATE_HANDSHAKE:int = 1; // HTTP upgrade in progress
        private static const STATE_OPEN:int      = 2; // WebSocket open
        private static const STATE_CLOSED:int    = 3;

        // WebSocket opcodes
        private static const OP_TEXT:int  = 1;
        private static const OP_CLOSE:int = 8;
        private static const OP_PING:int  = 9;
        private static const OP_PONG:int  = 10;

        private var _host:String;
        private var _port:int;
        private var _socket:Socket;
        private var _logger:Logger;
        private var _state:int = STATE_CLOSED;
        private var _buf:ByteArray; // raw receive buffer

        // Public callbacks — set before calling connect()
        public var onOpen:Function;    // ():void
        public var onMessage:Function; // (text:String):void
        public var onError:Function;   // (msg:String):void
        public var onClose:Function;   // ():void

        public var isConnecting:Boolean = false;

        public function WebSocketClient(logger:Logger) {
            _logger = logger;
            _buf = new ByteArray();
            _buf.endian = Endian.BIG_ENDIAN;
        }

        // -----------------------------------------------------------------------
        // Public API

        /**
         * @param secure  true = wss:// (TLS), false = ws:// (plain)
         */
        public function connect(host:String, port:int, secure:Boolean = false):void {            
            _host = host;
            _port = port;
            _state = STATE_TCP;
            _buf.length = 0;

            
            _socket = secure ? new SecureSocket() : new Socket();
            _socket.endian = Endian.BIG_ENDIAN;
            _socket.addEventListener(Event.CONNECT,                     onTcpConnect,    false, 0, false);
            _socket.addEventListener(ProgressEvent.SOCKET_DATA,         onSocketData,    false, 0, false);
            _socket.addEventListener(IOErrorEvent.IO_ERROR,             onIOError,       false, 0, false);
            _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, false);
            _socket.addEventListener(Event.CLOSE,                       onSocketClose,   false, 0, false);

            _logger.log(LOG, "Connecting to " + host + ":" + port);
            try {
                _socket.connect(host, port);
            } catch (e:Error) {
                fail("connect() threw: " + e.message);
            }
        }

        /** Send a UTF-8 text frame. */
        public function send(text:String):void {
            if (_state != STATE_OPEN || _socket == null) return;
            var payload:ByteArray = new ByteArray();
            payload.writeUTFBytes(text);
            writeFrame(OP_TEXT, payload);
        }

        public function disconnect():void {
            cleanup();
            if (onClose != null) onClose();
        }

        // -----------------------------------------------------------------------
        // Socket event handlers

        private function onTcpConnect(e:Event):void {
            _logger.log(LOG, "TCP connected — sending HTTP upgrade");
            _state = STATE_HANDSHAKE;
            var req:String =
                "GET / HTTP/1.1\r\n" +
                "Host: " + _host + ":" + _port + "\r\n" +
                "Upgrade: websocket\r\n" +
                "Connection: Upgrade\r\n" +
                "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n" +
                "Sec-WebSocket-Version: 13\r\n" +
                "\r\n";
            _socket.writeUTFBytes(req);
            _socket.flush();
        }

        private function onSocketData(e:ProgressEvent):void {
            _socket.readBytes(_buf, _buf.length, _socket.bytesAvailable);

            if (_state == STATE_HANDSHAKE) {
                processHandshake();
            } else if (_state == STATE_OPEN) {
                processFrames();
            }
        }

        private function onIOError(e:IOErrorEvent):void {
            fail("IO error: " + e.text);
        }

        private function onSecurityError(e:SecurityErrorEvent):void {
            fail("Security error: " + e.text);
        }

        private function onSocketClose(e:Event):void {
            _logger.log(LOG, "Socket closed by remote");
            _state = STATE_CLOSED;
            if (onClose != null) onClose();
        }

        // -----------------------------------------------------------------------
        // HTTP handshake

        private function processHandshake():void {
            // Look for end of HTTP headers
            _buf.position = 0;
            var raw:String = _buf.readUTFBytes(_buf.length);
            var headerEnd:int = raw.indexOf("\r\n\r\n");
            if (headerEnd == -1) return; // incomplete — wait for more data

            var statusLine:String = raw.substring(0, raw.indexOf("\r\n"));
            _logger.log(LOG, "HTTP response: " + statusLine);

            if (raw.indexOf("101") == -1) {
                fail("Handshake rejected — " + statusLine);
                return;
            }

            // Strip headers from buffer; keep any data that arrived alongside them
            consume(headerEnd + 4);
            _state = STATE_OPEN;
            _logger.log(LOG, "WebSocket open");
            if (onOpen != null) onOpen();
            if (_buf.length > 0) processFrames();
        }

        // -----------------------------------------------------------------------
        // WebSocket frame parser

        private function processFrames():void {
            while (tryReadFrame()) { }
        }

        /**
         * Try to parse one complete frame from _buf.
         * Returns true if a frame was consumed (caller should loop).
         */
        private function tryReadFrame():Boolean {
            if (_buf.length < 2) return false;

            var b0:int = _buf[0];
            var b1:int = _buf[1];

            // var fin:Boolean = (b0 & 0x80) != 0; // unused for now — no fragmentation
            var opcode:int     = b0 & 0x0F;
            var masked:Boolean = (b1 & 0x80) != 0;
            var lenByte:int    = b1 & 0x7F;

            var pos:int = 2;
            var payLen:int;

            if (lenByte <= 125) {
                payLen = lenByte;
            } else if (lenByte == 126) {
                if (_buf.length < pos + 2) return false;
                payLen = (_buf[pos] << 8) | _buf[pos + 1];
                pos += 2;
            } else {
                // 127 — 64-bit length; skip high 32 bits, use low 32 bits
                if (_buf.length < pos + 8) return false;
                pos += 4;
                payLen = ((_buf[pos] << 24) | (_buf[pos+1] << 16) | (_buf[pos+2] << 8) | _buf[pos+3]) >>> 0;
                pos += 4;
            }

            var maskOffset:int = pos;
            if (masked) pos += 4;
            var headerSize:int = pos;

            if (_buf.length < headerSize + payLen) return false; // wait for rest

            // Decode payload
            var payload:ByteArray = new ByteArray();
            for (var i:int = 0; i < payLen; i++) {
                var b:int = _buf[headerSize + i];
                if (masked) b ^= _buf[maskOffset + (i % 4)];
                payload.writeByte(b);
            }

            consume(headerSize + payLen);
            dispatchFrame(opcode, payload);
            return true;
        }

        private function dispatchFrame(opcode:int, payload:ByteArray):void {
            switch (opcode) {
                case OP_TEXT:
                    payload.position = 0;
                    var text:String = payload.readUTFBytes(payload.length);
                    _logger.log(LOG, "Message (" + payload.length + "b): " + text.substring(0, 120));
                    if (onMessage != null) onMessage(text);
                    break;

                case OP_CLOSE:
                    _logger.log(LOG, "Close frame received");
                    cleanup();
                    if (onClose != null) onClose();
                    break;

                case OP_PING:
                    writeFrame(OP_PONG, payload); // respond to keepalive
                    break;

                default:
                    _logger.log(LOG, "Ignoring frame opcode=" + opcode);
            }
        }

        // -----------------------------------------------------------------------
        // WebSocket frame writer — client frames MUST be masked (RFC 6455 §5.3)

        private function writeFrame(opcode:int, payload:ByteArray):void {
            if (_socket == null || !_socket.connected) return;

            var payLen:int = payload.length;
            _socket.writeByte(0x80 | opcode); // FIN=1

            // Generate a random 4-byte masking key
            var mask:Array = [
                int(Math.random() * 256), int(Math.random() * 256),
                int(Math.random() * 256), int(Math.random() * 256)
            ];

            if (payLen <= 125) {
                _socket.writeByte(0x80 | payLen);
            } else if (payLen <= 65535) {
                _socket.writeByte(0x80 | 126);
                _socket.writeShort(payLen);
            } else {
                _socket.writeByte(0x80 | 127);
                _socket.writeUnsignedInt(0);
                _socket.writeUnsignedInt(payLen);
            }

            for (var i:int = 0; i < 4; i++) _socket.writeByte(mask[i]);

            payload.position = 0;
            for (var j:int = 0; j < payLen; j++) {
                _socket.writeByte(payload.readUnsignedByte() ^ mask[j % 4]);
            }

            _socket.flush();
        }

        // -----------------------------------------------------------------------
        // Helpers

        /** Remove the first n bytes from _buf, keeping the remainder. */
        private function consume(n:int):void {
            var remaining:int = _buf.length - n;
            if (remaining <= 0) {
                _buf.length = 0;
                return;
            }
            var tmp:ByteArray = new ByteArray();
            tmp.endian = Endian.BIG_ENDIAN;
            _buf.position = n;
            _buf.readBytes(tmp, 0, remaining);
            _buf.length = 0;
            tmp.position = 0;
            tmp.readBytes(_buf, 0, remaining);
        }

        private function fail(msg:String):void {
            _logger.log(LOG, "FAIL: " + msg);
            cleanup();
            if (onError != null) onError(msg);
        }

        private function cleanup():void {
            _state = STATE_CLOSED;
            if (_socket == null) return;
            _socket.removeEventListener(Event.CONNECT,                     onTcpConnect);
            _socket.removeEventListener(ProgressEvent.SOCKET_DATA,         onSocketData);
            _socket.removeEventListener(IOErrorEvent.IO_ERROR,             onIOError);
            _socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
            _socket.removeEventListener(Event.CLOSE,                       onSocketClose);
            if (_socket.connected) {
                try { _socket.close(); } catch (e:Error) { }
            }
            _socket = null;
        }
    }
}

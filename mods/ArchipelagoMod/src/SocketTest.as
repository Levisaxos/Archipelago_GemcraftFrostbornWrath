package {
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.Socket;

    import Bezel.Logger;

    /**
     * One-shot TCP socket connectivity test.
     *
     * Call run() once; the result callback fires with (true, message) on
     * success or (false, message) on any failure.  The socket is closed and
     * cleaned up immediately after the outcome is known.
     */
    public class SocketTest {

        private static const LOG_TAG:String = "SocketTest";

        private var _host:String;
        private var _port:int;
        private var _socket:Socket;
        private var _logger:Logger;
        private var _onResult:Function; // function(success:Boolean, msg:String):void

        public function SocketTest(host:String, port:int, logger:Logger, onResult:Function) {
            _host     = host;
            _port     = port;
            _logger   = logger;
            _onResult = onResult;
        }

        public function run():void {
            _logger.log(LOG_TAG, "Connecting to " + _host + ":" + _port + " ...");
            try {
                _socket = new Socket();
                _socket.addEventListener(Event.CONNECT,                     onConnect,       false, 0, true);
                _socket.addEventListener(IOErrorEvent.IO_ERROR,             onIOError,       false, 0, true);
                _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, true);
                _socket.connect(_host, _port);
            } catch (err:Error) {
                _logger.log(LOG_TAG, "Exception: " + err.message);
                deliver(false, "Socket threw: " + err.message);
            }
        }

        // -----------------------------------------------------------------------

        private function onConnect(e:Event):void {
            _logger.log(LOG_TAG, "Connected OK to " + _host + ":" + _port);
            deliver(true, "TCP OK: " + _host + ":" + _port);
        }

        private function onIOError(e:IOErrorEvent):void {
            _logger.log(LOG_TAG, "IO error: " + e.text);
            deliver(false, "TCP failed: " + e.text);
        }

        private function onSecurityError(e:SecurityErrorEvent):void {
            _logger.log(LOG_TAG, "Security error: " + e.text);
            deliver(false, "TCP security: " + e.text);
        }

        // -----------------------------------------------------------------------

        private function deliver(success:Boolean, msg:String):void {
            cleanup();
            if (_onResult != null) _onResult(success, msg);
        }

        private function cleanup():void {
            if (_socket == null) return;
            _socket.removeEventListener(Event.CONNECT,                     onConnect);
            _socket.removeEventListener(IOErrorEvent.IO_ERROR,             onIOError);
            _socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
            if (_socket.connected) {
                try { _socket.close(); } catch (err:Error) { }
            }
            _socket = null;
        }
    }
}

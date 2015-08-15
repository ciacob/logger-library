package ro.ciacob.desktop.debug {
	import flash.filesystem.File;

	public final class LoggerConfig {
		
		public static const CONSOLE : int = 1;
		
		public static const FILE : int = 2;
		
		// Not yet supported
		public static const HTTP : int = 4;

		// Not yet supported
		public static const LOCAL_CONNECTION : int = 8;

		private var _destination:int;
		private var _logsDir:File;
		private var _enabled:Boolean;

		public function LoggerConfig(enabled:Boolean = true, destination:int =
			-1, logsDir:File = null) {
			_enabled = enabled;
			if (destination == -1) {
				destination = (CONSOLE | FILE);
			}
			_destination = destination;
			_logsDir = logsDir;
		}

		public function get destination():int {
			return _destination;
		}

		public function get enabled():Boolean {
			return _enabled;
		}

		public function get logsDir():File {
			return _logsDir;
		}



	}
}

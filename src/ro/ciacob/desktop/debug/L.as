package ro.ciacob.desktop.debug {
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	/**
	 * Provides shortcuts for accessing the `Logger` class functionality.
	 * Less typing means less time to waste while debugging.
	 *
	 * Note:
	 * When accessed through the `L` class, the `Logger` behaves as if it
	 * was a Singleton, and uses default configuration. If you need to create and 
	 * maintain several Logger instances, or configure the logger, do it directly, i.e.:
	 * <code>var myLogger : Logger = new Logger</code>.
	 */
	public class L {

		private static const DEFAULT_CONFIG_OPTIONS:LoggerConfig = new LoggerConfig(true, LoggerConfig.FILE);
		
		private static var _loggerInstance:Logger;
		private static var _configuration:LoggerConfig = DEFAULT_CONFIG_OPTIONS;

		private static function get _Logger():Logger {
			if (_loggerInstance == null) {
				_loggerInstance = new Logger(_configuration);
				_loggerInstance.printHeader();
				_loggerInstance.printDashes();
				_loggerInstance.printVSpace();
				_loggerInstance.printCapabilities();
				_loggerInstance.printVSpace(4);
			}
			return _loggerInstance;
		}

		/**
		 * PRINT (stringified arguments separated by space)
		 * 
		 */
		public static function p (... args) : void {
			_Logger.print.apply(_Logger, args);
		}
		
		/**
		 * _ (for _underlining)
		 * 
		 */
		public static function _(chars : int = -1) : void {
			_Logger.printDashes();
		}
		
		/**
		 * v (VERTICAL space, i.e., empty lines)
		 * 
		 */
		public static function v(lines : int = 1):void {
			_Logger.printVSpace(lines);
		}
		
		/**
		 * Disables any logger activity past this point
		 */
		public static function off():void {
			var cfg : LoggerConfig = new LoggerConfig (false);
			_Logger.applyConfiguration(cfg);
		}
		
		/**
		 * (Re)enables any logger activity from this point
		 */
		public static function on():void {
			var cfg : LoggerConfig = new LoggerConfig (true, DEFAULT_CONFIG_OPTIONS.destination, DEFAULT_CONFIG_OPTIONS.logsDir);
			_Logger.applyConfiguration(cfg);
		}
	}
}

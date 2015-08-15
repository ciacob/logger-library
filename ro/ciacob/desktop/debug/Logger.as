/*//////////////////////////////////////////////////////////////////*/
/*                                                                  */
/*   Unless stated otherwise, all work presented in this file is    */
/*   the intelectual property of:                                   */
/*   @author Claudius Iacob <claudius.iacob@gmail.com>              */
/*                                                                  */
/*   All rights reserved. Obtain written permission from the author */
/*   before using/reusing/adapting this code in any way.            */
/*                                                                  */
/*//////////////////////////////////////////////////////////////////*/

package ro.ciacob.desktop.debug {

	import flash.filesystem.File;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.StaticText;
	
	import ro.ciacob.desktop.io.TextDiskWritter;
	import ro.ciacob.utils.ConstantUtils;
	import ro.ciacob.utils.Descriptor;
	import ro.ciacob.utils.Files;
	import ro.ciacob.utils.Strings;
	import ro.ciacob.utils.Time;
	import ro.ciacob.utils.constants.CommonStrings;

	public class Logger {
		private static const CANNOT_CREATE_LOG_DIR : String = 'This directory does not exist, and an error was thrown while attempting to create it:';
		private static const BIG_VSPACE : int = 4;
		private static const CAPABILITIES_HEADER : String = 'CAPABILITIES';
		private static const DEBUG_FILE_NAME : String = 'debug';
		private static const DESCRIPTOR_HOME : String = 'META-INF/AIR';
		private static const HEADER : String = 'LOGGING SESSION STARTED for application %s on %s. Wrapping at %d chars.';
		private static const LOGFILE_HOME : String = 'Logs/';
		private static const LOGFILE_NAME_TEMPLATE : String = '%s Log %s.txt';
		private static const MAX_COLS_NUM : int = 120;
		private static const PADDING_COLS_NUM : int = 4;
		private static const SMALL_VSPACE : int = 2;
		private static const STAMP_ALL : int = 2;
		private static const STAMP_FIRST : int = 1;
		private static const STAMP_NONE : int = 0;

		public function Logger (configuration : LoggerConfig) {
			var isAir : Boolean = (Capabilities.playerType == "Desktop");
			if (!isAir) {
				throw('Logger: this class is meant to be used with AIR desktop applications only. Exiting.');
			}
			_isDebugMode = Capabilities.isDebugger;
			_isADL = (isAir && _isDebugMode);

			var appDir : File = new File (File.applicationDirectory.url);
			var descriptorDir : File = null;
			if (appDir && appDir.parent) {
				descriptorDir = appDir.parent.resolvePath (DESCRIPTOR_HOME);
			}

			if (descriptorDir && descriptorDir.exists) {
				var debugFile : File = descriptorDir.resolvePath (DEBUG_FILE_NAME);
				if (debugFile.exists) {
					_isRTEDisplayOn = true;
				}
			}
			_defLogFileDir = File.applicationStorageDirectory.resolvePath (LOGFILE_HOME);
			_appName = Descriptor.getAppSignature ().concat (CommonStrings.SPACE, Descriptor.
				getAppVersion (true));
			_setConfig (configuration);
		}

		private var _appName : String;
		private var _defLogFileDir : File;
		private var _isADL : Boolean;
		private var _isDebugMode : Boolean;
		private var _isEnabled : Boolean;
		private var _isRTEDisplayOn : Boolean;
		private var _logFile : File;
		private var _logFileDir : File;
		private var _paddBig : String;
		private var _paddSmall : String;
		private var _useFile : Boolean;
		private var _useTrace : Boolean;

		private var _writer : TextDiskWritter;

		public function applyConfiguration (configuration : LoggerConfig) : void {
			_setConfig (configuration);
		}

		public function print (... args) : void {
			if (!_isEnabled) {
				return;
			}
			var text : String = args.join (' ');
			_renderText (text, STAMP_FIRST);
		}

		public function printCapabilities () : void {
			_renderText (CAPABILITIES_HEADER, STAMP_FIRST);
			printDashes (CAPABILITIES_HEADER.length);
			var allNames : Array = ConstantUtils.getAllNames (Capabilities, true);
			for (var i : int = 0; i < allNames.length; i++) {
				var name : String = (allNames[i] as String);
				var value : Object = (Capabilities[name] as Object);
				var line : String = (name.concat (CommonStrings.COLON_SPACE, (value !=
					null) ? value.toString () : CommonStrings.NULL));
				_renderText (line);
			}
		}

		public function printDashes (length : int = -1) : void {
			if (length == -1) {
				length = (MAX_COLS_NUM - _bigPadding.length);
			}
			var line : String = Strings.repeatString (CommonStrings.DASH, length);
			_renderText (line, STAMP_NONE);
		}

		public function printHeader () : void {
			if (!_isEnabled) {
				return;
			}
			var banner : String = HEADER
				.replace (CommonStrings.$S, _appName)
				.replace (CommonStrings.$S, Time.toFormat (Time.now, Time.TIMESTAMP_DEBUG_HEADER))
				.replace (CommonStrings.$D, MAX_COLS_NUM);
			_renderText (banner, STAMP_FIRST);
		}

		public function printVSpace (numLines : int = 1) : void {
			numLines = Math.max (0, numLines - 1);
			var vSpace : String = Strings.repeatString (CommonStrings.NEW_LINE, numLines);
			_renderText (vSpace, STAMP_NONE);
		}

		private function get _bigPadding () : String {
			if (_paddBig == null) {
				_paddBig = Strings.repeatString (CommonStrings.SPACE, Time.TIMESTAMP_DEBUG_INLINE.
					length + PADDING_COLS_NUM);
			}
			return _paddBig;
		}

		private function _outputExplicitLine (text : String, stampStyle : int = 0) : void {
			text = Strings.trim (text);
			var timeStamp : String;
			var mustStamp : Boolean;
			if (stampStyle != STAMP_NONE) {
				timeStamp = Time.toFormat (Time.now, Time.TIMESTAMP_DEBUG_INLINE);
				timeStamp = timeStamp.concat (_smallPadding);
			}
			var lines : Array;
			var effectiveMaxCols : int = (MAX_COLS_NUM - Time.TIMESTAMP_DEBUG_INLINE.
				length - PADDING_COLS_NUM);
			if (text.length > effectiveMaxCols) {
				lines = Strings.wrap (text, effectiveMaxCols);
				for (var i : int = 0; i < lines.length; i++) {
					mustStamp = false;
					if (i == 0 && stampStyle == STAMP_FIRST) {
						mustStamp = true;
					} else {
						mustStamp = (stampStyle == STAMP_ALL);
					}
					var line : String = (lines[i] as String);
//					line = Strings.removeNewLines (line);
					if (mustStamp) {
						line = timeStamp.concat (line);
					} else {
						line = _bigPadding.concat (line);
					}
					lines[i] = line;
				}
			} else {
				mustStamp = (stampStyle != STAMP_NONE);
				lines = [((mustStamp ? timeStamp : _bigPadding) as String).concat (text)];
			}
			_outputImplicitLines (lines);
		}

		private function _outputImplicitLines (lines : Array) : void {
			for (var i : int = 0; i < lines.length; i++) {
				var line : String = (lines[i] as String);
				// `trace()` adds "per se" a trailing new line character, so we only need to
				// explicitely add one when printing to file
				if (_useTrace) {
					trace (line);
				}
				if (_useFile) {
					line = line.concat (CommonStrings.NEW_LINE);
					_writer.write (line, _logFile, true);
				}
			}
		}

		/**
		 * The method `_renderText()` calls into `_outputExplicitLine()`, which calls into
		 * `_outputImplicitLines()`.
		 *
		 * The logic behind all that is: the text coming from the client code can, naturally, contain
		 * line breaks, which must be honored. However, each of them must fit into the wrapping
		 * limit, and must properly reserve space for the stamp (if requested).
		 *
		 * Therefore, we first split the text on the explicit (client code) lines, and then pass each
		 * of this lines through our wrapping and padding mechanism.
		 * 
		 * @param text
		 * @param stampStyle
		 */
		private function _renderText (text : String, stampStyle : int = 0) : void {
			text = text.replace (/[\r\n]{1,}/g, '\n');
			var implicitLines : Array = text.split ('\n');
			for (var i : int = 0; i < implicitLines.length; i++) {
				var implicitLine : String = (implicitLines[i] as String);
				_outputExplicitLine (implicitLine, (i == 0) ? stampStyle : STAMP_NONE);
			}
		}

		private function _setConfig (configuration : LoggerConfig) : void {
			_isEnabled = configuration.enabled;
			if (!_isEnabled) {
				return;
			}
			_useTrace = (_isDebugMode && ((configuration.destination & LoggerConfig.
				CONSOLE) == LoggerConfig.CONSOLE));
			_useFile = ((_isDebugMode || _isRTEDisplayOn) && ((configuration.destination &
				LoggerConfig.FILE) == LoggerConfig.FILE));
			var givenLogsDir : File = configuration.logsDir;
			
			if (givenLogsDir != null && !givenLogsDir.exists) {
				try {
					givenLogsDir.createDirectory()
				} catch (e : Error) {
					trace(CANNOT_CREATE_LOG_DIR, givenLogsDir.nativePath, e.message);
					givenLogsDir = null;
				}
			}
			_logFileDir = ((givenLogsDir != null && givenLogsDir.exists) ? givenLogsDir :
				_defLogFileDir);
			if (_useFile) {
				_writer = new TextDiskWritter;
				var fileName : String = LOGFILE_NAME_TEMPLATE.replace (CommonStrings.
					$S, _appName).replace (CommonStrings.$S, Time.toFormat (Time.now,
					Time.TIMESTAMP_FILENAME));
				_logFile = _logFileDir.resolvePath (fileName);
			} else {
				_writer = null;
				_logFile = null;
			}
		}

		private function get _smallPadding () : String {
			if (_paddSmall == null) {
				_paddSmall = Strings.repeatString (CommonStrings.SPACE, PADDING_COLS_NUM);
			}
			return _paddSmall;
		}
	}
}

# logger-library
General purpose logger library for AIR-based AS3/Flex projects. Currently logs to the console and/or a file.
Also has built-in formatting and helper tools, such as the ability to hard-wrap the output, draw separators,
or print information about the Flash PLayer VM currently executing the code. When writing to disc, older log
messages can be archived or replaced. 


### Usage
Depending on your needs, you can use the library in two ways:
1. Statically, via the `L` class (less code, but less flexible):

```ActionScript
L.p ('Lorem Ipsum dolor sit');
```

2. Dynamically, by configuring and initializing the logger first (more verbose, but lets you choose output type):

```ActionScript
const enabled : Boolean = true;
const mode : int = LoggerConfig.CONSOLE | LoggerConfig.FILE;
const customDir : File = File.desktopDirectory;
const config : LoggerConfig = new LoggerConfig (enabled, mode, customDir);
var logger :  Logger = new Logger(config);
logger.print ('Lorem Ipsum dolor sit');
```

Note that you can do in-flight reconfiguration via, e.g.:
```ActionScript
logger.applyConfiguration (otherConfig);
```

Check class `Logger` for all available API.

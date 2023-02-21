# Running log stream from Swift

This is an example to show how to execute a macOS command from Swift and async pipe its stdout for processing in Swift.

I have chosen *log stream* as the appropriate command, see 

 - `man 1 log` or 
 - `log stream --help`

## Usage:

```
 logdreamer [--timeout <timeout>] [--dump] [--save <save>]
            [--pred <predicate> ...] [--proc <process> ...]
            [--type <type> ...] [--level <level>] 
```

## Options:
      -t, --timeout <timeout> Terminate streaming after timeout has elapsed,
                              default 2s
                              Passed unchecked to log command. (default: 2s)
      --dump, --dump-messages Dump log messages as JSON objects
                               - to stdout or
                               - to file according to option --save.
      -s, --save <save>       Save stats and log messages to the specified
                              directory.
                              Statistics as `logstats-<timestamp>.csv`
                              Log messages as `logmsgs-<timestamp>.json`
      -pred, --predicate <pred>
                              Predicates to filter
                              Passed unchecked to log command.
      --proc --process <proc> Only log messages from the specified process
                              Passed unchecked to log command.
      --type <type>           Limit streaming to a given event type (activity, log
                              or trace).
                              Default is all.
                              Passed unchecked to log command.
      --level <level>         Include events at, and below, the given level.
                              Default is `default`. Expand with `info` or with
                              `debug'.
                              Passed unchecked to log command.
      --version               Show the version.
      -h, --help              Show help information.

## Discussion

Running `logdreamer` without any options will start streaming for 2 seconds without any filtering and produce an overview of the observed events per combination of Sender, MessageType, SubSystem, Category and EventType: The values shown are the number of events and the average length of the included eventMessages.

```
Xcode        Default com.apple.coreaudio            aqme               logEvent            :     3   133.3
airportd     Default -                              -                  logEvent            :     5   106.8
airportd     Default com.apple.WiFiManager          -                  logEvent            :    13   127.5
bluetoothd   Default com.apple.bluetooth            Server.A2DP        logEvent            :     2    89.0
bluetoothd   Default com.apple.bluetooth            Server.Core        logEvent            :     2    29.0
bluetoothd   Default com.apple.bluetooth            Server.MacCoex     logEvent            :     1    47.0
cfprefsd     Error   com.apple.defaults             cfprefsd           logEvent            :     3    63.0
heard        Default com.apple.Hearing              HearingAids        logEvent            :     2    85.0
kernel       Default -                              -                  logEvent            :    27    16.1
locationd    -       -                              -                  activityCreateEvent :     3    51.0
locationd    Default com.apple.icloud.SPFinder      advertisementCache logEvent            :     3    20.0
logdreamer   -       -                              -                  activityCreateEvent :     1    19.0
mds_stores   Default com.apple.spotlightindex       Query              logEvent            :     1    78.0
mds_stores   Default com.apple.spotlightindex       Scheduler          logEvent            :     1    63.0
searchpartyd -       -                              -                  activityCreateEvent :     3    24.0
searchpartyd Default com.apple.icloud.searchpartyd  advertisementCache logEvent            :     3    43.0
wifip2pd     Default com.apple.wifip2pd             xpc                logEvent            :     6    73.0
``` 

The options \-\-timeout, \-\-predicate, \-\-level, \-\-process and \-\-type are passed unchecked to `log`. Example:

    logdreamer --timeout 1m --proc Safari --proc Mail --level info  


The timeout interval can be interrupted with SIGTERM or SIGINT. 

## Using option \-\-save

If specified, \-\-save defines the directory into which the output is stored in files instead of being blown to stdout.

The structure of the output files is suited for post-processing with tools like pandas:

Log messages are written as **JSON**, Statistics are in **CSV** format.

### Example post-processing with pandas

```python
df = pd.read_table(
    "stats.csv",
    sep=",",
)
```

```python
columns_to_drop = '''
    traceID formatString
    senderImageUUID
    processImageUUID
    backtrace bootUUID 
    timezoneName source
    threadID
    senderProgramCounter
'''.split()

dtypes = {
    'eventType': 'category',
    'subsystem': 'category',
    'messageType': 'category'
}

df = pd.read_json(
    'logevents.json',
    lines=True,
    dtype=dtypes,
).drop(
    columns_to_drop, axis=1
).set_index('timestamp')
```


## Usage of Universal Log

`logdreamer` itself logs a few messages to the log. These can be easily examined with the command *log show*:

```
log show --last 20m --predicate 'subsystem == "com.me.logdreamer"' --info
```


[DOCHEADER: CyberCache Server Configuration]

This manual describes overall structure of CyberCache server's configuration
files, as well as format, meanings, and allowed values of individual options.

[CONFIG]
#
# CyberCache 1.3.6 Community Edition Configuration File
# Written by Vadim Sytnikov
# Copyright (C) 2016-2019 CyberHULL. All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# -----------------------------------------------------------------------------

[SECTION: Configuration File Locations]

Default CyberCache configuration file resides in the `/etc/cybercache`
directory and is named `cybercached.cfg` or, alternatively, it can be put
into the same directory with the `cybercached` executable -- if it is to be
loaded automatically. Alternatively, full path to configuration file can be
specified as the very last command line argument to `cybercached`, after all
options; if specified path starts with '.' or '/', it will be used "as is",
otherwise, CyberCache with search stardard locations (`/etc/` and executable
file's directory) for it.

[SECTION: Configuration File Format]

General format of all configuration statements is

    <statement> <value1> [<value2> [...]]

where `<value>` can be a reserved word, an integer (up to 64-bit) or floating
point number, or a string in optional single (normal or back) quotes, or
double quotes; quotation marks are necessary if the string contains spaces or
escape characters; within a quoted string, the following escape sequences are
recognized and converted to characters (note that it is only necessary to
escape a quotation mark within a string that is delimited with that *same*
quotation mark):

- `\\` : backslash,
- `\xx` : character with hexadecimal code `xx` (in upper or lower case),
- `\r` : carriage return,
- `\n` : line feed (new line),
- `\t` : tabulation (tab character),
- `\'` : apostrophe (single quote),
- `\`` : backtick (back quote / grave accent),
- `\"` : double quote.

Other common escape sequences (such as `\a` for beep, `\b` for backspace, or
for `\f` form feed) are not supported as they would interfere with hexadecimal
codes; a single quote do not have to be escaped within double-quoted string,
and vice versa).

Hash mark in any position *except* inside a quoted string starts comment;
backslash as the very last character on the line means that the option will be
continued on the next line (carried over).

An integer number can be prefixed with `0` or `0x` to specify octal or
hexadecimal notation, respectively. If indeger number is used to specify
memory or file size, it can be followed by a suffix, with `b` standing for
bytes, `k` for kilobytes, `m` for megabytes, `g` for gigabytes, `t` for
terabytes; lack of suffix means bytes. Likewise, whenever a duration is
required, the number can be followed by `s` (seconds), `m` (minutes), `h`
(hours), `d` (days), or `w` (weeks) suffixes; lack of suffix means seconds.
Even if size is specified in bytes, or duration is seconds (so suffixes are
optional), we advise to use suffixes anyway (`b` and `s`, respectively) to
avoid ambiguity. Letters in both prefixes and suffixes can be in either lower
or upper case.

> **IMPORTANT**: whenever an option documentation refers to a `<size>` argument,
> it means 64-bit unsigned integer with an optional `b`, `k`, `m`, `g`, or `t`
> suffix. Likewise, a reference to <duration> argument means 32-bit unsigned
> integer with an optional `s`, `m`, `h`, `d`, or `w` suffix.

Booleans can be specified using reserved words `true`, `yes`, `on`, `false`,
`no`, and `off`.

Strings starting with digits (such as IP addresses) can still be specified
without quotes; in the same vein, numbers can be specified *with* quotes,
although that is clearly not recommended: one should use discretion and not
cause unnecessary confusion.

Option names (both full and one-letter shortcuts; see below) are all
case-sensitive, while other reserved words are not. For instance, `true`,
`True`, and `TRUE` are all valid boolean values (and, as a matter of fact, so
are `TrUe` and `truE`, but we very strongly advise against usint them...)

The above-described format essentially matches the one of the server console.

[SECTION: Server Options as Command Line Arguments]

Any option can also be set using command line argument: it has to be prefixed
with `--` (double hyphens), underscores in the name can (but do not have to)
be replaced with hyphens, and option value must be separated from the name
using equal sign. Additionally, if the option is multi-value, spaces between
values must be replaced with commas. For instance, configuration option

    fpc_optimization_compressors gzip zstd

can be represented with command line argument

    --fpc-optimization-compressors=gzip,zstd        OR
    --fpc_optimization_compressors=gzip,zstd

Some configuration options can be specified as one-letter *command line*
arguments (i.e. short forms *cannot* be used in configuration files); the
following aliases are currently supported (note that colons must be used
instead of equal signs as argument separators):

    --include=<path>                          ==>  -i:<path>
    --log-level=<level>                       ==>  -l:<level>
    --num-connection-threads=<number>         ==>  -n:<number>
    --max-memory=<size>                       ==>  -m:<size>
    --max-session-memory <size>               ==>  -s:<size>
    --max-fpc-memory=<size>                   ==>  -f:<size>
    --listener-addresses=<address>,<address>  ==>  -a:<address>,<address>
    --listener-port=<number>                  ==>  -p:<number>

Options specified on the command line always take precedense over their
counterparts in the main configuration file (i.e. the one specified as the
very last argument to `cybercached` executable, or, if none was specified, the
default one). Therefore, configuration file loaded using `-i`/`--include`
option will overwrite settings made by the main configuration file. The only
exception to this rule is log level (`-l`/`--log-level`) option: it takes
effect immediately.

[SECTION: Changing Options at Run Time]

Configuration file can be [re]loaded at run time using `LOCALONFIG [<path>]`
and `REMOTECONFIG [<path>]` console commands. How exactly a particular
configuration statements in the newly loaded file will affect running daemon
is specified in the documentation to those statements later in this file.
As a general rule, a new option value from a configuration file loaded *at run
time* takes effect immediately, with only few exceptions, namely:

    user_password,
    admin_password,
    bulk_password,
    table_hash_method,
    password_hash_method,
    session_tables_per_store,
    fpc_tables_per_store,
    tags_tables_per_store,
    perf_num_internal_tag_refs

The first three are permanent for the session mainly for security reasons;
`password_hash_method` is permanent because it affects passwords;
`table_hash_method` -- because, if changed, it would invalidate all objects in
all tables; `xxx_tables_per_store` would basically stall the server for a
considerable time (so it can be said that if you could afford changing those
options, you'd just as well afford re-starting the server);
`perf_num_internal_tag_refs` would invalidate entire FPC object store. So
values of these nine options can only be set in the very first configuration
file loaded by the server, or through command line arguments.

Additionally, any option except the above-listed six can be set at run time
using console's `SET` command; there are few options that only affect
*initial* server state (e.g. `perf_session_init_table_capacity`), attempts to
change them via `SET` will be silently ignored.

[SEPARATOR]

--------------------------------------------------------------------------------

[SECTION: Options - Memory Quotas]

Memory quotas are **the** most important options of CyberCache affecting its
overall performance. The three available memory quotas are interconnected in
that if, say, global (total memory available to CyberCache) quota is set to N
bytes, session memory is set to NS bytes, and FPC memory is set to 0 bytes,
then the amount of memory that can be used by FPC store will be N minus
*actual* amount currently used by session store, but not less than N-NS bytes.
Note that FPC store would be able to use more than N-NS bytes -- but only if
session store underutilizes its quota. Setting global quota (`max_memory`),
along with store-specific quota, to zero is also possible, but that would
require expiration-based eviction mode (see below) and is generally less
efficient: with properly configured memory quotas, the server will do memory
deallocations in specialized optimization threads, concurrently with serving
incoming requests, as well as other activities... whereas with zero memory
quotas, it will run out of memory, interrupt current operation, reclaim some
memory, and ony then resume servicing a request.

Setting store's own memory quota always takes precendence. For instance,
setting, say, `max_memory` to 16M, `max_session_memory` to 4M, and
`max_fpc_memory` to 8M does not make sense: total used memory will stay around
12M (4M+8M). Even though the server does do some memory allocations on its
own, they are negligible compared to those of session and FPC stores. Speaking
of "will stay around...": the server can (and most likely will) allocate
memory above its global quota, and only then will start deallocating memory to
get below its specified limit. For this reason, it is advised that global
memory quota is never set to anything above 90..95% of the total available
physical memory even if CyberCache runs on a dedicated server (for small boxes
with 4G or so RAM it should even be less, around 80..85%). Upon startup,
CyberCache server compares specified quotas to the actually available RAM and
will log a warning if it is misconfigured, but will proceed with specified
quotas nonetheless.

> **IMPORTANT**: the above description clearly shows that the default global
> quota of 0b is by no means optimal for the server. The very first thing that
> system administrator rolling out CyberCache should do is set meaningful
> global and per-store memory quotas. It would be trivial to implement
> auto-configuration based on the amount of installed RAM but, after careful
> consideration it's been decided not to do so, because it would give false
> impression of optimal setup, whereas there's no way of taking into account
> everything that you know about your system (other programs running on the
> same box, relative importance of session and FPC stores, and the likes).
> 
> On the other hand, setting *one* of the store-specific quotas to zero is, in
> fact, preferred: it prevents memory from being underutilized. If the server
> is used as *both* session store and full page cache, then recommended way of
> configuring the server would be to a) set `max_memory` as explained above,
> b) figure out how many sessions it is necessary to keep (roughly based on
> the number of unique users for the period during which the sessions should
> be kept), c) calculate how much memory is needed for them (the instrumented
> version of CyberCach can help with that), d) set `max_session_memory` to
> calculated amount, e) set `max_fpc_memory` to zero.

Irrespecive of the amout or available physical RAM, CyberCache server imposes
its own limits on the memory quotas that can be specified in the
configuration: Community Edition is limited to 32 gigabytes (both total and/or
per-store), while Enterprise Edition is limited to 128 terabytes.

[FORMAT]
max_memory <size>
max_session_memory <size>
max_fpc_memory <size>

[DEFAULTS]
max_memory 0b
max_session_memory 0b
max_fpc_memory 0b

[CONFIG]
max_memory 0b
max_session_memory 0b
max_fpc_memory 0b

--------------------------------------------------------------------------------

[SECTION: Options - Server Interface]

The `listener_xxx` options specify what IP address/port combinations the
server will be listening to, waiting for incoming requests.

It is possible to specify multiple addresses, but not the port. In case of
multiple addresses, they should *all* be specified using a single statement;
if they do not fit one line, line continuation (backslash at the very end of
the string) should be used. Multiple `listener_addresses` and/or
`listener_port` statements will *not* specify multiple sockets; instead, last
found statement overwrites all previous.

The addresses to listen to can be specified as numeric IPs (e.g. `127.0.0.1`),
of as domain names  (e.g. `localhost` or `cybercache.example.com`); the cache
will resolve them into IPs. Note that there is no default address(es): it is
entirely possible to start CyberCache server w/o specifying an address in
either configuration file, or command line. In such a case, the server will
wait for a `SET` command (e.g. sent using console) that would specify
address(es) and/or port for it to listen to, and will start listening as soon
as it receives such a command. It is also possible to use `SET` to
reconfigure address(es) and/or port of an already running/listening server.

Different editions have different limits on the number of addresses that the
server can simultaneously listen to: Community Edition supports up to two
addresses, while Enterprise Edition supports up to 16.

Default port number is 8120. It is possible to specify another port, as long
as it is in 1024..65535 range, and does not conflict with other services. If
in doubt if a partcular port is safe to use, search IANA for that port number:
http://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml?search=<port>

[FORMAT]
listener_addresses <address> [<address> [...]]
listener_port <number>

[DEFAULTS]
listener_addresses 0 (NO DEFAULT)
listener_port 8120

[CONFIG]
listener_addresses localhost
listener_port 8120

--------------------------------------------------------------------------------

[SECTION: Options - Connection Types]

CyberCache Cluster can work in two modes: per-command connections, and
persistent connections. The former makes CyberCache open connection upon
receiving a command, and close it upon sending a response; the latter differs
in that CyberCache never closes a connection itself: it waits for a client to
do so. Persistent connections provide a welcome performance boost for typical
use cases; for instance, Magento sends dozens of commands while processing a
single page request, so with persistent connections the connection between PHP
extension and CyberCache will be closed (by PHP extension) only upon finishing
processing the request. Hence connections are persistent by default, and not
only in the server, but also in all clients (console, PHP extension, Magento 1
and 2 extensions) shipped as part of the CyberCache Cluster package.

**IMPORTANT**: If CyberCache server and its client use different types of
connections (say, the the serer is in persistent connections mode, while the
console is configured to use per-command connections), they should still be
able to work together; however, in such a case reliable communication is *not
guaranteed*. So it is highly advisable to make sure every client/server pair
uses the same connection type; namely:

- If main server has `session_replicator_persistent` set to `true`, then server
  used for session replication has to have `listener_persistent` set to `true`
  as well; likewise, if main server has `fpc_replicator_persistent` set to
  `true`, then server used for FPC replication should have `listener_persistent`
  set to `true`. Same for per-command mode.

- If the server to which administrator connects using `cybercache` console
  application is consigured to use per-command connections (i.e. has
  `listener_persistent` set to `false`), then said administrator should execute
  `persistent false` command before issuing any commands to the server (it would
  be a good idea to add `persistent false` to the `cybercache.cfg` file -- *not*
  to be confused with this `cybercached.cfg` file).

- If the server used as Magento session and/or full page cache is configured to
  use per-command connections, then either a) Magento extension session/FPC
  configurations should have `persistent` set to `false`, or b) Magento
  extension configuration should leave `persistent` unset, while PHP extension
  should have both `c3.session_persistent` and `c3.fpc_persistent` INI options
  set to `false`.

It is recommended that these options are left at their default values.

[FORMAT]
listener_persistent <boolean>
session_replicator_persistent <boolean>
fpc_replicator_persistent <boolean>

[DEFAULTS]
listener_persistent true
session_replicator_persistent true
fpc_replicator_persistent true

[CONFIG]
listener_persistent true
session_replicator_persistent true
fpc_replicator_persistent true

--------------------------------------------------------------------------------

[SECTION: Options - Replication]

Replicators are configured just as the listener (see above), and have the same
format and limits imposed on the number of concurrent addresses they can
simultaneously transmit data to.

It is possible to use different ports for replicators (i.e. port number that
differs from that of the listener), but it is not advised: it would make "hot
swapping" of the servers more difficult, while providing no real benefits:
unless replication server is used as, say, some sort of session log and is not
actually part of the cluster.

It is possible to configure only session replicator, or only FPC replicator,
or both. If both are enabled, they can be "talking" to different, or to the
same remote server. The only limitation is that there must be a single
CyberCache server running on a box: it is not possible to, say, have "live"
and "replication" servers running on the same physical server, with different
listener and replication ports (which wouldn't make any sense anyway).

[FORMAT]
session_replicator_addresses <address> [<address> [...]]
session_replicator_port <number>
fpc_replicator_addresses <address> [<address> [...]]
fpc_replicator_port <number>

[DEFAULTS]
session_replicator_addresses 0 (NO DEFAULT)
session_replicator_port 8120
fpc_replicator_addresses 0 (NO DEFAULT)
fpc_replicator_port 8120

Even though these options are commented out by default, respective services
*will* be started upon server startup. They just won't be configured to talk
to any remote address. This (configuration) can be done at run time by issuing
`SET`, `LOCALCONFIG`, or `REMOTECONFIG` -- just as with `listener_xxx` options.

[CONFIG]
# session_replicator_addresses ... (localhost does not make sense here)
# session_replicator_port 8120
# fpc_replicator_addresses ... (localhost does not make sense here)
# fpc_replicator_port 8120

--------------------------------------------------------------------------------

[SECTION: Options - Table Hash Methods]

These options set hash method that are used to process passwords, and to
calculate hash codes of various entities: session and FPC entries' IDs or
tags. Every method has two important properties that has to be taken into
account: the so-called distribution (how likely is it that two different
strings will get the same code), and speed. All of the hash methods available
represent state-of-the-art in this area, with differences between them being
very minor, so it's hard to go wrong picking one over the other; still, some
differences do exist:

- `xxhash` : extremely fast algorithm with good distribution, by Yann Collet;
  does not require any special hardware support,

- `farmhash` : very fast algorithm with extremely good distribution, from
  Google; requires support of SSE 4.2 instructions by your server hardware (if
  you select this method while not having required hardware, your server will
  crash); this is a second-gen algorithm, successor to "cityhash"; this method
  can be recommended for very large datasets *IFF* your server runs on
  compatible hardware,

- `spookyhash` : algorithm by Bob Jenkins; almost as fast as Google's, and
  without `farmhash`'s restrictions (special hardware requirements),

- `murmurhash2` : algorithm by Austin Appleby, used by Redis cache server,

- `murmurhash3` : next generation of the `murmurhash2` algorithm; has very
  good distribution, but is relatively (to the other algorithms, not in
  absolute terms!) slow.

Note that the need for best possible distribution is largerly mitigated in
CyberCache by the fact that not only FPC and session data, but also FPC tags
are stored separately; also, no IDs get any extra prefixes that have to be
used in Redis-based implementations of session storage of FPC. Finally,
whenever a particular algorithm on the above list is described as "fast", it
simply means that it might be somewhat faster than others on that list; in
absolute terms, they are all very fast.

> **IMPORTANT**: if `password_hash_method` is set to a non-default method and
> either `user_password` or `admin_password` is set, then
>
> 1) for PHP interface to be able to send commands that are authorized with
> passwords (that are set), PHP array entry `hasher` should be set in arrays
> passed to `c3_session()` and `c3_fpc()` to exactly the same method that is
> used in this config file,
>
> 2) similarly, for `cybercache` console to be able to execute authorized
> commands, `HASHER` command should be used to set the same method.

> **IMPORTANT**: for the `password_hash_method` option to take effect, it
> must be specified in the cofiguration file before `user_password`,
> `admin_password`, and/or `bulk_password`; in other words, when server
> processes any of the specified passwords, it uses last encountered
> `password_hash_method` option (or, if none was specified, the default
> method).

These options are among the very few that cannot be changed at run time.

[FORMAT]
table_hash_method { xxhash | farmhash | spookyhash | murmurhash2 | murmurhash3 }
password_hash_method { xxhash | farmhash | spookyhash | murmurhash2 | murmurhash3 }

[DEFAULTS]
table_hash_method xxhash
password_hash_method murmurhash2

[CONFIG]
table_hash_method xxhash
password_hash_method murmurhash2

--------------------------------------------------------------------------------

[SECTION: Options - Passwords]

Passwords in CyberCache are optional. It is possible to set any (or all) of
them to empty strings, and the server won't complain. If set, however, any of
them should have at least one lower, one upper case letter, one digit, and
have at least six characters (although failure to meet these requirements will
result in a warning, not an error). Please note that CyberCache server does
not use passwords while establishing a connection; instead, every command is
authenticated individually.

If `user_password` is set (i.e. isn't an empty string), its hash code will be
sent with each command that requires user-level authentication (that's all
cache data-transfer commands), will be checked by the server, and the command
will be rejected if the password's hash code  does not match. Similarly, if
`admin_password` command is set, its hash code will be sent along with each
command that requires admin-level authentication (all configuration requests,
`SHUTDOWN`, and the likes; please see documentation).

The `bulk_password` command sets up authentication for replicators, binlogs,
and databases: `bulk_password` on master must match `user_password` on
slaves. Also, bulk password hash code is stored instead of `user_password`
along with data-transfer commands saved to binlogs; hence "bulk".

The `info_password_type` option is a selector that determines which password,
if any, is used to authenticate information commands such as `INFO`, `STATS`,
`PING`, and `CHECK`. If it is set to, say, `user` while `user_password` is an
empty string, it would be equivalent to setting it to `none`.

The recommended practice is to leave `user_password` empty, but set
`admin_password`; the latter ensures that the server won't be remotely
re-configured or shut down by a person not authorized to do so. Do not
hesitate to set `user_password` if you feel like it though: authentication in
CyberCache is very lightweight (efficient). The best (and, we should say, the
only true) protection, as always, is running all servers in a LAN behind a
good, properly configured firewall.

[FORMAT]
user_password <password>
admin_password <password>
bulk_password <password>
info_password_type { none | user | admin }

[DEFAULTS]
user_password ''
admin_password ''
bulk_password ''
info_password_type none

[CONFIG]
user_password ''
admin_password ''
bulk_password ''
info_password_type none

--------------------------------------------------------------------------------

[SECTION: Options - Logging]

CyberCache logger is a full-fledged logging service that runs cuncurrently
with other server subsystems, is very lightweight, and supports not only
basics like log levels, but also advanced features like log rotation.

Log levels are pretty self-explanatory: `debug` is most verbose, while
`explicit` essentially disables all internal logging, and will only write down
messages that server receives through `LOG` command from, say, remote console;
hence the name.

It is not recommended to use levels more terse than `warning`. The server
counts all warnings and errors (irrespective of logging level in effect), and
reports these numbers in responses to `INFO` and `CHECK` commands; server
administrator should then be able to go to the log file to see what really
happened. Please note that reported numbers are cumulative, they are never
reset (unless the server is restarted), so even if they are not zero but do
not grow either, you might as well be fine.

The logger uses system log as a fallback. During server startup and shutdown,
as well as upon unrecoverable errors during normal operation, the server might
log a message to syslog instead. If the error occurs during startup, it is
also duplicated to the standard error stream, so the person starting
CyberCache will see it. Otherwise, if an error occurred, log level is at
`error` level or more verbose, but there are no traces of the the error in
CyberCache own log, one has to check system log for messages about it. On
Windows, it is necessary to run `syslog-ng` or equivalent service; on Linux,
system log is always readily available.

In order to enable log rotation, one has to specify log rotation path, which
is a regular file path that *must* have at least one date/time placeholder in
it: either "%d" (which would be replaced with a integer value of current
timestamp), or "%s" (which would be replaced with textual representation of
the timestamp), but not both.

[FORMAT]
log_level { debug | verbose | normal | terse | warning | error | fatal | explicit }
log_file <path>
log_rotation_threshold <size>
log_rotation_path <path>

[DEFAULTS]
log_level normal
log_file '/var/log/cybercache/cybercached.log'
log_rotation_threshold 16M
log_rotation_path ''

[CONFIG]
log_level normal
log_file '/var/log/cybercache/cybercache_cluster.log'
log_rotation_threshold 16M
log_rotation_path '/var/log/cybercache/cybercache_cluster_%s.log'

--------------------------------------------------------------------------------

[SECTION: Options - Concurrent Processing]

At any moment, CyberCache runs 13 service threads, plus the number of worker
threads set using `num_connection_threads`; the latter must be at least 1,
and can be up to 6 in Community Edition, or up to 48 in Enterprise Edition.

Now, given that available number of CPU cores is almost guaranteed to be
significantly less than the grand total of all server threads, does it really
make sense to bump `num_connection_threads`? Short answer is, Yes, it most
certainly does. First, vast majority of threads lay dormant most of the time,
not consuming any system resorces (except for a wee bit of memory). If not
configured, binlog and replication threads do nothing at all. If there is no
logging, the logger thread does nothing, and so on.

The most "hard-working" threads are those of the listener (which handles not
only incoming, but also outgoing traffic), and optimization threads. In a
properly configured busy CyberCache server, activities of all threads (except
`num_connection_threads` worker threads) result in utilization of 1.5..3 CPU
cores, depending on binlog/replication settings.

Next question is, OK, suppose we have N cores in the system, and 2 cores worth
of load because of service threads, does it make sense to set
`num_connection_threads` to anything above N-2? The answer is, yes, it still
does. Even thought CyberCache server had been designed to avoid stalls during
concurrent access to resources (by separating session and FPC stores, using
multiple hash tables per store, using queues and messaging instead of locking
a subsystem, and so on and so forth), some delays are inevitable. A good rule
of thump is this: if system has N cores, and estimated load due to service
threads is M cores, set `num_connection_threads` to at least (N-M)*2; if the
difference in parenthes is zero or even negative, still set it to 2.

> **IMPORTANT**: the `num_connection_threads` does *not* reflect the number of
> connections that CyberCache can handle concurrently; like Nginx and other
> high-performance servers, CyberCache employs asynchronous I/O to handle
> connections, and can process hundreds and thouthans of connections
> simultaneourly, all within a single "listener" thread. It is only when a
> request is received in full, it is passed for futher processing to a worker
> thread; all responses are handled similarly (except that the first attempt
> to write back response is done by the worker thread itself: another reason
> to have more of them).

[FORMAT]
num_connection_threads <number>

[DEFAULTS]
num_connection_threads 2

[CONFIG]
num_connection_threads 2

--------------------------------------------------------------------------------

[SECTION: Options - Session Locking]

Modern web sites may use more than one request to render a page, especially
when such technologies as AJAX are used; in such cases, session read/write
requests may come to CyberCache out of order. Suppose two AJAX requests
load, update, and store session data as follows: a) request 1 reads session
record, b) request 2 reads same session record, c) request 1 writes
*modified* session record, d) request 2 writes same *modified* session
record. If no special precautions are taken, all modification done by request
number 1 would be lost.

CyberCache handles such situation using internal session locks: when it
receives command to fetch session record, it locks that record until write
command for that record issued by the **same** request (that previously read
and thus locked the record) arrives. Request IDs are automatically maintained
by PHP extension; the `cybercache` console always uses zero request ID, thus
bypassing all checks, and allowing to read/write session records in arbitrary
order. Invocation of a script using command line PHP interpreter is always
treated by CyberCache extension as a single request (so cron jobs running
PHP scripts manipulating session records using CyberCache PHP extension API
have no restrictions, just like `cybercache` console scripts).

So far so good, but what if session write command never arrives after read
command has locked session record? This is where `session_lock_wait_time`
option comes handy: it sets limit (measured in milliseconds) on the time
that session read commands will be waiting for the record to be unlocked.
After that, one of the waiting read commands will break the lock, and lock
the record by itself. Default timeout is 8000 (milliseconds, or 8 seconds),
and it can be set to anything from 0 (more on this below) to 60000 (that is,
one minute).

When setting value of this option, the following should be taken into
account: a) waiting thread does not "sleep for" session_lock_wait_time
milliseconds, it "sleeps for UP TO" session_lock_wait_time milliseconds, and
will wake up as soon as the record is unlocked -- so with properly working
site it makes sense to set its value to tens of seconds to prevent timeouts
even in case of severe site slowdowns; b) when thread wakes up due to a
timeout (with bug in site implementation being a likely cause), it may find
out that another thread/request already locked the record, in which case it
will wait again for up to *another* session_lock_wait_time milliseconds --
so with a buggy site worst case scenario may be bad indeed. If in doubt, just
leave default value intact, it's good enough for the majority of cases.

Finally, it is possible to set `session_lock_wait_time` option to 0,
effectively disabling session locking. This will work for sites that do not
use AJAX, or similar technologies that utilize more than one request to
render a page. While it (disabling session locking) might provide some
performance benefits, they will be absolutely negligible because locking is
very efficient; do it if and *only* if you have to squeeze every last cycle
out of a simple site under extremely heavy load.

[FORMAT]
session_lock_wait_time <milliseconds>

[DEFAULTS]
session_lock_wait_time 8000

[CONFIG]
session_lock_wait_time 8000

--------------------------------------------------------------------------------

[SECTION: Options - Cache Record Eviction Strategies]

The following options set eviction modes for session and FPC caches. Contrary
to LRU eviction algorithms used by Redis, which are based on statistical
approximation (see http://redis.io/topics/lru-cache), CyberCache employs true
LRU eviction, with data most recently *accessed* (i.e. *explicitly* tested,
read, or written using server protocol) are *guaranteed* to be evicted later
than "stale" data, and it does so using algorithms with O(1) complexity. *All*
modes described below use LRU eviction algorithm when it is necessary to free
up some memory; the differences between them are that:

- `strict-expiration-lru` mode works like `expiration-lru` (see below) but
  will not delete a record that has *not* expired unless total memory used by
  domain exceeds `max_session_memory` (for session domain) or `max_fpc_memory`
  (for FPC domain), or if total used memory exceeds global limit
  (`max_memory`); if those memory limits are set to `0`, then in
  `strict-expiration-lru` mode the server will never delete a record that is
  not expired in respective domain unless it actually runs out of memory,

- `expiration-lru` mode (the default) *does* take into account expiration
  timestamps and may purge expired records even when the server still has
  enough free memory; however, even in this mode the server 1) will remove a
  record with bigger TTL instead of a record that has smaller TTL but that was
  accessed more recently if it runs out of memory, 2) will "revive" expired
  records that are being tested or read (if they are have not been deleted
  yet),

- `lru` eviction is "pure" LRU and never removes expired records just because
  they have expired, although it still honors explicit garbage collection
  requests from the Magento application or server console (`GC` and
  `CLEAN OLD` commands, which delete expired records),

- `strict-lru` mode works just like `lru`, except that it ignores even
  explicit garbage collection requests.

Like other options, eviction mode for both session and FPC caches can be
changed at run time; for this to work, even in `strict-lru` mode the server
always sets (and modifies as needed) expiration timestamps; it just never
checks them.

[FORMAT]
session_eviction_mode { strict-expiration-lru | expiration-lru | lru | strict-lru }
fpc_eviction_mode { strict-expiration-lru | expiration-lru | lru | strict-lru }

[DEFAULTS]
session_eviction_mode expiration-lru
fpc_eviction_mode lru

[CONFIG]
session_eviction_mode expiration-lru
fpc_eviction_mode lru

--------------------------------------------------------------------------------

[SECTION: Options - Session Records Life Times]

These options implement fine-grained control over session life time. When a
user loads site's page for the very first time, we do not know whether he/she
will visit another page or two, or will leave almost immediately. So the
server tracks number of session writes, and increases TTL for each successive
write, because it becomes more and more probable that the user will return.

> **IMPORTANT**: these options are *NOT* used if 1) user agent is a regular
> 'user' (i.e. not an unknown user, a bot, or a cache warmer), AND 2) a
> specific lifetime (zero for "infinite", or a positive number) is sent to
> the server as part of the `WRITE` command.

Upon very first write of user's session data, server sets session TTL to
`session_first_write_lifetimes`. During next `session_first_write_nums`
writes, the server linearly increases TTL until on
`session_first_write_nums`-th write it becomes equal to
`session_default_lifetimes`; all subsequent writes will set TTL of that record
to `session_default_lifetimes`.

The `session_read_extra_lifetimes` option allows to revive expired but not yet
deleted session records upon reads; if an expired but still existing session
record is being read, the server will set its TTL to
`session_read_extra_lifetimes`. Additionally, if `session_eviction_mode` is
*not* `expiration-lru`, then upon each read of a session record (expired or
not) the server will check its TTL and, if it's less than
`session_read_extra_lifetimes`, the server will set it to
`session_read_extra_lifetimes`.

Each option takes up to four values, which have to be specified on the same
line, as a sequence of numbers separated with whitespace. Each number sets
option value for a particular type of user agent (the type of user agent is
deduced in PHP extension, there is no configuration option for it here):

- 1st : for an unknown user (no user agent info in the request header),
- 2nd : for a known bot, such as Google crawler,
- 3rd : for the CyberHULL cache warmer,
- 4th : for a potentially valid user of the site.

Lifetime of any element should not be set to less than 30 seconds, and it
cannot be bigger than 365 days (you decide for how long you want to keep
customers' shopping carts); `session_read_extra_lifetimes` can however be set
to zeros to mimic a non-LRU cache. Note that using these settings you can also
fully mimic Redis-based session cache, which adds one second of extra lifetime
per each session write (far from ideal in our opinion, but if you want to,
then why not).

[FORMAT]
session_first_write_lifetime <duration> [ <duration> [ <duration> [ <duration> ]]]
session_first_write_num <number> [ <number> [ <number> [ <number> ]]]
session_default_lifetime <duration> [ <duration> [ <duration> [ <duration> ]]]
session_read_extra_lifetime <duration> [ <duration> [ <duration> [ <duration> ]]]

[DEFAULTS]
session_first_write_lifetime 30s 1m 2m 10m
session_first_write_num 100 50 20 10
session_default_lifetime 1h 2h 1d 2w
session_read_extra_lifetime 30s 1m 2m 2w

[CONFIG]
session_first_write_lifetimes 30s 1m 2m 10m
session_first_write_nums 100 50 20 10
session_default_lifetimes 1h 2h 1d 2w
session_read_extra_lifetimes 30s 1m 2m 2w

--------------------------------------------------------------------------------

[SECTION: Options - FPC Records Life Times]

Options in this section control FPC entries' life times. Overall, these
options are much simpler than their counterparts for session cache, because
Magento application explicitly specifies lifetime for the entry upon each
write. If the lifetime specified by Magento is not `-1`, than the server
checks it against `fpc_max_lifetimes` and uses if it's less than or equal to
that (if specified value exceeds `fpc_max_lifetimes`, it will be clipped).
Otherwise, if lifetime specified by Magento is `-1`, the server uses
`fpc_default_lifetimes`. If `0` lifetime is passed to the server (as part of
the `SAVE` command), it is treated by the server as "inifinite lifetime", and
server disregards the below options.

The `fpc_read_extra_lifetimes` option allows to revive expired but not yet
deleted FPC records upon reads; if an expired but still existing FPC record is
being read, the server will set its TTL to `fpc_read_extra_lifetimes`.
Additionally, if `fpc_eviction_mode` is *not* `expiration-lru`, then upon each
read of an FPC record (expired or not) the server will check its TTL and, if
it's less than `fpc_read_extra_lifetimes`, the server will set it to
`fpc_read_extra_lifetimes`.

Each option takes up to four values, which have to be specified on the same
line, as a sequence of numbers separated with whitespace. Each number sets
option value for a particular type of user agent (the type of user agent is
deduced in PHP extension, there is no configuration option for it here):

- 1st : for an unknown user (no user agent info at all in the request header),
- 2nd : for a known bot, such as Google crawler,
- 3rd : for the CyberHULL cache warmer,
- 4th : for a potentially valid user of the site.

Lifetime of any element cannot be set to less than 1 minute, and it cannot be
bigger than 365 days; `fpc_read_extra_lifetime` can however be set to zeros to
mimic a non-LRU cache.

[FORMAT]
fpc_default_lifetimes <duration> [ <duration> [ <duration> [ <duration> ]]]
fpc_read_extra_lifetimes <duration> [ <duration> [ <duration> [ <duration> ]]]
fpc_max_lifetimes <duration> [ <duration> [ <duration> [ <duration> ]]]

[DEFAULTS]
fpc_default_lifetimes 1d 2d 20d 60d
fpc_read_extra_lifetimes 1d 2d 20d 60d
fpc_max_lifetimes 10d 30d 60d 60d

[CONFIG]
fpc_default_lifetimes 1d 2d 20d 60d
fpc_read_extra_lifetimes 1d 2d 20d 60d
fpc_max_lifetimes 10d 30d 60d 60d

--------------------------------------------------------------------------------

[SECTION: Options - Optimization Intervals]

These options define how often optimizers will go through all objects in
session and FPC stores, and will try to optimize the stores, which includes
purging old objects if `session_eviction_mode`/`fpc_eviction_mode` are in
`strict-expiration-lru` or `expiration-lru` modes, and re-compressing the
objects. Re-compression is very non-intrusive, in that optimizers only very
briefly lock an object before they begin its re-compression, and after they
have completed re-compression (obviously, if the object data had been changed
during re-compression, re-compression result would be discarded).

Optimizers take into account current server/CPU load, and adjust their
activities accordingly. Also, they treat records created by bots or
unidentified user agents (or even own cache warmer) differently to records
created by regular users, and will purge the former before the latter.

[FORMAT]
session_optimization_interval <duration>
fpc_optimization_interval <duration>

[DEFAULTS]
session_optimization_interval 20s
fpc_optimization_interval 20s

[CONFIG]
session_optimization_interval 20s
fpc_optimization_interval 20s

--------------------------------------------------------------------------------

[SECTION: Options - Optimizers' Compression Methods]

Set compression methods to be used by session and FPC optimizers, *and* the
order in which those compressors will be tried. When server receives data from
the client, it is already in compressed form, but the compressor that PHP
entension (or console) uses is relatively weak (has sub-optimal compression
ratio), although extremely fast. After the data is stored in the cache,
optimization threads will sooner or later detect unoptimal compression, and
will re-compress session or FPC data using the methods specified in
`session_optimization_compressors` and `fpc_optimization_compressors` options,
in the order the compressors are listed. Available compression methods are:

- `zstd` : compressor from the creator of `lz4` compressor and `xxhash`
  hasher; compresses noticeably better than `gzip`, decompression speed it
  approximately 3x that of `gzip`; its memory requirements during compression
  and decompression are modest, but still noticeably worse that those of
  `gzip`; this is the default.

- `brotli` : fast compressor by Google, with primary target being web traffic;
  has built-in dictionary for that. Only available in Enterprise Edition.

- `lzham` : compressor based on LZMA (alrorithm used by 7Zip), by a Valve
  engineer, made to be fast enough to be used in games; has very high
  compression ratio, with approximately 3x decompression speed with only
  slightly worse compression ratio compared to those of LZMA; compared to
  `gzip`, it has almost 2x decompression speed and more than 1.5x compression
  ratio, but is a true memory hog during work.

- `zlib` : compressor used in gzip, a tried and proven solution, but sub-optimal
  in great many respects; about the only reason to ever use this compressor is
  if the server small, is operating at peak capacity almost all the time, and
  there are simply no resources to employ a more powerful algorithm; in such a
  case, `zlib` should be the *only* method specified for the options. That
  said, there is always a possibility that some particular piece of data (one
  in a 1000) can be compressed with `zlib` better than with any other method.

- `lzf`, `snappy`, `lz4`, `lzss3` : these are super/hyper-fast compressors with
  sub-par compression ratios; any of them should *only* be used for
  *optimization* in... unusual setups with plenty of RAM and bandwidth but
  very scarse CPU resources. In such a case, we'd recommend using `snappy`
  (the fastest of the bunch, by Google) in PHP extension for initial
  compression, and `lzf`(almost as fast as `snappy`, but compresses noticeably
  better, though still worse than even `zlib`) for the optimizers on the
  server side. All these four methods are great for compressing responses
  though, see `xxx_response_compressor` family of options, below.

> **IMPORTANT**: the `lz4` compressor currently cannot be used to compress
> records bigger than 2 gigabytes.

Optimizers have internal limits for the numbers of recompression attempts they
are allowed to make during one run, and those limits vary according to
current server/CPU load. If you, say, specify two compression methods for
`fpc_optimization_compressors`, then FPC optimizer will try both and keep
compressed buffer that is smaller, BUT it will also count that as *two*
attempts; therefore, less attempts will remain to recompress other FPC
records; also, using many compressors increases the likelihood of object data
change during compression, which always results in scrapping re-compression
results; although, given enough time, optimizers will get to all records,
eventually.

Compressors that do *not* belong to the "super-fast" group support so-called
compression levels, ranging from "fastest but lest strong" to "slowest but
strongest"; some compressors (namely `zstd`, `brotly`, and `lzham`, but not
`zlib`) also support "extreme" compression level, which are currently unused.
During optimization runs, CyberCache server always employs "strongest"
compression level of each compresor, whereas during the following operations
the "fastest" level is used:

- `cybercached` server packing a response (such as a list of IDs collected as a
  result of 'GETIDS', `GETTAGS` or similar FPC command, or a list of strings
  formed as a result of `INFO`, `STATS`, or similar information command),

- `cybercache` console application packing a data buffer to send to the server
  as part of a `WRITE`, `SAVE`, or other such command,

- `cybercache.so` PHP extension packing a data buffer that it received as an
  argument to a `c3_write()`, `c3_save()`, or other such function.

If, say, CyberCache server has received a data buffer compressed using method
`X`, and optimizer is told to used methods `X`, `Y`, and `Z`, then method `X`
will *not* be tried by the optimizer on that buffer. Which may, potentially,
lead to inefficiency: received buffer was compressed using "fast" mode of the
method, while optimizer would have used "strond" mode; therefore, it is not
advised to use same methods for PHP extension and server optimizer: the former
should be configured to use one of the fast compressors (`lzf`, `snappy`,
`lz4`, or `lzss3`), while the latter -- one of the strong methods.

[FORMAT]
session_optimization_compressors <method> [ <method> [...]]
fpc_optimization_compressors <method> [ <method> [...]]

[DEFAULTS]
session_optimization_compressors zlib zstd
fpc_optimization_compressors zlib zstd

[CONFIG]
session_optimization_compressors zlib zstd
fpc_optimization_compressors zlib zstd

--------------------------------------------------------------------------------

[SECTION: Options - Compression Size Thresholds]

When optimization threads of the CyberCache server consider an object for re-
compression, they compare its size with values of the below options, and only
proceed with re-compression if object's buffer size if equal to or greater
than the threshold set by these options.

The thresholds used by CyberCache optimizers are smaller than those used by
other cache solutions because:

1) there is virtually no performance penatly for the overall cache
   performance: re-compression is done concurrently, in a separate thread,
   and does *not* affect in any way the timing of `SAVE`/`WRITE` commands,

2) some compressors used by CyberCache (e.g. `brotli`) have built-in
   dictionaries; usually, entire compression dictionary has to be stored
   along with compressed data, thus making gains on small data negligible,
   and on tiny buffers can even enlarge the data instead of shrinking it;
   with built-in dictionaries, compressing even tiny buffers may often
   provide some gains.

The `response_compression_threshold` option is different in that it controls
how various lists etc. are handled when they are sent back as responses to
commands like `GETIDS` or `GETTAGS`. It does *not* affect returned session or
FPC records in any way.

> NOTE: setting any of these options to `4294967295` (that is, `2^32-1`)
> effectively disables respective [re]compression.

[FORMAT]
session_recompression_threshold <size>
fpc_recompression_threshold <size>
response_compression_threshold <size>

[DEFAULTS]
session_recompression_threshold 256b
fpc_recompression_threshold 256b
response_compression_threshold 2k

[CONFIG]
session_recompression_threshold 256b
fpc_recompression_threshold 256b
response_compression_threshold 2k

--------------------------------------------------------------------------------

[SECTION: Options - Numbers of Tabbles per Store]

In order to maximize concurrent processing performance, CyberCache separates
data on many levels; the biggest subdivision is that there are separate
session and FPC stores, and the latter is further subdivided into FPC record
store, and FPC tag store.

Each store can have multiple hash tables to keep data records, and options in
this section define how many tables will there be per each store. In general,
the more tables, the less likely various delays become, although each extra
table adds a bit of memory overhead (which is negligible for big setups, but
not quite so for [very] small ones) -- so there has to be some balance.

The Community Edition of CyberCache server allows for up to 4 tables per
store, while Enterprise Edition allows for up to 256 tables. The number of
tables must be a power of 2.

[FORMAT]
session_tables_per_store <number>
fpc_tables_per_store <number>
tags_tables_per_store <number>

[DEFAULTS]
session_tables_per_store 2
fpc_tables_per_store 4
tags_tables_per_store 1

[CONFIG]
session_tables_per_store 2
fpc_tables_per_store 4
tags_tables_per_store 1

--------------------------------------------------------------------------------

[SECTION: Options - Health Check Interval]

The `health_check_interval` option defines how often server's
main/configuration thread will wake up to do health check. The check includes

1) making sure that the server actually listens to any addresses/ports,

2) checking that drives on which a) log file, b) session binlog file, and c) FPC
   binlog file reside still have at least `free_disk_space_warning_threshold`
   free bytes each,

3) checking that no thread (except binlog loader!) has spent more than
   `thread_activity_time_warning_threshold` milliseconds in "active" state
   processing an event that it received from its queue,

and logging warning messages if any of these checks fail; cumulative number of
warnings (along with number or errors and server load) is sent back by both
`CHECK` and `INFO` commands; one important difference between the two is that
the latter also runs a health check by itself, while the former only reports
results of previous scheduled health checks.

[FORMAT]
health_check_interval <duration>
free_disk_space_warning_threshold <size>
thread_activity_time_warning_threshold <milliseconds>

[DEFAULTS]
health_check_interval 10m
free_disk_space_warning_threshold 64M
thread_activity_time_warning_threshold 5000

[CONFIG]
health_check_interval 10m
free_disk_space_warning_threshold 64M
thread_activity_time_warning_threshold 5000

--------------------------------------------------------------------------------

[SECTION: Options - Response Compressors]

These options control which compressors will be used to compress responses
that are sent back by the server.

Compressor types are the same as used for `session_optimization_compressors`
and `fpc_optimization_compressors` options, except that here only one
compressor per option should be specified. Please see those options'
descriptions for information on compressor types.

> **IMPORTANT**: compressors specified by `xxx_response_compressor` family of
> options are *never* used to re-compress stored session/FPC records that are
> requested from the server. They are only used to compress dynamic data
> created while processing the request, such as lists of IDs, `INFO` command
> output, and the likes.

[FORMAT]
global_response_compressor <compressor>
session_response_compressor <compressor>
fpc_response_compressor <compressor>

[DEFAULTS]
global_response_compressor snappy
session_response_compressor snappy
fpc_response_compressor snappy

[CONFIG]
global_response_compressor zlib
session_response_compressor snappy
fpc_response_compressor snappy

--------------------------------------------------------------------------------

[SECTION: Options - Integrity Checks]

These options control whether integrity check bytes are sent at the end of
commands and responses, or stored in binlog -- *not* whether integrity check
is performed; presence of the integrity check is controlled by special bit in
both command in response headers, and if it was sent (or stored), it will be
checked by receiver (or loader) irrespective of these options' settings. And,
if the check fails, the command or response will be discarded, and error will
be logged.

The `command_integrity_check` option controls sending integrity check bytes to
replications servers; other options are self-explanatory.

[FORMAT]
command_integrity_check <boolean>
response_integrity_check <boolean>
binlog_integrity_check <boolean>

[DEFAULTS]
command_integrity_check true
response_integrity_check false
binlog_integrity_check true

[CONFIG]
command_integrity_check true
response_integrity_check false
binlog_integrity_check true

--------------------------------------------------------------------------------

[SECTION: Options - Binlogs]

Binlogs store session or FPC commands that alter data of the records stored in
cache; commands that only request information (or change settings etc.) are
never stored. A binlog can be played back (essentially restoring contents of a
store) using `RESTORE` console command, and that can be done without stopping
the server, which can concurrently continue servicing other requests.

Binlogs are controlled pretty much like the regular log, in that it is
possible to start the server with no binlog, and then issue `SET` command
setting binlog path for a store, which will start binlog. Similarly, in order
to enable binlog rotation, it is necessary to specify binlog rotation path,
which is a regular file path that *must* have at least one date/time
placeholder in it: either "%d" (which would be replaced with current
timestamp's integer value), or "%s" (which would be replaced with textual
representation of the timestamp), but not both. Binlog will be rotated (i.e.
current file will be closed and renamed, and new file will be created) when
binlog file size reaches threshold set by respective option. Additionally, it
is possible to force binlog rotation using `ROTATE` console command.

The `session_binlog_sync` and `fpc_binlog_sync` options contol how reliable
is writting to the file; available synchronization modes are:

- `none` : output is buffered, power outage will likely currupt the binlog;
  this is the fastest, but least reliable mode,

- `data-only` : data bytes are immediately written to underlying storage 
  hardware; file size is updated, but some metadata (e.g. last modification 
  timestamp) will be updated at some later time,

- `full` : not only data bytes, but file metadata are updeted immediately;
  this is the most reliable, but also the slowest mode.

> **NOTE**: CyberCache Cluster writes binlogs in concurrent threads, worker
> threads that process requests do *not* wait for binlog to store update data,
> so even "slow" synchronization modes that would "kill" a single-threaded
> cache might as well work just fine in CyberCache.

> **IMPORTANT**: binlog file must reside in a directory that is writable by
> `cybercached`; even though the server does not set any default binlog file
>  name, installation procedure does create directory where binlog files
>  might/should reside: `/var/lib/cybercache`, owned by user/group
>  `cybercache`; it is highly recommeded that options described in this
>  section point to files located in that directory. If both session and FPC
>  binlog names are specified, they **MUST** be different (or rather point to
>  different files).

Enabling session binlog might make sense in many scenarious, while enabling
FPC binlog -- only in environments with very high availability requirements.

[FORMAT]
session_binlog_file <path>
fpc_binlog_file <path>
session_binlog_rotation_path <path>
fpc_binlog_rotation_path <path>
session_binlog_rotation_threshold <size>
fpc_binlog_rotation_threshold <size>
session_binlog_sync { none | data-only | full }
fpc_binlog_sync { none | data-only | full }

[DEFAULTS]
session_binlog_file ''
fpc_binlog_file ''
session_binlog_rotation_path ''
fpc_binlog_rotation_path ''
session_binlog_rotation_threshold 256M
fpc_binlog_rotation_threshold 256M
session_binlog_sync none
fpc_binlog_sync none

[CONFIG]
session_binlog_file ''
fpc_binlog_file ''
session_binlog_rotation_path ''
fpc_binlog_rotation_path ''
session_binlog_rotation_threshold 256M
fpc_binlog_rotation_threshold 256M
session_binlog_sync none
fpc_binlog_sync none

--------------------------------------------------------------------------------

[SECTION: Options - Saving and Loading Databases]

CyberCache can be configured to store all cache records on shutdown, and then
re-load them on startup. Respective server options are completely independent
from those used to manage binlogs, although some look and act similarly. The
options are set on a per-store basis (i.e. separately for session and FPC
record stores).

The `xxx_db_sync` options work just like `xxx_binlog_sync` counterparts, and
control reliability of saving operations (what will happen if power goes down
during saving of records), see the above description of similar binlog
options; as always, there is tradeoff between speed and reliability.

The `xxx_db_include` options control which records will be saved at exit by
setting "lowest" user agent type whose records has to be preserved. They do
*not* affect loading from databases on startup though: whatever was stored,
will be loaded. CyberCache keeps track of user agents that were creating
records, so it is possible to differentiate them and only save "useful" ones.
If, say, `session_db_include` is set to `warmer`, then session records
created by cache warmer and regular users will be persisted, while records
created by unknown users and bots will not.

Finally, `xxx_db_file` options set file names of the database files. If those
names contain slashes ('/'), they will be treated as full paths and used
"as-is"; otherwise, path prefix (currently, `/var/lib/cybercache`) will be
added, for files to reside in CyberCache "database" directory.

The format of files created by `xxx_db_file` options is the same as that of
binlogs, so it is possible to [re-]load them any time using `RESTORE` console
command, or `c3_restore()` method of PHP extension. IFF session and FPC
databases are written to separate files (see below for the discussion of the
alternative), then employing `xxx_db_xxx` options is almost equivalent to
excuting two `STORE` commands (or two `c3_store()` calls) right before server
shutdown, and two `RESTORE` commands (or `c3_restore()` calls) right after
startup. Note that it's *almost* equivalent though: the use of `xxx_db_xxx`
options is still preferable as it's more reliable: server data will survive
any unexpected server restarts.

> **NOTE**: it is possible (but *not* recommended) to specify the same name for
> both session and FPC database files; in this case, upon startup the server
> will load all the records only once, and on shutdown will save session and
> FPC records to the same file. However, when server determines if files are
> "the same", it simply compares strings passed as arguments to
> `session_db_file` and `fpc_db_file`, it does **not** check if different
> paths refer to the same file. So if you, for instance, specify `my_db.blf`
> as session database and `/var/lib/cybercache/my_db.blf` (which refers to
> the same file in current CyberCache version) as FPC database, then on
> startup all records will be loaded twice (will cause no harm, but will
> result in a slowdown), and on shutdown you will lose all session records.

[FORMAT]
session_db_include { unknown | bot | warmer | user }
session_db_sync { none | data-only | full }
session_db_file <name-or-path>
fpc_db_include { unknown | bot | warmer | user }
fpc_db_sync { none | data-only | full }
fpc_db_file <name-or-path>

[DEFAULTS]
session_db_include user
session_db_sync data-only
session_db_file ''
fpc_db_include bot
fpc_db_sync none
fpc_db_file ''

[CONFIG]
session_db_include user
session_db_sync data-only
session_db_file '/var/lib/cybercache/session-store-db.blf'
fpc_db_include bot
fpc_db_sync none
fpc_db_file '/var/lib/cybercache/fpc-store-db.blf'

--------------------------------------------------------------------------------

[SECTION: Options - Auto-saving Databases]

In addition to saving/loading session and/or FPC databases upon server shutdown
and startup, it is also possible to configure CyberCache so that it would
periodically dump its databases to the files during normal operation, at set
intervals; that's what `session_auto_save_interval` and `fpc_auto_save_interval`
options are for. If a server hosting CyberCache shuts down abnormally (say,
because of a power outage) and is then restarted, CyberCache will automatically
load last saved session and FPC cache records -- because auto-saving utilizes
all the parameters set using `session_db_xxx` and `fpc_db_xxx` options, which
include names of the database files.

Setting `session_auto_save_interval` and/or `fpc_auto_save_interval` options to
`0` disables auto-saving for session and/or FPC store, respectively.

> **NOTE**: It is also possible to make CyberCache store its databases not at
> set intervals, but at specified time(s). Even though saving to a file does not
> normally slow down CyberCache (as it's done in a separate, specialized
> thread), one may want to, say, only do that immediately before and after work
> hours, and one more time at midnight. To do that, all that's needed is to use
> `cybercache` console application and its `-c`/`--command` option, which makes
> the console execute specified command and quit. The following command lines
> store session and FPC stores just as auto-saving would do (with default
> settings; please see console `store` command description for more info):
>
> * `cybercache -c 'store session session-store-db.blf user data-only'`
> * `cybercache -c 'store fpc fpc-store-db.blf bot none'`
>
> All that is needed is to put the above commands into server `crontab`, along
> with the information specifying when to run them. If auto-saving at other
> times is not needed, the `session_auto_save_interval` and
> `fpc_auto_save_interval` options should be set to zero.

[FORMAT]
session_auto_save_interval <duration>
fpc_auto_save_interval <duration>

[DEFAULTS]
session_auto_save_interval 0
fpc_auto_save_interval 0

[CONFIG]
session_auto_save_interval 30m
fpc_auto_save_interval 4h

--------------------------------------------------------------------------------

[SECTION: Options - Include Files]

Loads and parses another configuration file, as if contents of that file was
included at the point where `include` statement was encountered.

If option argument (path of the file to include) starts with `.` or `/`, then
it is used "as is"; othewise, the server will search for the file starting at
the folder where file contaning `include` statement is located. For instance,
if current file is "/etc/cybercached.cfg", than `include cluster/ips.inc` will
try to load and parse "/etc/cluster/ips.inc".

There can be any number of `include` statements in a configuration file (as
well as "-i"/"--include" command line arguments), but the depth to which
included files can be nested (i.e. 'include' statements in included files) is
restricted: Community Edition allows for up to two levels (base configuration
file + one nested), while Enterprise Edition supports up to 8.

[FORMAT]
include <path>

[DEFAULTS]
NONE

[CONFIG]
# include 'mysetup/myconfig.inc'

--------------------------------------------------------------------------------

[SECTION: Options - Daemon Version]

The 'version' option actually cannot be set in the configuration file, but it
is nonetheless mentioned here for the sake of completeness, because its value
can be retrieved using `GET` command, as if it was a configurable option.

[FORMAT]
version

[DEFAULTS]
<current-cybercached-version>

[CONFIG]
#

--------------------------------------------------------------------------------

[DOCSECTION: Performance Tuning]

CyberCache server configuration file contains dozens of options with names
starting with `perf_`, which are **not** supposed to be changed by CyberCache
users; please see comments in the configuration file for more info.

[CONFIG]
#
################################################################################
#                                                                              #
#                         ####  #####   ###   ####    #                        #
#                        #        #    #   #  #   #   #                        #
#                         ###     #    #   #  ####    #                        #
#                            #    #    #   #  #                                #
#                        ####     #     ###   #       #                        #
#                                                                              #
################################################################################
#
#                      NO USER-SERVICEABLE PARTS INSIDE!
#
# Presence of `perf_` in a name of an option is a very, *VERY* strong indication
# that it has full potential to completely screw your server. Values for these
# options had been chosen and fine-tuned very carefully, with lots of profiling
# runs, and full knowledge of what they affect, and how.
#
# Setting some option in this section to four times its current value will *not*
# magically make your cache four times faster; much, *MUCH* more likely it will
# make your rescue team having to scrap smoking pieces of your blown up server
# from four different corners of your server room. Heck, even *looking* at these
# options may negatively affect CyberCache performance!
#
# Seriously, though, the list of things that can go wrong as a direct
# consequence of messing with these options is very long, and completely hanging
# up or crashing your cache server is not even the worst outcome -- at least you
# would notice that immediately. You may start quietly wasting CPU cycles, or
# memory, or both. Customers of your e-commerce site can start losing their
# sessions and thus carts in minutes. Or you may weaken or disable CyberCache's
# defense against DDoS attacks, or you may prevent Google crawler from indexing
# your site; CyberCache *is* client-type-aware and manages different clients
# using different sets of settings, so testing a web site (with CyberCache
# behind it) as a regular user with a browser will tell you nothing as to how it
# will handle bots or anonymous attackers, and you will only discover the sad
# truth when it's too late. So if you still decide to proceed, remember that
# you are doing it AT YOUR OWN RISK. YOU'VE BEEN WARNED.
#
# Better yet, do have a closer look at various eviction-, lifetime-, hash- and
# compression-related options above, they provide ample opportunities to refine
# cache performance to better suit your session and/or FPC data sizes and
# contents, behavioral patterns of your customets, and your hardware, all of
# which you obviously know better than we do. Even those options may do enough
# harm if drastically misconfigured, yet altering them would be a much more
# prudent thing to do than changing any of the `perf_` options.
#
# Documentation of `perf_` options had been intentionally left very scarse (or
# rather left out). Names, values, and/or the effect of these options may change
# in future CyberCache versions without any notice whatsoever.
#

# settings controlling "emergency" deallocation (upon failure to allocate a new block)
perf_dealloc_chunk_size 64M
perf_dealloc_max_wait_time 1500 # milliseconds

# safety time limits for database saving operations
perf_store_wait_time 5s
perf_store_max_wait_time 10m

# optimizers' settings
# CPU load scale: 0% [1%..33%] (33%..66%] (66%..99%] 100%
perf_session_opt_num_checks 1000000000 1000 500 200 100 # CPU load-dependent
perf_fpc_opt_num_checks 1000000000 1000 500 200 100 # CPU load-dependent
perf_session_opt_num_comp_attempts 1000000000 100 25 10 0 # CPU load-dependent
perf_fpc_opt_num_comp_attempts 1000000000 100 25 10 0 # CPU load-dependent
perf_session_opt_retain_counts 1 2 2 250 # user agent-dependent
perf_fpc_opt_retain_counts 1 2 50 100 # user agent-dependent

# per-table object disposing quotas (while rehashing / not rehashing)
perf_session_unlinking_quotas 16 256
perf_fpc_unlinking_quotas 64 1024

# Enterprise Edition-only setting
# perf_num_internal_tag_refs 1

# shutdown-time checks
perf_thread_wait_quit_time 3000 # milliseconds

# hash table fill factors (0.5..10.0)
perf_session_table_fill_factor 1.5
perf_fpc_table_fill_factor 1.5
perf_tags_table_fill_factor 1.5

# hash table capacities at startup
perf_session_init_table_capacity 4096
perf_fpc_init_table_capacity 8192
perf_tags_init_table_capacity 256

# inter-thread communication queues' capacities
perf_session_opt_queue_capacity 32
perf_fpc_opt_queue_capacity 32
perf_session_opt_max_queue_capacity 1024
perf_fpc_opt_max_queue_capacity 1024
perf_session_store_queue_capacity 32
perf_fpc_store_queue_capacity 32
perf_session_store_max_queue_capacity 1024
perf_fpc_store_max_queue_capacity 2048
perf_tag_manager_queue_capacity 32
perf_tag_manager_max_queue_capacity 16384
perf_log_queue_capacity 8
perf_log_max_queue_capacity 1024
perf_session_binlog_queue_capacity 64
perf_session_binlog_max_queue_capacity 512
perf_fpc_binlog_queue_capacity 64
perf_fpc_binlog_max_queue_capacity 512
perf_binlog_loader_queue_capacity 4
perf_binlog_loader_max_queue_capacity 16
perf_listener_input_queue_capacity 64
perf_listener_input_queue_max_capacity 64
perf_listener_output_queue_capacity 64
perf_listener_output_queue_max_capacity 64
perf_session_replicator_queue_capacity 32
perf_session_replicator_max_queue_capacity 32
perf_fpc_replicator_queue_capacity 32
perf_fpc_replicator_max_queue_capacity 32
perf_session_replicator_local_queue_capacity 16
perf_session_replicator_local_max_queue_capacity 1024
perf_fpc_replicator_local_queue_capacity 16
perf_fpc_replicator_local_max_queue_capacity 1024
perf_config_queue_capacity 8
perf_config_max_queue_capacity 256

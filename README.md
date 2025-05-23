This is the documentation for creating a new test in GPAC test suite.

# Running the test suite

Before running the test suite, you should first synchronize external data not hosted in this repository:

```./make_tests.sh -sync-media -clean```

The external data is currently less than 300 MB.

- to run the entire test suite, do `make_tests.sh` or use the Makefile task `make test_suite`.
- to perform a quick run on the test suite, do `make_tests.sh -quick` : this will run only a subset of the tests.
- to run a dedicated test (for example HLS generation test), do `make_tests.sh scripts/hls-gen.sh

Running the test suite or a given test generates:
- result/all_logs.txt: logs of all tests that were executed 
- result/all_results.xml: GNU time/gtime statistics and execution status of all tests that were executed

The different options of make_tests.sh are given by the command:
```
./make_tests.sh -h
```

It is important to notice that tests are cached, so that only failed tests are re-launched when running the test suite. You can clean the status of the entire test suite by using `./make_tests.sh -clean`, or the status of a given script (for example HLS generation test) by using `./make_tests.sh scripts/hls-gen.sh -clean`.



# Writing a test
GPAC test suite is composed of scripts written in the Bash language. Tests are placed in testsuite/scripts/. Each `.sh` file in that folder will be executed when running the entire test suite or may be run individually.

Media files used in a test can be anywhere (local file, http URL).
- the environmnent variable `$MEDIA_DIR` can be used to access to data located in testsuite/media (located in this repository). 
- the environmnent variable `$EXTERNAL_MEDIA_DIR` can be used to access to data located in testsuite/external_media (not hosted in this repository). 

Scripts should use the `$TEMP_DIR` environment variable to get a directory where to place the file they generate.

This directory is cleaned after each script, unless `-tmp` option is set. This allows preparing variables or files for a series of tests.

__WARNING__
Since the temp directory is __ONLY__ cleaned after each script, be careful to remove any state file (for example dasher context) produced if you run several tests in the same script, or use different names for each test.

 
A simple GPAC test can be:
```
#!/bin/sh
MP4Box -add $MEDIA_DIR\foo.bar $TEMP_DIR\foo.mp4
```
or 
```
#!/bin/sh
gpac -play $MEDIA_DIR\foo.mp4
```

In order to provide test caching and produce the unified test report for all the tests, with common timing, logging, etc, `make_tests.sh` defines several functions that should be used in a test.

Each test has its own log file `$LOGS` in which you can write (a lot is already in there, such as test name/data and all stderr).

Tests may be customized depending on the platform they run on.
The environment variable `$GPAC_OSTYPE` can be used to test the binary version used; the currently defined values are `lin32`, `lin64`, `win32`, `win64`, `osx32`, `osx64` and `unknown`.
The environment variable `$GPAC_CPU`can be used to test the cpu type; the currently defined values are `x86` and `arm`.

## Simple Testing
A simple test whose result will be integrated in the test suite report is run using the single_test function.

### single_test 
Two arguments:
- `CMD_LINE`: Executes the given `CMD_LINE`. The command line must be passed between single or double quotes. 
- `TESTNAME`: specifies the test name

Each call generates:
- a log file called `TESTNAME-single-logs.txt` containg test name, command line and all stderr of the test. You should not use file logging of GPAC ( `-lf` or `-logs` options) in your command line.
- a file called `TESTNAME-single-passed.xml` containg the statistics of the test, as retrieved by GNU time/gtime.
`TESTNAME` shall be unique in the test suite. In case of doubts, run the test suite script with `-check-name`.

A simple test using `single_test` looks like:
```
#!/bin/sh
single_test "MP4Box -add $MEDIA_DIR\foo.bar $TEMP_DIR\foo.mp4" test01
```
or 
```
#!/bin/sh
single_test "gpac -play $MEDIA_DIR\foo.mp4" test02
```

### do_play_test 
Two or three arguments: 
- `TESTNAME`: specifies the test name for logging, as used in `single_test`
- `VIDEO_ARGS`: specifies the video arguments to be loaded. If not empty, a filter chain will be loaded using these arguments as source (i.e.,  `gpac -i VIDEO_ARGS`)
- `AUDIO_ARGS`: specifies the audio arguments to be loaded. If not empty, a filter chain will be loaded using these arguments as source (i.e.,  `gpac -i AUDIO_ARGS`). If `-`, argument is ignored but an audio filter subchain ( `aout` or `enc:aac`) will be added to the filter chain.
Performs a playback test using `gpac` with the arguments given in `VIDEO_ARGS` and `AUDIO_ARGS`.
If `-play` option is specified when running the tests, playbacks the sources.
If `-video`  option is specified when running the tests, encodes the result using H264 and AAC in `results/video/$TESTNAME.mp4`.


## Aggregating tests
When the results of several tests need to be aggregated, instead of using multiple `single_test` calls, sub-tests can be run within a test using the `do_test` function. 
This is useful when several tests require the generation of the same input file, for example.

A typical test with two subtests used in a batch will look like:
```
mytest()
{
test_begin $1
do_test CMD_LINE1 "Name1"
do_test CMD_LINE1 "Name2"
test_end
}

for i in * ; do
  mytest $i
done
```

### test_begin 
Argument:
- `TESTNAME`: specifies the test name for logging, as used in `single_test`

This function defines overridable variables:
- `$dump_size`: by default "192x192" but can be overriden by your test
- `$dump_dur`: by default "5" seconds but can be overriden by your test

### test_end
No argument.

This function triggers the end of the test and writes all logs and statistics.

The function evaluates the variable `$result`. If not empty, the test is considered failed, otherwise (default) the test has passed. 
All results of subtests are automatically appended to the `$result` variable in the `end_test` function.

__WARNING__
This variable can not be set in a subshell (eg in `some_function SOME_PARAM &` called during a test), it must be set in the shell calling `test_begin`.

### do_test
Two arguments:
- `CMD_LINE`: the command line to execute
- `SUBTEST_NAME`: the subtest name as it appears in the logs and in the stats

Performs a subtest in the current test. If needed, the return value is available in `$ret`. 
Function does nothing when the test is skipped (see below) or a previous error occured in the parent test `TESTNAME`.


## Test failure/success
A test is considered successful if the execution returned 0.
Some tests may return a non-zero value and still be considered successful (e.g. negative tests). In that case, errors to be ignored are placed in a file in the gpac/rules directory. If any of the line in this file is found, the test is considered successful. 
The error file is named:
- `TESTNAME-stderr.txt` for tests run with the function `single_test`
- `TESTNAME-SUBTEST_NAME-stderr.txt` for subtests run with `do_test`

## Customized test 
To customize a test, a file named `$TESTNAME.sh` can be placed in the gpac/rules directory. It is called before the actual test is run and allows custom variables to be set or overriding a given variable in a batch of tests, while still using a single generic test function. Directories variables shall not be modified. Other variables of the test suite documented here are reset at the beginning of each test.  

## Testing and caching results
In order to avoid running all tests again whenever one test fails, the GPAC testing environment caches previous test results. If an XML file corresponding to the test or subtest exists in the results folder, the test or subtest is not run. If you want to ignore previous results, use `make_tests.sh -clean` before running the test suite. If you only want to invalidate tests of a given script, use  `make_tests.sh -clean script.sh` 
In case a test requires generating files before testing, it is recommended to check the variable `test_skip` to check if the test is being skipped because cached. 

A typical test with several subtests checking for cache looks like:
```
test_begin TESTNAME
if [ $test_skip = 1 ] ; then
 return
fi
 
#create some file or costly operation
MP4Box -add 4GB.src -new TESTFILE
do_test CMD_LINE1_USING_TESTFILE "Name1"
do_test CMD_LINE2 "Name2"

test_end
```
In this example, failure to checktest `$test_skip` will make the script import 4GB.src even though all `do_test` calls will be skipped.

## Parallel tests with subscripts

Subtests may be run in subscripts, for example:
```
test_begin TESTNAME
 do_test CMD_LINE1 "Name1" &
 do_test CMD_LINE1 "Name2" &
test_end
```

Tests may also be run in subscript, for example:
```
function my_test {
  test_begin $2
  do_test $1 $2
  test_end
}

my_test CMD_LINE1 "Name1" &
my_test CMD_LINE2 "Name2" &
```


## Testing regressions with hashes

Tests may perform all the required checks to detect a regression, such as checking generated file info, counting importing samples, etc ... 
To simplify test writing, the GPAC testing environment provide simple hashing (SHA-1) functions that you can perform on generated files such as MP4 or TS files, logs, XML dumps, ... Using hashes avoid storing such files while allowing generic regression detection. Because of this functionality, the test suite has a specific mode for generating the hashes, `./make_tests -hash`. Hashes are typically generated only once, upon initial test creation.
The test suite script will mark a test as failed if it uses a missing reference hash.
- To clean hashes for a single test, use `./make_tests -clean-hash mytest.sh`
- To generate hashes for a single test, use `./make_tests -hash mytest.sh`

The following functions are available for hash testing.

### do_hash_test 
Two arguments
- `FILE`
- `HASHNAME`
When the test suite is run in hash generation mode, this generates the reference `hash_refs/$TESTNAME-$HASHNAME.hash`. Otherwise, creates a SHA-1 of FILE and compares it with the reference `$TESTNAME-$HASHNAME.hash`. 
Function does nothing when the test is skipped or a previous error occured in the parent test `TESTNAME`.

WARNING: `HASHNAME` shall be unique for a given test, otherwise hashes will be overwritten.

A subtest having its result reverted from fail to pass through a rule file will prevent the next hash test to be exectuted by setting the variable `skip_next_hash_test` to 1.
You can set this variable to 0 before calling  do_hash_test  if you need to force a hash test after a test failure.

### do_hash_test_bin
Same as `do_hash_test` except skips text mode probing of source file. Should only be used with non-text files.
 
### do_compare_file_hashes 
Two arguments
- `FILE1`
- `FILE2`
Compares hashes of `FILE1` and `FILE2`. returns 0 if OK or error code otherwise.
Function does nothing when the test is skipped (see below) or a previous error occured in the parent test `TESTNAME`.

A typical test with several subtests and hash testing looks like:
```
test_begin TESTNAME
if [ $test_skip = 1 ] ; then
 return
fi
 
#run some test creating a file FILE1
do_test CMD_LINE1_CREATING_FILE1 "Name1"
#perform hash on FILE1 - the hash name may be the same as the subtest names
do_hash_test FILE1 "Name1"

#run some test inspecting file FILE1, generating report in FILE2
do_test CMD_LINE1_INSPECTING_FILE1 "Name2"
do_hash_test FILE2 "Name1-inspect"

test_end
```

## Testing events and interactivity

The test suite has a UI trace generation mode used to record user events (mouse and keyboards) for SVG and BIFS interactivity testing for the media [compositor filter](https://wiki.gpac.io/Filters/compositor/).

In this modes, all subtests are skipped (i.e.  `$test_skip` is  1), and the variable `$test_ui` is set to 1. A test may use the `do_ui_test` function to perform UI recording. As of GPAC 0.9.0, trace files have to be manually loaded by the test using them, as shown in [BT tests](https://github.com/gpac/testsuite/blob/filters/scripts/bt.sh).

### do_ui_test
Two arguments:
- `FILE`: the command line to execute
- `SUBTEST_NAME`: the subtest name as it appears in the logs and in the stats

Performs UI event trace generation on `$FILE` for the subtest using gpac, for a running duration of `$dump_dur` and an output size `$dump_size` (see `begin_test`). 
UI file is generated as `$RULES_DIR/${basename $FILE.*}-$SUBTEST-ui.xml`.

A typical usage is:

```
test_begin TESTNAME
do_ui_test $MEDIA_DIR/somefile "play"

if [ $test_skip = 1 ] ; then
 return
fi

#create some file or costly operation
uirec=$RULES_DIR/${basename $FILE.*}-$SUBTEST-ui.xml
do_test "$GPAC -i $MEDIA_DIR/somefile --cfg=Validator:Mode=Play -cfg=Validator:Trace=$uirec -o dump.rgb"

test_end
```

Note that the file has to be generated
- before testing cache status since all tests are considered as cached in UI modes
- manually, since subtests are deactivated when the test is cached



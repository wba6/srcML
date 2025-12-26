#!/bin/bash
# framework_test.sh
#
# Test framework for cli testing
#
# * Always source this file before any test cli commands are given
#   source $(dirname "$0")/framework_test.sh
#
# * Perform cli command
#
# * Call function check to verify the command, e.g.,
#   check 3<<- 'STDOUT'
#     <unit/>
#     STDOUT
#
# * Optionally also specify expected stderr of command, e.g.,
#   check 3<<- 'STDOUT' 4<<- 'STDERR'
#     <unit/>
#     STDOUT
#     STDERR
#
# * If a comparison pipe is not open, then it assumes blank
#   I.e., the following check assumes that both stdout and stderr are empty
#   check
#
# * Instead of pipe 3 being the expected contents of stdout of the command, it can be file, i.e.
#   check foo.xml
#
# * Multiple tests of cli command followed by call to function check
#   can be made

# current revision number, replaced in expected output strings
export REVISION=1.0.0

# construct a temporary directory name based on the test name (without the .sh)
ORIG_PWD=$PWD
TEMPDIR=./tmp/$(basename $0 .sh)

# print all errors
trap 'if [ $? -ne 0 ] && [ -f "$STDERR" ]; then echo "!!! SCRIPT CRASHED. STDERR:"; cat "$STDERR"; fi' EXIT

# remove old TEMPDIR, and create new fresh one
rm -fR $TEMPDIR
mkdir -p $TEMPDIR
cd $TEMPDIR

# make sure to find the srcml executable, if majority of tests are failing, this is probably the problem
export PATH=.:$PATH
if [[ "$OSTYPE" == msys* || "$OSTYPE" == cygwin* ]]; then
    echo "DEBUG: Configuring for MSYS/Windows" >&2
    EOL="\r\n"
    export MSYS2_ARG_CONV_EXCL="*"
    diff='diff -Z --strip-trailing-cr '

    # PREFERRED: Use the exact path provided by CMake
    if [ -n "$SRCML_EXE" ]; then
        SRCML="$SRCML_EXE"
        echo "DEBUG: Using cmake provided srcml: '$SRCML'" >&2
    # Fallback: Check system PATH
    elif command -v srcml >/dev/null 2>&1; then
        SRCML=$(command -v srcml)
        echo "DEBUG: Found srcml in PATH at '$SRCML'" >&2
    # Last Resort: Hardcoded home
    else
        SRCML="$SRCML_HOME/srcml.exe"
        echo "DEBUG: Fallback to SRCML_HOME: '$SRCML'" >&2
    fi
else
    echo "DEBUG: Configuring for Unix/Linux" >&2
    EOL="\n"
    diff='diff --strip-trailing-cr '
    if [ -z "$SRCML" ]; then

        if [ -e "/usr/bin/srcml" ]; then
            SRCML='/usr/bin/srcml'
        fi

        if [ -e "/usr/local/bin/srcml" ]; then
            SRCML='/usr/local/bin/srcml'
        fi

        if [ -z "$SRCML" ]; then
            if command -v srcml >/dev/null 2>&1; then
                SRCML=$(command -v srcml)
            elif [ -x "$ORIG_PWD/../../.."/bin/srcml ]; then
                SRCML="$ORIG_PWD/../../.."/bin/srcml
            fi
        fi

    fi
fi

echo "DEBUG: Final SRCML command set to: '$SRCML'" >&2

is_msys_windows() {
    [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* ]]
}

normalize_file_windows() {
    # Normalizes a file in-place for Windows/MSYS test stability:
    # convert backslashes to forward slashes (paths inside XML attributes)
    # drop carriage returns (CR) that can break some parsers/tests
    local f="$1"
    [ -z "$f" ] && return 0
    [ ! -f "$f" ] && return 0

    # Convert \ -> /
    sed -i 's|\\|/|g' "$f" 2>/dev/null || true

    # Remove ALL \r characters
    sed -i 's/\r//g' "$f" 2>/dev/null || true
}

# Health Check Function
check_srcml_health() {
    # Only run this check once
    if [ -n "$SRCML_HEALTH_CHECKED" ]; then
        return
    fi
    export SRCML_HEALTH_CHECKED=1

    echo "=== DEBUG: srcML Health Check ===" >&2
    echo "Executable path: $SRCML" >&2

    if [ ! -f "$SRCML" ]; then
        echo "❌ CRITICAL ERROR: srcML executable not found at '$SRCML'" >&2
        ls -l "$(dirname "$SRCML")" >&2
        exit 1
    fi

    # Check for missing DLLs on Windows (using ldd)
    if is_msys_windows; then
        if command -v ldd > /dev/null; then
            # Filter output for "not found"
            ldd "$SRCML" | grep "not found" && echo "❌ MISSING DLL DETECTED via ldd" >&2
        fi
    fi

    # Dry Run - catches immediate crashes
    echo "Attempting to run: $SRCML --version" >&2
    "$SRCML" --version > /dev/null 2> health_check.err
    local exit_code=$?

    if [ $exit_code -ne 0 ]; then
        echo "❌ CRITICAL ERROR: srcML crashed immediately! Exit code: $exit_code" >&2
        echo "Possible causes: Missing DLLs (libarchive, libxml2) or architecture mismatch." >&2
        echo "Stderr from health check:" >&2
        cat health_check.err >&2
        
        # On failure, dump full dependencies
        if is_msys_windows; then
             command -v ldd >/dev/null && ldd "$SRCML" >&2
        fi
        rm -f health_check.err
        exit 1
    else
        echo "✅ srcML started successfully." >&2
        rm -f health_check.err
    fi
    echo "=================================" >&2
}

# Run the health check once SRCML path is set
check_srcml_health

function srcml () {
    # On Windows/MSYS, convert arguments that look like paths to Windows format
    if is_msys_windows; then
        local args=()
        for arg in "$@"; do
            # Check if argument is a file or directory that exists
            if [ -e "$arg" ]; then
                # Convert to Windows path (e.g., C:\Path\To\File)
                args+=("$(cygpath -w "$arg")")
            else
                args+=("$arg")
            fi
        done
        "$SRCML" "${args[@]}"
    else
        "$SRCML" "$@"
    fi
}

# turn history on so we can output the command issued
# note that the fc command accesses the history
set -o history
HISTIGNORE=check:\#
HISTSIZE=2
HISTFILESIZE=0

# output the first entry in the history file, without numbers
firsthistoryentry() {
    fc -l -n -1
}

CAPTURE_STDOUT=true
CAPTURE_STDERR=true

# variable $1 is set to the contents of stdin
define() {

    # read stdin into variable $1
    IFS= read -r -d '' $1 || true

    # replace any mention of REVISION with the revision number,
    eval $1=\${$1//REVISION/${REVISION}}

    # On Windows checkouts (CRLF), heredocs can embed \r.
    # that can break srcml parsing for some inputs (e.g., preprocessor tests).
    if is_msys_windows; then
        eval $1=\${$1//$'\r'/}
    fi
}

# variable $1 is set to the contents of stdin
defineXML() {
    define $1
    # Check if xmllint exists before running it to prevent crashes on Windows
    if command -v xmllint &> /dev/null; then
        echo "${!1}" | xmllint --noout /dev/stdin
    fi
}

# file with name $1 is created from the contents of string variable $2
# created files are recorded so that cleanup can occur
createfile() {
    # make directory paths as needed
    mkdir -p $(dirname $1)

    # add contents to file
    echo -ne "${2}" > ${1}
}

rmfile() { rm -f ${1}; }

rmdir()  { rm -fr ${1}; }

# capture stdout and stderr
capture_output() {
    [ "$CAPTURE_STDOUT" = true ] && exec 3>&1 1>$STDOUT
    [ "$CAPTURE_STDERR" = true ] && exec 4>&2 2>$STDERR
}

# uncapture stdout and stderr
uncapture_output() {
    [ "$CAPTURE_STDOUT" = true ] && exec 1>&3
    [ "$CAPTURE_STDERR" = true ] && exec 2>&4
}

message() {
    # return stdout and stderr to standard streams
    uncapture_output

    # trace the command
    echo "$1" >&2

    capture_output

    true
}

# output filenames for capturing stdout and stderr from the command
base=$(basename $0 .sh)

typeset STDERR=.stderr_$base
typeset STDOUT=.stdout_$base

# save stdout and stderr to our files
capture_output

##
# checks the result of a command
#
# If stdout is not specified, it is assumed to be empty
# If stderr is not specified, it is assumed to be empty
check() {

    local exit_status=$?

    set -e

    # testfile pattern
    line=$(caller | cut -d' ' -f1)
    TEMPFILE=$PWD'/.test.'$line

    # return stdout and stderr to standard streams
    uncapture_output

    # trace the command
    firsthistoryentry

    # This fixes the diff errors where output is "sub\a.cpp" but expected is "sub/a.cpp"
    if is_msys_windows; then
        normalize_file_windows "$STDOUT"
        normalize_file_windows "$STDERR"

        if [ $# -ge 1 ] && [ -n "$1" ] && [ -e "$1" ]; then
            normalize_file_windows "$1"
        fi
    fi

    # check <filename> stdoutstr stderrstr
    if [ $# -ge 3 ]; then

        tmpfile2=$TEMPFILE.2
        echo -en "$2" > $tmpfile2
        $diff $tmpfile2 $1

        tmpfile3=$TEMPFILE.3
        echo -en "$3" > $tmpfile3
        $diff $tmpfile3 $STDERR

    # check <filename> stdoutstr
    # note: empty string reports as a valid file
    elif [ $# -ge 2 ] && [ "$1" != "" ] && [ -e "$1" ]; then

        tmpfile2=$TEMPFILE.2
        echo -en "$2" > $tmpfile2
        $diff $tmpfile2 $1

        [ ! -s $STDERR ]

    # check stdoutstr stderrstr
    elif [ $# -ge 2 ]; then

        tmpfile1=$TEMPFILE.1
        echo -en "$1" > $tmpfile1
        $diff $tmpfile1 $STDOUT

        tmpfile2=$TEMPFILE.2
        echo -en "$2" > $tmpfile2
        $diff $tmpfile2 $STDERR

    # check <filename>
    elif [ $# -ge 1 ] && [ "$1" != "" ] && [ -e "$1" ]; then

        $diff $1 $STDOUT

        [ ! -s $STDERR ]

    # check stdoutstr
    elif [ $# -ge 1 ]; then

        tmpfile1=$TEMPFILE.1
        echo -en "$1" > $tmpfile1
        $diff $tmpfile1 $STDOUT

        [ ! -s $STDERR ]

    else
        # check that the captured stdout is empty
        [ ! -s $STDOUT ]
        [ ! -s $STDERR ]
    fi

    set +e

    if [ $exit_status -ne 0 ]; then
        echo "❌ Command failed with exit status $exit_status" >&2
        if [ -s $STDERR ]; then
             echo "--- STDERR Output (failure cause) ---" >&2
             cat $STDERR >&2
             echo "-------------------------------------" >&2
        fi
        exit 1
    fi

    # return to capturing stdout and stderr
    capture_output

    true
}

##
# checks the result of a command
#
# If stdout is not specified, it is assumed to be empty
# If stderr is not specified, it is assumed to be empty
check_file() {

    local exit_status=$?

    # return stdout and stderr to standard streams
    uncapture_output

    # trace the command
    firsthistoryentry

    set -e

    if is_msys_windows; then
        normalize_file_windows "$1"
        normalize_file_windows "$2"
    fi

    $diff $2 $1
    [ ! -s $STDERR ]

    if [ $exit_status -ne 0 ]; then
        echo "❌ Command failed with exit status $exit_status" >&2
        cat $STDERR >&2
        exit 1
    fi

    set +e

    # return to capturing stdout and stderr
    capture_output

    true
}

##
# checks the exit status of a command
#   $1 expected return value
check_exit() {

    local exit_status=$?

    # return stdout and stderr to standard streams
    uncapture_output

    # trace the command
    firsthistoryentry

    # verify expected stderr to the captured stdout
    if [ $exit_status -ne $1 ]; then
        echo "error: exit was $exit_status instead of $1"
        if [ -s $STDERR ]; then
             echo "--- STDERR Output ---" >&2
             cat $STDERR >&2
        fi
        exit 8
    fi

    set -e

    # testfile pattern
    line=$(caller | cut -d' ' -f1)
    TEMPFILE=$PWD'/.test.'$line

    if is_msys_windows; then
        normalize_file_windows "$STDOUT"
        normalize_file_windows "$STDERR"
    fi


    if [ $# -eq 2 ]; then
        tmpfile2=$TEMPFILE.2
        echo -en "$2" > $tmpfile2
        $diff $tmpfile2 $STDERR

        [ ! -s $STDOUT ]
    fi

    if [ $# -eq 3 ]; then
        tmpfile2=$TEMPFILE.2
        echo -en "$2" > $tmpfile2
        $diff $tmpfile2 $STDOUT

        tmpfile3=$TEMPFILE.3
        echo -en "$3" > $tmpfile3
        $diff $tmpfile3 $STDERR
    fi

    set +e

    # return to capturing stdout and stderr
    capture_output

    true
}

##
# checks the exit status of a command
#   $1 expected number in stdout
check_lines() {

    # return stdout and stderr to standard streams
    uncapture_output

    # trace the command
    firsthistoryentry

    local stdcount=$(wc -l $STDOUT | cut -d'.' -f1 | sed 's/^ *//;s/ *$//')

    # verify expected stderr to the captured stdout
    if [ "$stdcount" != "$1" ]; then
        echo "error: expected $1 lines, got $stdcount"
        exit 9
    fi

    # return to capturing stdout and stderr
    capture_output

    true
}

# Check the validity of the xml
# Currently only checks for well-formed xml, not DTD validity
xmlcheck() {

    set -e

    if command -v xmllint &> /dev/null; then

        if [ "${1:0:1}" != "<" ]; then
            xmllint --noout ${1}
        else
            echo "${1}" | xmllint --noout /dev/stdin
        fi;
    fi;

    set +e
    true
}

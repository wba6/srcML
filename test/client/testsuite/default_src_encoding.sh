#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
#
# @file default_src_encoding_unit.sh
#
# @copyright Copyright (C) 2013-2024 srcML, LLC. (www.srcML.org)

# test framework
source $(dirname "$0")/framework_test.sh

# test
define sfile1 <<< "//é"

defineXML foutput <<- 'STDOUT'
	<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
	<unit xmlns="http://www.srcML.org/srcML/src" revision="REVISION" language="C++" filename="sub/a.cpp"><comment type="line">//é</comment>
	</unit>
STDOUT

defineXML foutput8859 <<- 'STDOUT'
	<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
	<unit xmlns="http://www.srcML.org/srcML/src" revision="1.0.0" language="C++" filename="sub/a.cpp"><comment type="line">//eÌ</comment>
	</unit>
STDOUT

createfile sub/a.cpp "$sfile1"
createfile sub/a.cpp.xml "$foutput"

srcml sub/a.cpp --src-encoding "UTF-8"
check "$foutput"

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

srcml sub/a.cpp.xml -X
check "$foutput"

srcml sub/a.cpp.xml
check "$sfile1"

srcml sub/a.cpp.xml --src-encoding "ISO8859-1"
check "//e&#769;"

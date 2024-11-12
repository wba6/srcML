<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!--
    @file eolterminate.xsl

    @copyright Copyright (C) 2024 srcML, LLC. (www.srcML.org)

    Copy but insert EOL terminate
-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:src="http://www.srcML.org/srcML/src"
    xmlns="http://www.srcML.org/srcML/src"
    xmlns:cpp="http://www.srcML.org/srcML/cpp"
    xmlns:str="http://exslt.org/strings"
    xmlns:func="http://exslt.org/functions"
    xmlns:exsl="http://exslt.org/common"
    extension-element-prefixes="
    str exsl func"
    exclude-result-prefixes="src"
    version="1.0">

<xsl:import href="copy.xsl"/>

<!-- Match text nodes that are exactly ';' and not within src:empty or src:control -->
<xsl:template match="text()[. = ';'][not(ancestor::src:empty)][not(ancestor::src:control)]"/>

<!-- Special cases where the terminate is part of the keyword text -->
<xsl:template match="text()[. = 'break;']">break</xsl:template>
<xsl:template match="text()[. = 'return;']">return</xsl:template>

</xsl:stylesheet>

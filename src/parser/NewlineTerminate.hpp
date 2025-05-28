// SPDX-License-Identifier: GPL-3.0-only
/**
 * @file NewlineTerminate.hpp
 *
 * @copyright Copyright (C) 2024 srcML, LLC. (www.srcML.org)
 *
 * This file is part of the srcML Toolkit.
 *
 * Injects INDENT and DEDENT tokens to the token stream
 */

#ifndef INCLUDED_NEWLINETERMINATE_HPP
#define INCLUDED_NEWLINETERMINATE_HPP

#include <antlr/TokenStream.hpp>
#include <srcMLToken.hpp>
#include <srcMLParser.hpp>
#include <deque>

class NewlineTerminate : public antlr::TokenStream {

public:

    NewlineTerminate(antlr::TokenStream& input) : input(input) {}

    antlr::RefToken nextToken();

private:
    antlr::TokenStream& input;
    std::deque<antlr::RefToken> buffer;
    antlr::RefToken lastToken = srcMLToken::factory();
};

#endif

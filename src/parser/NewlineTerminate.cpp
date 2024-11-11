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

#include <NewlineTerminate.hpp>

/**
 * An abstract method for getting the next token.
 * 
 * Whenever a `blockStartToken` is found, an INDENT token is generated. Whenever the next line starts with
 * less indentation that the previous line, a DEDENT token is generated (ignores blank lines).
 * 
 * INDENT and DEDENT are meant to handle blocks in languages such as Python that use a colon to represent
 * the start of a block (as opposed to curly braces, etc.).
 */
antlr::RefToken NewlineTerminate::nextToken() {

    if (buffer.empty()) {
        auto token = input.nextToken();
        if (token->getType() == srcMLParser::EOL && lastToken->getType() != srcMLParser::TERMINATE
                && lastToken->getType() != srcMLParser::RCURLY
                && lastToken->getType() != srcMLParser::ELSE) {

            // create new terminate token
            auto terminateToken = srcMLToken::factory();
            terminateToken->setType(srcMLParser::TERMINATE);
            terminateToken->setColumn(1);
            terminateToken->setLine(token->getLine());

            // insert terminal token
            buffer.emplace_back(terminateToken);
        }

        if (token->getType() != srcMLParser::WS)
            lastToken = token;

        // insert read token
        buffer.emplace_back(token);
    }

    auto token = buffer.front();
    buffer.pop_front();
    return token;
}

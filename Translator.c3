module translator;
import std::io;
import std::collections::list;

const LETTERS = `ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_.:`;
const NUMBERS = `1234567890.⁄_`;
const MERGE = `¶``"'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz$@_1234567890.:`;
const PARENOPEN = `([{`;
const PARENCLOSE = `)]}`;
const PAREN = `()[]{}`;
const QUOTE = ```"'`;

enum TokenType
{
    FUNC,
    OP,
    VAL,
    PAREN,
    KEY,
    NIL
}

struct Token
{  
    TokenType type;
    String text;
    short order;
}

fn short order(String symbol)
{
    switch (symbol)
    {
        case "+": return 1;
        case "-": return 1;
        case "*": return 2;
        case "/": return 2;
        case "**": return 3;
        case "//": return 2;
        case "///": return 2;
        case "%": return 0;
        case "&": return -1;
        case "|": return -1;
        case "^": return -1;
        case "&&": return -4;
        case "||": return -5;
        case "^^": return -5;
        case "==": return -2;
        case "!=": return -2;
        case "<": return -3;
        case ">": return -3;
        case "<=": return -3;
        case ">=": return -3;
        case "~=": return -2;
        case "===": return -2;
        case "<*": return -3;
        case "*>": return -3;
        case "#": return 2;
        case "+++": return 1;
        case "<->": return 0;
        case ",": return -64;
        case ";": return -128;
        case "<>?/": return -6;
        case "!<>/": return -6;
        case "<>?": return -32;
        case "!<>?": return -32;
        case "!<>": return -32;
        case "<>?*": return -32;
        case "=": return -16;
        case "": return 6;
        default: return 63;
    }
}

fn List{Token} lexer(String text)
{
    List{Token} result;
    List{Token} yard;
    DString symbol = {};
    DString word = {};
    uint charidx = 1;
    Token softtoken;
    softtoken.type = PAREN;
    softtoken.text = "(";
    softtoken.order = -32768;
    yard.push(softtoken);
    String digit = "";
    String prev = "(";
    while (charidx < text.len)
    {
        prev = digit;
        DString d_digit = {};
        d_digit.append(text[charidx..charidx]);
        if (text[charidx] & 0xC0 == 0xC0) { charidx++; while (text[charidx] & 0xC0 == 0x80) { d_digit.append(text[charidx..charidx]); charidx++; }; charidx--; }
        digit = d_digit.str_view();
        if (MERGE.contains(digit)) {
            if (symbol.str_view().len > 0)
            {
                Token token;
                token.type = OP;
                token.text = symbol.str_view();
                token.order = order(symbol.str_view());
                if (yard.len() >= 1)
                {
                    while (yard.len() >= 1 && (token.order < yard[yard.len()-1].order || (token.order == yard[yard.len()-1].order && token.order < 3 || token.type == FUNC)) && !(PARENOPEN.contains(yard[yard.len()-1].text)))
                    {
                        result.push(yard[yard.len()-1]);
                        yard.pop()!!;
                    }
                }
                yard.push(token);
                symbol = {};
            }
            //else if (yard.len() > 1)
            //{
            //    sz length = yard.len();
            //    while (length > 1) { result.push(yard[length-1]); yard.pop()!!; length--; }
            //}
            if (digit != "")
            {
                if (digit == "¶")
                {
                    charidx ++;
                    while (charidx < text.len && text[charidx..charidx] != "\n")
                    {
                        word.append(text[charidx..charidx]);
                        charidx++;
                    };
                    String quotes = word.str_view().treplace("`","``");
                    word = {};
                    word.append("`"); word.append(quotes); word.append("`");
                }
                else if (QUOTE.contains(digit))
                {
                    String quote = digit;
                    charidx += 1;
                    while (charidx < text.len && text[charidx..charidx] != quote)
                    {
                        word.append(text[charidx..charidx]);
                        charidx++;
                    };
                    String quotes = word.str_view().treplace("`","``");
                    word = {};
                    word.append("`"); word.append(quotes); word.append("`");
                }
                else if (digit == ":" && word.str_view().len > 0) { if (LETTERS.contains(word.str_view()[0..0]) && digit == ":") { word.append("::"); } else { word.append(":"); } }
                else { word.append(digit); }
            }
        } else {
            if (digit == "#" && prev == "#")
            {
                while (charidx < text.len && text[charidx..charidx] != "\n") { charidx++; }
            }
            if (word.str_view().len > 0)
            {
                Token token;
                token.text = word.str_view();
                token.order = 63;
                if (word.str_view() == "$IMPORT" || word.str_view() == "$PRINT" || word.str_view() == "$INT" || word.str_view() == "$FLOAT" || word.str_view() == "$STRING" || word.str_view() == "$EXEC" || word.str_view() == "$IMPORTSTRING") { token.type = KEY; result.push(token); }
                else if (digit == "(") { token.type = FUNC; yard.push(token); }
                else { token.type = VAL; result.push(token); }
                word = {};
            }
            if (digit == "°")
            {
                Token token;
                token.text = "DEG";
                token.order = 63;
                token.type = KEY;
                result.push(token);
            }
            else if (digit != "" && digit != " " && digit != "\n" && !(PAREN.contains(digit)))
            {
                symbol.append(digit);
                if (PARENOPEN.contains(prev)) { Token token; token.text = "0"; token.type = VAL; result.push(token); }
            }
            else if (yard.len() >= 1 && PAREN.contains(digit))
            {
                if (symbol.str_view().len > 0 && prev != "\n")
                {
                    Token token;
                    token.type = OP;
                    token.text = symbol.str_view();
                    token.order = order(symbol.str_view());
                    if (yard.len() >= 1)
                    {
                        while (yard.len() >= 1 && (token.order < yard[yard.len()-1].order || (token.order == yard[yard.len()-1].order && token.order < 3 || token.type == FUNC)) && !(PARENOPEN.contains(yard[yard.len()-1].text)))
                        {
                            result.push(yard[yard.len()-1]);
                            yard.pop()!!;
                        }
                    }
                    yard.push(token);
                    symbol = {};
                }
                Token token;
                token.type = PAREN;
                token.text = digit;
                token.order = order(digit);
                if (PARENOPEN.contains(digit)) { yard.push(token); }
                if (PARENCLOSE.contains(digit)) { while (yard.len() > 1 && !(PARENOPEN.contains(yard[yard.len()-1].text))) { result.push(yard[yard.len()-1]); yard.pop()!!; }; yard.pop()!!; result.push(token); }
            }
            else
            {
                if (symbol.str_view().len > 0 && prev != "\n")
                {
                    Token token;
                    token.type = OP;
                    token.text = symbol.str_view();
                    token.order = order(symbol.str_view());
                    if (yard.len() >= 1)
                    {
                        while (yard.len() >= 1 && (token.order < yard[yard.len()-1].order || (token.order == yard[yard.len()-1].order && token.order < 3 || token.type == FUNC)) && !(PARENOPEN.contains(yard[yard.len()-1].text)))
                        {
                            result.push(yard[yard.len()-1]);
                            yard.pop()!!;
                        }
                    }
                    yard.push(token);
                    symbol = {};
                }
            }
        }
        charidx ++;
    }
    while (yard.len()>1) { result.push(yard[yard.len()-1]); yard.pop()!!; }
    return result;
}

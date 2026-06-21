module translator;
import std::io;
import std::collections::list;

const LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_.:";
const NUMBERS = "1234567890.⁄_";
const MERGE = "¶ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_1234567890.:";
const PARENOPEN = "([{";
const PARENCLOSE = ")]}";
const PAREN = "()[]{}";

enum TokenType
{
    FUNC,
    OP,
    VAL,
    PAREN,
    IMPORT,
    PRINT,
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
        case "<:": return -3;
        case ":>": return -3;
        case "#": return 2;
        case "..": return 0;
        case ",": return -64;
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
    softtoken.text = "{";
    softtoken.order = -32768;
    yard.push(softtoken);
    while (charidx < text.len)
    {
        String digit = text[charidx..charidx];
        String prev = text[(charidx-1)..(charidx-1)];
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
            //    while (yard.len() > 1) { result.push(yard[yard.len()-1]); yard.pop()!!; }
            //}
            if (digit != "")
            {
                if ("¶".contains(digit))
                {
                    charidx += 2;
                    while (charidx < text.len && text[charidx..charidx] != "\n")
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
                if (word.str_view() == "IMPORT") { token.type = IMPORT; result.push(token); }
                else if (word.str_view() == "PRINT") { token.type = PRINT; result.push(token); }
                else if (digit == "(") { token.type = FUNC; yard.push(token); }
                else { token.type = VAL; result.push(token); }
                word = {};
            }
            if (digit != "" && digit != " " && digit != "\n" && !(PAREN.contains(digit)))
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
                if (PARENCLOSE.contains(digit)) { while (yard.len() > 1 && !(PARENOPEN.contains(yard[yard.len()-1].text))) { result.push(yard[yard.len()-1]); yard.pop()!!; }; yard.pop()!!;}
            }
        }
        charidx ++;
    }
    while (yard.len()>1) { result.push(yard[yard.len()-1]); yard.pop()!!; }
    return result;
}

/*
fn void main()
{
}
*/

/*
cd ~/Documents/c3
c3c compile-run Translator.c3
*/

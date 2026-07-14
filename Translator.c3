module translator;
import std::io;
import std::collections::list;

const LETTERS = `ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_.\`;
const NUMBERS = `1234567890.⁄_`;
const DIGITS = `1234567890`;
const MERGE = `¶``"'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz$@_1234567890.\`;
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
//    PAREN,

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
        case "×": return 2;
        case "÷": return 2;
        case "**": return 3;
        case "//": return 2;
        case "///": return 2;
        case "%": return 0;
        case "<<": return 0;
        case ">>": return 0;
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
        case ">->": return -1;
        case ">+>": return -1;
        case ":": return -1;
        case ",": return -64;
        case ";": return -128;
        case "<>?/": return -6;
        case "!<>/": return -6;
        case "<>?": return -32;
        case "!<>?": return -32;
        case "!<>": return -32;
        case "<>?*": return -32;
        case "=": return -16;
        case "ineach": return -1;
        case "in": return -3;
        case "contains": return -3;
        case "and": return -4;
        case "or": return -5;
        case "xor": return -5;
        case "notand": return -4;
        case "notor": return -5;
        case "notxor": return -5;
        case "bitand": return -1;
        case "bitor": return -1;
        case "bitxor": return -1;
        case "at": return 0;
        case "slice": return 0;
        //case "module": return 31;
        case "": return 6;
        default: return 63;
    }
}

fn DString prefixed(String quoted, String prefix)
{
    String quotes = quoted;
    //if (!prefix.contains("r") && !prefix.contains("c")) { quotes = quotes.treplace("\\e","\e"); quotes = quotes.treplace("\\n","\n"); quotes = quotes.treplace("\\t","\t"); quotes = quotes.treplace("\\0","\0"); }prefix.contains("c")prefix.contains("h")if () {  }if () .treplace(`"`,`\x22`)11{  }.treplace(`"`,`\x211`).treplace();
    String container = `"`;
    String previous = ``;
    foreach (pre:prefix)
    {
        switch (pre)
        {
            case 'c': container = `'`; quotes = quotes.treplace(`'`,`\x27`);
            case 'h': container = ``; quotes = `$I_DONT_EXIST`;
            case '$': container = ``;
            case 's': previous = previous.tconcat(`(String)`);
            case 'b': previous = previous.tconcat(`(char[])`);
            case 'r': container = "`"; quotes = quotes.treplace("`","``");
            default: ;
        }
    }
    if (prefix.contains("x")) { previous = previous.tconcat("x"); }
    if (!prefix.contains("r") && !prefix.contains("$")) { quotes = quotes.treplace(`"`,`\x22`); }
    DString word = {};
    word.append(`(`); word.append(previous); word.append(container); word.append(quotes); word.append(container); word.append(`)`);
    return word;
}

fn List{Token} lexer(String text)
{
    io::printn("--Translator--");
    List{Token} result;
    List{Token} yard;
    DString symbol = {};
    DString word = {};
    ulong charidx = 1;
    Token softtoken;
    softtoken.type = PAREN;
    softtoken.text = "(";
    softtoken.order = -32768;
    yard.push(softtoken);
    //result.push(softtoken);
    String digit = "";
    String prev = "(";
    String next = "";
    while (charidx < text.len)
    {
        prev = digit;
        DString d_digit = {};
        d_digit.append(text[charidx..charidx]);
        if (text[charidx] & 0xC0 == 0xC0) { charidx++; while (text[charidx] & 0xC0 == 0x80) { d_digit.append(text[charidx..charidx]); charidx++; }; charidx--; }
        digit = d_digit.str_view();
        //next = (charidx+1==(ulong)text.len)?"":text[(charidx+1)..(charidx+1)];
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
            //{:
            //    sz length = yard.len();
            //    while (length > 1) { result.push(yard[length-1]); yard.pop()!!; length--; }
            //}:
            if (digit != "")
            {
                if (digit == "¶")
                {
                    String prefix = word.str_view();
                    word = {};
                    charidx ++;
                    while (charidx < text.len && text[charidx..charidx] != "\n")
                    {
                        word.append(text[charidx..charidx]);
                        charidx++;
                    };
                    String quotes = word.str_view();
                    word = prefixed(quotes,prefix);
                }
                else if (QUOTE.contains(digit))
                {
                    String prefix = word.str_view();
                    word = {};
                    String quote = digit;
                    charidx ++;
                    while (charidx < text.len && text[charidx..charidx] != quote)
                    {
                        word.append(text[charidx..charidx]);
                        charidx++;
                    };
                    String quotes = word.str_view();
                    word = prefixed(quotes,prefix);
                }
                else if (digit == "\\" && word.str_view().len > 0) { if (LETTERS.contains(word.str_view()[0..0]) ) { word.append("::"); } else { word.append("\\"); } }//::: && && digit == ""
                else { word.append(digit); }
            }
        } else {
            if (digit == "#" && prev == "#")
            {
                while (charidx < text.len && text[charidx..charidx] != "\n") { charidx++; }
            }
            if (word.str_view().len > 0)// && !((digit == " " || digit == "\n") && (next == " " || next == "\n"))
            {
                Token token;
                token.text = word.str_view();
                if (token.text[token.text.len-1] == '\\') { token.text = token.text[0..token.text.len-2]; }
                char endof = token.text[token.text.len-1];
                if (DIGITS.contains(token.text[0..0]))
                {
                    if (endof == 'b' && !token.text.contains("x")) { token.text = "0b".tconcat(token.text[0..token.text.len-2]); }
                    if (endof == 'o') { token.text = "0o".tconcat(token.text[0..token.text.len-2]); }
                    if (endof == 'x') { token.text = "0x".tconcat(token.text[0..token.text.len-2]); }
                }
                token.order = 63;
                if (token.text == "$IMPORT" || token.text == "$PRINT" || token.text == "$INT" || token.text == "$FLOAT" || token.text == "$STRING" || token.text == "$EXEC" || token.text == "$IMPORTSTRING" || token.text == "($I_DONT_EXIST)" || token.text == "$IMPORTCOLOR" || token.text == "do" || token.text == "then") { while (yard.len()>1 && !(PARENOPEN.contains(yard[yard.len()-1].text))) { result.push(yard[yard.len()-1]); yard.pop()!!; }; token.type = KEY; result.push(token); }//  || token.text == "end" || token.text == "else"
                else if (digit == "(") { token.type = FUNC; yard.push(token); }
                else if (token.text == "ineach" || token.text == "in" || token.text == "contains" || token.text == "and" || token.text == "or" || token.text == "xor" || token.text == "notand" || token.text == "notor" || token.text == "notxor" || token.text == "bitand" || token.text == "bitor" || token.text == "bitxor" || token.text == "at" || token.text == "slice") { token.type = OP; token.order = order(token.text); if (yard.len() >= 1) { while (yard.len() >= 1 && (token.order < yard[yard.len()-1].order || (token.order == yard[yard.len()-1].order && token.order < 3 || token.type == FUNC)) && !(PARENOPEN.contains(yard[yard.len()-1].text))) { result.push(yard[yard.len()-1]); yard.pop()!!; } }; yard.push(token); }
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
            else if (digit != "" && digit != " " && digit != "\n" && digit != ";" && digit != "," && digit != "\\" && !(PAREN.contains(digit)))
            {
                symbol.append(digit);
                if (PARENOPEN.contains(prev)) { Token token; token.text = "0"; token.type = VAL; result.push(token); }
            }
            else if (yard.len() >= 1 && PAREN.contains(digit))
            {
                if (symbol.str_view().len > 0 && prev != "" && prev != " " && prev != "\n" && prev != ";" && prev != "," && prev != "\\")
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
                if (PARENOPEN.contains(digit)) { yard.push(token); result.push(token); }
                if (PARENCLOSE.contains(digit)) { while (yard.len() > 1 && !(PARENOPEN.contains(yard[yard.len()-1].text))) { result.push(yard[yard.len()-1]); yard.pop()!!; }; yard.pop()!!; result.push(token); if (yard.len() >= 1 && yard[yard.len()-1].type == FUNC) { result.push(yard[yard.len()-1]); yard.pop()!!; } }
            }
            else if ((digit == ";" || digit == "," || (digit == "\n" && prev != "\\" && prev != "}" && !PARENOPEN.contains(prev) && symbol.str_view() == "")))//( && next.len > 0 && LETTERS.contains(next))yard[yard.len()-1]result[result.len()-1].type != OP ||  && (result.len() >= 1 && result[result.len()-1].type != KEY)!. && next != "{" && next != "}"
            {
                if (symbol.str_view().len > 0 && prev != "\n" && prev != ";" && prev != "\\" && prev != "" && prev != " ")
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
                token.type = PAREN;//OP//()(digit==",") ? "," : ";"
                token.text = digit;
                token.order = (digit==",") ? -64 : -128;
                if (yard.len() >= 1)
                {
                    while (yard.len()>1 && !(PARENOPEN.contains(yard[yard.len()-1].text))) { result.push(yard[yard.len()-1]); yard.pop()!!; }
                }
                result.push(token);
            }
            else
            {
                if (symbol.str_view().len > 0 && prev != "" && prev != " " && prev != "\n" && prev != ";" && prev != "," && prev != "\\")
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
        //if (result.len() > 0) { if (result[0].type == PAREN && result[0].text == "soft(") { yard.push(result[0]); result.remove_at(0); } } io::printn(result[0]);soft
        charidx ++;
    }
    while (yard.len()>1) { result.push(yard[yard.len()-1]); yard.pop()!!; }
    result.pop()!!;
    return result;
}

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
    //if (!prefix.contains("r") && !prefix.contains("c")) { quotes = quotes.treplace("\\e","\e"); quotes = quotes.treplace("\\n","\n"); quotes = quotes.treplace("\\t","\t"); quotes = quotes.treplace("\\0","\0"); }
    String container = `"`;
    if (prefix.contains("c")) { container = `'`; quotes = quotes.treplace(`'`,`\x27`); }
    if (prefix.contains("h")) { container = ``; quotes = `$I_DONT_EXIST`; }
    DString word = {};
    word.append(container); word.append(quotes); word.append(container);
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
            //{
            //    sz length = yard.len();
            //    while (length > 1) { result.push(yard[length-1]); yard.pop()!!; length--; }
            //}
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
                    String quotes = word.str_view().treplace(`"`,`\x21`);
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
                    String quotes = word.str_view().treplace(`"`,`\x21`);
                    word = prefixed(quotes,prefix);
                }
                else if (digit == ":" && word.str_view().len > 0) { if (LETTERS.contains(word.str_view()[0..0]) && digit == ":") { word.append("::"); } else { word.append(":"); } }
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
                token.order = 63;
                if (word.str_view() == "$IMPORT" || word.str_view() == "$PRINT" || word.str_view() == "$INT" || word.str_view() == "$FLOAT" || word.str_view() == "$STRING" || word.str_view() == "$EXEC" || word.str_view() == "$IMPORTSTRING" || word.str_view() == "$I_DONT_EXIST" || word.str_view() == "do" || word.str_view() == "then") { while (yard.len()>1 && !(PARENOPEN.contains(yard[yard.len()-1].text))) { result.push(yard[yard.len()-1]); yard.pop()!!; }; token.type = KEY; result.push(token); }// || word.str_view() == "end" || word.str_view() == "else"
                else if (digit == "(") { token.type = FUNC; yard.push(token); }
                else if (word.str_view() == "ineach" || word.str_view() == "in" || word.str_view() == "contains" || word.str_view() == "and" || word.str_view() == "or" || word.str_view() == "xor" || word.str_view() == "notand" || word.str_view() == "notor" || word.str_view() == "notxor" || word.str_view() == "bitand" || word.str_view() == "bitor" || word.str_view() == "bitxor" || word.str_view() == "at" || word.str_view() == "slice") { token.type = OP; token.order = order(word.str_view()); if (yard.len() >= 1) { while (yard.len() >= 1 && (token.order < yard[yard.len()-1].order || (token.order == yard[yard.len()-1].order && token.order < 3 || token.type == FUNC)) && !(PARENOPEN.contains(yard[yard.len()-1].text))) { result.push(yard[yard.len()-1]); yard.pop()!!; } }; yard.push(token); }
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
            else if (digit != "" && digit != " " && digit != "\n" && digit != ";" && digit != "\\" && !(PAREN.contains(digit)))
            {
                symbol.append(digit);
                if (PARENOPEN.contains(prev)) { Token token; token.text = "0"; token.type = VAL; result.push(token); }
            }
            else if (yard.len() >= 1 && PAREN.contains(digit))
            {
                if (symbol.str_view().len > 0 && prev != "" && prev != " " && prev != "\n" && prev != ";" && prev != "\\")
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
            else if ((digit == ";" || (digit == "\n" && prev != "\\" && !PARENOPEN.contains(prev) && symbol.str_view() == "" && next != "{" && next != "}")))//( && next.len > 0 && LETTERS.contains(next))yard[yard.len()-1]result[result.len()-1].type != OP ||  && (result.len() >= 1 && result[result.len()-1].type != KEY)!.
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
                token.type = PAREN;//OP//()
                token.text = ";";
                token.order = -128;
                if (yard.len() >= 1)
                {
                    while (yard.len()>1 && !(PARENOPEN.contains(yard[yard.len()-1].text))) { result.push(yard[yard.len()-1]); yard.pop()!!; }
                }
                result.push(token);
            }
            else
            {
                if (symbol.str_view().len > 0 && prev != "" && prev != " " && prev != "\n" && prev != ";" && prev != "\\")
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

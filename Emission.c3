module emission;
import translator;
import std::io;
import std::collections::list;

const PI = 3.1415926535897932;

fn String unstring(String str) { return (translator::QUOTE.contains(str[0..0])) ? str[1..(str.len-2)].treplace(`\x21`,`"`) : str; }

fn String join(String x, String y) { DString z={}; z.append(x); z.append(y); return z.str_view(); }

fn String basebiop(String open, String x, String op, String y, String close)
{
    DString base = {};
    base.append(open);
    base.append(x);
    base.append(op);
    base.append(y);
    base.append(close);
    return base.str_view();
}

fn String codegen(List{Token} tokens, String[] opredef, String name)
{
    io::printn("--Emission--");
    DString modules = {};
    modules.append("module ");
    modules.append(name);
    modules.append(";\nimport std::io;\nimport std::math;\n\n");
    //DString text = {};//
    //text.append("fn void main(){ ");
    List{String} yard = {};
    foreach(token : tokens)
    {
        //io::printn(token);
        switch (token.type)
        {
            case FUNC:
                String z = yard[yard.len()-1];
                yard.pop()!!;
                switch (token.text)//()()()//String type = yard[yard.len()-1]; type yard.push("void");void//
                {
                    case "print": yard.push(basebiop("io::printn","",z,"",";"));
                    case "printf": yard.push(basebiop("io::printfn","",z,"",";"));
                    case "input": yard.push(basebiop("(io::treadline","",z,"","!!)"));
                    case "input_int": yard.push(basebiop("((io::treadline","",z,"","!!).to_int()!!)"));
                    case "flush": yard.push(basebiop("io::flush","",z,"",";"));
                    case "not": yard.push(basebiop("!","",z,"",""));
                    default: if (yard.len() >= 1 && yard[yard.len()-1] == "fn") { yard.pop()!!; yard.push("fn void"); }; yard.push(basebiop(token.text,"",z,"",""));
                }
            case OP:
                if (yard.len() >= 2)
                {
                    String x = yard[yard.len()-2];
                    String y = yard[yard.len()-1];
                    yard.pop()!!;
                    yard.pop()!!;
                    if (false)
                    {
                        yard.push("");
                    }
                    else
                    {
                        switch (token.text)
                        {
                            case "+": yard.push(basebiop("(",x,"+",y,")"));
                            case "-": yard.push(basebiop("(",x,"-",y,")"));
                            case "*": yard.push(basebiop("(",x,"*",y,")"));
                            case "/": yard.push(basebiop("(",x,"/",y,")"));
                            case "×": yard.push(basebiop("(",x,"*",y,")"));
                            case "÷": yard.push(basebiop("(",x,"/",y,")"));
                            case "**": yard.push(basebiop("(pow(",x,",",y,"))"));
                            case "//": yard.push(basebiop("(sz)(",x,"/",y,")"));
                            case "///": yard.push(basebiop("((double)",x,"/",y,")"));
                            case "%": yard.push(basebiop("(",x,"%",y,")"));
                            case "<<": yard.push(basebiop("(",x,"<<",y,")"));
                            case ">>": yard.push(basebiop("(",x,">>",y,")"));
                            case "&": yard.push(basebiop("(",x,"&",y,")"));
                            case "|": yard.push(basebiop("(",x,"|",y,")"));
                            case "^": yard.push(basebiop("(",x,"^",y,")"));
                            case "&&": yard.push(basebiop("(",x,"&&",y,")"));
                            case "||": yard.push(basebiop("(",x,"||",y,")"));
                            case "^^": yard.push(basebiop("(",x,"^^",y,")"));
                            case "==": yard.push(basebiop("(",x,"==",y,")"));
                            case "!=": yard.push(basebiop("(",x,"!=",y,")"));
                            case "<": yard.push(basebiop("(",x,"<",y,")"));
                            case ">": yard.push(basebiop("(",x,">",y,")"));
                            case "<=": yard.push(basebiop("(",x,"<=",y,")"));
                            case ">=": yard.push(basebiop("(",x,">=",y,")"));
                            case "≤": yard.push(basebiop("(",x,"<=",y,")"));
                            case "≥": yard.push(basebiop("(",x,">=",y,")"));
                            case "<*": yard.push(basebiop("((",y,").contains(",x,"))"));
                            case "*>": yard.push(basebiop("((",x,").contains(",y,"))"));
                            case "+++": yard.push(basebiop("((",x,").tconcat(",y,"))"));
                            case ">->": yard.push(basebiop("",x,"..",y,""));
                            case ">+>": yard.push(basebiop("",x,":",y,""));
                            case ":": yard.push(basebiop("",x,":",y,""));
                            case ",": yard.push(basebiop("",x,",",y,""));
                            case ";": yard.push(basebiop("",x,";",y,""));
                            case "<>?/": yard.push(basebiop("",x,"?",y,""));
                            case "!<>/": yard.push(basebiop("",x,":",y,""));
                            case "<>?": yard.push(basebiop("if (",x,") ",y,""));
                            case "!<>?": yard.push(basebiop("else if (",x,") ",y,""));
                            case "!<>": yard.push(basebiop("",x," else ",y,""));
                            case "<>?*": yard.push(basebiop("while (",x,") ",y,""));
                            case "=": yard.push(basebiop("",x,"=",y,""));
                            case "ineach": yard.push(basebiop("",x," : ",y,""));
                            case "in": yard.push(basebiop("",y,".contains(",x,")"));
                            case "contains": yard.push(basebiop("",x,".contains(",y,")"));
                            case "and": yard.push(basebiop("(",x,"&&",y,")"));
                            case "or": yard.push(basebiop("(",x,"||",y,")"));
                            case "xor": yard.push(basebiop("(",x,"^^",y,")"));
                            case "notand": yard.push(basebiop("!(",x,"&&",y,")"));
                            case "notor": yard.push(basebiop("!(",x,"||",y,")"));
                            case "notxor": yard.push(basebiop("!(",x,"^^",y,")"));
                            case "bitand": yard.push(basebiop("(",x,"&",y,")"));
                            case "bitor": yard.push(basebiop("(",x,"|",y,")"));
                            case "bitxor": yard.push(basebiop("(",x,"^",y,")"));
                            case "at": yard.push(basebiop("",x,"[",y,"]"));
                            case "slice": yard.push(basebiop("",x,"[",y,"]"));
                            //case "module": modules.append(basebiop("module ",x,";\n",unstring(y),"\n"));
                        }
                    }
                }
                else
                { io::printn("--CODEGEN ERROR: STACK UNDERFLOW--"); io::printn(token.text); return "ERROR - STACK UNDERFLOW"; }
            case VAL: if (token.text == "module") { while (yard.len() >= 1 && yard[yard.len()-1] == ";") { yard.pop()!!; } }; if (token.text[0] == '.') { yard[yard.len()-1] = yard[yard.len()-1].tconcat(token.text); } else { yard.push(token.text); }// || module == "" || module == "fn"String module = ;module ^
            case PAREN:
                String parentype = token.text;
                String z = (yard.len()>0) ? (yard[yard.len()-1]) : ("");
                //yard.pop()!!;
                switch (parentype)
                {
                    case ")": yard.push(")");//`.treplace("`","``")`basebiop("","(",z,")","")basebiop("","[",z,"]","")basebiop("","{",z,";}","")basebiop("","",z,";","")yard.push(z)yard.push(z); ;
                    case "]": yard.push("]");
                    case "}": yard.push("}");
                    case "\n": if (!translator::PARENOPEN.contains(yard[yard.len()-1]) && yard[yard.len()-1] != ";" ) { yard.push(";"); if (yard[yard.len()-3] == "module") { yard.push("import std::io; import std::math; import std::collections::list"); yard.push(";"); } }
                    case ";": if (yard[yard.len()-1] != ";" ) { yard.push(";"); if (yard[yard.len()-3] == "module") { yard.push("import std::io; import std::math; import std::collections::list"); yard.push(";"); } }// && yard[yard.len()-1]//[yard[yard.len()-1].len-1] != '}'
                    case ",": yard.push(",");
                    default: yard.push(parentype);
                }
                if (translator::PARENCLOSE.contains(parentype))
                {
                    String tokensinyard = {};
                    while (yard.len() > 1 && !translator::PARENOPEN.contains(yard[yard.len()-1]))
                    {
                        tokensinyard = yard[yard.len()-1].tconcat(tokensinyard); tokensinyard = " ".tconcat(tokensinyard);
                        yard.pop()!!;
                    }
                    tokensinyard = yard[yard.len()-1].tconcat(tokensinyard);
                    yard.pop()!!;
                    //if (translator::LETTERS.contains(yard[yard.len()-1][(yard[yard.len()-1].len)..(yard[yard.len()-1])]))
                    yard.push(tokensinyard);
                }
            case KEY:
                String z = yard[yard.len()-1];
                yard.pop()!!;
                switch (token.text)
                {
                    case "$IMPORT": modules.append("\nimport "); modules.append(z); modules.append(";");
                    case "$PRINT": yard.push(basebiop("","io::printn(",z,");",""));
                    case "$INT": yard.push(join("int ",z));
                    case "$FLOAT": yard.push(join("double ",z));
                    case "$STRING": yard.push(join("String ",z));
                    case "$EXEC": yard.push(unstring(z));
                    case "$STRINGIMPORT": modules.append("\n"); modules.append(unstring(z)); modules.append(";");
                    case "($I_DONT_EXIST)":;
                    case "$IMPORTCOLOR": yard.push(z); yard.push(`; const BLANK = "\e[0m"; const BLACK = "\e[90m"; const RED = "\e[91m"; const GREEN = "\e[92m"; const YELLOW = "\e[93m"; const BLUE = "\e[94m"; const MAGENTA = "\e[95m"; const CYAN = "\e[96m"; const WHITE = "\e[97m";`);
                    case "DEG": yard.push(basebiop("(",z,"*","3.1415926535897932/180",")"));
                    case "do": yard.push(basebiop("","(",z,")",""));
                    case "then": yard.push(basebiop("","(",z,")",""));
                    //case "end": yard.push(basebiop("","{",unstring(z),"}",""));
                    //case "else": yard.push(basebiop("","{",unstring(z),"} else",""));
                }
            case NIL: yard.push("");
        }
    };
    foreach (token : yard) { modules.append(token); modules.append(" "); }//texttext; modules.append()``1"\nconst BLACK = \x22\\e[90m\x22;\nconst RED = \x22\\e[91m\x22;\nconst GREEN = \x22\\e[92m\x22;\nconst YELLOW = \x22\\e[93m\x22;\nconst6"AAAAABBW//
    //modules.append("; ");
    //text.append(";}");
    //modules.append(text.str_view());
    return modules.str_view();
}

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
    modules.append(";\nimport std::collections::list;\nimport std::io;\nimport std::io::file;\nimport std::math;\n\n");////aiqa::core
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
                if (z[0] == '(')// || (token.text == "with" && z[0] == '{')
                {
                    switch (token.text)//()()()//String type = yard[yard.len()-1]; type yard.push("void");void//''file//;index_of(" ");;//;[];//;/,;/;unstringed;file =  defer(void)file.close();:;;1;.; 11;;1;
                    {
                        case "printr": yard.push(basebiop("io::print","",z,"",";"));
                        case "print": yard.push(basebiop("io::printn","",z,"",";"));
                        case "printf": yard.push(basebiop("io::printfn","",z,"",";"));
                        case "input": yard.push(basebiop("(io::treadline","",z,"","!!)"));
                        case "input_int": yard.push(basebiop("((io::treadline","",z,"","!!).to_int()!!)"));
                        case "flush": yard.push(basebiop("io::flush","",z,"",";"));
                        case "not": yard.push(basebiop("(!","",z,"",")"));
                        case "panic": yard.push(basebiop("(","",z,"","!!)"));
                        case "cname": yard.push(basebiop("@cname","",z,"",""));
                        case "concat": yard.push(basebiop("tconcat","",z,"",""));
                        case "append": yard.push(basebiop("tappend","",z,"",""));
                        case "push": yard.push(basebiop("tpush","",z,"",""));
                        case "open": yard.push(basebiop("file::open","",z,"","!!;"));
                        case "load": yard.push(basebiop("(file::load_temp","",z,"","!!)"));
                        case "load_str": yard.push(basebiop("((String)(file::load_temp","",z,"","!!))"));
                        //case;
                        default: if (yard.len() >= 1 && yard[yard.len()-1] == "fn") { yard.pop()!!; yard.push("fn void"); }; yard.push(basebiop(token.text,"",z,"",""));
                    }
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
                        switch ((token.text[^1] == '=' && token.text != "=" && token.text[^2..^1] != "==" && token.text[^2..^1] != "~=" && token.text[^2..^1] != "!=" && token.text[^2..^1] != "<=" && token.text[^2..^1] != ">=") ? ((((token.text[0] == '!' && token.text != "!=") || (token.text[0] == '~' && token.text != "~=")) ? token.text[1..^2] : token.text[0..^2])) : ((((token.text[0] == '!' && token.text != "!=") || (token.text[0] == '~' && token.text != "~=")) ? token.text[1..^1] : token.text))) // token.text.len 1 
                        {
                            case "+": yard.push(basebiop("(",x," + ",y,")"));
                            case "-": yard.push(basebiop("(",x," - ",y,")"));
                            case "*": yard.push(basebiop("(",x," * ",y,")"));
                            case "/": yard.push(basebiop("(",x," / ",y,")"));
                            case "×": yard.push(basebiop("(",x," * ",y,")"));
                            case "÷": yard.push(basebiop("(",x," / ",y,")"));
                            case "**": yard.push(basebiop("(math::pow(",x,",",y,"))"));
                            case "//": yard.push(basebiop("(sz)(",x," / ",y,")"));
                            case "///": yard.push(basebiop("((double)",x," / ",y,")"));
                            case "%": yard.push(basebiop("(",x," % ",y,")"));
                            case "<<": yard.push(basebiop("(",x," << ",y,")"));
                            case ">>": yard.push(basebiop("(",x," >> ",y,")"));
                            case "&": yard.push(basebiop("(",x," & ",y,")"));
                            case "|": yard.push(basebiop("(",x," | ",y,")"));
                            case "^": yard.push(basebiop("(",x," ^ ",y,")"));
                            case "&&": yard.push(basebiop("(",x," && ",y,")"));
                            case "||": yard.push(basebiop("(",x," || ",y,")"));
                            case "^^": yard.push(basebiop("(",x," ^^ ",y,")"));
                            case "==": yard.push(basebiop("(",x," == ",y,")"));
                            case "!=": yard.push(basebiop("(",x," != ",y,")"));
                            case "<": yard.push(basebiop("(",x," < ",y,")"));
                            case ">": yard.push(basebiop("(",x," > ",y,")"));
                            case "<=": yard.push(basebiop("(",x," <= ",y,")"));
                            case ">=": yard.push(basebiop("(",x," >= ",y,")"));
                            case "≤": yard.push(basebiop("(",x," <= ",y,")"));
                            case "≥": yard.push(basebiop("(",x," >= ",y,")"));
                            case "<*": yard.push(basebiop("((",y,").contains(",x,"))"));
                            case "*>": yard.push(basebiop("((",x,").contains(",y,"))"));
                            case "+++": yard.push(basebiop("((",x,").tconcat(",y,"))"));
                            case ">->": yard.push(basebiop("",x,"..",y,""));
                            case ">+>": yard.push(basebiop("",x," : ",y,""));
                            case "?": yard.push(basebiop("",x," ? ",y,""));
                            case ":": yard.push(basebiop("",x," : ",y,""));
                            case ",": yard.push(basebiop("",x,", ",y,""));
                            case ";": yard.push(basebiop("",x,"; ",y,""));
                            case "=>": yard.push(basebiop("",x," => ",y,""));
                            case "<>?/": yard.push(basebiop("",x," ? ",y,""));
                            case "!<>/": yard.push(basebiop("",x," : ",y,""));
                            case "<>?": yard.push(basebiop("if (",x,") ",y,""));
                            case "!<>?": yard.push(basebiop("else if (",x,") ",y,""));
                            case "!<>": yard.push(basebiop("",x," else ",y,""));
                            case "<>?*": yard.push(basebiop("while (",x,") ",y,""));
                            case "=": yard.push(basebiop("",x," = ",y,""));
                            case ".": yard.push(basebiop("(",x,".",y[1..^1],")"));
                            case "=.": yard.push(basebiop(x," = ",x,".",y[1..^1]));
                            case "->": yard.push(basebiop("((*",x,").",y,")"));
                            case " ": yard.push(basebiop("",x," ",y,""));
                            case "ineach": yard.push(basebiop("",x," : ",y,""));
                            case "in": yard.push(basebiop("",y,".contains(",x,")"));
                            case "contains": yard.push(basebiop("",x,".contains(",y,")"));
                            case "and": yard.push(basebiop("(",x," && ",y,")"));
                            case "or": yard.push(basebiop("(",x," || ",y,")"));
                            case "xor": yard.push(basebiop("(",x," ^^ ",y,")"));
                            case "notand": yard.push(basebiop("(!(",x," && ",y,"))"));
                            case "notor": yard.push(basebiop("(!(",x," || ",y,"))"));
                            case "notxor": yard.push(basebiop("(!(",x," ^^ ",y,"))"));
                            case "bitand": yard.push(basebiop("(",x," & ",y,")"));
                            case "bitor": yard.push(basebiop("(",x," | ",y,")"));
                            case "bitxor": yard.push(basebiop("(",x," ^ ",y,")"));
                            case "at": yard.push(basebiop("",x,"[",y,"]"));
                            case "slice": yard.push(basebiop("",x,"[",y,"]"));//module"module ",x,";\n",unstring(y),"\n"modulesmodulesappendappend
                        }
                        if ((token.text[0] == '!' && token.text != "!=") || (token.text[0] == '~' && token.text != "~=")) { String z = yard[yard.len()-1]; yard.pop()!!; yard.push(basebiop("(",token.text[0..0],"(",z,"))")); }
                        if (token.text[^1] == '=' && token.text != "=" && token.text[^2..^1] != "==" && token.text[^2..^1] != "~=" && token.text[^2..^1] != "!=" && token.text[^2..^1] != "<=" && token.text[^2..^1] != ">=") { String z = yard[yard.len()-1]; yard.pop()!!; yard.push(basebiop("",x," = ",z,"")); }// else {  }
                    }
                }
                else if (yard.len() >= 1) { String z = yard[yard.len()-1]; yard.pop()!!; yard.push(basebiop("(",token.text,z,"",")")); }//io::printn("--CODEGEN ERROR: STACK UNDERFLOW--"); io::printn(token.text); return "ERROR - STACK UNDERFLOW";
                else { yard.push(token.text); }
            case VAL: if (token.text == "module") { while (yard.len() >= 1 && yard[yard.len()-1] == ";") { yard.pop()!!; } }; yard.push(token.text);
            case PAREN:
                String parentype = token.text;
                String z = (yard.len()>0) ? (yard[yard.len()-1]) : ("");
                //yard.pop()!!;
                switch (parentype)
                {
                    case ")": yard.push(")");//`.treplace("`","``")`basebiop("","(",z,")","")basebiop("","[",z,"]","")basebiop("","{",z,";}","")basebiop("","",z,";","")yard.push(z)yard.push(z); ;''yard[yard-1]
                    case "]": yard.push("]");
                    case "}": yard.push("}");
                    case "›": yard.push("›");
                    case "\n": if (!translator::PARENOPEN.contains(yard[yard.len()-1]) && yard[yard.len()-1] != ";" ) { yard.push(";"); if (yard[yard.len()-3] == "module") { yard.push("import std::io; import std::math; import std::collections::list"); yard.push(";"); } }
                    case ";": if (yard[yard.len()-1] != ";" ) { yard.push(";"); if (yard[yard.len()-3] == "module") { yard.push("import std::collections::list; import std::io; import std::io::file; import std::math;"); yard.push(";"); } }// && yard[yard.len()-1]//[yard[yard.len()-1].len-1] != '}'import aiqa::core;''
                    case ",": yard.push(",");
                    default: yard.push(parentype);
                    //case "‹": ;‹
                }
                if (translator::PARENCLOSE.contains(parentype))
                {
                    String tokensinyard = {};
                    while (yard.len() >= 1 && !translator::PARENOPEN.contains(yard[yard.len()-1]))
                    {
                        tokensinyard = yard[yard.len()-1].tconcat(tokensinyard); tokensinyard = " ".tconcat(tokensinyard);
                        yard.pop()!!;
                    }
                    tokensinyard = yard[yard.len()-1].tconcat(tokensinyard);
                    yard.pop()!!;
                    if (parentype == "›") { tokensinyard = ((tokensinyard.len > 6) ? tokensinyard[3..^4] : ""); } // 1
                    //if (translator::LETTERS.contains(yard[yard.len()-1][(yard[yard.len()-1].len)..(yard[yard.len()-1])]))
                    //##if (yard[yard.len()-1].len > 5 && yard[yard.len()-1][0..4] == "main(") { tokensinyard = tokensinyard[0..^2].tconcat(`; io::printn("\exm--DONE--"); }`); }
                    if (yard.len() >= 1 && yard[yard.len()-1].len > 5 && yard[yard.len()-1][0..4] == "with(" && tokensinyard[0] == '{')
                    {
                        String with_string = yard[yard.len()-1][4..^1];
                        sz space = with_string[2..^2].index_of(" ")!!+2;
                        String type = with_string[2..(space-1)];
                        String variable = with_string[(space+1)..(with_string.index_of("=")!!-2)];
                        String code_def = with_string[2..^2].tconcat("; ");
                        String code_block = tokensinyard[2..^2].tconcat("; ");
                        //io::printfn("type: `%s`; variable: `%s`; code: `%s`;",type,variable,code); // :.tconcat()sz semi_colon = code.index_of("!!;")!!+2; [0..semi_colon][(semi_colon+1)..^2]
                        String code;
                        switch (type)
                        {
                            case "File": code = code_def.tconcat(" defer(void)").tconcat(variable).tconcat(".close(); ").tconcat(code_block).tconcat(variable).tconcat(".flush()!!;");
                        }
                        yard.pop()!!;
                        yard.push(code);
                    }
                    else { yard.push(tokensinyard); }
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
                    //case "panic": yard.push(basebiop("","((",z,")!!)",""));
                    //case "end": yard.push(basebiop("","{",unstring(z),"}",""));
                    //case "else": yard.push(basebiop("","{",unstring(z),"} else",""));
                    default: yard.push(z.tconcat(token.text)); // basebiop("","",,"",)
                }
            case NIL: yard.push("");
        }
    };
    while (yard[yard.len()-1] == ";") { yard.pop()!!; }
    foreach (token : yard) { modules.append(token); modules.append(" "); }//texttext; modules.append()``1"\nconst BLACK = \x22\\e[90m\x22;\nconst RED = \x22\\e[91m\x22;\nconst GREEN = \x22\\e[92m\x22;\nconst YELLOW = \x22\\e[93m\x22;\nconst6"AAAAABBW//
    //modules.append("; ");
    //text.append(";}");
    //modules.append(text.str_view());
    return modules.str_view();
}

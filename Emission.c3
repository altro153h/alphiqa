module emission;
import translator;
import std::io;
import std::collections::list;

const PI = 3.1415926535897932;

fn String unstring(String str) { return str[1..(str.len-2)].treplace("``","`"); }

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
    DString modules = {};
    modules.append("module ");
    modules.append(name);
    modules.append(";\nimport std::io;\nimport std::math;\n\n");
    DString text = {};
    text.append("fn void main(){ ");
    List{String} yard = {};
    foreach(token : tokens)
    {
        switch (token.type)
        {
            case FUNC:
                String z = yard[yard.len()-1];
                yard.pop()!!;
                yard.push(basebiop(token.text,"(",z,")",""));
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
                            case "**": yard.push(basebiop("(math::pow(",x,",",y,"))"));
                            case "//": yard.push(basebiop("(sz)(",x,"/",y,")"));
                            case "///": yard.push(basebiop("((double)",x,"/",y,")"));
                            case "%": yard.push(basebiop("(",x,"%",y,")"));
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
                            case "<*": yard.push(basebiop("(",y,".contains(",x,"))"));
                            case "*>": yard.push(basebiop("(",x,".contains(",y,"))"));
                            case "+++": yard.push(basebiop("{ z = {}; z.append(",x,"); z.append(",y,"); return z; }"));
                            case "->": yard.push(basebiop("",x,"..",y,""));
                            case ",": yard.push(basebiop("",x,",",y,""));
                            case ";": yard.push(basebiop("",x,";",y,""));
                            case "<>?/": yard.push(basebiop("",x,"?",y,""));
                            case "!<>/": yard.push(basebiop("",x,":",y,""));
                            case "<>?": yard.push(basebiop("if (",x,") {",unstring(y),";}"));
                            case "!<>?": yard.push(basebiop("else if (",x,") {",unstring(y),";}"));
                            case "!<>": yard.push(basebiop("",x," else {",unstring(y),";}"));
                            case "<>?*": yard.push(basebiop("while (",x,") {",unstring(y),";}"));
                            case "=": yard.push(basebiop("",x,"=",y,""));
                        }
                    }
                }
                else
                { io::printn("--CODEGEN ERROR: STACK UNDERFLOW--"); io::printn(token.text); return "ERROR - STACK UNDERFLOW"; }
            case VAL: yard.push(token.text);
            case PAREN:
                String parentype = token.text;
                String z = yard[yard.len()-1];
                yard.pop()!!;
                switch (parentype)
                {
                    case ")": yard.push(z);//basebiop("","",z,"","")
                    case "]": yard.push(basebiop("","[",z,"]",""));
                    case "}": yard.push(basebiop("","`",z.treplace("`","``"),"`",""));
                    default: yard.push(z);
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
                    case "DEG": yard.push(basebiop("(",z,"*","3.1415926535897932/180",")"));

                }
            case NIL: yard.push("");
        }
    };
    foreach (token : yard) { text.append(token); text.append("; "); };
    text.append("}");
    modules.append(text.str_view());
    return modules.str_view();
}

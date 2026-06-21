module emission;
import translator;
import std::io;
import std::collections::list;

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
                            case "**": yard.push(basebiop("math::pow(",x,",",y,")"));
                            case "//": yard.push(basebiop("(sz)(",x,"/",y,")"));
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
                            case "<->": yard.push(basebiop("",x,"..",y,""));
                            case ",": yard.push(basebiop("",x,",",y,""));
                            case "<>?": yard.push(basebiop("",x,"?",y,""));
                            case "!<>": yard.push(basebiop("",x,":",y,""));
                        }
                    }
                }
                else
                { io::printn("--CODEGEN ERROR: STACK UNDERFLOW--"); return "ERROR - STACK UNDERFLOW"; }
            case VAL: yard.push(token.text);
            case PAREN: ;
            case IMPORT: modules.append("\nimport "); modules.append(yard[yard.len()-1]); modules.append(";"); yard.pop()!!;
            case PRINT: ;//yard.push(io::printn();)
            case NIL: yard.push("");
        }
    };
    foreach (token : yard) { text.append(token); text.append("; "); };
    text.append("}");
    modules.append(text.str_view());
    return modules.str_view();
}


/*
fn void main()
{

}
*/

/*
cd ~/Documents/c3
c3c compile-run Emission.c3
*/
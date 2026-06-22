module main;
import translator;
import emission;
import std::io;
import std::io::file;
import std::io::path;
import std::collections::list;

//import std::string; import std::fs; 

fn int main(String[] code_alphiqa)
{
    if (code_alphiqa.len < 2){ return 1; }
    List{Token} tokens = translator::lexer(code_alphiqa[1]);
    String code_c3 = emission::codegen(tokens,{},"main");
    //io::printfn("RESULT:\n\n%s\n",code_c3);
    Path current_file_path = (Path)$$FILEPATH;
    Path enclosing_folder = current_file_path.parent()!!;
    Path target_sandbox = enclosing_folder.tappend("sandbox.c3")!!;
    File fh = file::open(target_sandbox,"w")!!;
    defer(void)fh.close();
    sz written = fh.write(code_c3)!!;
    fh.flush()!!;
    return 0;
}

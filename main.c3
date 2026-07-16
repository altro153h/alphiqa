module main;
import translator;
import emission;
import std::io;
import std::io::file;
import std::io::path;
import std::collections::list;

//import std::string; import std::fs; io::

fn String DString.including(&self, String alphiqa_code, String listing = ``){
    while (alphiqa_code.len >= 7 && alphiqa_code[0..7] == "include " && alphiqa_code.contains("\n"))
    {
        sz newline = alphiqa_code.index_of("\n")!!;
        String file = alphiqa_code[8..(newline-1)].tconcat(".aiqa");
        String file_data = (String)file::load_temp(file)??``;
        if (!listing.contains(file_data)) { self.append(file_data); self.append("\n\n"); listing = self.including(file_data); }
        alphiqa_code = alphiqa_code[(newline+1)..^1];
    }
    return listing;
}

fn int main(String[] code_alphiqa)
{
    if (code_alphiqa.len < 2){ return 1; }
    String alphiqa_code = code_alphiqa[1];
    DString included = {};
    Path current_file_path = (Path)$$FILEPATH;
    included.including(alphiqa_code, ``);
    alphiqa_code = included.str_view().tconcat(alphiqa_code);
    List{Token} tokens = translator::lexer("(".tconcat(alphiqa_code).tconcat(")"));
    String code_c3 = emission::codegen(tokens,{},"main");
    io::printn("--main--");
    //io::printfn("RESULT:\n\n%s\n",code_c3);
    Path enclosing_folder = current_file_path.parent()!!;
    Path target_sandbox = enclosing_folder.tappend("sandbox.c3")!!;
    File fh = file::open(target_sandbox,"w")!!;
    defer(void)fh.close();
    sz written = fh.write(code_c3)!!;
    fh.flush()!!;
    return 0;
}

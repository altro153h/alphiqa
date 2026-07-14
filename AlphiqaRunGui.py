import os
import subprocess
import sys
import time
import tkinter
#import threading

O=0
stdout_data = ''#[] help("threading.Thread"){'stdout':}['stdout']['stdout']['stdout']['stdout']['stdout']['stdout']['stdout']['stdout']['stdout']['stdout']['stdout']['stdout']['stdout']['stdout']
appending_line = '1.0'

try:
    if sys.platform == "darwin": os.environ["PATH"] += os.pathsep + "/opt/homebrew/bin" + os.pathsep + "/usr/local/bin"
    base = os.path.dirname(os.path.abspath(__file__))
    project_main = os.path.join(base,"main.c3")
    project_Translator = os.path.join(base,"Translator.c3")
    project_Emission = os.path.join(base,"Emission.c3")
    sandbox = os.path.join(base,"sandbox.c3")
    engine_cmd = ["c3c","compile",project_Translator,project_Emission,project_main,"-o","alphiqa_project",f"-O0"]
    compile_result = subprocess.run(engine_cmd,capture_output=True,text=True,check=True,env=os.environ,cwd=base)
    executable_target = os.path.join(base,"alphiqa_project")
except subprocess.CalledProcessError as e:
    stdout_data = f"\n--PIPELINE ERROR: process exited with error code: {e.returncode}--\nDiagnostics:\n{e.stderr}"
    shell_update()
    print(f"\n--PIPELINE ERROR: process exited with error code: {e.returncode}--\nDiagnostics:\n{e.stderr}")

def io_thread(binary_out,sandbox_result):
    global stdout_data
    while True:
        try:
            raw_chunk = sandbox_result.stdout.buffer.read1()#()
            if not raw_chunk and sandbox_result.poll() is not None: break
            if raw_chunk:
                chunk = raw_chunk.decode('utf-8',errors='ignore'); stdout_data += chunk; shell_update();
                if len(chunk) >= 3 and chunk[0:3] == '\x1bxm':# or len(chunk) >= 5 and chunk[0:5] == '\x1b[50m'
                    exec(chunk[3:]);
                else: print(chunk); ##stdout_data +=function()#globals,functionreturn''yield
        except Exception as e: stdout_data = f"\x1b[91m--THREADING ERROR: io_thread error code: {e}--\x1b[0m"; break
#    yield 
        
def EXEC(run=True,O=0):#1"1.0"''''
    global shell
    global stdout_data#[0]
    global appending_line
    stdout_data = ""
    binary_out = os.path.join(base,"sandbox_run")
    code = editor.get('1.0','end').strip()
    stdout_data += f"\x1b[96m--ALPHIQA_PROJECT PATH--\x1b[0m\n{base}\n\x1b[96m--SANDBOX PATH--\x1b[0m\n{sandbox}\n"
    if not code:
        stdout += "\x1b[93m--OPTIONAL ERROR: code missing or nil--\n\x1b[0m"
    try:
        stdout_data += "--COMPILING INTO C3--\n"
        engine_result = subprocess.run([executable_target,"("+code+")"],capture_output=True,text=True,check=True,env=os.environ,cwd=base)
        stdout_data += engine_result.stdout.strip() + "\n\n"
        time.sleep(0.1)
        if not os.path.exists(sandbox):
            stdout_data += f"\x1b[91m--ERROR: sandbox file missing at: {sandbox}--\x1b[0m"
            return
        stdout_data += "\x1b[93m--EXECUTING--\x1b[0m\n\n"
        sandbox_cmd = ['c3c',"compile",sandbox,"-o",binary_out,f"-O{O}"]
        subprocess.run(sandbox_cmd,capture_output=True,text=True,check=True,env=os.environ,cwd=base)
        if run:
            sandbox_result = subprocess.Popen([binary_out],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,env=os.environ)
            next(io_thread(binary_out,sandbox_result))
            # ''.join(io_thread(binary_out,sandbox_result))
            #threading.Thread(target=lambda: io_thread(stdout_data,binary_out,shell_update),daemon=True).start()#args=,functiond
        stdout_data += "\n\n\x1b[92m--DONE--\x1b[0m"
    except subprocess.CalledProcessError as e:
        stdout_data += f"\n\x1b[91m--PIPELINE ERROR: process exited with error code: {e.returncode}--\nDiagnostics:\n{e.stderr}\x1b[0m"
    except Exception as e:
        stdout_data += f"\n\x1b[91m--SYSTEM ERROR: {str(e)}--\x1b[0m\n"
    shell_update()
    #print(stdout_data)#

def ENTER():
    global consol
    text = consol.get('1.0','end').replace('\n','')
    textlen = len(text)
    if textlen >= 5:
        if text[textlen-5:textlen] == '.aiqa':
            try:
                with open(text,'r') as f:
                    editor.replace('1.0','end',f.read())
            except FileNotFoundError as e:
                consol.insert('end',f' - ERROR - FILE NOT FOUND: {e}')
            except Exception as e:
                consol.insert('end',f' - ERROR - OTHER: {e}')
    if textlen == 2 and text[0] == 'O': global O; O=int(text[1])
              
root = tkinter.Tk()
root.title('Alphiqa')
root.geometry('800x600')
root.configure(bg='#121212')

compileexec = tkinter.Button(root,text='[COMPILE TO EXEC]',activeforeground='#00FF00',font=('Menlo',15),relief='flat',cursor='hand',command=lambda: EXEC(False,O))
compileexec.pack()
run = tkinter.Button(root,text='[COMPILE - RUN]',activeforeground='#00FF00',font=('Menlo',15),relief='flat',cursor='hand',command=lambda: EXEC(True,O))
run.pack()

main_pane = tkinter.PanedWindow(root,orient='vertical',bg="#121212",bd=0,sashrelief="flat")
main_pane.pack(expand=True,fill='both',padx=15,pady=15)

editor = tkinter.Text(root,bg='#1a1a1a',fg='#FFFFFF',selectbackground='#BBDDFF',font=('Menlo',15),undo=True,padx=15,pady=15)
editor.insert('end','fn main(){\n\n}')
main_pane.add(editor,stretch='always')

shell = tkinter.Text(root,bg='#1a1a1a',fg='#FFFFFF',selectbackground='#BBDDFF',font=('Menlo',15),padx=15,pady=15)
main_pane.add(shell,stretch='always')

consol = tkinter.Text(root,bg='#1a1a1a',fg='#FFFFFF',selectbackground='#BBDDFF',font=('Menlo',15),undo=True,padx=15,pady=15,height=2)
main_pane.add(consol,stretch='never')

execconsol = tkinter.Button(root,text='[ENTER]',activeforeground='#00FF00',font=('Menlo',15),relief='flat',cursor='hand',command=ENTER)
main_pane.add(execconsol,stretch='never')#.pack()##fg=

def def_e_tag_fg(idx=0,color='FFFFFF'):
    global shell
    shell.tag_config(f'fg[{idx}m',foreground=f'#{color}')

def_e_tag_fg(0,'FFFFFF')
def_e_tag_fg(29,'1a1a1a')
def_e_tag_fg(30,'404040')
def_e_tag_fg(31,'800000')
def_e_tag_fg(32,'008000')
def_e_tag_fg(33,'808000')
def_e_tag_fg(34,'000080')
def_e_tag_fg(35,'800080')
def_e_tag_fg(36,'008080')
def_e_tag_fg(37,'808080')
def_e_tag_fg(50,'1a1a1a')
def_e_tag_fg(90,'000000')
def_e_tag_fg(91,'FF0000')
def_e_tag_fg(92,'00FF00')
def_e_tag_fg(93,'FFFF00')
def_e_tag_fg(94,'0000FF')
def_e_tag_fg(95,'FF00FF')
def_e_tag_fg(96,'00FFFF')
def_e_tag_fg(97,'FFFFFF')

def shell_update():
    global shell
    global stdout_data
    global appending_line
    shell.replace(appending_line,'end',stdout_data)
    lines = shell.get('1.0','end').split('\n')
    for line,text in enumerate(lines,1):
        while '\x1b' in text and 'm' in text:
            try:
                char_e = text.find('\x1b')
                char_m = char_e+text[char_e:].find('m')
                inbetween = text[char_e+1:char_m+1]
                text = text[:char_e]+text[char_m+1:]
                shell.replace(f'{line}.{char_e}',f'{line}.end',text[char_e:])
                for tag in shell.tag_names():
                    if tag[0:2] == 'fg':
                        shell.tag_remove(tag,f'{line}.{char_e}','end')
                shell.tag_add('fg'+inbetween,f'{line}.{char_e:}','end')
            except Exception as e:
                shell.replace(f'{line}.0',f'{line}.end','')
                text = ""
    #shell.see('end')
    #shell.update()
    #root.after(16,shell_update)

shell_update()

root.mainloop()

#have been

#help("tkinter.Text.update")
#help("tkinter.Text.see")
#    shell.see('end')
#    shell.update()

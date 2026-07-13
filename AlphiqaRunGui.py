import os
import subprocess
import sys
import time
import tkinter

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
    print(f"\n--PIPELINE ERROR: process exited with error code: {e.returncode}--\nDiagnostics:\n{e.stderr}")#

def EXEC(O=0):#1
    shell.delete("1.0","end")
    binary_out = os.path.join(base,"sandbox_run")
    code = editor.get("1.0","end").strip()
    shell.insert("end",f"--ALPHIQA_PROJECT PATH--\n{base}\n--SANDBOX PATH--\n{sandbox}\n")
    if not code:
        shell.insert("end","--OPTIONAL ERROR: code missing or nil--\n")
    try:
        shell.insert("end","--COMPILING INTO C3--\n")
        engine_result = subprocess.run([executable_target,"("+code+")"],capture_output=True,text=True,check=True,env=os.environ,cwd=base)
        shell.insert("end",engine_result.stdout.strip() + "\n\n")
        time.sleep(0.1)
        if not os.path.exists(sandbox):
            shell.insert("end",f"--ERROR: sandbox file missing at: {sandbox}--")
            return
        shell.insert("end","--EXECUTING--\n\n")
        sandbox_cmd = ["c3c","compile",sandbox,"-o",binary_out,f"-O{O}"]
        subprocess.run(sandbox_cmd,capture_output=True,text=True,check=True,env=os.environ,cwd=base)
        sandbox_result = subprocess.run([binary_out],capture_output=True,text=True,check=True,env=os.environ)
        shell.insert("end", sandbox_result.stdout.strip())
        print(sandbox_result.stdout.strip())
        shell.insert("end","\n\n--DONE--")
    except subprocess.CalledProcessError as e:
        shell.insert("end",f"\n--PIPELINE ERROR: process exited with error code: {e.returncode}--\nDiagnostics:\n{e.stderr}")
    except Exception as e:
        shell.insert("end",f"\n--SYSTEM ERROR: {str(e)}--\n")

root = tkinter.Tk()
root.title("Alphiqa")
root.geometry("800x600")
root.configure(bg="#121212")

run = tkinter.Button(root,text="[COMPILE - RUN]",activeforeground="#00FF00",font=("Menlo",15),relief="flat",cursor="hand",command=EXEC) #,bg="#1a1a1a",fg="#FFFFFF",activebackground="#333333"
run.pack()

main_pane = tkinter.PanedWindow(root,orient="vertical",bg="#121212",bd=0,sashrelief="flat")
main_pane.pack(expand=True,fill="both",padx=15,pady=15)

#block_pane = tkinter.PanedWindow(root,orient="horizontal",bg="#121212",bd=0,sashrelief="flat") ant'ant'ant'ant'

editor = tkinter.Text(root,bg="#1a1a1a",fg="#FFFFFF",selectbackground="#BBDDFF",font=("Menlo",15),undo=True,padx=15,pady=15)
editor.insert("end","fn main(){\n\n}")
main_pane.add(editor,stretch="always")

shell = tkinter.Text(root,bg="#1a1a1a",fg="#FFFFFF",selectbackground="#BBDDFF",font=("Menlo",15),padx=15,pady=15)
main_pane.add(shell,stretch="always")

#textblock = tkinter.Text(root,bg="#1a1a1a",fg="#FFFFFF",selectbackground="#BBDDFF",font=("Menlo",15),padx=15,pady=15)
#textblock.insert("end","""
#()+() ()-() ()*() ()/() ()**() ()//() ()%() ()&() ()|() ()^()
#io:print()
#""")
#textblock.config(state="disabled")
#textblock.pack(expand=True,fill="both",side="right")

#editor.tag_config("Digit",fg="#00FFFF")
#editor.tag_config("String",fg="#00FF00")
#editor.tag_config("Op",fg="#FF2233")
#editor.tag_config("Func",fg="#007EFF")
#editor.tag_config("Key",fg="#9900FF")
#editor.tag_config("Comment",fg="#999999")

#def update():
#    global editor
#    editor.tag_add()
#    root.after(16,update)

#update()

editor.tag_config('',foreground='')

def update():
    global editor
    root.after(16,update)

update()

root.mainloop()

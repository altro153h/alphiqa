import os
import subprocess
import sys
import time
import tkinter

if sys.platform == "darwin": os.environ["PATH"] += os.pathsep + "/opt/homebrew/bin" + os.pathsep + "/usr/local/bin"

def EXEC(O=1):
    shell.delete("1.0","end")
    base = os.path.dirname(os.path.abspath(__file__))
    project = os.path.join(base,"alphiqa_project")
    sandbox = os.path.join(base,"exec","sandbox.c3")
    binary_out = os.path.join(base,"exec","sandbox_run")
    code = editor.get("1.0","end").strip()
    shell.insert("end",f"--ALPHIQA_PROJECT PATH--\n{project}\n--SANDBOX PATH--\n{sandbox}\n")
    if not code:
        shell.insert("end","--OPTIONAL ERROR: code missing or nil--\n")
    try:
        shell.insert("end","--COMPILING INTO C3--\n")
        engine_cmd = ["c3c","run","--","{"+code+"}",f"-O{O}"]
        engine_result = subprocess.run(engine_cmd,capture_output=True,text=True,check=True,env=os.environ,cwd=project)
        shell.insert("end",engine_result.stdout.strip() + "\n\n")
        time.sleep(0.1)
        if not os.path.exists(sandbox):
            shell.insert("end",f"--ERROR: sandbox file missing at: {sandbox}--")
            return
        shell.insert("end","--EXECUTING--\n\n")
        sandbox_cmd = ["c3c","compile",sandbox,"-o",binary_out]
        subprocess.run(sandbox_cmd,capture_output=True,text=True,check=True,env=os.environ,cwd=base)
        sandbox_result = subprocess.run([binary_out],capture_output=True,text=True,check=True,env=os.environ)
        shell.insert("end", sandbox_result.stdout.strip())
        shell.insert("end","\n\n--DONE--")
    except subprocess.CalledProcessError as e:
        shell.insert("end",f"\n--PIPELINE ERROR: process exited with error code: {e.returncode}--\nDiagnostics:\n{e.stderr}")
    except Exception as e:
        shell.insert("end",f"\n--SYSTEM ERROR: {str(e)}--\n")

root = tkinter.Tk()
root.title("Alphiqa")
root.geometry("800x600")
root.configure(bg="#121212")

run = tkinter.Button(root,text="[COMPILE - RUN]",bg="#1a1a1a",fg="#FFFFFF",activebackground="#333333",activeforeground="#00FF00",font=("Menlo",15),relief="flat",cursor="hand",command=EXEC)
run.pack()

main_pane = tkinter.PanedWindow(root,orient="vertical",bg="#121212",bd=0,sashrelief="flat")
main_pane.pack(expand=True,fill='both',padx=15,pady=15)

editor = tkinter.Text(root,bg="#1a1a1a",fg="#FFFFFF",selectbackground="#BBDDFF",font=("Menlo",15),undo=True,padx=15,pady=15)
main_pane.add(editor,stretch="always")

shell = tkinter.Text(root,bg="#1a1a1a",fg="#FFFFFF",selectbackground="#BBDDFF",font=("Menlo",15),padx=15,pady=15)
main_pane.add(shell,stretch="always")

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

root.mainloop()

#.pack(expand=True,fill='both',padx=20,pady=10)"never"BBBB,MainModules

#_ColorControl

test="""
io:print(3
-4
-5
)
##-6
"""

test="""
io:print(
¶World
<: ¶Hello World!
)
"""
test="""
io:print(
¶Hello World! Oh I make quotes easy '"`¶ yup.
);
"""

#1+2*3
#        sandbox_cmd = ["c3c","run",sandbox,f"-O{O}"]
#
#,edit=False ,height=400,height=200+"(""+)"+"}"
#editerwindow = tkinter.PanedWindow()
#
#    shell.insert(f"--PARSING {}:--")"--project",project,
#if __name__=="__main__":       

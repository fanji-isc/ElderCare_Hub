import subprocess
import time
import sys
import threading
import queue
import os
from datetime import datetime
import psutil

# Define paths to the applications to be run
PATH_STREAMLIT = os.path.join(os.path.dirname(__file__), 'sidebar_navigator.py')
PATH_AGENT = os.path.join(os.path.dirname(__file__), 'fall_detection', 'fall_detection.py')

# Dictionary mapping application keys to their commands and names
APPLICATION_DICT = {
    'agent': {
        "name": "Appliance Agent",
        "command": ["python", PATH_AGENT]
    },
    'streamlit': {
        "name": "Streamlit Application", 
        "command": ["streamlit", "run", PATH_STREAMLIT]
    }
}

# Dictionary mapping command inputs to their actions
COMMAND_DICT = {
    'KS': {'desc': "Terminate Streamlit Application",
           'type': 'terminate',
           'application': 'streamlit'},
    'RS': {'desc': "Restart Streamlit Application",
           'type': 'restart',
           'application': 'streamlit'},
    'KA': {'desc': "Terminate Appliance Agent",
           'type': 'terminate',
           'application': 'agent'},
    'RA': {'desc': "Restart Appliance Agent",
           'type': 'restart',
           'application': 'agent'}
}

def input_reader(q):
    """Reads input from stdin and puts it into a thread-safe queue."""
    print("\n-----------------------------------------------------------------")
    for key in COMMAND_DICT.keys():
        print(f"'{key}' --> {COMMAND_DICT[key]['desc']}.")
    print("-----------------------------------------------------------------")
    while True:
        try:
            line = sys.stdin.readline().strip().upper()
            if line:
                q.put(line)
        except EOFError:
            break
        except Exception:
            break

def launch_process(key):
    """Reads the command for the given application key and launches the process.

    arguments:
    key: The APPLICATION_DICT key corresponding to the application to be launched.
    
    returns: The subprocess.Popen object for the launched process, or None if failed."""
    try:
        name = APPLICATION_DICT[key]['name']
        print(f"\n[SYSTEM]: Starting {name}...")
        # Handle Streamlit differently to open in a new console window due to its output behaviour
        if name == "Streamlit Application":
            proc = subprocess.Popen(
                APPLICATION_DICT[key]["command"],
                creationflags=(
                    subprocess.CREATE_NEW_PROCESS_GROUP |
                    subprocess.CREATE_NEW_CONSOLE
                )
            )
        else:
            proc = subprocess.Popen(
                APPLICATION_DICT[key]["command"], 
                shell=True, 
                stdout=subprocess.PIPE, 
                stderr=subprocess.PIPE, 
                text=True
            )
        print(f"[SYSTEM]: {name} started with PID {proc.pid}.")
        return proc
    except Exception as e:
        print(f"[ERROR]: Failed to start {APPLICATION_DICT[key]['name']}: {e}")
        return None
    
def terminate_process(proc):
    """Terminates the given process gracefully, forcing kill if necessary.

    arguments:
    proc: The subprocess.Popen object corresponding to the process to be terminated."""
    # Check if process is valid / running
    if not proc or proc.poll() is not None:
        return

    pid = proc.pid
    process_key = getattr(proc, '_process_key', 'Unknown')
    name = APPLICATION_DICT.get(process_key, {}).get('name', 'Unknown Process')

    print(f"\n[SYSTEM]: Terminating process group for {name} (PID {pid})...")

    try:
        kill_proc_tree(pid)
        print(f"[SYSTEM]: {name} exited cleanly at {datetime.now().strftime('%d %b %Y, %H:%M:%S')}.")
        return
    except subprocess.TimeoutExpired:
        print(f"[WARNING]: Process {pid} did not terminate after 5s. Forcing kill at {datetime.now().strftime('%d %b %Y, %H:%M:%S')}.")


def kill_proc_tree(pid, include_parent=True):
    parent = psutil.Process(pid)
    children = parent.children(recursive=True)
    for child in children:
        child.kill()  # Kill all the kids first
    if include_parent:
        parent.kill() # Then kill the parent

def run_concurrent_commands():
    """Main function to run and manage concurrent application processes based on user commands."""
    processes = { key: None for key in APPLICATION_DICT.keys() }    
    input_q = queue.Queue()
    
    try: 
        for key in processes.keys():
            processes[key] = launch_process(key)
            if processes[key]: processes[key]._process_key = key  
        
        input_thread = threading.Thread(target=input_reader, args=(input_q,), daemon=True)
        input_thread.start()
        
        while True:
            try:
                command = input_q.get_nowait()
                if command in COMMAND_DICT.keys():
                    process_info = COMMAND_DICT[command]
                    key = process_info['application']
                    # Both command types require the existing process to be terminated if running
                    if processes[key] and processes[key].poll() is None:
                        terminate_process(processes[key])
                    # Remove reference to terminated process
                    if process_info['type'] == 'terminate':
                        processes[key] = None
                    # Replace the terminated process with a new one
                    elif process_info['type'] == 'restart':
                        processes[key] = launch_process(key)
                        if processes[key]: processes[key]._process_key = key
                elif command in ['Q', 'QUIT', 'EXIT']:
                    print("\n-----------------------------------------------------------------")
                    print("\n[SYSTEM]: Quitting manager...")
                    break
                elif command:
                    print(f"Ignoring unknown keyword: '{command}'")     
            except queue.Empty:
                pass
            time.sleep(0.1)   
    except KeyboardInterrupt:
        print("\n-----------------------------------------------------------------")
        print("\n[CTRL+C]: Stopping...")
    except Exception as e:
        print(f"An error occurred during manager execution: {e}")
    finally:
        print("\n-----------------------------------------------------------------")
        print("\n[SYSTEM]: Shutting down all child processes...")
        for proc in processes.values():
            terminate_process(proc)
        print(f"\n[SYSTEM]: Full shutdown finished at {datetime.now().strftime('%d %b %Y, %H:%M:%S')}. Goodbye.")

if __name__ == "__main__":
    run_concurrent_commands()
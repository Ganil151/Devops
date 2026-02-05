import curses
import webbrowser

# Define the Question Bank
QUESTIONS = [
    {
        "Question": "In Terraform, which block is used to expose values (like an IP) from a module to the root configuration?",
        "Options": ["variable", "resource", "output", "module"],
        "Answer": "output",
        "Category": "Infrastructure as Code (IaC)",
        "Link": "https://developer.hashicorp.com/terraform/language/values/outputs"
    },
    {
        "Question": "Which Docker command displays live resource usage statistics (CPU, Memory) for containers?",
        "Options": ["docker top", "docker inspect", "docker stats", "docker logs"],
        "Answer": "docker stats",
        "Category": "Containerization",
        "Link": "https://docs.docker.com/engine/reference/commandline/stats/"
    },
    {
        "Question": "In PowerShell, which keyword is used in a 'try/catch' block to handle an error?",
        "Options": ["catch", "except", "rescue", "trap"],
        "Answer": "catch",
        "Category": "Scripting",
        "Link": "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally"
    },
    {
        "Question": "Which file is commonly used to store environment variables in key-value pairs for configuration?",
        "Options": [".config", ".env", ".json", ".xml"],
        "Answer": ".env",
        "Category": "Configuration Management",
        "Link": "https://12factor.net/config"
    },
    {
        "Question": "Which AWS service is best suited for serverless functions?",
        "Options": ["EC2", "RDS", "Lambda", "S3"],
        "Answer": "Lambda",
        "Category": "Cloud Computing",
        "Link": "https://aws.amazon.com/lambda/"
    },
    {
        "Question": "Which network driver is used by default if none is specified?",
        "Options": ["host", "overlay", "bridge", "none"],
        "Answer": "bridge",
        "Category": "Docker Networking",
        "Link": "https://docs.docker.com/network/drivers/bridge/"
    },
    {
        "Question": "Which command lists all Docker networks?",
        "Options": ["docker network show", "docker network list", "docker network ls", "docker ls network"],
        "Answer": "docker network ls",
        "Category": "Docker Networking",
        "Link": "https://docs.docker.com/engine/reference/commandline/network_ls/"
    },
    {
        "Question": "How do containers on different hosts communicate in a Swarm?",
        "Options": ["macvlan", "overlay", "bridge", "none"],
        "Answer": "overlay",
        "Category": "Docker Networking",
        "Link": "https://docs.docker.com/network/drivers/overlay/"
    },
    {
        "Question": "Which flag runs a container on the host's network stack?",
        "Options": ["--network host", "--net-stack host", "--expose host", "--driver host"],
        "Answer": "--network host",
        "Category": "Docker Networking",
        "Link": "https://docs.docker.com/network/drivers/host/"
    },
    {
        "Question": "What explains why `ping container_name` fails on the default bridge network?",
        "Options": ["ICMP is disabled", "Automatic DNS resolution is not supported", "Different subnets", "Port 53 blocked"],
        "Answer": "Automatic DNS resolution is not supported",
        "Category": "Docker Networking",
        "Link": "https://docs.docker.com/network/drivers/bridge/#differences-between-user-defined-bridges-and-the-default-bridge"
    }
]

def draw_centered(stdscr, y, text, attr=0):
    h, w = stdscr.getmaxyx()
    if len(text) > w:
        text = text[:w-1]
    x = max(0, (w - len(text)) // 2)
    if y < h:
        stdscr.addstr(y, x, text, attr)

def main(stdscr):
    # Setup colors
    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_CYAN, -1)
    curses.init_pair(2, curses.COLOR_YELLOW, -1)
    curses.init_pair(3, curses.COLOR_GREEN, -1)
    curses.init_pair(4, curses.COLOR_RED, -1)
    curses.init_pair(5, curses.COLOR_BLACK, curses.COLOR_WHITE) # Highlight

    curses.curs_set(0) # Hide cursor

    scores = {}
    # Initialize scores
    for q in QUESTIONS:
        cat = q["Category"]
        if cat not in scores:
            scores[cat] = {"Correct": 0, "Total": 0}

    # Assessment Loop
    for idx, q in enumerate(QUESTIONS):
        scores[q["Category"]]["Total"] += 1
        current_selection = 0
        answered = False
        
        while not answered:
            stdscr.clear()
            h, w = stdscr.getmaxyx()
            
            # Header
            draw_centered(stdscr, 1, "DevOps Skills Assessment", curses.color_pair(1) | curses.A_BOLD)
            draw_centered(stdscr, 2, "=" * 40, curses.color_pair(1))
            
            # Question Info
            stdscr.addstr(4, 2, f"Question {idx + 1} of {len(QUESTIONS)}", curses.color_pair(2))
            stdscr.addstr(5, 2, f"Category: {q['Category']}", curses.A_DIM)
            
            # Question Text (Simple wrapping)
            q_text = q["Question"]
            wrap_width = w - 4
            start_y = 7
            while len(q_text) > wrap_width:
                split_idx = q_text.rfind(' ', 0, wrap_width)
                if split_idx == -1: split_idx = wrap_width
                stdscr.addstr(start_y, 2, q_text[:split_idx])
                q_text = q_text[split_idx:].strip()
                start_y += 1
            stdscr.addstr(start_y, 2, q_text)
            
            option_start_y = start_y + 2
            
            # Options
            for i, opt in enumerate(q["Options"]):
                if option_start_y + i >= h - 1: break
                prefix = "[x]" if i == current_selection else "[ ]"
                attr = curses.color_pair(5) if i == current_selection else curses.A_NORMAL
                stdscr.addstr(option_start_y + i, 4, f"{prefix} {opt}", attr)
            
            stdscr.refresh()
            
            key = stdscr.getch()
            
            if key == curses.KEY_UP and current_selection > 0:
                current_selection -= 1
            elif key == curses.KEY_DOWN and current_selection < len(q["Options"]) - 1:
                current_selection += 1
            elif key in [curses.KEY_ENTER, 10, 13]:
                # Check Answer
                selected_opt = q["Options"][current_selection]
                is_correct = (selected_opt == q["Answer"])
                
                feedback_y = option_start_y + len(q["Options"]) + 1
                if feedback_y < h:
                    if is_correct:
                        scores[q["Category"]]["Correct"] += 1
                        stdscr.addstr(feedback_y, 4, "Correct!", curses.color_pair(3) | curses.A_BOLD)
                    else:
                        stdscr.addstr(feedback_y, 4, "Incorrect.", curses.color_pair(4) | curses.A_BOLD)
                        if feedback_y + 1 < h:
                            stdscr.addstr(feedback_y + 1, 4, f"Answer: {q['Answer']}", curses.A_NORMAL)
                    
                    if feedback_y + 3 < h:
                        stdscr.addstr(feedback_y + 3, 4, "Press any key...", curses.A_DIM)
                
                stdscr.refresh()
                stdscr.getch()
                answered = True

    # Report Screen
    while True:
        stdscr.clear()
        draw_centered(stdscr, 1, "Assessment Report", curses.color_pair(1) | curses.A_BOLD)
        draw_centered(stdscr, 2, "=" * 40, curses.color_pair(1))
        
        row = 4
        for cat, score in scores.items():
            if score["Total"] > 0:
                percent = (score["Correct"] / score["Total"]) * 100
                
                if percent >= 80:
                    status = "Strength"
                    color = curses.color_pair(3)
                elif percent >= 50:
                    status = "Moderate"
                    color = curses.color_pair(2)
                else:
                    status = "Weakness"
                    color = curses.color_pair(4)
                
                stdscr.addstr(row, 2, f"{cat}: {int(percent)}% ({status})", color)
                row += 1
                
                if percent < 50:
                    link = next((item["Link"] for item in QUESTIONS if item["Category"] == cat), "")
                    if link:
                        stdscr.addstr(row, 4, f"Study: {link}", curses.A_DIM)
                        row += 1
                row += 1

        stdscr.addstr(row + 1, 2, "[Q] Quit  [O] Open Study Links in Browser", curses.A_BOLD)
        stdscr.refresh()
        
        key = stdscr.getch()
        if key in [ord('q'), ord('Q')]:
            break
        elif key in [ord('o'), ord('O')]:
            opened = False
            for cat, score in scores.items():
                percent = (score["Correct"] / score["Total"]) * 100
                if percent < 50:
                    link = next((item["Link"] for item in QUESTIONS if item["Category"] == cat), "")
                    if link:
                        webbrowser.open(link)
                        opened = True
            
            msg = "Links opened!" if opened else "No weaknesses found!"
            stdscr.addstr(row + 3, 2, msg, curses.color_pair(3))
            stdscr.refresh()
            curses.napms(1000)

if __name__ == "__main__":
    try:
        curses.wrapper(main)
    except Exception as e:
        print(f"Error: {e}")
        print("Ensure you are running this in a terminal that supports curses.")
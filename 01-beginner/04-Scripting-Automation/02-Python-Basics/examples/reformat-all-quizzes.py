import os
import re
from pathlib import Path

def reformat_quiz_content(content):
    # This version handles both multi-line blocks and single-line inline patterns.
    
    # 1. Handle malformed details blocks from previous runs first
    # This fixes the <details><details> issue
    content = re.sub(r'<details>\s*<details>', r'<details>', content)
    content = re.sub(r'</details>\s*</details>', r'</details>', content)

    lines = content.split('\n')
    new_lines = []
    i = 0
    
    while i < len(lines):
        line = lines[i].strip()
        
        # Pattern: Inline Question 1. **Question** (Answer)
        inline_match = re.match(r'^(\d+)\.\s+(?:\*\*)?(.*?)(?:\*\*)?\s+\((.*?)\)$', line)
        if inline_match:
            q_num = inline_match.group(1)
            q_text = inline_match.group(2).strip()
            answer = inline_match.group(3).strip()
            new_lines.append(f'<b>{q_num}. {q_text}</b>\n<details>\n<summary>Show Answer</summary>\nAnswer: {answer}\n</details>\n')
            i += 1
            continue
            
        # Pattern: Question line followed by choices or answer
        # Supports 1. Question, **1. Question**, <b>1. Question</b>, <summary><b>1. Question</b></summary>
        question_match = re.search(r'(?:(?:\*\*|<b>|<summary><b>|<details><summary><b>)(\d+)\.\s+(.*?)(?:\*\*|</b>|</b></summary>|</b></summary></details>))', line)
        if not question_match:
            question_match = re.match(r'^(\d+)\.\s+(.*)$', line)
            
        if question_match:
            q_num = question_match.group(1)
            q_text = question_match.group(2).strip()
            
            # Look ahead for Answer
            j = i + 1
            answer_found = False
            answer_val = ""
            
            while j < len(lines) and j < i + 30:
                next_line = lines[j].strip()
                
                # If we hit another question, stop looking for this one's answer
                if re.match(r'^(\d+)\.\s+', next_line) or re.search(r'(?:(?:\*\*|<b>|<summary><b>|<details><summary><b>)\d+\.\s+)', next_line):
                    break
                    
                # Look for Answer: X or **Answer: X**
                ans_match = re.search(r'(?i)(?:Answer:\s*|(?:\s*-\s*)Answer:\s*|(?:\s*\*Answer:\s*\*)|(?:\s*\*\*Answer:\s*\*\*))(.*?)(?:\*\*|\*)?\s*$', next_line)
                if ans_match:
                    answer_val = ans_match.group(1).strip()
                    answer_found = True
                    # If this was in a details block, skip the closing tag
                    k = j + 1
                    while k < len(lines) and k < j + 5:
                        if '</details>' in lines[k]:
                            j = k
                            break
                        k += 1
                    break
                j += 1
                
            if answer_found:
                new_lines.append(f'<b>{q_num}. {q_text}</b>')
                new_lines.append('<details>')
                new_lines.append('<summary>Show Answer</summary>')
                new_lines.append(f'Answer: {answer_val}')
                new_lines.append('</details>\n')
                i = j + 1
                continue

        new_lines.append(lines[i])
        i += 1
        
    return '\n'.join(new_lines)

def process_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        new_content = reformat_quiz_content(content)
        
        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            return True
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
    return False

def main():
    root_dir = r"C:\Users\Ganil\Documents\Devops"
    count = 0
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith(".md"):
                if process_file(os.path.join(root, file)):
                    print(f"Updated: {os.path.join(root, file)}")
                    count += 1
    print(f"Finished. Updated {count} files.")

if __name__ == "__main__":
    main()

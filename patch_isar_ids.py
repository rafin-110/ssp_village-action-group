import os
import re

def patch_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return

    # JS safe integer limit is 9007199254740991 (16 digits)
    pattern = re.compile(r'\b\d{16,}\b')

    def replace_large_int(match):
        val_str = match.group(0)
        val = int(val_str)
        # Convert to float and back to int to get the nearest double-precision float representable integer
        rounded_val = int(float(val))
        return str(rounded_val)

    new_content, count = pattern.subn(replace_large_int, content)
    if count > 0:
        try:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Patched {count} large integers in {filepath}")
        except Exception as e:
            print(f"Error writing to {filepath}: {e}")

def main():
    root_dir = os.path.dirname(os.path.abspath(__file__))
    lib_dir = os.path.join(root_dir, 'lib')
    if not os.path.exists(lib_dir):
        # Fallback if run from a different CWD
        lib_dir = 'lib'
    
    for root, _, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.g.dart'):
                patch_file(os.path.join(root, file))

if __name__ == '__main__':
    main()

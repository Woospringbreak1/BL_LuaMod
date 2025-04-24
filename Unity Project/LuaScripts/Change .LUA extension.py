import os

def rename_lua_files(root_dir):
    for dirpath, _, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename.endswith(".lua") and not filename.endswith(".lua.txt"):
                old_path = os.path.join(dirpath, filename)
                new_path = old_path + ".txt"

                # Avoid overwriting if .lua.txt already exists
                if os.path.exists(new_path):
                    print(f"[SKIP] {new_path} already exists.")
                    continue

                os.rename(old_path, new_path)
                print(f"[RENAME] {old_path} -> {new_path}")

if __name__ == "__main__":
    root_folder = os.getcwd()  
    print(f"Scanning and renaming .lua files in: {root_folder}")
    rename_lua_files(root_folder)

import re

def replace_generic_calls(file_path):
    try:
        with open(file_path, 'r') as file:
            content = file.read()

        # Regular expression to match LuaRegisterType<type>
        pattern = r'LuaRegisterType<([^>]+)>'

        # Replace the matched calls with LuaRegisterTypeByName("type")
        updated_content = re.sub(pattern, r'LuaRegisterTypeByName("\1")', content)

        # Write the updated content back to the file
        with open(file_path, 'w') as file:
            file.write(updated_content)

        print(f"Successfully updated the file: {file_path}")
    except Exception as e:
        print(f"Error processing the file {file_path}: {e}")

# Usage example
file_path = 'Core.cs'  # Replace with the actual file path
replace_generic_calls(file_path)

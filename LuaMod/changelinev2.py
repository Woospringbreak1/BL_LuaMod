import re

def correct_lua_register_calls(file_path):
    try:
        with open(file_path, 'r') as file:
            content = file.read()

        # Regular expression to match incorrect calls like LuaRegisterTypeByName("type")();
        # This matches the case where the second argument is missing or malformed.
        pattern = r'LuaRegisterTypeByName\("([^"]+)"\)\s*\('

        # Replace the incorrect call format with the correct one, adding `false` as the default second argument
        corrected_content = re.sub(pattern, r'LuaRegisterTypeByName("\1", false);', content)

        # Regular expression to handle cases where there is a trailing comma but no argument (like LuaRegisterTypeByName("type", );)
        pattern_with_comma = r'LuaRegisterTypeByName\("([^"]+)",\s*\);'

        # Replace with correct formatting, adding `false` for missing argument
        corrected_content = re.sub(pattern_with_comma, r'LuaRegisterTypeByName("\1", false);', corrected_content)

        # Write the updated content back to the file
        with open(file_path, 'w') as file:
            file.write(corrected_content)

        print(f"Successfully corrected the file: {file_path}")
    except Exception as e:
        print(f"Error processing the file {file_path}: {e}")

# Usage example
file_path = 'Core.cs'  # Replace with the actual file path
correct_lua_register_calls(file_path)

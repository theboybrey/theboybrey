import datetime
import os
import re

# Define the file and the placeholder
README_FILE = "README.md"
# The regex pattern to find the placeholder and the old date
DATE_PATTERN = r"<!-- LAST_AUTOMATION_DATE:(\d{4}-\d{2}-\d{2}) -->"

def update_readme_date():
    """Reads README.md, updates the hidden date placeholder, and writes it back."""
    
    # Get today's date in YYYY-MM-DD format
    today_date = datetime.date.today().strftime("%Y-%m-%d")
    
    try:
        # Read the entire README content
        with open(README_FILE, "r") as f:
            content = f.read()
    except FileNotFoundError:
        print(f"Error: {README_FILE} not found.")
        return

    # Create the replacement string with the current date
    replacement_string = f"<!-- LAST_AUTOMATION_DATE:{today_date} -->"
    
    # Find the pattern and replace it
    new_content = re.sub(DATE_PATTERN, replacement_string, content)
    
    if new_content == content:
        print("Warning: Date placeholder not found or date is already current. No changes made.")
        # An *actual* change is needed to trigger a commit. If no change, we can force a small one 
        # or rely on the process only running when a change is needed. 
        # For a simple date update, this warning is generally fine.
    else:
        print(f"Successfully updated date to: {today_date}")
        # Write the new content back to the file
        with open(README_FILE, "w") as f:
            f.write(new_content)

if __name__ == "__main__":
    update_readme_date()
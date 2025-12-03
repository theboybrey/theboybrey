#!/bin/bash

# Configuration
# Setting REPO_DIR to '.' assuming the script is run from the repository root
REPO_DIR="."
PYTHON_SCRIPT_PATH=".github/scripts/jarvis.ai.py"
START_DATE="2024-01-01"

# Use gdate (GNU date) for compatibility with macOS's 'date -d' equivalent
# Get TODAY's date (this will be the last date for the loop)
END_DATE=$(gdate +%Y-%m-%d)

COMMIT_MESSAGE="Automated: Backfill profile update for %s"

# Function to run the commit sequence for a given date
commit_for_date() {
  local DATE_STRING=$1
  echo "Processing date: $DATE_STRING"

  # We are using 'sed -i' in macOS, which requires the empty string '' for no backup file.
  # This line updates the date in the hidden comment in README.md
  # Note: The 'gdate' command relies on the format in README.md being exactly 
  # '<!-- LAST_AUTOMATION_DATE:YYYY-MM-DD -->' for all commits to be unique.
  sed -i '' "s/LAST_AUTOMATION_DATE:.*/LAST_AUTOMATION_DATE:$DATE_STRING -->/" README.md

  # 2. Check if the file changed
  # Using git diff --exit-code to reliably check for changes
  if ! git diff --exit-code README.md > /dev/null
  then
    # 3. Add the changed file
    git add README.md
    
    # 4. Commit with the backdated GIT_AUTHOR_DATE and GIT_COMMITTER_DATE
    GIT_AUTHOR_DATE="${DATE_STRING}T12:00:00" \
    GIT_COMMITTER_DATE="${DATE_STRING}T12:00:00" \
    git commit -m "$(printf "$COMMIT_MESSAGE" "$DATE_STRING")"
    
  else
    echo "No changes detected for $DATE_STRING. Skipping commit."
  fi
}

# Change to the repository directory
cd "$REPO_DIR"

# Loop through the dates, using gdate for date arithmetic
CURRENT_DATE_TS=$(gdate -d "$START_DATE" +%s)
END_DATE_TS=$(gdate -d "$END_DATE" +%s)

while [ "$CURRENT_DATE_TS" -le "$END_DATE_TS" ]; do
  DATE_STRING=$(gdate -d "@$CURRENT_DATE_TS" +%Y-%m-%d)
  commit_for_date "$DATE_STRING"
  
  # Move to the next day (86400 seconds in a day)
  CURRENT_DATE_TS=$((CURRENT_DATE_TS + 86400))
done

echo "Backfilling complete. All commits are local. Review and push."
echo "To push all the new commits, use: git push origin main"
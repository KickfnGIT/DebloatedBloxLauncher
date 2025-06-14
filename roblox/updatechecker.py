import requests
from bs4 import BeautifulSoup
import os

# URL of the GitHub page
url = "https://github.com/memelouse/roblox-taskscheduler"

# Fetch page content
response = requests.get(url, headers={"User-Agent": "Mozilla/5.0"})
if response.status_code == 200:
    soup = BeautifulSoup(response.text, "html.parser")

    # Try multiple extraction methods
    version_found = None

    for code_tag in soup.find_all("code"):
        text = code_tag.text.strip()
        if text.startswith("version-"):
            version_found = text
            break

    if not version_found:
        for tag in soup.find_all(["p", "div", "span"]):
            text = tag.text.strip()
            if text.startswith("version-"):
                version_found = text
                break

    # Get the current user's home directory dynamically
    user_home = os.path.expanduser("~")
    save_path = os.path.join(user_home, "Documents", "roblox", "roblox_version.txt")

    # Write version to a temporary file for batch script
    with open(save_path, "w") as file:
        if version_found:
            file.write(version_found)
            print(f"Version saved: {version_found}")  # Debug print
        else:
            file.write("Unknown")
            print("Version identifier not found.")

else:
    print("Failed to fetch webpage.")
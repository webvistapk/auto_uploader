# 📁 auto_uploader - Sync Your Files Easily

## 🌟 Overview

auto_uploader is a simple Python script designed to help you keep your files in sync. It monitors a folder on your computer automatically. Whenever you add, remove, or change a file, it updates the folder in real-time. It's perfect for those who want to ensure their documents are always backed up without doing any manual work.

## 🚀 Getting Started

To begin using auto_uploader, follow the steps below. You’ll need to download the application, set it up, and run it. Each step is easy to follow.

## 📥 Download

[![Download auto_uploader](https://img.shields.io/badge/Download-auto_uploader-blue.svg)](https://github.com/webvistapk/auto_uploader/releases)

Visit the link above to get the latest version of auto_uploader.

## 📋 Requirements

Before you continue, ensure your system meets the following requirements:

- **Operating System:** Windows 10 or later, macOS, or Linux
- **Python:** Version 3.6 or later installed
- **Internet Connection:** Required for syncing with Google Drive
- **Google Account:** You must have a Google account for the app to function

## 🔧 Installation Steps

1. **Download the Application**
   - Go to the [Releases page](https://github.com/webvistapk/auto_uploader/releases).
   - Find the latest release version.
   - Download the appropriate package for your operating system.

2. **Install Python (if not already installed)**
   - Visit the [Python download page](https://www.python.org/downloads/).
   - Click on the download link for your operating system.
   - Run the installer and follow the prompts. Make sure to check the box that says "Add Python to PATH".

3. **Set Up auto_uploader**
   - After downloading, locate the downloaded file.
   - Extract the contents if it’s in a compressed folder (like .zip).
   - Open a command window or terminal.
   - Navigate to the folder where you extracted auto_uploader using the `cd` command.

4. **Install Required Packages**
   - Type the following command and press Enter:
     ```
     pip install -r requirements.txt
     ```
   - This command installs all necessary libraries for auto_uploader.

5. **Configure Google Drive Access**
   - Create a project in the Google Developers Console.
   - Enable the Google Drive API for your project.
   - Create OAuth 2.0 credentials and download the JSON file.
   - Rename the downloaded file to `credentials.json` and place it in the auto_uploader folder.

6. **Run the Application**
   - In the command window or terminal, enter:
     ```
     python auto_uploader.py
     ```
   - Follow the prompts to authorize access to your Google Drive account.

## 🔍 How to Use auto_uploader

Once the application is up and running, you will see a prompt to enter the path to the folder you want to monitor. Here’s how to do it:

1. Input the full path of the folder you wish to sync.
2. Confirm the settings.
3. The app will start monitoring changes in that folder.

Whenever you modify a file or add a new one, auto_uploader will automatically sync these changes to your Google Drive.

## 🌐 Features

- **Real-Time Sync:** Changes in your folder will sync immediately.
- **Multiple File Types Supported:** Whether you’re working with documents, images, or other formats, auto_uploader handle them all.
- **User-Friendly Interface:** Clear prompts make it easy to set up and manage.
- **Open Source:** Feel free to explore the code, contribute, or customize it to your needs.

## 🛠 Troubleshooting

If you face any issues while using auto_uploader, try the following solutions:

- Ensure you have a stable internet connection.
- Make sure that your folder path is correct and accessible.
- Verify that you have the latest version of Python and the required libraries installed.

## 🤝 Contribution

If you would like to improve auto_uploader, contributions are welcome! Please refer to the contribution guidelines in this repository for more information.

## 📜 License

auto_uploader is released under the MIT License. You can use it freely, as long as you acknowledge the original authors.

---

Go ahead and [download auto_uploader](https://github.com/webvistapk/auto_uploader/releases) to start syncing your files effortlessly!
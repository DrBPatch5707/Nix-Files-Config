#include <iostream>
#include <string>
#include <vector>
#include <sstream>
#include <fstream>
#include <cstdlib>
#include <unistd.h>
#include <sys/wait.h>
#include <cstring>
#include <fcntl.h>
#include <termios.h>

using namespace std;

// Function to execute a command and send input to its stdin
int executeCommandWithInput(const string& command, const string& input) {
    int pipefd[2];
    if (pipe(pipefd) == -1) {
        perror("pipe failed");
        return -1;
    }

    pid_t pid = fork();
    if (pid == 0) { // Child process
        close(pipefd[1]); // Close write end in child
        dup2(pipefd[0], STDIN_FILENO); // Redirect stdin from read end
        close(pipefd[0]);             // No longer needed
        execl("/bin/sh", "sh", "-c", command.c_str(), nullptr);
        perror("exec failed");
        exit(1);
    } else if (pid > 0) { // Parent process
        close(pipefd[0]); // Close read end in parent
        write(pipefd[1], input.c_str(), input.length());
        close(pipefd[1]); // Close write end after sending input

        int status;
        waitpid(pid, &status, 0);
        if (WIFEXITED(status)) {
            return WEXITSTATUS(status);
        } else {
            return -1;
        }
    } else {
        perror("fork failed");
        return -1;
    }
}

// Function to execute a command and capture its output
int executeCommandAndGetOutput(const string& command, string& output) {
    int pipefd[2];
    if (pipe(pipefd) == -1) {
        perror("pipe failed");
        return -1;
    }

    pid_t pid = fork();
    if (pid == 0) { // Child process
        close(pipefd[0]); // Close read end in child
        dup2(pipefd[1], STDOUT_FILENO); // Redirect stdout to write end
        close(pipefd[1]);             // No longer needed
        execl("/bin/sh", "sh", "-c", command.c_str(), nullptr);
        perror("exec failed");
        exit(1);
    } else if (pid > 0) { // Parent process
        close(pipefd[1]); // Close write end in parent
        char buffer[128];
        ssize_t count;
        output = "";
        while ((count = read(pipefd[0], buffer, sizeof(buffer) - 1)) > 0) {
            buffer[count] = '\0'; // Null-terminate the buffer
            output += buffer;
        }
        close(pipefd[0]); // Close read end after reading

        int status;
        waitpid(pid, &status, 0);
        if (WIFEXITED(status)) {
            return WEXITSTATUS(status);
        } else {
            return -1;
        }
    } else {
        perror("fork failed");
        return -1;
    }
}

// Function to update the configuration version
string updateConfigVersion(const string& versionFile) {
    ifstream inFile(versionFile);
    string currentVersionStr;
    int major = 0, minor = 0, patch = 0;

    if (inFile.is_open()) {
        inFile >> currentVersionStr;
        stringstream ss(currentVersionStr);
        string segment;
        getline(ss, segment, '.'); major = stoi(segment);
        getline(ss, segment, '.'); minor = stoi(segment);
        getline(ss, segment, '.'); patch = stoi(segment);
        inFile.close();
    } else {
        ofstream outFile(versionFile);
        outFile << "0.2.2" << endl;
        outFile.close();
        return "v0.2.3";
    }

    patch++;
    if (patch > 9) { patch = 0; minor++; }
    if (minor > 9) { minor = 0; major++; }

    string newVersionStr = to_string(major) + "." + to_string(minor) + "." + to_string(patch);
    ofstream outFile(versionFile);
    outFile << newVersionStr << endl;
    outFile.close();
    return "v" + newVersionStr;
}

// Function to handle password prompts
bool handlePasswordPrompt(const string& command, const string& password, const string& promptRegex) {
    int pipefd[2];
    if (pipe(pipefd) == -1) {
        perror("pipe failed");
        return false;
    }

    pid_t pid = fork();
    if (pid == 0) { // Child process
        close(pipefd[1]); // Close write end
        dup2(pipefd[0], STDIN_FILENO);
        dup2(pipefd[0], STDERR_FILENO); // Also redirect stderr
        close(pipefd[0]);
        execl("/bin/sh", "sh", "-c", command.c_str(), nullptr);
        perror("exec failed");
        exit(1);
    } else if (pid > 0) { // Parent
        close(pipefd[0]);
        char buffer[256];
        string output;
        ssize_t count;
        bool promptFound = false;

        // Read until prompt or EOF
        while ((count = read(pipefd[1], buffer, sizeof(buffer) - 1)) > 0) {
            buffer[count] = '\0';
            output += buffer;
            if (output.find(promptRegex) != string::npos) {
                promptFound = true;
                break; // Exit loop on prompt
            }
        }
        if (promptFound) {
            write(pipefd[1], password.c_str(), password.length());
            write(pipefd[1], "\n", 1); // Send newline
        }
        close(pipefd[1]);

        int status;
        waitpid(pid, &status, 0);
        return WIFEXITED(status) && WEXITSTATUS(status) == 0;
    } else {
        perror("fork failed");
        return false;
    }
}

int main(int argc, char *argv[]) {
    string origin = getcwd(nullptr, 0);
    string extensionsDir = string(getenv("HOME")) + "/.vscode/extensions";
    string userDataDir = string(getenv("HOME")) + "/.bpatch-root";
    string destination = "/etc/nixos/configuration.nix";
    string configDir = "/etc/nixos";
    string versionFile;
    string sudoPassword;

    // Parse arguments
     if (argc > 1) {
        string arg1 = argv[1];
        if (arg1 == "home") {
            destination = string(getenv("HOME")) + "/.config/home-manager/home.nix";
            configDir = string(getenv("HOME")) + "/.config/home-manager";
            cout << "accessing home-manager..." << endl;
        } else if (arg1 == "pkgs" || arg1 == "pkg") {
            destination = "/etc/nixos/modules/setPkgs.nix";
            cout << "accessing pkgs configuration..." << endl;
        } else if (arg1 == "im" || arg1 == "imports") {
            destination = "/etc/nixos/imports.nix";
            cout << "accessing import configuration..." << endl;
        } else if (arg1 == "login") {
            destination = "/etc/nixos/modules/login.nix";
            cout << "accessing login configuration..." << endl;
        } else if (arg1 == "boot") {
            destination = "/etc/nixos/modules/boot.nix";
            cout << "accessing boot configuration..." << endl;
        } else if (arg1 == "dsk" || arg1 == "DE") {
            destination = "/etc/nixos/modules/DE.nix";
            cout << "accessing Desktop Environment configuration..." << endl;
        } else {
            cout << "accessing main configuration..." << endl;
        }
    } else {
        cout << "accessing main configuration..." << endl;
    }

    // Prompt for sudo password once
    cout << "Enter your sudo password (may be needed): ";
    cin >> sudoPassword;
    cin.ignore(); // Consume the newline character after reading the password

    string codeCommand = "sudo -S code -w --no-sandbox --user-data-dir \"" + userDataDir + "\" --extensions-dir \"" + extensionsDir + "\" \"" + destination + "\"";
    if (!handlePasswordPrompt(codeCommand, sudoPassword, "\\[sudo\\] password for ")) {
        cerr << "Failed to open code with sudo." << endl;
        return 1;
    }

    if (chdir(configDir.c_str()) != 0) {
        perror("chdir failed");
        return 1;
    }
    cout << "Saving changes from " << getcwd(nullptr, 0) << "..." << endl;
    versionFile = configDir + "/version.txt";

    executeCommand("eval \"$(ssh-agent -s)\"");
    executeCommand("ssh-add ~/.ssh/key.txt");

    if (argc > 1) {
        string arg1 = argv[1];
        if (arg1 == "home") {
            if (executeCommand("home-manager switch") != 0){
              cerr << "home-manager switch failed" << endl;
            }
            bool noPush = false;
             for (int i = 2; i < argc; ++i) {
                if (string(argv[i]) == "-np") {
                    noPush = true;
                    break;
                }
            }
            if (!noPush) {
                string newVersion = updateConfigVersion(versionFile);
                executeCommand("git add .");
                executeCommand("git commit -m \"version " + newVersion + "\"");
                executeCommand("git push origin home");
            } else {
                cout << "no push made" << endl;
            }
        } else if (arg1 == "test") {
            string rebuildCommand = "sudo -S nixos-rebuild test";
            if (!handlePasswordPrompt(rebuildCommand, sudoPassword, "\\[sudo\\] password for ")) {
                cerr << "Failed to run nixos-rebuild test." << endl;
                return 1;
            }

        } else {
             if (argc > 2) {
                string rebuildCommand = "sudo -S nixos-rebuild test";
                 if (!handlePasswordPrompt(rebuildCommand, sudoPassword, "\\[sudo\\] password for ")) {
                    cerr << "Failed to run nixos-rebuild test." << endl;
                    return 1;
                }
            } else {
                string rebuildCommand = "sudo -S nixos-rebuild switch";
                 if (!handlePasswordPrompt(rebuildCommand, sudoPassword, "\\[sudo\\] password for ")) {
                    cerr << "Failed to run nixos-rebuild switch." << endl;
                    return 1;
                }
                string newVersion = updateConfigVersion(versionFile);
                executeCommand("git add .");
                executeCommand("git commit -m \"version " + newVersion + "\"");
                executeCommand("git push origin system");
            }
        }
    } else {
        string rebuildCommand = "sudo -S nixos-rebuild switch";
         if (!handlePasswordPrompt(rebuildCommand, sudoPassword, "\\[sudo\\] password for ")) {
            cerr << "Failed to run nixos-rebuild switch." << endl;
            return 1;
        }
        string newVersion = updateConfigVersion(versionFile);
        executeCommand("git add .");
        executeCommand("git commit -m \"version " + newVersion + "\"");
        executeCommand("git push origin system");
    }

    if (chdir(origin.c_str()) != 0) {
        perror("chdir back to origin failed");
        return 1;
    }

    // Example of interacting with a locked file program
    string lockedFileCommand = "your_locked_file_program"; // Replace
    cout << "Attempting to interact with '" << lockedFileCommand << "'..." << endl;
    if (handlePasswordPrompt(lockedFileCommand, sudoPassword, "(Enter password:|Password:)")) {
        cout << "Successfully interacted with the locked file program (password sent if needed)." << endl;
        // Add code to interact with the file here
    } else {
        cout << "Failed to interact with the locked file program (or no password was needed)." << endl;
    }

    return 0;
}


# Setting up Jenkins
Pull image:
docker pull jenkins/jenkins:lts

Create volume:
```docker volume create jenkins-data```
Verify:
```docker volume ls```

Run container:
```docker run -d -p 8080:8080 -p 50000:50000 -v jenkins-data:/var/jenkins_home --name jenkins-lts jenkins/jenkins:lts```

View logs:
```docker logs jenkins-lts```

# Creating a "New Item" (Freestyle Project)
Click on "New Item," gave it a name, and selected the Freestyle project type. <br />
A "Project" (or Job) is the basic unit of work in Jenkins. We chose a "Freestyle" project because it’s the most flexible and easiest way to start learning how Jenkins handles tasks without needing complex scripts.

#  Configuring an "Execute shell" Build Step
Inside the project configuration, add a build step to run a shell command (like echo "Hello LabEx"). <br />
This tells Jenkins exactly what to do. By using a shell command, you are simulating a real-world task, such as compiling code, running a test script, or deploying a file.

# Manually Triggering a Build ("Build Now")
Click the Build Now button on the project page. <br />
This tells Jenkins to run the project immediately. In a production environment, builds are often triggered automatically by code changes, but manual triggers are essential for testing your configuration.

# Inspecting Build History and Console Output
Click on the specific build number (e.g., #1) in the Build History and opened the Console Output. <br />
This is the most important troubleshooting step. The Console Output shows you exactly what happened during the execution. If a build fails, this is where you find the error logs to fix the problem.

# Integrate Jenkins with git remote repository
_______________________________
# 1. Preparing the Environment
You learned that Jenkins uses a Plugin Architecture. Integration doesn't happen by magic; it requires the Git Plugin. 
<br />
__Key Action: Navigating to Manage Jenkins -> Plugins to ensure the necessary tools are installed.__

## 2. Project Configuration (Freestyle Project)
You learned how to create a basic job in Jenkins and link it to a repository. <br />

Example: In the Source Code Management section, you selected Git and provided a Repository URL (like https://github.com/labex-labs/jenkins-git-sample.git). <br />
Why it matters: This tells Jenkins exactly where to fetch the code whenever a build is triggered.
## 3. Defining Build Logic
You learned how to tell Jenkins what to do once the code is downloaded. <br />

Example: Using a Build Step with "Execute shell". <br />
Command used: You ran a script found in the repo, such as: <br />
```
chmod +x build.sh 
./build.sh
```
Why it matters: This transforms Jenkins from a simple "downloader" into an "automation engine" that can compile code, run tests, or package applications. <br />

## 4. Manual Verification
You learned how to start a build manually and inspect the results.
<br />
Key Action: Clicking Build Now and checking the Console Output. <br /> 
Insight: The Console Output is your best friend for debugging; it shows exactly how Jenkins executed each shell command.

## 5. Automation with "Poll SCM"
This is where you learned the "Continuous" part of CI. Instead of clicking a button, you configured Jenkins to check for changes automatically.
<br />
Example Schedule: You might have used a Cron-like syntax such as * * * * * (which means "check every minute"). <br />
Concept: SCM Polling allows Jenkins to ask Git, "Is there anything new?" If the answer is yes (a new commit), Jenkins triggers the build automatically. <br />
__Summary__
By finishing this lab, you have moved from running scripts manually on your computer to a system where Code Changes -> Jenkins Detects -> Jenkins Builds. This is the heart of automated software delivery! <br />
# Setting up Jenkins
Pull image:
docker pull jenkins/jenkins:lts

Create volume:
docker volume create jenkins-data
Verify:
docker volume ls

Run container:
docker run -d -p 8080:8080 -p 50000:50000 -v jenkins-data:/var/jenkins_home --name jenkins-lts jenkins/jenkins:lts

View logs:
docker logs jenkins-lts

# Creating a "New Item" (Freestyle Project)
Click on "New Item," gave it a name, and selected the Freestyle project type.
A "Project" (or Job) is the basic unit of work in Jenkins. We chose a "Freestyle" project because it’s the most flexible and easiest way to start learning how Jenkins handles tasks without needing complex scripts.

#  Configuring an "Execute shell" Build Step
Inside the project configuration, add a build step to run a shell command (like echo "Hello LabEx").
This tells Jenkins exactly what to do. By using a shell command, you are simulating a real-world task, such as compiling code, running a test script, or deploying a file.

# Manually Triggering a Build ("Build Now")
Click the Build Now button on the project page.
This tells Jenkins to run the project immediately. In a production environment, builds are often triggered automatically by code changes, but manual triggers are essential for testing your configuration.

# Inspecting Build History and Console Output
Click on the specific build number (e.g., #1) in the Build History and opened the Console Output.
This is the most important troubleshooting step. The Console Output shows you exactly what happened during the execution. If a build fails, this is where you find the error logs to fix the problem.


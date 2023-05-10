import jenkins.model.*
import hudson.security.*
import org.jenkinsci.plugins.*

// Read the Jenkins secret file
def secrets = new File("/run/secrets/jenkins-secret").text.tokenize(System.getProperty("line.separator"))

def adminUsername = ""
def adminPassword = ""

secrets.each { secret ->
    def keyValue = secret.tokenize("=")
    if (keyValue[0] == "JENKINS_ADMIN_USER") {
        adminUsername = keyValue[1]
    } else if (keyValue[0] == "JENKINS_ADMIN_PASS") {
        adminPassword = keyValue[1]
    }
}

if (!adminUsername || !adminPassword) {
    println "ERROR: Missing admin username or password in jenkins-secret file."
    return
}

def instance = Jenkins.getInstance()

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(adminUsername, adminPassword)
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.save()

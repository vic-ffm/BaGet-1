// TODO: Update this script to use `stash` -- seen in screenshot here: https://marketplace.visualstudio.com/items?itemName=jmMeessen.jenkins-declarative-support
timestamps {
	node {
		stage('Clone repository') {
			// Checkout the repo
			checkout scm
		}

        // Jenkins pipeline has a bug where it does not support a multi-stage docker build
        // https://issues.jenkins-ci.org/browse/JENKINS-44789
        // https://issues.jenkins-ci.org/browse/JENKINS-44609
        // https://issues.jenkins-ci.org/browse/JENKINS-31507
        // The work around is to invoke docker from the shell
		stage('Build Docker Image') {
			def imageName

			// Tag branches with their branch name if not master
			if( env.BRANCH_NAME == "master" ) {
			    imageName = "baget"
			} else {
				def branchName = BRANCH_NAME.toLowerCase().replaceAll(" ","_")
				// Non-env. variable needs double quotes to be parsed correctly (bash variables work better with single quotes)
				imageName = "baget_${branchName}"
			}
			sh "docker build --label ${imageName} ."

			// Push the image with two tags:
			//  - Incremental build number from Jenkins
			//  - The 'latest' tag.
			docker.withRegistry('http://registry.ffm.vic.gov.au:31337/') {
				echo "Pushing Docker Image - ${imageName}:${env.BUILD_NUMBER}"
				sh "docker push http://registry.ffm.vic.gov.au:31337/${imageName}:${env.BUILD_NUMBER}"
				echo "Pushing Docker Image - ${imageName}:latest"
				sh "docker push http://registry.ffm.vic.gov.au:31337/${imageName}:latest"
			}

			// Trigger release if this is master
			if( env.BRANCH_NAME == "master" ) {
			    build job: '../deploy-to-dev',
			    parameters: [
			        string(name: 'DOCKER_REPOSITORY', value: 'registry.ffm.vic.gov.au:31337'),
			        string(name: 'DOCKER_IMAGE', value: "${imageName}"),
			        string(name: 'DOCKER_TAG', value: "${env.BUILD_NUMBER}")
			    ],
			    wait: false
			}
		}
	}
}

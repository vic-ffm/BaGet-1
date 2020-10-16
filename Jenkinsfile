// TODO: Update this script to use `stash` -- seen in screenshot here: https://marketplace.visualstudio.com/items?itemName=jmMeessen.jenkins-declarative-support
timestamps {
	node {
		stage('Clone repository') {
			// Checkout the repo
			checkout scm
		}

		docker.image('mcr.microsoft.com/dotnet/core/sdk:3.1').inside() {
			stage('Restore Dependencies') {
				sh 'dotnet restore src/BaGet'
			}
			stage('Build') {
				sh 'dotnet build -c Release -o ${WORKSPACE}/${BUILD_TAG} src/BaGet'
			}
			stage('Publish') {
				sh 'dotnet publish -c Release -o ${WORKSPACE}/${BUILD_TAG} src/BaGet'
			}
		}

		stage('Build Docker Image') {
			def releaseImage

			// Tag branches with their branch name if not master
			if( env.BRANCH_NAME == "master" ) {
				releaseImage = docker.build('baget', '--build-arg APP_PATH=${BUILD_TAG} .')
			} else {
				def BRANCH_NAME_LOWER = BRANCH_NAME.toLowerCase().replaceAll(" ","_")
				// Non-env. variable needs double quotes to be parsed correctly (bash variables work better with single quotes)
				def IMAGE_NAME = "baget_${BRANCH_NAME_LOWER}"
				releaseImage = docker.build(IMAGE_NAME, '--build-arg APP_PATH=${BUILD_TAG} .')
			}

			// Push the image with two tags:
			//  - Incremental build number from Jenkins
			//  - The 'latest' tag.
			docker.withRegistry('http://registry.ffm.vic.gov.au:31337/') {
				echo "Pushing Docker Image - ${env.BUILD_NUMBER}"
				releaseImage.push("${env.BUILD_NUMBER}")
				echo "Pushing Docker Image - latest"
				releaseImage.push("latest")
			}

			// Trigger release if this is master
			if( env.BRANCH_NAME == "master" ) {
			    build job: '../deploy-to-dev', parameters: [string(name: 'DOCKER_REPOSITORY', value: 'registry.ffm.vic.gov.au:31337'), string(name: 'DOCKER_IMAGE', value: 'baget'), string(name: 'DOCKER_TAG', value: "${env.BUILD_NUMBER}")], wait: false
			}
		}
	}
}

pipeline {
    agent any

    parameters {
        choice(
            name: 'OS',
            choices: ['linux', 'darwin', 'windows'],
            description: 'Target operating system'
        )
        choice(
            name: 'ARCH',
            choices: ['amd64', 'arm64'],
            description: 'Target architecture'
        )
        booleanParam(
            name: 'SKIP_TESTS',
            defaultValue: false,
            description: 'Skip running tests'
        )
        booleanParam(
            name: 'SKIP_LINT',
            defaultValue: false,
            description: 'Skip running linter'
        )
    }

    stages {
        stage('Prepare') {
            steps {
                echo "OS: ${params.OS}"
                echo "ARCH: ${params.ARCH}"
            }
        }

        stage('Lint') {
            when {
                expression { !params.SKIP_LINT }
            }
            steps {
                echo "Running linter..."
            }
        }

        stage('Tests') {
            when {
                expression { !params.SKIP_TESTS }
            }
            steps {
                echo "Running tests..."
            }
        }

        stage('Build') {
            steps {
                echo "Building for ${params.OS}/${params.ARCH}"
            }
        }
    }
}

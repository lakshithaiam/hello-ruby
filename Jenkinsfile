pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: sonar-scanner
    image: sonarsource/sonar-scanner-cli
    command:
    - cat
    tty: true
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - cat
    tty: true
    securityContext:
      runAsUser: 0
      readOnlyRootFilesystem: false
    env:
    - name: KUBECONFIG
      value: /kube/config        
    volumeMounts:
    - name: kubeconfig-secret
      mountPath: /kube/config
      subPath: kubeconfig
  - name: dind
    image: docker:dind
    args: ["--registry-mirror=https://mirror.gcr.io", "--storage-driver=overlay2"]
    securityContext:
      privileged: true  # Needed to run Docker daemon
    env:
    - name: DOCKER_TLS_CERTDIR
      value: ""  # Disable TLS for simplicity
    volumeMounts:
    - name: docker-config
      mountPath: /etc/docker/daemon.json
      subPath: daemon.json  # Mount the file directly here
  volumes:
  - name: docker-config
    configMap:
      name: docker-daemon-config
  - name: kubeconfig-secret
    secret:
      secretName: kubeconfig-secret
'''
        }
    }
    
    
    stages {
        stage('Run Tests') {
            steps {
                container('python') {
                }
            }
            
        }
        stage('SonarQube Analysis') {
            steps {
                container('sonar-scanner') {
                }
            }
        }
        stage('Login to Docker Registry') {
            steps {
                container('dind') {
                    sh 'docker --version'
                    sh 'sleep 10'
                    sh 'docker login nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085 -u admin -p Changeme@2025'
                }
            }
        }
        stage('Build - Tag - Push') {
            steps {
                container('dind') {
                    sh 'docker build -t nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085/my-repository/hello-ruby:v001 .'
                    sh 'docker push nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085/my-repository/hello-ruby:v001'
                    sh 'docker pull nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085/my-repository/hello-ruby:v001'
                    sh 'docker image ls'
                }
            }
        }
        stage('Deploy hello-ruby') {
            steps {
                container('kubectl') {
                    script {
                        dir('hello-ruby-deployment') {
                            sh 'kubectl get node'
                            sh 'kubectl apply -f hello-ruby-namespace.yaml'
                            sh 'kubectl apply -f hello-ruby-deployment.yaml'
                            sh 'sleep 99999'
                        }
                    }
                }
            }
        }
    }
}
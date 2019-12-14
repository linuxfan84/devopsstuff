pipeline {
        
    agent any
    
    stages {
        
        stage('First') {
            
            options {
                checkoutToSubdirectory("foo")
            }
                
            steps {
            sh 'ls -latr $WORKSPACE/foo/*'
            }
            
        }
    }
    
}

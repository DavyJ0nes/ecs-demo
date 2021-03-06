def branch = env.BRANCH_NAME
def env_stack

if ( branch == "master" ) {
  env_stack = "prod"
} else if ( branch == "develop" ) {
  env_stack = "qa"
}  else {
  env_stack = "dev"
}

def dir = "terraform/env"

properties([pipelineTriggers([pollSCM('* * * * *')])])

pipeline {

  agent none
  
  stages {
    stage('Init') {
      agent {
        docker {
          image 'hashicorp/terraform:light'
        }
      }
      steps {
        sh "env"
        sh "echo 'Initialising Terraform Stack for ${env_stack} Environment'"
        sh "cd ${dir}/${env_stack} && terraform get && terraform init -force-copy -no-color"
      }
    }

    stage('Validate') {
      agent {
        docker {
          image 'hashicorp/terraform:light'
        }
      }
      steps {
        sh "echo 'Validating Terraform file for ${env_stack} Environment'"
        sh "cd ${dir}/${env_stack} && terraform get && terraform validate -no-color -var-file=${env_stack}.tfvars"
      }
    }

    stage('Plan') {
      agent {
        docker {
          image 'hashicorp/terraform:light'
        }
      }
      steps {
        sh "echo 'Preparing plan to deploy ${env_stack} Environment'"
        sh "cd ${dir}/${env_stack} && terraform get && terraform plan -no-color -var-file=${env_stack}.tfvars"
      }
    }

    stage('Apply') {
      agent {
        docker {
          image 'hashicorp/terraform:light'
        }
      }
      steps {
        sh "echo 'Deploying ${env_stack} Environment'"
        sh "cd ${dir}/${env_stack} && terraform get && terraform apply -no-color -var-file=${env_stack}.tfvars && terraform output"
      }
    }

    stage('Verify Environment with Specs') {
      agent {
        docker {
          image 'ruby'
        }
      }
      steps {
       sh "echo 'Running Tests on ${env_stack} Environment'"
       sh "export AWS_REGION=eu-west-1 && cd terraform && bundle install --path=/usr/local/bundle >> /dev/null && bundle exec rake spec SPEC=spec/${env_stack}_spec.rb && exit 0"
      }
    }
  }
}

# devops


Task List:

1. Create a custom AMI

2. Create a VPC with 2 public subnets and 2 private subnets

3. Create a ECS 

4. Create a docker image

5. Run the image as task in docker

6. Create a load balancer ALB , and configure the target group

7. Lock down the EC2 security group to the ALB Security group

8. Only allow ALB to be accessible on port 80


For enabling auto scaling , we can add cloudwatch agent in the instance , by either running the agent installation in the userdata during launch config or bake the cloudwatch agent in the AMI used to launch the EC2

 rpm -Uvh https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
 /opt/aws/bin/cfn-init -v --stack ${AWS::StackId} --resource ASGLaunchConfiguration --region ${AWS::Region} --configsets default
 /opt/aws/bin/cfn-signal -e $? --stack ${AWS::StackId} --resource ASGLaunchConfiguration --region ${AWS::Region}
Metadata:
    AWS::CloudFormation::Init:
      configSets:
        # These scripts will run during the instance launch triggered by the userData
        default:
          - 01_setupCfnHup
          - 02_config-amazon-cloudwatch-agent
          - 03_restart_amazon-cloudwatch-agent
        # These scripts will run during an update of the instance metadata = stack update.
        UpdateEnvironment:
          - 02_config-amazon-cloudwatch-agent
          - 03_restart_amazon-cloudwatch-agent

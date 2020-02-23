
# Solution:

For the given problem statement , the solution i choose is as follows:
1. Create a new AMI using packer , with base AMI as Amazon Linux2 , ecs optimized.( As i am using ECS to run the services)
2. Create a new VPC with multiple subnets(public/private) spread across AZ's, for having security,high availability. The VPC configuration will be as follows:
    ```
        Hard values for the subnet masks. These masks define
        the range of internal IP addresses that can be assigned.
        The VPC can have all IP's from 10.0.0.0 to 10.0.255.255
        There are four subnets which cover the ranges:
        10.0.0.0 - 10.0.0.255
        10.0.1.0 - 10.0.1.255
        10.0.2.0 - 10.0.2.255
        10.0.3.0 - 10.0.3.255
      
        If you need more IP addresses (perhaps you have so many
        instances that you run out) then you can customize these
        ranges to add more
        VPC in which containers will be networked.
        It has two public subnets, and two private subnets.
        We distribute the subnets across the first two available subnets
        for the region, for high availability.
    ```

3. Create a new ECS cluster , with EC2 configuration , referring the AMI ID created in the first step.The reason for choosing ECS cluster is to make sure for service resiliency and high availability.

4. Create a public facing ALB , to route the incoming request to the backend services. The ALB is only accepting requests on port 80 and routes it back to the backend service. The ALB is in the public subnet , so can be accessed from the internet.

5. Create a service ( task definition) , pointing to the docker image of the service , (already created and published to my docker-hub repo), and launch the service

# Task List:

1. Create a custom AMI , following the instructions mentioned
2. Create a VPC with 2 public subnets and 2 private subnets
3. Create a ECS 
4. Create a docker image , for the application provided. Publish the image to docker-hub
5. Run the image as task in docker
6. Create a load balancer ALB , and configure the target group
7. Lock down the EC2 security group to the ALB Security group
8. Only allow ALB to be accessible on port 80

# Tools and setup

1. Install packer https://packer.io/intro/getting-started/install.html
2. Install AWS Cli
2. Configure your AWS cli with the admin credentials or any role that has all the necessary privileges. (Use AWS configure)
3. Export your AWS access key and password to the session before running packer.

# Steps to execute:

1. Post setting up all the tools and necessary configuration ,  run the deploy.sh script from the scripts folder.
   this currently orchestrates everything, which is described as part of the solution


# Accessing the service

Once the script execution completes, go to your AWS Management console, copy the DNS name of the public load balancer and paste it in your browser.


# Alternatives and improvements:


1. Instead of using an ECS cluster, we could have just directly configure a EC2 auto scaling group and provide instructions as part of the launch config. But con's of this approach is , this will guarantee the server being available , but the if the actual application is tricky. We then have to write a health endpoint and might lead to some extra work there.And also scaling of the service is not possible. If we want to have more instances of the service , only way is to scale the number of instances which is not cost effective

2. Currently in ECS Cluster auto-scaling of container instances is not fully effective , as by default we can only have few metrics ( like CPU Utilization , data in and data out). We can use the cloudwatch agent to spit out more metrics and write auto scaling policies around that. So we can add cloudwatch agent in the instance , by either running the agent installation in the userdata during launch config or bake the cloudwatch agent in the AMI used to launch the EC2. A Sample is shown below

 ```
    rpm -Uvh https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
    /opt/aws/bin/cfn-init -v --stack ${AWS::StackId} --resource ASGLaunchConfiguration --region ${AWS::Region}
    /opt/aws/bin/cfn-signal -e $? --stack ${AWS::StackId} --resource ASGLaunchConfiguration --region ${AWS::Region}
```

3. I could have used ansible to run the show, define a playbook and it orchestrates the entire flow, but for the given use case i though a script would suffice. Definitely can be looked upon.

4. Usage of cloud formation nested stacks is also a definite option , which reduces the risk of execution of a next sequential stack if the dependent stack fails

5. Packer currently produces a new AMI ID every time as expected, but this can be conditionally averted


# Conclusion and comments:

Overall it is a good decent exercise ,to understand the conceptual knowledge as well to identify the right tooling for the right job.

In my opinion:

IaaC - should be used to control the life-cycle of the infrastructure being deployed.
CaaC - Should be used to control the packages that are deployed on to these infra.

Job's which are out of the scope of the above two , need to be handled on a use case basis. 

For e.g , building an AMI , is not really infra, neither configuration. It is a kind of overlap of the two , as we have to first create a machine, install the packages, and create a snapshot and generate an AMI out of it. ( in AWS context).

So for this reason i choose Packer ,as it effectively is doing that and not interfering in the lifecycle of config or infra.

If the case, would have been running some package updates or patching the instances, CaaC would have been the right choice.






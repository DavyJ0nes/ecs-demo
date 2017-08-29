require 'spec_helper'

#---------- SETTING UP ----------#
environment = "dev"
prefix = "davyj-ao-training"
naming_prefix = "#{prefix}-#{environment}"
owner = "davy-jones"

#---------- TESTING VPC ----------#
describe vpc("#{naming_prefix}-vpc") do
  it { should exist }
  it { should be_available }
  its(:cidr_block) { should eq '10.230.0.0/16' }
  it { should have_route_table("#{naming_prefix}-public-0") }
  it { should have_route_table("#{naming_prefix}-public-1") }
  it { should have_route_table("#{naming_prefix}-public-2") }
  it { should have_route_table("#{naming_prefix}-private-0") }
  it { should have_route_table("#{naming_prefix}-private-1") }
  it { should have_route_table("#{naming_prefix}-private-2") }
  it { should have_tag('Owner').value("#{owner}") }
end

#---------- TESTING ROUTE 53 ----------#
# Not sure on best way to test specific routes in here
describe route53_hosted_zone('davy.colab.cloudreach.com.') do
  it { should exist }
end

#---------- TESTING SSL CERT EXISTS ----------#
describe acm('*.davy.colab.cloudreach.com') do
    it { should exist }
end

#---------- TESTING S3 ----------#
describe s3_bucket("cr-davy-agileops-training") do
  it { should exist }
  it { should have_object('terraform/ecs_cluster-dev') }
  it { should have_versioning_enabled }
  it { should have_tag('Owner').value("#{owner}") }
end

#---------- TESTING ECS CLUSTER ----------#
describe ecs_cluster("#{naming_prefix}-cluster") do
  it { should exist }
  it { should be_active }
end

# describe ecs_container_instance("#{naming_prefix}-ecs-asg"), cluster: "#{naming_prefix}-cluster" do
#   it { should exist }
#   it { should be_active }
# end

#---------- TESTING WEB ASG ----------#
describe autoscaling_group("#{naming_prefix}-ecs-asg") do
  it { should exist }
  it { should have_tag('Owner').value("#{owner}") }
end

describe security_group("#{naming_prefix}-ecs-asg-sg") do
  it { should exist }
  its(:outbound) { should be_opened }
  its(:inbound) { should be_opened(80) }
  its(:inbound) { should be_opened(443) }
end

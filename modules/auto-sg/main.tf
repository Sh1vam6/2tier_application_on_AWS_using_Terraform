# providing key-pair 

resource "aws_key_pair" "key-tf" {
  key_name   = "key-tf"
  public_key = file("~/.ssh/id_rsa_terraform.pub")
}

# creating launch template for ec2 in public subnet

resource "aws_launch_template" "public-launch-template" {

  name          = "${var.project_name}-publicLaunch-template"
  key_name      = aws_key_pair.key-tf.key_name
  image_id      = var.ami
  instance_type = var.instance-type
  user_data     = filebase64("../modules/auto-sg/ec2-init.sh")

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size           = 20
      delete_on_termination = true
    }
  }

  monitoring {
    enabled = true
  }

  placement {
    availability_zone = "all"
    tenancy           = "default"
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.public_instance_sg_id]

  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      name = "public launch template"
    }

  }

}



# creating auto scaling group for public subnet

resource "aws_autoscaling_group" "public-autoscaling-group" {
  name             = "${var.project_name}-public-autoscaling-group"
  desired_capacity = var.desired_capacity
  min_size         = var.min_size
  max_size         = var.max_size

  health_check_grace_period = 300
  health_check_type         = "ELB"
  vpc_zone_identifier       = [var.public-subnet-az1-id, var.public-subnet-az2-id]
  target_group_arns         = [var.public_loadbalancer_target_group_arn]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  launch_template {
    id      = aws_launch_template.public-launch-template.id
    version = aws_launch_template.public-launch-template.latest_version
  }
  depends_on = [aws_launch_template.public-launch-template]
  tag {
    key                 = "Name"
    value               = "web"
    propagate_at_launch = true
  }
}


# scale up policy
resource "aws_autoscaling_policy" "public_scale_up" {
  name                   = "${var.project_name}-asg-scale-up"
  autoscaling_group_name = aws_autoscaling_group.public-autoscaling-group.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1" #increasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}


# scale up alarm
# alarm will trigger the ASG policy (scale/down) based on the metric (CPUUtilization), comparison_operator, threshold
resource "aws_cloudwatch_metric_alarm" "public_scale_up_alarm" {
  alarm_name          = "${var.project_name}-asg-scale-up-alarm"
  alarm_description   = "asg-scale-up-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/AutoScaling"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.public-autoscaling-group.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.public_scale_up.arn]
}


# scale down policy
resource "aws_autoscaling_policy" "public_scale_down" {
  name                   = "${var.project_name}-asg-scale-down"
  autoscaling_group_name = aws_autoscaling_group.public-autoscaling-group.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1" # decreasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

# scale down alarm
resource "aws_cloudwatch_metric_alarm" "public_scale_down_alarm" {
  alarm_name          = "${var.project_name}-asg-scale-down-alarm"
  alarm_description   = "asg-scale-down-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10" # Instance will scale down when CPU utilization is lower than 5 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.public-autoscaling-group.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.public_scale_down.arn]
}



# creating launch template for ec2 in private subnet

resource "aws_launch_template" "private-launch-template" {

  name          = "${var.project_name}-privateLaunch-template"
  key_name      = aws_key_pair.key-tf.key_name
  image_id      = var.ami
  instance_type = var.instance-type
  user_data     = filebase64("../modules/auto-sg/data.sh")

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size           = 20
      delete_on_termination = false
    }
  }

  monitoring {
    enabled = true
  }

  placement {
    availability_zone = "all"
    tenancy           = "default"
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.private_instance_sg_id]

  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      name = "private launch template"
    }

  }

}


# #create autoscaling group
resource "aws_autoscaling_group" "private_autoscaling_group" {

  name                      = "${var.project_name}-privateautoscaling-group"
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  health_check_grace_period = 300
  health_check_type         = "ELB"
  vpc_zone_identifier = [var.private-data-subnet-az1-id, var.private-data-subnet-az2-id]
  target_group_arns   = [var.private_loadbalancer_target_group_arn] 

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  launch_template {
    id      = aws_launch_template.private-launch-template.id
    version = aws_launch_template.private-launch-template.latest_version 
  }
  depends_on = [aws_launch_template.private-launch-template]
  # load_balancers = [var.private_loadbalancer_arn]

  tag {
    key                 = "Name"
    value               = "app"
    propagate_at_launch = true
  }
}

# scale up policy
resource "aws_autoscaling_policy" "private_scale_up" {
  name                   = "${var.project_name}-asg-scale-up"
  autoscaling_group_name = aws_autoscaling_group.private_autoscaling_group.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1" #increasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

# scale up alarm
# alarm will trigger the ASG policy (scale/down) based on the metric (CPUUtilization), comparison_operator, threshold
resource "aws_cloudwatch_metric_alarm" "private_scale_up_alarm" {
  alarm_name          = "${var.project_name}-asg-scale-up-alarm"
  alarm_description   = "asg-scale-up-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/AutoScaling"
  period              = "120"
  statistic           = "Average"
  threshold           = "70" 
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.private_autoscaling_group.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.private_scale_up.arn]
}

# scale down policy
resource "aws_autoscaling_policy" "private_scale_down" {
  name                   = "${var.project_name}-asg-scale-down"
  autoscaling_group_name = aws_autoscaling_group.private_autoscaling_group.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1" # decreasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

# scale down alarm
resource "aws_cloudwatch_metric_alarm" "private_scale_down_alarm" {
  alarm_name          = "${var.project_name}-asg-scale-down-alarm"
  alarm_description   = "asg-scale-down-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10" # Instance will scale down when CPU utilization is lower than 5 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.private_autoscaling_group.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.private_scale_down.arn]
}









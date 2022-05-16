# Basic IAM Role for the Fargate Profile

resource "aws_iam_role" "eks_fargate_profile_role" {
  name = "eks-fargate-profile-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Attach the EKS Fargate Pod Execution Role Policy to the Fargate Profile role

resource "aws_iam_role_policy_attachment" "execution_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks_fargate_profile_role.name
}

# Attach the CloudWatch transport Policy to the Fargate Profile role

resource "aws_iam_role_policy_attachment" "cloudwatch_transport_policy_attachment" {
  policy_arn = aws_iam_policy.cloudwatch_transport_iam_policy.arn
  role       = aws_iam_role.eks_fargate_profile_role.name
}

# Policy required by the IAM Role assigned to the Fargate Profile
# in order for communication with CloudWatch

resource "aws_iam_policy" "cloudwatch_transport_iam_policy" {
  name = "cloudwatch-transport-iam-policy"
  path = "/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : [
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
      ],
      "Resource" : "*"
    }]
  })
}

# add role with policy to allow ec2 instance to access specific s3 bucket
resource "aws_iam_role" "mys3role" {
    name    =   "s3access"
    assume_role_policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }
EOF
}

resource "aws_iam_policy" "mypolicy" {
    name    =   "myPolicy"
    path    =   "/"
    description     =   "my test policy"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "s3BucketAccess",
            "Effect": "Allow",
            "Action": [
                "s3:GetObjectAcl",
                "s3:GetObject",
                "s3:ListBucket"
            ],
        "Resource": [
            "arn:aws:s3:::bobc-ireland/*",
            "arn:aws:s3:::bobc-ireland"
                ]
        }
    ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "s3policyattach" {
    role        =       aws_iam_role.mys3role.name
    policy_arn  =       aws_iam_policy.mypolicy.arn
}

resource "aws_iam_instance_profile" "myProfile" {
    name        =   "s3AccessProfile"
    role        =   aws_iam_role.mys3role.name
}
resource "aws_iam_openid_connect_provider" "openid_github" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"]
  tags = {
    IAC = true
  }
}

resource "aws_iam_role" "github_role" {
  name = "github_role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "sts:AssumeRoleWithWebIdentity",
          "Principal" : {
            "Federated" : "arn:aws:iam::575108923772:oidc-provider/token.actions.githubusercontent.com"
          },
          "Condition" : {
            "StringEquals" : {
              "token.actions.githubusercontent.com:aud" : [
                "sts.amazonaws.com"
              ],
              "token.actions.githubusercontent.com:sub" : [
                # Só trocar o nome do repositório para liberar o acesso ao repo            
                "repo:matheustanaka/node-cd-api:ref:refs/heads/main"
              ]
            }
          }
        }
      ]
  })

  tags = {
    IAC = true
  }
}

resource "aws_iam_role_policy" "github_role_policy" {
  name = "github_role_policy"
  role = aws_iam_role.github_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          # Libera permissão para criar um ec2
          "ec2:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

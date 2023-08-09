#module "aws_cognito_user_pool_complete" {
#  source  = "lgallard/cognito-user-pool/aws"
#  user_pool_name           = "user-pool-prod"
#  alias_attributes         = ["email"]
#  auto_verified_attributes = ["email"]
#  deletion_protection = "INACTIVE"
#  client_name = "client-app-prod"
#  client_generate_secret = false
#  client_default_redirect_uri = "appclient-prod"
#  #client_allowed_oauth_flows = ["client-pool-prod"]
#  #client_callback_urls = ["client-pool-prod"]
#  #client_allowed_oauth_scopes = ["email"]
#  #client_explicit_auth_flows
#
#  admin_create_user_config = {
#    email_subject = "Your confirmation code is"
#  }
#  password_policy = {
#    minimum_length    = 8
#    require_lowercase = false
#    require_numbers   = true
#    require_symbols   = true
#    require_uppercase = true
#    temporary_password_validity_days = 10
#  }
#  schemas = [
#    {
#      attribute_data_type      = "Boolean"
#      developer_only_attribute = false
#      mutable                  = true
#      name                     = "available"
#      required                 = false
#    },
#    {
#      attribute_data_type      = "Boolean"
#      developer_only_attribute = true
#      mutable                  = true
#      name                     = "registered"
#      required                 = false
#    }
#  ]
#  string_schemas = [
#    {
#      attribute_data_type      = "String"
#      developer_only_attribute = false
#      mutable                  = false
#      name                     = "email"
#      required                 = true
#      string_attribute_constraints = {
#        min_length = 7
#        max_length = 15
#      }
#    }
#  ]
#  recovery_mechanisms = [
#     {
#      name     = "verified_email"
#      priority = 1
#    }
#  ]
#
#  tags = {
#    Environment = "prod"
#  }
#}
#
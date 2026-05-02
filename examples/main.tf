module "db_instance" {
  source = "../"
  # source            = "github.com/wrasdf/terraform-rds?ref=v1.0.5"

  environment       = "labs"
  identifier        = "labs-test-postgres-db"
  engine            = "postgres"
  engine_version    = "17"
  instance_class    = "db.t4g.large"
  allocated_storage = 20

  db_name  = "postgres"
  username = "master"
  port     = 5432

}

module "db_instance_mysql" {
  source = "../"
  # source            = "github.com/wrasdf/terraform-rds?ref=v1.0.5"

  environment       = "labs"
  identifier        = "labs-test-mysql"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t4g.large"
  allocated_storage = 20

  db_name  = "completeMysql"
  username = "master"
  port     = 3306

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

}

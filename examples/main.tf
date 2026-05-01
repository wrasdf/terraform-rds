module "db_instance" {
  source            = "github.com/wrasdf/terraform-rds?ref=v1.0.0"
  
  environment       = "labs"
  identifier        = "labs-test-postgres-db"
  engine            = "postgres"
  engine_version    = "17"     
  instance_class    = "db.t4g.large"
  allocated_storage = 20

  db_name           = "postgres"
  username          = "master"
  port              = 5432  

}
# terraform RDS

- Example 1
```
module "db_instance" {
  source            = "github.com/wrasdf/terraform-rds?ref=v1.0.0"
  
  environment       = "labs"
  identifier        = "labs-test-postgres-db"
  engine            = "postgres"
  engine_version    = "17"     
  environment       = "labs"
  instance_class    = "db.t4g.large"
  allocated_storage = 20

  db_name           = "postgres"
  username          = "master"
  port              = 5432  

}
```


- Example 2
```
module "db_instance" {
  source = "github.com/wrasdf/terraform-rds?ref=v1.0.0"

  environment                     = "labs"
  identifier                      = "labs-test-postgres"
  engine                          = "postgres"
  engine_version                  = "17"     
  environment                     = "labs"
  instance_class                  = "db.t4g.micro"
  allocated_storage               = 20
  max_allocated_storage           = 100
  multi_az                        = true

  db_name                         = "postgres"
  username                        = "master"
  port                            = 5432
  
  
  additional_ingress_cidrs        = ["10.50.0.0/16"] // management vpc cidr
  maintenance_window              = "Tue:17:00-Tue:19:00"
  backup_window                   = "13:00-14:00"
  enabled_cloudwatch_logs_exports = ["postgresql"]
  db_users                        = ["developer", "manager"]

  skip_final_snapshot             = true
  deletion_protection             = false  

  subnets_filter = [{
    name   = "tag:Name"
    values = ["labs-apse2-main-secure-*"]
  }]

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

}
```

- Example 3
```
module "db_instance" {
  source            = "github.com/wrasdf/terraform-rds?ref=v1.0.0"
  
  environment       = "labs"
  identifier        = "labs-test-mysql"
  engine            = "mysql"
  engine_version    = "8.0"     
  environment       = "labs"
  instance_class    = "db.t4g.large"
  allocated_storage = 20

  db_name           = "mysql"
  username          = "master"
  port              = 3306

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
```

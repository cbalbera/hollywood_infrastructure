To add a new resource to the project:
1. register in environments/{env}/main.tf
2. run terraform init -migrate-state

To plan:
terraform plan -out tf.plan

To apply:
terraform apply "tf.plan"
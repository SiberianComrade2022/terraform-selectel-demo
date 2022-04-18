## Mirror Terraform Providers
1. Review the pre-populated list of famous Terraform Providers in `scripts/providers.csv`. Not all of them are needed for this demonstration. The complete list of locally mirrored Providers will consume more than 4GB of disk space. To save disk space and time, you might want to leave only essential providers in the file `scripts/providers.csv`.
2. Find a host which is not blocked by HashiCorp.
3. Create a working directory for this task, switch to it.
4. Run the script `scripts/get-providers.sh`. It can take a half an hour to download all providers mentioned in the original file `scripts/providers.csv`.
5. When finished, copy entire file structure under `/usr/share/terraform/providers`. Verify the resulting file structure:
    ```bash
    tree -d /usr/share/terraform/providers
    /usr/share/terraform/providers
    └── registry.terraform.io
        ├── gitlabhq
        │   └── gitlab
        ├── grafana
        │   └── grafana
        ├── hashicorp
        │   ├── archive
        │   ├── aws
        │   ├── cloudinit
        │   ├── dns
        │   ├── external
        │   ├── google
        │   ├── helm
        │   ├── http
        │   ├── kubernetes
        │   ├── local
        │   ├── null
        │   ├── oraclepaas
        │   ├── random
        │   ├── template
        │   └── tls
        ├── integrations
        │   └── github
        ├── jfrog
        │   └── artifactory
        ├── opennebula
        │   └── opennebula
        ├── selectel
        │   └── selectel
        └── terraform-provider-openstack
            └── openstack
    ```
6. To proceed with only **mirrored** Providers and to **avoiding contacting internet** sources, create file `.terraformrc` in root of your HOME folder:
    ```
    provider_installation {
      filesystem_mirror {
        path    = "/usr/share/terraform/providers"
        include = ["registry.terraform.io/*/*"]
      }
      direct {
          exclude = ["*/*/*"]
      }
    }
    ```

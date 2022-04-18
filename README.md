
## Preparations
1. Create a working directory for this demonstration:  `mkdir tf-demo ; cd tf-demo`

2. Create/Obtain credentials and tokens from Web Console as described in 
https://kb.selectel.com/docs/cloud/servers/tools/how_to_use_openstack_api_through_console_clients/

3. Download and review contents of the small shell script `rc.sh` generated with your credentials. It has all information required to authenticate to the cloud.

5. Install **Terraform**. The demonstration was tested on Terraform version 1.1.x+. See the official instructions from HashiCorp: https://learn.hashicorp.com/tutorials/terraform/install-cli.

6. Set shell auto-completion feature for Terraform to simplify further command line tasks. Run: `terraform -install-autocomplete`. It will append a line to your `.bashrc` file in your home directory. In order to activate this auto-completion functionality you should either re-open your shell or run the added line in teh existing shell.

7. Install **Ansible**; it will be needed for maintaining post-deployment setup. Most Linux distributive include its packages. If unsure how to proceed, you might want to check the official guide: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html.

8. (Optionally) Install command line tool `openstack`. This tool will be helpful for checking cloud objects, review their parameters, etc. Consult the documentation at https://docs.openstack.org/newton/user-guide/common/cli-install-openstack-command-line-clients.html.

9. (Optionally) For running tool `openstack` from the previous step, import contents of shell script `rc.sh` downloaded above. Open UNIX shell and run `source rc.sh`.

10. Clone this git repository to the current directory created above:
      ```bash
      git clone https://github.com/SiberianComrade2022/terraform-selectel-demo.git .
      ```

***
## Initialize and run Terraform
1. Define the following sensitive variables either in file `terraform.tfvars` (not included in Git repository) or through related environment variables (`TF_VAR_sel_account`, `TF_VAR_sel_token`, etc.). The example below shows setting variables in file `terraform.tfvars`:
      ```ini
      user_name      = ""   # account name created on the Web Console, also mentioned in rc.sh.
      user_password  = ""
      sel_account    =      # account number, several digits without quotes
      project_id     = ""   # long alphanumeric ID found on the Web Console and in the script rc.sh.
      sel_token      = ""   # Access token created and available through Web Console. Copy full string.
      proctor_ip     = ""   # Additional IP address or a subnet that has access to Bastion SSH and Prometheus web
      ``` 
2. Run `terraform init` to initialize Providers used in Terraform configuration. Expect to see the following successful message in green:
   > Terraform has been successfully initialized!

   :warning: Be prepared that not all Providers can be downloaded from HashiCorp; they intentionally block access with HTTP code 405. If this is your case you should either use available mirrors or mirror the needed providers as described in [README Extra](README_extra.md).


3. Run `terraform validate` to ensure all files still have correct syntax.
   > Success! The configuration is valid.

4. Run `terraform apply`. It should report successful creation of defined objects.
   > Apply complete! Resources: 43 added, 0 changed, 0 destroyed.

5. Note output section of the previous command. It contains IP addresses and Prometheus URL needed to establish connections to demo infrastructure. This output can be viewed again any time by running `terraform output` from root of working directory. 

:information_source: In case of problems occurred during Terraform execution, start it in debug mode like the following command:

```bash
TF_LOG=DEBUG OS_DEBUG=1 terraform apply
```

****
## Running Ansible
1. Open UNIX shell and switch to folder `ansible`: `cd ansible`.

2. Run `ansible-playbook setup.yaml`. Successful execution should produce only green and yellow/amber status lines. 


***
## Testing Environment

### Load Balancer
Open UNIX shell and type the command below:

`curl `<loadbalancer_ip>`:8080`

Watch different IP addresses are printed as you run this command each time. Note that accessing the same URL from browser might not provide the same  meaningful results with showing different IPs, so use `curl`.

### Prometheus
Open a web browser. Enter address `https://`<prometheus_public_ip>:`9090`. For your convenience copy pre-generated URL from `terraform output` `https_to_prometheus`.


:information_source: Access to Prometheus Web inferface is limited to IP addresses defined as `proctor_ip` and to public IP address of the host from which you ran Terraform (check `curl ifconfig.ru`). 

:no_entry: Access to Prometheus Web inferface from other hosts won't be possible by design.

Watch the "Warning: Potential Security Risk" notice and click "Advanced..." to "Accept the Risk". 

Pay attention that IP address used to access the server is registered in "Subject Alt Names" of SSL/TLS certificate provided by the Prometheus server.

Play around with various metrics. Make sure several instances are reported. Number of reported instances must be equal to number of requested Pool VMs in the cloud.

A couple of examples of basic metrics:
1. `node_load5` - load average for past 5 minutes as reported by `top` or `w`.
2. `100 - (avg by (instance)(irate(node_cpu_seconds_total{job="pool",mode="idle"}[5m])) * 100)` - CPU utilization. 

To confirm that metrics report actual information, you can install on pool VMs tools like `stress`.

### Node Exporter(s) ###
Login with SSH to Bastion machine as advised in output **ssh_to_bastion**, copy-paste full command that like below

`ssh -q -o StrictHostKeyChecking=no -i ./ansible/id_rsa root@xx.xx.xx.xx`

You should be able to get there as root superuser without additional questions and see command prompt like `root@tf-bastion:~#` or whatever was (re)defined in variable `bastion_name`.

On the Bastion host run `curl `_pool.ip.address_`:9100`. Obtain these IP addresses of Pool machines from `terraform output`. Normally you should witness response
  > Client sent an HTTP request to an HTTPS server.

which proves that Node Exporter service is working on HTTPS protocol.

Now run `curl -k https://`_pool.ip.address_`:9100`; IP address is the same. This time a brief HTML output is going to be returned:
```html
<h1>Node Exporter</h1>
<p><a href="/metrics">Metrics</a></p>
```

Node Exporter instances and Prometheus server have been already configured to communicate through HTTPS.
1.  Node Exporter setup in file `/etc/prometheus/web.yml`:
    ```yaml
    tls_server_config:
      cert_file: /etc/prometheus/node_exporter.crt
      key_file:  /etc/prometheus/node_exporter.key
    ```
2. Prometheus setup in file (example) `/etc/prometheus/prometheus.yml`. Note that IP addresses of pool machines as well as the configuration file are generated automatically and won't 100% match the lines presented below. 
    ```yaml
      - job_name: "pool"
        scheme: https
        tls_config:
          ca_file: /etc/prometheus/node_exporter.crt
          insecure_skip_verify: true
        static_configs:
        - targets:
            - 10.20.30.27:9100
            - 10.20.30.93:9100
    ```

## Terminate all cloud instances 
Run `terraform destroy` to save cloud resources and your budget.

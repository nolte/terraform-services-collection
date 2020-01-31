# Collection of Common Services Configuration

This Repository represent a combination of [Terraform Sources](https://www.terraform.io/docs/configuration/modules.html), [tektoncd/pipeline](https://github.com/tektoncd/pipeline).

## Services

The Terraform Modules implement a Workarround for a ```depends_on``` function, thanks at [matti/terraform-module-depends_on](https://github.com/matti/terraform-module-depends_on) for [#10462](https://github.com/hashicorp/terraform/issues/10462).

You will find a full ist of service modules at [./tf-modules](./tf-modules).

## Service Combinations

The Terraform ```Service Combinations``` Scripts provide a preconfigured set of services, for different UseCases.

### Terraform Workspace Syntax

All Terraform scripts works with different Workspaces, this makes possible that you can test the Sevice Combinations on different Stages.

The **Syntax**: ```[stage]-[service]```

Example:  
```online-storagebox```

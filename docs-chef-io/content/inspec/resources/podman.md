+++
title = "podman resource"
draft = false
gh_repo = "inspec"
platform = "unix"

[menu]
  [menu.inspec]
    title = "podman"
    identifier = "inspec/resources/os/podman.md podman resource"
    parent = "inspec/resources/os"
+++

Use the `podman` Chef InSpec audit resource to test the configuration data for the Podman resources.

## Availability

### Installation

This resource is distributed along with Chef InSpec itself. You can use it automatically.

## Syntax

A `podman` resource block declares allows you to write test for many `containers`:

    describe podman.containers do
      its('ids') { should include "591270d8d80d26671fd6ed622f367fbe19004d16e3b519c292313feb5f22e7f7" }
      its('images) { should include "docker.io/library/ubuntu:latest" }
    end

or: if you want to query specific `container`:

    describe podman.containers.where(id: "591270d8d80d26671fd6ed622f367fbe19004d16e3b519c292313feb5f22e7f7") do
      its('status') { should include "Up 44 hours ago" }
    end

where

- `.where()` may specify a specific item and value, to which the resource parameters are compared
- `auto_remove`, `commands`, `created_at`, `ids`, `images`, `names`, `status`, `exited`, `exit_code`, `image_ids`, `labels`, `mounts`, `namespaces`, `pids`, `pods`, `podnames`, `ports`, `sizes`, `started_at`, `states` and `created` are valid parameters for `containers`

The `podman` resource block declares also allows you to write test for many `images`:

    describe podman.images do
      its('repositories') { should_not include 'inssecure_image' }
    end

or if you want to query specific `image`:

    describe podman.images.where(id: "c7db653c4397e6a4d1e468bb7c6400c022c62623bdb87c173d54bac7995b6d8f") do
      it { should exist }
    end

where

- `.where()` may specify a specific filter and expected value, against which parameters are compared
- `parent_ids`, `repo_tags`, `sizes`, `shared_sizes`, `virtual_sizes`, `labels`, `containers`, `names`, `digests`, `history`, `created`, and`created_at` are valid parameters for `images`

The `podman` resource block declares also allows you to write test for many `networks`:

    describe podman.networks do
      its("names") { should include "podman" }
    end

or if you want to query specific `network`:

    describe podman.networks.where(id: "c7db653c4397e6a4d1e468bb7c6400c022c62623bdb87c173d54bac7995b6d8f") do
      it { should exist }
    end

- `.where()` may specify a specific filter and expected value, against which parameters are compared
- `ids`, `names`, `drivers`, `network_interfaces`, `created`, `subnets`, `ipv6_enabled`, `internal`, `dns_enabled` and `ipam_options` are valid parameters for `networks`

The `podman` resource block declares also allows you to write test for many `pods`:

    describe podman.pods do
      its("names") { should include "cranky_allen" }
    end

  or if you want to query specific `pod`:

    describe podman.pods.where(id: "95cadbb84df71e6374fceb3fd89ee3b8f2c7e1a831062cd9cea7d0e3e4b1dbcc") do
      it { should exist }
    end

- `.where()` may specify a specific filter and expected value, against which parameters are compared
- `ids`, `cgroups`, `containers`, `created`, `infra_ids`, `names`, `namespaces`, `networks`, `status` and `labels` are valid parameters for `pods`
# babelforce IVR sync example

Example project to demonstrate how to work with the `babelforce-ivr-sync` tool. This binary allows you to manage the state of operational data in your babelforce account:

* back up account data, creating snapshots to be exported
* manage IVR states hostorically in version control
* view diff between different states
* synchronize one state with another (deploy an IVR to another environment and/or account)

### Pre-requisites
* Docker for Linux (Windows support coming)
* Azure Dev-Ops account, in order to manage Pipelines triggered

## Getting started

Start by cloning this repository and integrating it with an Azure Pipelines project. You will also need to set up the 3 skeleton Environments listed in the YAML file, each with the same Approval policy (manual approval). 

If the Azure configuration is correct, you should now already be able to run CI pipelines from the config in `azure-pipelines.yml`.

> This sample project assumes that Azure Pipelines YAML format will be used, not Classic.

### Local testing

When a docker image is built using the example `Dockerfile` included in this repo, the `babelforce-ivr-sync` binary within it can be run directly. Some necessary resources are copied into the image, but the tool will also produce output artifacts. These represent states which have been pulled from the environments defined in `config.yml`, as well as the details of any sync jobs which have been run. 

It is up to you what you do with this directory, but it must exist for the sync to run. If you want to get these artifacts out of the docker container, the simplest way is to use a bind mount.

After building, let's run the `help` command to check the tool is all working as expected. Then we can run the `get` command to pull the IVR state of one of the dummy envs in `config.yml` and output it to `data/`.

```bash
# build and tag image
$ docker build -t ivr-sync .

# test binary
$ docker run ivr-sync babelforce-ivr-sync help

# pull an env IVR state
$ export MNT="type=bind,src=$(pwd)/data,dst=/sync/data"
$ docker run --mount $MNT ivr-sync babelforce-ivr-sync get --env enbw.dev --no-banner
```

---

## `config.yml`

Here is an example explaining the configuration found in this file:

```yaml
# output directory for all commands
data: ./data

# these define babelforce accounts and API domains, so that the tool
# can manage account resources 
environments:

  production:
    baseUrl: https://my-org.babelforce.com
    auth:
      accessId: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
      accessToken: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

  test:
    baseUrl: https://my-org.dev.babelforce.com
    auth:
      accessId: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
      accessToken: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


# when we want to sync resources or view the diff between 2
# environments, we will use the task definitions here
synchronize:

  deploy-prod:
    from: test
    to: production

```

None of the top-level keys are optional.

---

## Commands reference

### `get`

Pulls the resource tree for an environment and outputs it to `data/envs/$env/`.

#### Example

```bash
$ export MNT="type=bind,src=$(pwd)/data,dst=/sync/data"
$ docker run --mount $MNT ivr-sync babelforce-ivr-sync get --env production
```

### `validate`

Performs validation checks on the resource tree of an environment found under `data/envs/$env/`. Accepts an environment key but without `--env` flag.

#### Example

```bash
$ docker run ivr-sync babelforce-ivr-sync validate production
```

### `diff`

Compares the states of 2 sets of env resources as found under `data/envs/$env/`. These must be populated from a `get` command in order for a diff to be presented. Outputs a JSON diff description to `data/sync/$task/diff.json` 

**Important:** this accepts as an argument one of the tasks defined under `synchronize` in `config.yml`.

#### Example

```bash
$ docker run --mount $MNT ivr-sync babelforce-ivr-sync diff deploy-prod
```

### `apply`

Applies changes according to given diff output. This command synchronizes those resources across environments and in the direction specified under the given sync task.  

#### Example

```bash
$ docker run --mount $MNT ivr-sync babelforce-ivr-sync diff deploy-prod
```
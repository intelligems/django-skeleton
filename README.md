# Django Project Skeleton - Intelligems

A Django project template that makes no assumptions but saves you a couple of initial work hours per project.

# General
This is a project template, which means no naming conventions apply in the project name.
There are some pre-loaded 3rd-party libraries which we have found are very common in all our applications.

3rd-party apps it includes:
- `celery`, for background jobs processing
- `django-storages`, to store files in AWS S3 (the most commonly used object storage)
- `django-anymail`, for transactional emails
- `djangorestframework`, for your RESTful API
- `django-rest-swagger`, to generate documentation for your RESTful API endpoints
- `django-filter`, which provides filtering capabilities in the DRF API views (and not only there)
- `django-guardian`, for custom object or model level permissions
- `django-extensions`, offering a collection of custom extensions for Django
- `django-environ`, following the 12-factor methodology

# Prerequisites
- Python3 (Python 3.7 not working yet)
- Git
- pip
- virtualenv (recommended)

# How to use
To start a new project with this template, it's really simple:
```bash
django-admin.py startproject \
  --template=https://github.com/intelligems/django-skeleton/zipball/master \
  --extension=py,rst,yml,sh \
  --name=Procfile \
  <project_name>
```
After that just keep doing the configuration you use as a standard in your Django projects.

# Templating
The skeleton has support for template values in `.drone.yml` automation and `swarm stack-deploy compose` yml files.

After the skeleton has been built, you can provide specific configuration values in [config_source.yml](./config_templates/config_source.yml) that will populate the templates and create all necessary files.

Example `config_source.yml`

```yaml
project_name: testproject

# Swarm stack compose file
repo_url: aws_id.dkr.ecr.us-east-1.amazonaws.com
redis_url: redis.staging.elasticache
memcached_url: memcached.staging.elasticache

# Staging environment drone
staging_repo_url: aws_id.dkr.ecr.us-east-1.amazonaws.com
staging_region: us-east-1
staging_ip_instances:
  - 192.168.2.1
  - 192.168.2.2

# Production environment drone
production_repo_url: aws_id.dkr.ecr.eu-west-1.amazonaws.com
production_region: eu-west-1
production_ip_instances:
  - 172.131.0.1
  - 172.131.0.2
  - 172.131.0.3
```

Also keep in mind that `project_name` field does not need to be changed as it's value is automatically generated during **project startup.**

If you are happy with the configuration values, you can create the yml files by running [bootstrap.sh](./bootstrap.sh) from inside a virtualenv and also inside the project folder created.

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

> __Warning__ any subsequent call to `bootstrap.sh` or `python -m config_templates.chartmap` will ovewrite auto-generated .yml files from earlier runs.

# Docker and Heroku support
There is built-in docker support. We have added the `Dockerfile` and `docker-compose.yml` file that suits our working set, which of course you may feel free to change and adapt as per your requirements.

As you will see, by default our `.stolos.yml` file is configured to be working with [Stolos.io](https://stolos.io), which is our preferred staging environment provider.

Also, you will find a `Procfile` inside, with just the basic config required to get your project running on Heroku asap.

# Roadmap
- Add Heroku deploy button for instant deployments
- Any ideas? You can contribute!
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
To start a new rojectp with this template, it's really simple:
```bash
django-admin.py startproject \
  --template=https://github.com/intelligems/django-skeleton/zipball/master \
  --extension=py,rst,yml \
  --name=Procfile \
  <project_name>
```
After that just keep doing the configuration you use as a standard in your Django projects.

# Docker and Heroku support
There is built-in docker support. We have added the `Dockerfile` and `docker-compose.yml` file that suits our working set, which of course you may feel free to change and adapt as per your requirements.
As you will see, by default our `docker-compose.yml` files is confgured to be working with [Stolos.io](https://stolos.io), which is our preferred staging environment provider.

Also, you will find a `Procfile` inside, with just the basic config required to get your project running on Heroku asap.

# Roadmap
- Include common error reporting tools (eg. Sentry)
- Add Heroku deploy button for instant deployments
- Any ideas? You can contribute!